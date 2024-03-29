# frozen_string_literal: true

module Decidim
  module Initiatives
    # A command with all the business logic that creates a new initiative.
    class CreateInitiative < Rectify::Command
      include CurrentLocale

      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # current_user - Current user.
      def initialize(form, current_user)
        @form = form
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        initiative = create_initiative

        if initiative.persisted?
          broadcast(:ok, initiative)
        else
          broadcast(:invalid, initiative)
        end
      end

      private

      attr_reader :form, :current_user

      # Creates the initiative and all default components
      def create_initiative
        initiative = build_initiative
        return initiative unless initiative.valid?

        initiative.transaction do
          initiative.save!
          create_components_for(initiative)
          send_notification(initiative)
          add_author_as_follower(initiative)
          add_author_as_committee_member(initiative)
        end

        initiative
      end

      def build_initiative
        Initiative.new(
          organization: form.current_organization,
          title: { current_locale => form.title },
          description: { current_locale => form.description },
          author: current_user,
          decidim_user_group_id: form.decidim_user_group_id,
          scoped_type: scoped_type,
          signature_type: form.signature_type,
          state: "created"
        )
      end

      def scoped_type
        InitiativesTypeScope.find_by(
          decidim_initiatives_types_id: form.type_id,
          #decidim_scopes_id: form.scope_id
          decidim_areas_id: form.area_id
        )
      end

      def create_components_for(initiative)
        Decidim::Initiatives.default_components.each do |component_name|
          component = Decidim::Component.create!(
            name: Decidim::Components::Namer.new(initiative.organization.available_locales, component_name).i18n_name,
            manifest_name: component_name,
            published_at: Time.current,
            participatory_space: initiative
          )

          initialize_pages(component) if component_name == :pages
        end
      end

      def initialize_pages(component)
        Decidim::Pages::CreatePage.call(component) do
          on(:invalid) { raise "Can't create page" }
        end
      end

      def send_notification(initiative)
        Decidim::EventsManager.publish(
          event: "decidim.events.initiatives.initiative_created",
          event_class: Decidim::Initiatives::CreateInitiativeEvent,
          resource: initiative,
          followers: initiative.author.followers
        )
      end

      def add_author_as_follower(initiative)
        form = Decidim::FollowForm
               .from_params(followable_gid: initiative.to_signed_global_id.to_s)
               .with_context(
                 current_organization: initiative.organization,
                 current_user: current_user
               )

        Decidim::CreateFollow.new(form, current_user).call
      end

      def add_author_as_committee_member(initiative)
        form = Decidim::Initiatives::CommitteeMemberForm
               .from_params(initiative_id: initiative.id, user_id: initiative.decidim_author_id, state: "accepted")
               .with_context(
                 current_organization: initiative.organization,
                 current_user: current_user
               )

        Decidim::Initiatives::SpawnCommitteeRequest.new(form, current_user).call
      end
    end
  end
end
