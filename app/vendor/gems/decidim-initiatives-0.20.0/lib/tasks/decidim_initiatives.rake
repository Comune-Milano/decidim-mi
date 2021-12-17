# frozen_string_literal: true

namespace :decidim_initiatives do
  desc "Check validating initiatives and moves all without changes for a configured time to discarded state"
  task check_validating: :environment do
    Decidim::Initiatives::OutdatedValidatingInitiatives
        .for(Decidim::Initiatives.max_time_in_validating_state)
        .each(&:discarded!)
  end

  desc "Check published initiatives and moves to accepted/rejected state depending on the votes collected when the signing period has finished"
  task check_published: :environment do
    Decidim::Initiatives::SupportPeriodFinishedInitiatives.new.each do |initiative|
      supports_required = initiative.scoped_type.supports_required

      if initiative.initiative_votes_count >= supports_required
        initiative.accepted!
      else
        initiative.rejected!
      end
    end
  end

  desc "Notify progress on published initiatives"
  task notify_progress: :environment do
    Decidim::Initiative
        .published
        .where.not(first_progress_notification_at: nil)
        .where(second_progress_notification_at: nil).find_each do |initiative|
      if initiative.percentage >= Decidim::Initiatives.second_notification_percentage
        notifier = Decidim::Initiatives::ProgressNotifier.new(initiative: initiative)
        notifier.notify

        initiative.second_progress_notification_at = Time.now.utc
        initiative.save
      end
    end

    Decidim::Initiative
        .published
        .where(first_progress_notification_at: nil).find_each do |initiative|
      if initiative.percentage >= Decidim::Initiatives.first_notification_percentage
        notifier = Decidim::Initiatives::ProgressNotifier.new(initiative: initiative)
        notifier.notify

        initiative.first_progress_notification_at = Time.now.utc
        initiative.save
      end
    end
  end
  desc "Check Initiatives end date signature upload and send mail. Validatore/admin"
  task check_validation_signature_start_date: :environment do
    Decidim::Initiatives::ValidationSignaturesPeriodStartedInitiatives.new.each do |initiative|

      users = Decidim::User.all
      users.each do |user|
        if user.admin? || user.role?("initiative_manager")
          Decidim::Initiatives::InitiativesMailer.notify_start_validation_signature_date(initiative, user).deliver
        end
      end
    end
  end

  desc "Check Initiatives end date signature upload and send mail. Proponente"
  task check_signature_end_date: :environment do
    Decidim::Initiatives::UploadSignaturesPeriodFinishedInitiatives.new.each do |initiative|

      user = Decidim::User.find_by(id: initiative.author.id)
      Decidim::Initiatives::InitiativesMailer.notify_end_signature_date(initiative, user).deliver

    end
  end

  desc "Check Initiatives start date to signature upload"
  task check_signature_start_date: :environment do
    Decidim::Initiatives::UploadSignaturesPeriodStartedInitiatives.new.each do |initiative|

      user = Decidim::User.find_by(id: initiative.author.id)
      Decidim::Initiatives::InitiativesMailer.notify_start_signature_date(initiative, user).deliver

    end
  end

  ############## CR
  desc "Check Initiatives end signs (one week before)"
  task check_one_week_before_end_signs: :environment do
    Decidim::Initiatives::CheckOneWeekBeforeEndSigns.new.each do |initiative|

      user = Decidim::User.find_by(id: initiative.author.id)
      Decidim::Initiatives::InitiativesMailer.notify_one_week_before_end(initiative, user).deliver

    end
  end

end
