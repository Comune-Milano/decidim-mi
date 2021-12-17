# frozen_string_literal: true

module Decidim
  module Referendums
    class ReferendumsTypeSignatureTypesController < Decidim::Referendums::ApplicationController
      helper_method :allowed_signature_types_for_referendums

      # GET /referendum_type_signature_types/search
      def search
        enforce_permission_to :search, :referendum_type_signature_types
        render layout: false
      end

      private

      def allowed_signature_types_for_referendums
        @allowed_signature_types_for_referendums ||= ReferendumsType.find(params[:type_id]).allowed_signature_types_for_referendums
      end
    end
  end
end
