# frozen_string_literal: true

module Decidim
  module Referendums

    class CheckDayAfterEnd < Rectify::Query

      # Controllo se la data attuale e' uguale al giorno di fine referendum + 1 giorno

      def query

        Decidim::Referendum
          .includes(:scoped_type)
          .where(state: "published")
          .where(signature_type: "online")
          .where("signature_end_date = ?", Date.current - 1.day)
      end
    end
  end
end
