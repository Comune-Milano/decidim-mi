# frozen_string_literal: true

module Decidim
  module Referendums
    # Class uses to retrieve referendums that have been a long time in
    # validating state
    class OutdatedValidatingReferendums < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # period_length - Maximum time in validating state
      def self.for(period_length)
        new(period_length).query
      end

      # Initializes the class.
      #
      # period_length - Maximum time in validating state
      def initialize(period_length)
        @period_length = Time.current - period_length
      end

      # Retrieves the available referendum types for the given organization.
      def query
        Decidim::Referendum
          .where(state: "validating")
          .where("updated_at < ?", @period_length)
      end
    end
  end
end
