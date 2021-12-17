# frozen_string_literal: true

module Decidim
  module Referendums
    # A command with all the business logic when a user or organization unvotes an referendum.
    class UnvoteReferendum < Rectify::Command
      # Public: Initializes the command.
      #
      # referendum   - A Decidim::Referendum object.
      # current_user - The current user.
      # group_id     - Decidim user group id
      def initialize(referendum, current_user, group_id)
        @referendum = referendum
        @current_user = current_user
        @decidim_user_group_id = group_id
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the referendum.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        destroy_referendum_vote
        broadcast(:ok, @referendum)
      end

      private

      def destroy_referendum_vote
        @referendum
          .votes
          .where(
            author: @current_user,
            decidim_user_group_id: @decidim_user_group_id
          )
          .destroy_all
      end
    end
  end
end
