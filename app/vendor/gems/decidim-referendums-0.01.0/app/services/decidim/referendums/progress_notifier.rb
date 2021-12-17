# frozen_string_literal: true

module Decidim
  module Referendums
    # Service that notifies progress for an referendum
    class ProgressNotifier
      attr_reader :referendum

      def initialize(args = {})
        @referendum = args.fetch(:referendum)
      end

      # PUBLIC: Notifies the support progress of the referendum.
      #
      # Notifies to Referendum's authors and followers about the
      # number of supports received by the referendum.
      def notify
        referendum.followers.each do |follower|
          Decidim::Referendums::ReferendumsMailer
            .notify_progress(referendum, follower)
            .deliver_later
        end

        referendum.committee_members.approved.each do |committee_member|
          Decidim::Referendums::ReferendumsMailer
            .notify_progress(referendum, committee_member.user)
            .deliver_later
        end

        Decidim::Referendums::ReferendumsMailer
          .notify_progress(referendum, referendum.author)
          .deliver_later
      end
    end
  end
end
