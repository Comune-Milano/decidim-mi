# frozen_string_literal: true

module Decidim
  module Referendums
    # Class uses to retrieve Referendums that have been a long time in validating
    # state
    class ValidationSignaturesPeriodStartedReferendums < Rectify::Query
      # Retrieves the Referendums ready to be evaluated to decide if they've been
      # accepted or not.
      def query

        Decidim::Referendum
          .includes(:scoped_type)
          .where(state: "published")
          .where(signature_type: "online")
          .where("signature_last_day = ?", Date.current - 1.day)
      end
    end
  end
end
