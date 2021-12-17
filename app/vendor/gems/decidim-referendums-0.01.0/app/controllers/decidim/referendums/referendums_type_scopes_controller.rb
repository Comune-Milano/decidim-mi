# frozen_string_literal: true

module Decidim
  module Referendums
    # Exposes the referendum type text search so users can choose a type writing its name.
    class ReferendumsTypeScopesController < Decidim::Referendums::ApplicationController
      helper_method :scoped_types

      # GET /referendum_type_scopes/search
      def search
        enforce_permission_to :search, :referendum_type_scope
        render layout: false
      end

      private

      def scoped_types
        @scoped_types ||= ReferendumsType.find(params[:type_id]).scopes
      end
    end
  end
end
