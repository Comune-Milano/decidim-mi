# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Referendums
    # Common logic for elements that need to be able to select referendum types.
    module TypeSelectorOptions
      extend ActiveSupport::Concern

      include Decidim::TranslationsHelper

      included do
        helper_method :available_referendum_types, :referendum_type_options,
                      :referendum_types_each

        private

        # Return all referendum types with scopes defined.
        def available_referendum_types
          Decidim::Referendums::ReferendumTypes
            .for(current_organization)
            .joins(:scopes)
            .distinct
        end

        def referendum_type_options
          available_referendum_types.map do |type|
            [type.title[I18n.locale.to_s], type.id]
          end
        end

        def referendum_types_each
          available_referendum_types.each do |type|
            yield(type)
          end
        end
      end
    end
  end
end
