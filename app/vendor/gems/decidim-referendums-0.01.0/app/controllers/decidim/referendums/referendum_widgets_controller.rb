# frozen_string_literal: true

module Decidim
  module Referendums
    # This controller provides a widget that allows embedding the referendum
    class ReferendumWidgetsController < Decidim::WidgetsController
      helper ReferendumsHelper
      helper PaginateHelper
      helper ReferendumHelper
      helper Decidim::Comments::CommentsHelper
      helper Decidim::Admin::IconLinkHelper

      include NeedsReferendum

      private

      def model
        @model ||= current_referendum
      end

      def current_participatory_space
        model
      end

      def iframe_url
        @iframe_url ||= referendum_referendum_widget_url(model)
      end
    end
  end
end
