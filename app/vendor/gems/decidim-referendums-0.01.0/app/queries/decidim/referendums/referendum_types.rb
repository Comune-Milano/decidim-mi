# frozen_string_literal: true

module Decidim
  module Referendums
    # Class uses to retrieve the available referendum types.
    class ReferendumTypes < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # organization - Decidim::Organization
      def self.for(organization)
        new(organization).query
      end

      # Initializes the class.
      #
      # organization - Decidim::Organization
      def initialize(organization)
        @organization = organization
      end

      # Retrieves the available referendum types for the given organization.
      def query
        ReferendumsType.where(organization: @organization)
      end
    end
  end
end
