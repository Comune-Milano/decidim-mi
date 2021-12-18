# frozen_string_literal: true

module Decidim
  module Referendums
    # Mailer for referendums engine.
    class ReferendumsMailer < Decidim::ApplicationMailer
      include Decidim::TranslatableAttributes
      include Decidim::SanitizeHelper

      add_template_helper Decidim::TranslatableAttributes
      add_template_helper Decidim::SanitizeHelper

      # Notifies referendum creation
      def notify_creation(referendum)
        return if referendum.author.email.blank?

        @referendum = referendum
        @organization = referendum.organization

        with_user(referendum.author) do
          @subject = I18n.t(
              "decidim.referendums.referendums_mailer.creation_subject",
              title: translated_attribute(referendum.title)
          )

          mail(to: "#{referendum.author.name} <#{referendum.author.email}>", subject: @subject)
        end
      end

      # Notify changes in state
      def notify_state_change(referendum, user, state)
        return if user.email.blank?

        @organization = referendum.organization

        with_user(user) do
          @subject = I18n.t(
              "decidim.referendums.referendums_mailer.status_change_for",
              title: translated_attribute(referendum.title)
          )

          if state.to_s == "published"
            stato = "pubblicato"
          elsif state.to_s == "discarded"
            stato = "scartato"
          elsif state.to_s == "rejected"
            stato = "rifiutato"
          elsif state.to_s = "accepted"
            stato = "accettato"
          end

          @link2 = referendum_url(referendum, host: @organization.host)
          @body = "Il referendum "+translated_attribute(referendum.title)+" è stato "+stato.to_s+".<br />Puoi vedere i dettagli <a href='"+@link2+"'>qui.</a>"

          if state.to_s == "published" || state.to_s == "accepted"
            @body += "<br /><br />Congratulazioni!<br />Lo Staff di Milano Partecipa"
          else
            @body += "<br /><br />Lo Staff di Milano Partecipa"
          end

          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end

      # Notify an referendum requesting technical validation
      def notify_validating_request(referendum, user)
        return if user.email.blank?

        @organization = referendum.organization
        @link = decidim_admin_referendums.edit_referendum_url(referendum, host: @organization.host)

        with_user(user) do
          @subject = I18n.t(
              "decidim.referendums.referendums_mailer.technical_validation_for",
              title: translated_attribute(referendum.title)
          )
          @body = I18n.t(
              "decidim.referendums.referendums_mailer.technical_validation_body_for",
              title: translated_attribute(referendum.title)
          )

          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end

      def notify_start_validation_signature_date(referendum, user)
        return if user.email.blank?

        @organization = referendum.organization
        @link = referendum_url(referendum, host: @organization.host)

        with_user(user) do
          @subject = I18n.t(
              "decidim.referendums.referendums_mailer.validation_signature_started",
              title: translated_attribute(referendum.title)
          )
          @body = I18n.t(
              "decidim.referendums.referendums_mailer.validation_signature_started_body_for",
              title: translated_attribute(referendum.title),
              author_name: user.name
          )

          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end


      def notify_end_signature_date(referendum, user)
        return if user.email.blank?

        @organization = referendum.organization
        @link = referendum_url(referendum, host: @organization.host)

        with_user(user) do
          @subject = I18n.t(
              "decidim.referendums.referendums_mailer.end_signature_upload",
              title: translated_attribute(referendum.title)
          )
          @body = I18n.t(
              "decidim.referendums.referendums_mailer.end_signature_upload_body_for",
              title: translated_attribute(referendum.title),
              author_name: user.name

          )

          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end

      def notify_start_signature_date(referendum, user)
        return if user.email.blank?

        @organization = referendum.organization
        @link = referendum_url(referendum, host: @organization.host)

        with_user(user) do
          @subject = I18n.t(
              "decidim.referendums.referendums_mailer.start_signature_upload",
              title: translated_attribute(referendum.title)
          )
          @body = I18n.t(
              "decidim.referendums.referendums_mailer.start_signature_upload_body_for",
              title: translated_attribute(referendum.title),
              end_date: referendum.signature_end_date,
              author_name: user.name
          )

          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end

      # Notify progress to all referendum subscribers.
      def notify_progress(referendum, user)
        return if user.email.blank?

        @organization = referendum.organization
        @link = referendum_url(referendum, host: @organization.host)

        with_user(user) do
          @body = I18n.t(
              "decidim.referendums.referendums_mailer.progress_report_body_for",
              title: translated_attribute(referendum.title),
              percentage: referendum.percentage
          )

          @subject = I18n.t(
              "decidim.referendums.referendums_mailer.progress_report_for",
              title: translated_attribute(referendum.title)
          )

          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end

      ######################## CR

      # Notifica una settimana prima della scadenza delle firme
      def notify_one_week_before_end(referendum, user)
        return if user.email.blank?

        @organization = referendum.organization
        @link = referendum_url(referendum, host: @organization.host)

        with_user(user) do
          @body = "Manca una settimana prima della chiusura della raccolta firme per la petizione #{translated_attribute(referendum.title)}."
          @subject = "Scadenza imminente per la raccolta firme (#{translated_attribute(referendum.title)})"
          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end




    end
  end
end