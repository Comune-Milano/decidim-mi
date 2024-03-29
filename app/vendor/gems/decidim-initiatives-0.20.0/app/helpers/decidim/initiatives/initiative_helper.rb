# frozen_string_literal: true

module Decidim
  module Initiatives
    # Helper method related to initiative object and its internal state.
    module InitiativeHelper
      include Decidim::SanitizeHelper

      # Public: The css class applied based on the initiative state to
      #         the initiative badge.
      #
      # initiative - Decidim::Initiative
      #
      # Returns a String.
      def state_badge_css_class(initiative)
        state_badge = "alert"
        if initiative.accepted?
          state_badge = "success"
        elsif initiative.rejected?
          state_badge = "alert"
        elsif initiative.published?
          if initiative.signature_end_date >= Date.current
            state_badge = "success"
          else
            state_badge = "warning"
          end
        elsif initiative.discarded?
          state_badge = "alert"
        elsif initiative.validating?
          state_badge = "warning"
        end
        return state_badge
      end

      # Public: The state of an initiative in a way a human can understand.
      #
      # initiative - Decidim::Initiative.
      #
      # Returns a String.
      def humanize_state(initiative)
        I18n.t(initiative.accepted? ? "accepted" : "expired",
               scope: "decidim.initiatives.states",
               default: :expired)
      end

      # Public: The state of an referendum in a way a human can understand.
      #
      # referendum - Decidim::Referendum.
      #
      # Returns a String.
      # #
      def humanize_state_partecipata(initiative)
        stato = ""
        if initiative.accepted?
          stato = "Conclusa"
        elsif initiative.rejected?
          stato = "Non ammessa"
        elsif initiative.published?
          if initiative.signature_end_date >= Date.current
            stato = "Raccolta firme in corso"
          else
            stato = "In attesa di risposta"
          end
        elsif initiative.discarded?
          stato = "Non ammessa"
        elsif initiative.validating?
          stato = "In validazione"
        end
        return stato
      end

      # Public: The state of an initiative from an administration perspective in
      # a way that a human can understand.
      #
      # state - String
      #
      # Returns a String
      def humanize_admin_state(state)
        I18n.t(state, scope: "decidim.initiatives.admin_states", default: :created)
      end

      def popularity_tag(initiative)
        content_tag(:div, class: "extra__popularity popularity #{popularity_class(initiative)}".strip) do
          5.times do
            concat(content_tag(:span, class: "popularity__item") {})
          end

          concat(content_tag(:span, class: "popularity__desc") do
            I18n.t("decidim.initiatives.initiatives.vote_cabin.supports_required",
                   total_supports: initiative.scoped_type.supports_required)
          end)
        end
      end

      def popularity_class(initiative)
        return "popularity--level1" if popularity_level1?(initiative)
        return "popularity--level2" if popularity_level2?(initiative)
        return "popularity--level3" if popularity_level3?(initiative)
        return "popularity--level4" if popularity_level4?(initiative)
        return "popularity--level5" if popularity_level5?(initiative)

        ""
      end

      def popularity_level1?(initiative)
        initiative.percentage.positive? && initiative.percentage < 40
      end

      def popularity_level2?(initiative)
        initiative.percentage >= 40 && initiative.percentage < 60
      end

      def popularity_level3?(initiative)
        initiative.percentage >= 60 && initiative.percentage < 80
      end

      def popularity_level4?(initiative)
        initiative.percentage >= 80 && initiative.percentage < 100
      end

      def popularity_level5?(initiative)
        initiative.percentage >= 100
      end

      def authorized_vote_modal_button(initiative, html_options, &block)
        return if current_user && action_authorized_to("vote", resource: initiative, permissions_holder: initiative.type).ok?

        tag = "button"
        html_options ||= {}

        if !current_user
          html_options["data-open"] = "loginModal"
        else
          html_options["data-open"] = "authorizationModal"
          html_options["data-open-url"] = authorization_sign_modal_initiative_path(initiative)
        end

        html_options["onclick"] = "event.preventDefault();"

        send("#{tag}_to", "", html_options, &block)
      end
    end
  end
end
