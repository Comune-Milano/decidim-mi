# frozen_string_literal: true

namespace :decidim_referendums do
  desc "Check validating referendums and moves all without changes for a configured time to discarded state"
  task check_validating: :environment do
    Decidim::Referendums::OutdatedValidatingReferendums
      .for(Decidim::Referendums.max_time_in_validating_state)
      .each(&:discarded!)
  end

  desc "Check published referendums and moves to accepted/rejected state depending on the votes collected when the signing period has finished"
  task check_published: :environment do
    Decidim::Referendums::SupportPeriodFinishedReferendums.new.each do |referendum|
      supports_required = referendum.scoped_type.supports_required

      if referendum.referendum_votes_count >= supports_required
        referendum.accepted!
      else
        referendum.rejected!
      end
    end
  end

  desc "Notify progress on published referendums"
  task notify_progress: :environment do
    Decidim::Referendum
      .published
      .where.not(first_progress_notification_at: nil)
      .where(second_progress_notification_at: nil).find_each do |referendum|
      if referendum.percentage >= Decidim::Referendums.second_notification_percentage
        notifier = Decidim::Referendums::ProgressNotifier.new(referendum: referendum)
        notifier.notify

        referendum.second_progress_notification_at = Time.now.utc
        referendum.save
      end
    end

    Decidim::Referendum
      .published
      .where(first_progress_notification_at: nil).find_each do |referendum|
      if referendum.percentage >= Decidim::Referendums.first_notification_percentage
        notifier = Decidim::Referendums::ProgressNotifier.new(referendum: referendum)
        notifier.notify

        referendum.first_progress_notification_at = Time.now.utc
        referendum.save
      end
    end
  end
end
