# frozen_string_literal: true

module Decidim
  module Referendums
    # Service that encapsulates all logic related to filtering referendums.
    class ReferendumSearch < Searchlight::Search
      include CurrentLocale

      # Public: Initializes the service.
      # page        - The page number to paginate the results.
      # per_page    - The number of proposals to return per page.
      def initialize(options = {})
        super(options)
      end

      def base_query
        Decidim::Referendum
          .includes(scoped_type: [:scope])
          .where(organization: options[:organization])
      end

      # Handle the search_text filter
      def search_search_text
        query
          .where("title->>'#{current_locale}' ILIKE ?", "%#{search_text}%")
          .or(
            query.where(
              "description->>'#{current_locale}' ILIKE ?",
              "%#{search_text}%"
            )
          )
      end

      # Handle the state filter
      def search_state
        case state
        when "closed"
          query.closed
        else # Assume open
          query.open
        end
      end

      def search_type
        return query if type == "all"

        types = ReferendumsTypeScope.where(decidim_referendums_types_id: type).pluck(:id)

        query.where(scoped_type: types)
      end

      def search_author
        if author == "myself" && options[:current_user]
          query.where(decidim_author_id: options[:current_user].id)
        else
          query
        end
      end

      def search_scope_id
        return if scope_id.nil?

        query
          .joins(:scoped_type)
          .where(
            "decidim_referendums_type_scopes.decidim_scopes_id": scope_id
          )
      end
    end
  end
end
