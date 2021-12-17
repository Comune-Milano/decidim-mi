# frozen_string_literal: true

module Decidim
  module Referendums
    # A command with all the business logic when a user or organization votes an referendum.
    class VoteReferendum < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # current_user - The current user.
      def initialize(form, current_user)
        @form = form
        @referendum = form.referendum
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal vote.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        build_referendum_vote
        set_vote_timestamp

        percentage_before = @referendum.percentage
        vote.encrypted_metadata = Time.now.to_i.to_s #unixtime per campo encrypted_metadata
        vote.save!

        send_notification
        send_notification_author
        percentage_after = @referendum.reload.percentage

        notify_percentage_change(percentage_before, percentage_after)

        broadcast(:ok, vote)
      end

      attr_reader :vote

      private

      attr_reader :form, :current_user

      def build_referendum_vote
        @vote = @referendum.votes.build(
            author: @current_user,
            decidim_user_group_id: form.group_id,
            encrypted_metadata: form.encrypted_metadata,
            hash_id: form.hash_id
        )
      end

      def set_vote_timestamp
        return unless timestamp_service

        @vote.assign_attributes(
            timestamp: timestamp_service.new(document: vote.encrypted_metadata).timestamp
        )
      end

      def timestamp_service
        @timestamp_service ||= Decidim.timestamp_service.to_s.safe_constantize
      end

      def send_notification
        return if vote.user_group.present?
        Decidim::EventsManager.publish(
            event: "decidim.events.referendums.referendum_endorsed",
            event_class: Decidim::Referendums::EndorseReferendumEvent,
            resource: @referendum,
            followers: @referendum.author.followers
        )
      end

      def send_notification_author
        #return if vote.user_group.present?
        Decidim::EventsManager.publish(
            event: "decidim.events.referendums.signature_referendum_author_event",
            event_class: Decidim::Referendums::SignatureReferendumAuthorEvent,
            resource: @referendum,
            affected_users: [@current_user],
        #followers: @referendum.author.followers
        )
      end

      def notify_percentage_change(before, after)
        percentage = [25, 50, 75, 100].find do |milestone|
          before < milestone && after >= milestone
        end

        return unless percentage

        Decidim::EventsManager.publish(
            event: "decidim.events.referendums.milestone_completed",
            event_class: Decidim::Referendums::MilestoneCompletedEvent,
            resource: @referendum,
            affected_users: [@referendum.author],
            followers: @referendum.followers,
            extra: {
                percentage: percentage
            }
        )
      end
    end
  end
end
