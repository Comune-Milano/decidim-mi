# frozen_string_literal: true

module Decidim
  module Referendums
    # This query retrieves the organization prioritized referendums that will appear in the homepage
    class OrganizationPrioritizedReferendums < Rectify::Query
      attr_reader :organization

      def initialize(organization)
        @organization = organization
      end

      def query
        Decidim::Referendum.where(organization: organization).published.open
      end
    end
  end
end
