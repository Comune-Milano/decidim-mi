# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # A command with all the business logic that publishes an
      # existing referendum.
      class PublishReferendum < Rectify::Command
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
          return broadcast(:invalid) if referendum.published?

          @referendum = Decidim.traceability.perform_action!(
            :publish,
            referendum,
            current_user,
            visibility: "all"
          ) do
            referendum.publish!
            increment_score
            referendum
          end
          broadcast(:ok, referendum)
        end

        private

        attr_reader :referendum, :current_user

        def increment_score
          if referendum.user_group
            Decidim::Gamification.increment_score(referendum.user_group, :referendums)
          else
            Decidim::Gamification.increment_score(referendum.author, :referendums)
          end
        end
      end
    end
  end
end
