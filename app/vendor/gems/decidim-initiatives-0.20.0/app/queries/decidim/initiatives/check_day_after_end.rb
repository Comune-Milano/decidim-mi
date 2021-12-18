# frozen_string_literal: true

module Decidim
  module Initiatives
    # Class uses to retrieve initiatives that have been a long time in validating
    # state
    class CheckDayAfterEnd < Rectify::Query

      # Controllo se la data attuale e' uguale al giorno di fine petizione + 1 giorno

      def query

        Decidim::Initiative
          .includes(:scoped_type)
          .where(state: "published")
          .where(signature_type: "online")
          .where("signature_end_date = ?", Date.current - 1.day)
      end
    end
  end
end
