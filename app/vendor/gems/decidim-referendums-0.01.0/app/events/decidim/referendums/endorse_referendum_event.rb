# frozen-string_literal: true

module Decidim
  module Referendums
    class EndorseReferendumEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::AuthorEvent

      def i18n_scope
        "decidim.referendums.events.endorse_referendum_event"
      end
    end
  end
end
