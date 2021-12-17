# frozen_string_literal: true

module Decidim
  module Referendums
    # Helper functions for referendums views
    module ReferendumsHelper
      def referendums_filter_form_for(filter)
        content_tag :div, class: "filters" do
          form_for filter,
                   builder: Decidim::Referendums::ReferendumsFilterFormBuilder,
                   url: url_for,
                   as: :filter,
                   method: :get,
                   remote: true,
                   html: { id: nil } do |form|
            yield form
          end
        end
      end
    end
  end
end
