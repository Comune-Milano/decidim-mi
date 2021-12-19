# frozen_string_literal: true

module Decidim
  module Referendums
    # Service that reports changes in referendum status
    class StatusChangeNotifier
      attr_reader :referendum

      def initialize(args = {})
        @referendum = args.fetch(:referendum)
      end

      # PUBLIC
      # Notifies when an referendum has changed its status.
      #
      # * created: Notifies the author that his referendum has been created.
      #
      # * validating: Administrators will be notified about the referendum that
      #   requests technical validation.
      #
      # * published, discarded: Referendum authors will be notified about the
      #   result of the technical validation process.
      #
      # * rejected, accepted: Referendum's followers and authors will be
      #   notified about the result of the referendum.
      def notify
        notify_referendum_creation if referendum.created?
        notify_validating_referendum if referendum.validating?
        notify_validating_result if referendum.published? || referendum.discarded?
        notify_support_result if referendum.rejected? || referendum.accepted?
      end

      private

      def notify_referendum_creation
        Decidim::Referendums::ReferendumsMailer
          .notify_creation(referendum)
          .deliver_later
      end

      def notify_validating_referendum
        referendum.organization.admins.each do |user|
          Decidim::Referendums::ReferendumsMailer
            .notify_validating_request(referendum, user)
            .deliver_later
        end
      end


      ###########################################################################

      def notify_validating_result

	# questo metodo manda al mailer lo stato di pubblicata o scartata
        #aggiunto terzo argomento: referendum.state

        referendum.committee_members.approved.each do |committee_member|
          Decidim::Referendums::ReferendumsMailer
	    .notify_state_change(referendum, committee_member.user, referendum.state)
            .deliver_later
        end

        Decidim::Referendums::ReferendumsMailer
          .notify_state_change(referendum, referendum.author)
          .deliver_later
      end

      ###########################################################################

      def notify_support_result

        # questo metodo manda al mailer lo stato di rifiutata o accettata
        #aggiunto terzo argomento: referendum.state

        referendum.followers.each do |follower|
          Decidim::Referendums::ReferendumsMailer
	    .notify_state_change(referendum, follower, referendum.state)
            .deliver_later
        end

        referendum.committee_members.approved.each do |committee_member|
          Decidim::Referendums::ReferendumsMailer
            .notify_state_change(referendum, committee_member.user, referendum.state)
            .deliver_later
        end

        Decidim::Referendums::ReferendumsMailer
          .notify_state_change(referendum, referendum.author, referendum.state)
          .deliver_later
      end
    end
  end
end
