# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # A command with all the business logic that updates an
      # existing referendum.
      class UpdateReferendum < Rectify::Command
        # Public: Initializes the command.
        #
        # referendum - Decidim::Referendum
        # form       - A form object with the params.
        def initialize(referendum, form, current_user)
          @form = form
          @referendum = referendum
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

          @referendum = Decidim.traceability.update!(
            referendum,
            current_user,
            attributes
          )
          notify_referendum_is_extended if @notify_extended
          broadcast(:ok, referendum)
        rescue ActiveRecord::RecordInvalid
          broadcast(:invalid, referendum)
        end

        private

        attr_reader :form, :referendum, :current_user

        def attributes
          attrs = {
            title: form.title,
            description: form.description,
            hashtag: form.hashtag
          }

          if form.signature_type_updatable?
            attrs[:signature_type] = form.signature_type
            attrs[:scoped_type_id] = form.scoped_type_id if form.scoped_type_id
          end

          if current_user.admin?
            attrs[:signature_start_date] = form.signature_start_date
            attrs[:signature_end_date] = form.signature_end_date
            attrs[:signature_last_day] = form.signature_last_day
            attrs[:offline_votes] = form.offline_votes if form.offline_votes
            attrs[:state] = form.state if form.state

            if referendum.published?
              @notify_extended = true if form.signature_end_date != referendum.signature_end_date &&
                                         form.signature_end_date > referendum.signature_end_date
            end
          end

          attrs
        end

        def notify_referendum_is_extended
          Decidim::EventsManager.publish(
            event: "decidim.events.referendums.referendum_extended",
            event_class: Decidim::Referendums::ExtendReferendumEvent,
            resource: referendum,
            followers: referendum.followers - [referendum.author]
          )
        end
      end
    end
  end
end
