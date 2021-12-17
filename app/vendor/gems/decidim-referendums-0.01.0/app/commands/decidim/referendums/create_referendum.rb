# frozen_string_literal: true

module Decidim
  module Referendums
    # A command with all the business logic that creates a new referendum.
    class CreateReferendum < Rectify::Command
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

        referendum = create_referendum

        if referendum.persisted?
          broadcast(:ok, referendum)
        else
          broadcast(:invalid, referendum)
        end
      end

      private

      attr_reader :form, :current_user

      # Creates the referendum and all default components
      def create_referendum
        referendum = build_referendum
        return referendum unless referendum.valid?

        referendum.transaction do
          referendum.save!
          create_components_for(referendum)
          send_notification(referendum)
          add_author_as_follower(referendum)
          add_author_as_committee_member(referendum)
        end

        referendum
      end

      def build_referendum
        Referendum.new(
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
        ReferendumsTypeScope.find_by(
          decidim_referendums_types_id: form.type_id,
          decidim_scopes_id: form.scope_id
        )
      end

      def create_components_for(referendum)
        Decidim::Referendums.default_components.each do |component_name|
          component = Decidim::Component.create!(
            name: Decidim::Components::Namer.new(referendum.organization.available_locales, component_name).i18n_name,
            manifest_name: component_name,
            published_at: Time.current,
            participatory_space: referendum
          )

          initialize_pages(component) if component_name == :pages
        end
      end

      def initialize_pages(component)
        Decidim::Pages::CreatePage.call(component) do
          on(:invalid) { raise "Can't create page" }
        end
      end

      def send_notification(referendum)
        Decidim::EventsManager.publish(
          event: "decidim.events.referendums.referendum_created",
          event_class: Decidim::Referendums::CreateReferendumEvent,
          resource: referendum,
          followers: referendum.author.followers
        )
      end

      def add_author_as_follower(referendum)
        form = Decidim::FollowForm
               .from_params(followable_gid: referendum.to_signed_global_id.to_s)
               .with_context(
                 current_organization: referendum.organization,
                 current_user: current_user
               )

        Decidim::CreateFollow.new(form, current_user).call
      end

      def add_author_as_committee_member(referendum)
        form = Decidim::Referendums::CommitteeMemberForm
               .from_params(referendum_id: referendum.id, user_id: referendum.decidim_author_id, state: "accepted")
               .with_context(
                 current_organization: referendum.organization,
                 current_user: current_user
               )

        Decidim::Referendums::SpawnCommitteeRequest.new(form, current_user).call
      end
    end
  end
end
