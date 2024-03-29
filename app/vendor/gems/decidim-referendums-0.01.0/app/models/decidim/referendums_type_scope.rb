# frozen_string_literal: true

module Decidim
  class ReferendumsTypeScope < ApplicationRecord
    belongs_to :type,
               foreign_key: "decidim_referendums_types_id",
               class_name: "Decidim::ReferendumsType",
               inverse_of: :scopes

    belongs_to :scope,
               foreign_key: "decidim_scopes_id",
               class_name: "Decidim::Scope",
               optional: true

    has_many :referendums,
             foreign_key: "scoped_type_id",
             class_name: "Decidim::Referendum",
             dependent: :restrict_with_error,
             inverse_of: :scoped_type

    validates :scope, uniqueness: { scope: :type }
    validates :supports_required, presence: true
    validates :supports_required, numericality: {
      only_integer: true,
      greater_than: 0
    }

    def scope_name
      return { I18n.locale.to_s => I18n.t("decidim.scopes.global") } if decidim_scopes_id.nil?

      scope&.name.presence || { I18n.locale.to_s => I18n.t("decidim.referendums.unavailable_scope") }
    end
  end
end
