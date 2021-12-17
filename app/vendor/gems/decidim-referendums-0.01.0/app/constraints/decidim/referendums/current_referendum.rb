# frozen_string_literal: true

module Decidim
  module Referendums
    # This class infers the current referendum we're scoped to by
    # looking at the request parameters and the organization in the request
    # environment, and injects it into the environment.
    class CurrentReferendum
      include ReferendumSlug

      # Public: Matches the request against an initative and injects it
      #         into the environment.
      #
      # request - The request that holds the referendum relevant
      #           information.
      #
      # Returns a true if the request matched, false otherwise
      def matches?(request)
        env = request.env

        @organization = env["decidim.current_organization"]
        return false unless @organization

        current_referendum(env, request.params) ? true : false
      end

      private

      def current_referendum(env, params)
        env["decidim.current_participatory_space"] ||= Referendum.find_by(id: id_from_slug(params[:referendum_slug]))
      end
    end
  end
end
