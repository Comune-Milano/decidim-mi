# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # A form object used to collect the all the scopes related to an
      # referendum type
      class ReferendumTypeScopeForm < Form
        mimic :referendums_type_scope

        attribute :supports_required, Integer
        attribute :decidim_scopes_id, Integer

        validates :supports_required,
                  presence: true,
                  numericality: {
                    only_integer: true,
                    greater_than: 0
                  }

        validates :decidim_scopes_id, presence: true

      end
    end
  end
end
