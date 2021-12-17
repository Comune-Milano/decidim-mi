# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # Class that retrieves manageable referendums for the given user.
      # Regular users will get only their referendums. Administrators will
      # retrieve all referendums.
      class ManageableReferendums < Rectify::Query
        attr_reader :organization, :user, :q, :state

        # Syntactic sugar to initialize the class and return the queried objects
        #
        # organization - Decidim::Organization
        # user         - Decidim::User
        # query        - String
        # state        - String
        def self.for(organization, user, query, state)
          new(organization, user, query, state).query
        end

        # Initializes the class.
        #
        # organization - Decidim::Organization
        # user         - Decidim::User
        # query        - String
        # state        - String
        def initialize(organization, user, query, state)
          @organization = organization
          @user = user
          @q = query
          @state = state
        end

        # Retrieves all referendums / Referendums created by the user.
        def query
          if user.admin? || user.role?("initiative_manager")
            base = Referendum
                   .where(organization: organization)
                   .with_state(state)
          else
            ids = ReferendumsCreated.by(user).with_state(state).pluck(:id)
            ids += ReferendumsPromoted.by(user).with_state(state).pluck(:id)
            base = Referendum.where(id: ids)
          end

          return base if q.blank?

          organization.available_locales.each_with_index do |loc, index|
            base = if index.zero?
                     base.where("title->>? ilike ?", loc, "%#{q}%")
                         .or(Referendum.where("description->>? ilike ?", loc, "%#{q}%"))
                   else
                     base
                       .or(Referendum.where("title->>? ilike ?", loc, "%#{q}%"))
                       .or(Referendum.where("description->>? ilike ?", loc, "%#{q}%"))
                   end
          end

          base
        end
      end
    end
  end
end
