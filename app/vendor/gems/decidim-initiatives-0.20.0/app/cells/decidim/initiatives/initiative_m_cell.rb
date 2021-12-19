# frozen_string_literal: true

module Decidim
  module Initiatives
    # This cell renders the Medium (:m) initiative card
    # for an given instance of an Initiative
    class InitiativeMCell < Decidim::CardMCell
      include Decidim::Initiatives::Engine.routes.url_helpers

      property :state

      private

      def title
        decidim_html_escape(translated_attribute(model.title))
      end

      def hashtag
        decidim_html_escape(model.hashtag)
      end

      def has_state?
        true
      end

      def badge_name
        case state
        when "accepted"
          "Conclusa"
        when "published"
          if model.signature_end_date >= Date.current
            "Raccolta firme in corso"
          else
            "In attesa di risposta"
          end
        when "rejected"
          "Non ammessa"
        when "discarded"
          "Non ammessa"
        when "validating"
          "In validazione"
        else
          ""
        end
      end

      def state_classes
        case state
        when "accepted"
          ["success"]
        when "published"
          if model.signature_end_date >= Date.current
            ["success"]
          else
            ["warning"]
          end
        when "rejected"
          ["alert"]
        when "discarded"
          ["alert"]
        when "validating"
          ["warning"]
        else
          ["muted"]
        end
      end

      def resource_path
        initiative_path(model)
      end

      def resource_icon
        icon "initiatives", class: "icon--big"
      end

      def authors
        [present(model).author] +
          model.committee_members.approved.non_deleted.excluding_author.map { |member| present(member.user) }
      end
    end
  end
end
