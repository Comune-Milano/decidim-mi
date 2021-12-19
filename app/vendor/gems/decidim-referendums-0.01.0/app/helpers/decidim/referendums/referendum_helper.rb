# frozen_string_literal: true

module Decidim
  module Referendums
    # Helper method related to referendum object and its internal state.
    module ReferendumHelper
      include Decidim::SanitizeHelper

      # Public: The css class applied based on the referendum state to
      #         the referendum badge.
      #
      # referendum - Decidim::Referendum
      #
      # Returns a String.
      def state_badge_css_class(referendum)
        state_badge = "alert"
        if referendum.accepted?
          state_badge = "success"
        elsif referendum.rejected?
          state_badge = "alert"
        elsif referendum.published?
          if referendum.signature_end_date >= Date.current
            state_badge = "success"
          else
            state_badge = "warning"
          end
        elsif referendum.discarded?
          state_badge = "alert"
        elsif referendum.validating?
          state_badge = "warning"
        end
        return state_badge
      end

      # Public: The state of an referendum in a way a human can understand.
      #
      # referendum - Decidim::Referendum.
      #
      # Returns a String.
      def humanize_state(referendum)
        I18n.t(referendum.accepted? ? "accepted" : "expired",
               scope: "decidim.referendums.states",
               default: :expired)
      end

      # Public: The state of an referendum in a way a human can understand.
      #
      # referendum - Decidim::Referendum.
      #
      # Returns a String.
      def humanize_state_partecipata(referendum)
        stato = ""
        if referendum.accepted?
          stato = "Ammesso"
        elsif referendum.rejected?
          stato = "Firme insufficienti"
        elsif referendum.published?
          if referendum.signature_end_date >= Date.current
            stato = "Raccolta firme in corso"
          else
            stato = "Scaduto"
          end
        elsif referendum.discarded?
          stato = "Non ammesso"
        elsif referendum.validating?
          stato = "In validazione"
        end
        return stato
      end

      # Public: The state of an referendum from an administration perspective in
      # a way that a human can understand.
      #
      # state - String
      #
      # Returns a String
      def humanize_admin_state(state)
        I18n.t(state, scope: "decidim.referendums.admin_states", default: :created)
      end

      def popularity_tag(referendum)
        content_tag(:div, class: "extra__popularity popularity #{popularity_class(referendum)}".strip) do
          5.times do
            concat(content_tag(:span, class: "popularity__item") {})
          end

          concat(content_tag(:span, class: "popularity__desc") do
            I18n.t("decidim.referendums.referendums.vote_cabin.supports_required",
                   total_supports: referendum.scoped_type.supports_required)
          end)
        end
      end

      def popularity_class(referendum)
        return "popularity--level1" if popularity_level1?(referendum)
        return "popularity--level2" if popularity_level2?(referendum)
        return "popularity--level3" if popularity_level3?(referendum)
        return "popularity--level4" if popularity_level4?(referendum)
        return "popularity--level5" if popularity_level5?(referendum)

        ""
      end

      def popularity_level1?(referendum)
        referendum.percentage.positive? && referendum.percentage < 40
      end

      def popularity_level2?(referendum)
        referendum.percentage >= 40 && referendum.percentage < 60
      end

      def popularity_level3?(referendum)
        referendum.percentage >= 60 && referendum.percentage < 80
      end

      def popularity_level4?(referendum)
        referendum.percentage >= 80 && referendum.percentage < 100
      end

      def popularity_level5?(referendum)
        referendum.percentage >= 100
      end

      def authorized_vote_modal_button(referendum, html_options, &block)
        return if current_user && action_authorized_to("vote", resource: referendum, permissions_holder: referendum.type).ok?

        tag = "button"
        html_options ||= {}

        if !current_user
          html_options["data-open"] = "loginModal"
        else
          html_options["data-open"] = "authorizationModal"
          html_options["data-open-url"] = authorization_sign_modal_referendum_path(referendum)
        end

        html_options["onclick"] = "event.preventDefault();"

        send("#{tag}_to", "", html_options, &block)
      end
    end
  end
end
