# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # A command with all the business logic that unpublishes an
      # existing referendum.
      class UnpublishReferendum < Rectify::Command
        # Public: Initializes the command.
        #
        # referendum - Decidim::Referendum
        # current_user - the user performing the action
        def initialize(referendum, current_user)
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
          return broadcast(:invalid) unless referendum.published?

          @referendum = Decidim.traceability.perform_action!(
            :unpublish,
            referendum,
            current_user
          ) do
            referendum.unpublish!
            referendum
          end
          broadcast(:ok, referendum)
        end

        private

        attr_reader :referendum, :current_user
      end
    end
  end
end
