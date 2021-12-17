# frozen-string_literal: true

module Decidim
  module Initiatives
    class SignatureInitiativeAuthorEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::AuthorEvent

      def i18n_scope
        "decidim.initiatives.events.signature_initiative_author_event"
      end
    end
  end
end
