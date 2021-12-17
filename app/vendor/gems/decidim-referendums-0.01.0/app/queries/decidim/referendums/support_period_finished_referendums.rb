# frozen_string_literal: true

module Decidim
  module Referendums
    # Class uses to retrieve referendums that have been a long time in validating
    # state
    class SupportPeriodFinishedReferendums < Rectify::Query
      # Retrieves the referendums ready to be evaluated to decide if they've been
      # accepted or not.
      def query
        Decidim::Referendum
          .includes(:scoped_type)
          .where(state: "published")
          .where(signature_type: "online")
          .where("signature_end_date < ?", Date.current)
      end
    end
  end
end
