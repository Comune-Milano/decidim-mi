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

  desc "Check Referendums end date signature upload and send mail. Validatore/admin"
  task check_validation_signature_start_date: :environment do
    Decidim::Referendums::ValidationSignaturesPeriodStartedReferendums.new.each do |referendum|

      users = Decidim::User.all
      users.each do |user|
        if user.admin? || user.role?("initiative_manager")
          Decidim::Referendums::ReferendumsMailer.notify_start_validation_signature_date(referendum, user).deliver
        end
      end
    end
  end

  desc "Check Referendums end date signature upload and send mail. Proponente"
  task check_signature_end_date: :environment do
    Decidim::Referendums::UploadSignaturesPeriodFinishedReferendums.new.each do |referendum|

      user = Decidim::User.find_by(id: referendum.author.id)
      Decidim::Referendums::ReferendumsMailer.notify_end_signature_date(referendum, user).deliver

    end
  end

  desc "Check Referendums start date to signature upload"
  task check_signature_start_date: :environment do
    Decidim::Referendums::UploadSignaturesPeriodStartedReferendums.new.each do |referendum|

      user = Decidim::User.find_by(id: referendum.author.id)
      Decidim::Referendums::ReferendumsMailer.notify_start_signature_date(referendum, user).deliver

    end
  end

  ############## CR
  desc "Check Referenda end signs (one week before)"
  task check_one_week_before_end_signs: :environment do
    Decidim::Referendums::CheckOneWeekBeforeEndSigns.new.each do |referendum|

      user = Decidim::User.find_by(id: referendum.author.id)
      Decidim::Referendums::ReferendumsMailer.notify_one_week_before_end(referendum, user).deliver

    end
  end

  ############### CR DICEMBRE
  desc "Controlla se la data corrente è uguale a un giorno dopo la scadenza del referendum"
  task check_day_after_end: :environment do
    Decidim::Referendums::CheckDayAfterEnd.new.each do |referendum|
      user = Decidim::User.find_by(id: referendum.author.id)
      Decidim::Referendums::ReferendumsMailer.notify_one_day_after(referendum, user).deliver
    end
  end

  desc "Controlla se la data corrente è uguale a una settimana prima della scadenza del referendum"
  task check_one_week_before_end: :environment do
    Decidim::Referendums::CheckOneWeekBeforeEnd.new.each do |referendum|
      user = Decidim::User.find_by(id: referendum.author.id)
      Decidim::Referendums::ReferendumsMailer.notify_one_week_before_end_referendum(referendum, user).deliver
    end
  end


end