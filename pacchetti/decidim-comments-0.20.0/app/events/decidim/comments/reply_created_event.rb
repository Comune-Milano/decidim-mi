# frozen-string_literal: true

module Decidim
  module Comments
    class ReplyCreatedEvent < Decidim::Events::SimpleEvent

      include Decidim::Comments::CommentEvent

      def resource_text
        ActionView::Base.full_sanitizer.sanitize(comment.formatted_body, :tags => %w(href))
      end

    end
  end
end
