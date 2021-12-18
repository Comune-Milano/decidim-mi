# frozen_string_literal: true

module Decidim
  module Initiatives
    # Class uses to retrieve initiatives that have been a long time in validating
    # state
    class CheckOneWeekBeforeEnd < Rectify::Query

      # Controllo se la data attuale e' uguale a una settimana prima della fine petizione

      def query

        Decidim::Initiative
          .includes(:scoped_type)
          .where(state: "published")
          .where(signature_type: "online")
          .where("signature_end_date = ?", Date.current - 7.days)
      end
    end
  end
end
