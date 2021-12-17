# frozen_string_literal: true

module Decidim
  module Referendums
    # This cell renders the Medium (:m) referendum card
    # for an given instance of an Referendum
    class ReferendumMCell < Decidim::CardMCell
      include Decidim::Referendums::Engine.routes.url_helpers

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

      def state_classes
        case state
        when "accepted", "published"
          ["success"]
        when "rejected", "discarded"
          ["alert"]
        when "validating"
          ["warning"]
        else
          ["muted"]
        end
      end

      def resource_path
        referendum_path(model)
      end

      def resource_icon
        icon "referendums", class: "icon--big"
      end

      def authors
        [present(model).author] +
          model.committee_members.approved.non_deleted.excluding_author.map { |member| present(member.user) }
      end
    end
  end
end
