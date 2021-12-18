# frozen_string_literal: true

module Decidim
  module Initiatives
    # Mailer for initiatives engine.
    class InitiativesMailer < Decidim::ApplicationMailer
      include Decidim::TranslatableAttributes
      include Decidim::SanitizeHelper

      add_template_helper Decidim::TranslatableAttributes
      add_template_helper Decidim::SanitizeHelper

      # Notifies initiative creation
      def notify_creation(initiative)
        return if initiative.author.email.blank?

        @initiative = initiative
        @organization = initiative.organization

        with_user(initiative.author) do
          @subject = I18n.t(
              "decidim.initiatives.initiatives_mailer.creation_subject",
              title: translated_attribute(initiative.title)
          )

          mail(to: "#{initiative.author.name} <#{initiative.author.email}>", subject: @subject)
        end
      end

      # Notify changes in state
      def notify_state_change(initiative, user, state)
        return if user.email.blank?

        @organization = initiative.organization

        with_user(user) do
          @subject = I18n.t(
              "decidim.initiatives.initiatives_mailer.status_change_for",
              title: translated_attribute(initiative.title)
          )

          if state.to_s == "published"
            stato = "pubblicata"
          elsif state.to_s == "discarded"
            stato = "scartata"
          elsif state.to_s == "rejected"
            stato = "rifiutata"
          elsif state.to_s = "accepted"
            stato = "accettata"
          end

          @link2 = initiative_url(initiative, host: @organization.host)
          @body = "La petizione "+translated_attribute(initiative.title)+" è stata "+stato.to_s+".<br />Puoi vedere i dettagli <a href='"+@link2+"'>qui.</a>"

          if state.to_s == "published" || state.to_s == "accepted"
            @body += "<br /><br />Congratulazioni!<br />Lo Staff di Milano Partecipa"
          else
            @body += "<br /><br />Lo Staff di Milano Partecipa"
          end

          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end

      # Notify an initiative requesting technical validation
      def notify_validating_request(initiative, user)
        return if user.email.blank?

        @organization = initiative.organization
        @link = decidim_admin_initiatives.edit_initiative_url(initiative, host: @organization.host)

        with_user(user) do
          @subject = I18n.t(
              "decidim.initiatives.initiatives_mailer.technical_validation_for",
              title: translated_attribute(initiative.title)
          )
          @body = I18n.t(
              "decidim.initiatives.initiatives_mailer.technical_validation_body_for",
              title: translated_attribute(initiative.title)
          )

          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end

      def notify_start_validation_signature_date(initiative, user)
        return if user.email.blank?

        @organization = initiative.organization
        @link = initiative_url(initiative, host: @organization.host)

        with_user(user) do
          @subject = I18n.t(
              "decidim.initiatives.initiatives_mailer.validation_signature_started",
              title: translated_attribute(initiative.title)
          )
          @body = I18n.t(
              "decidim.initiatives.initiatives_mailer.validation_signature_started_body_for",
              title: translated_attribute(initiative.title),
              author_name: user.name
          )

          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end



      def notify_end_signature_date(initiative, user)
        return if user.email.blank?

        @organization = initiative.organization
        @link = initiative_url(initiative, host: @organization.host)

        with_user(user) do
          @subject = I18n.t(
              "decidim.initiatives.initiatives_mailer.end_signature_upload",
              title: translated_attribute(initiative.title)
          )
          @body = I18n.t(
              "decidim.initiatives.initiatives_mailer.end_signature_upload_body_for",
              title: translated_attribute(initiative.title),
              author_name: user.name
          )

          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end

      def notify_start_signature_date(initiative, user)
        return if user.email.blank?

        @organization = initiative.organization
        @link = initiative_url(initiative, host: @organization.host)

        with_user(user) do
          @subject = I18n.t(
              "decidim.initiatives.initiatives_mailer.start_signature_upload",
              title: translated_attribute(initiative.title)
          )
          @body = I18n.t(
              "decidim.initiatives.initiatives_mailer.start_signature_upload_body_for",
              title: translated_attribute(initiative.title),
              end_date: initiative.signature_end_date,
              author_name: user.name
          )

          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end

      # Notify progress to all initiative subscribers.
      def notify_progress(initiative, user)
        return if user.email.blank?

        @organization = initiative.organization
        @link = initiative_url(initiative, host: @organization.host)

        with_user(user) do
          @body = I18n.t(
              "decidim.initiatives.initiatives_mailer.progress_report_body_for",
              title: translated_attribute(initiative.title),
              percentage: initiative.percentage
          )

          @subject = I18n.t(
              "decidim.initiatives.initiatives_mailer.progress_report_for",
              title: translated_attribute(initiative.title)
          )

          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end


      ######################## CR

      # Notifica una settimana prima della scadenza delle firme
      def notify_one_week_before_end(initiative, user)
        return if user.email.blank?

        @organization = initiative.organization
        @link = initiative_url(initiative, host: @organization.host)

        with_user(user) do
          @body = "Manca una settimana prima della chiusura della raccolta firme per la petizione #{translated_attribute(initiative.title)}."
          @subject = "Scadenza imminente per la raccolta firme (#{translated_attribute(initiative.title)})"
          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end

      ######################## CR DICEMBRE

      # Notifica una settiamana prima della scadenza della petizione
      def notify_one_week_before_end_petizione(initiative, user)
        return if user.email.blank?

        @organization = initiative.organization
        @link = initiative_url(initiative, host: @organization.host)

        with_user(user) do
          @body = "Manca una settimana prima della chiusura della petizione #{translated_attribute(initiative.title)}."
          @subject = "Chiusura imminente della petizione (#{translated_attribute(initiative.title)})"
          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end

      # Notifica un giorno dopo la scadenza della petizione
      def notify_one_day_after(initiative, user)
        return if user.email.blank?

        @organization = initiative.organization
        @link = initiative_url(initiative, host: @organization.host)

        with_user(user) do
          @body = "Si avvisa che la petizione #{translated_attribute(initiative.title)} \u00E8 scaduta."
          @subject = "Chiusura petizione (#{translated_attribute(initiative.title)})"
          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end


    end
  end
end
