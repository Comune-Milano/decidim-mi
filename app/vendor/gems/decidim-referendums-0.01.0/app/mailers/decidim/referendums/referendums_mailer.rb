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
      def notify_state_change(referendum, user)
        return if user.email.blank?

        @organization = referendum.organization

        with_user(user) do
          @subject = I18n.t(
            "decidim.referendums.referendums_mailer.status_change_for",
            title: translated_attribute(referendum.title)
          )

          @body = I18n.t(
            "decidim.referendums.referendums_mailer.status_change_body_for",
            title: translated_attribute(referendum.title),
            state: I18n.t(referendum.state, scope: "decidim.referendums.admin_states")
          )

          @link = referendum_url(referendum, host: @organization.host)

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
    end
  end
end
