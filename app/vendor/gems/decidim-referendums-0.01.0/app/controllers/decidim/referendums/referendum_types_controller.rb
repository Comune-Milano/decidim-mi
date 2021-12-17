# frozen_string_literal: true

module Decidim
  module Referendums
    # Exposes the referendum type text search so users can choose a type writing its name.
    class ReferendumTypesController < Decidim::Referendums::ApplicationController
      # GET /referendum_types/search
      def search
        enforce_permission_to :search, :referendum_type

        types = FreetextReferendumTypes.for(current_organization, I18n.locale, params[:term])
        render json: { results: types.map { |type| { id: type.id.to_s, text: type.title[I18n.locale.to_s] } } }
      end
    end
  end
end
