# frozen-string_literal: true

module Decidim
  module Referendums
    class SignatureReferendumAuthorEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::AuthorEvent

      def i18n_scope
        "decidim.referendums.events.signature_referendum_author_event"
      end
    end
  end
end
