# frozen_string_literal: true

module Decidim
  module Referendums

    class CheckOneWeekBeforeEnd < Rectify::Query

      # Controllo se la data attuale e' uguale a una settimana prima della fine referendum

      def query

        Decidim::Referendum
          .includes(:scoped_type)
          .where(state: "published")
          .where(signature_type: "online")
          .where("signature_end_date = ?", Date.current - 7.days)
      end
    end
  end
end
