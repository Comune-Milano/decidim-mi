# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # A class used to find the admins for an referendum.
      class AdminUsers < Rectify::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # referendum - Decidim::Referendum
        def self.for(referendum)
          new(referendum).query
        end

        # Initializes the class.
        #
        # referendum - Decidim::Referendum
        def initialize(referendum)
          @referendum = referendum
        end

        # Finds organization admins and the users with role admin for the given referendum.
        #
        # Returns an ActiveRecord::Relation.
        def query
          Decidim::User.where(id: organization_admins)
        end

        private

        attr_reader :referendum

        def organization_admins
          referendum.organization.admins
        end
      end
    end
  end
end
