# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20171017095143)

class UpdateReferendumScopedType < ActiveRecord::Migration[5.1]
  class ReferendumsTypeScope < ApplicationRecord
    self.table_name = :decidim_referendums_type_scopes
  end

  class Scope < ApplicationRecord
    self.table_name = :decidim_scopes

    # Scope to return only the top level scopes.
    #
    # Returns an ActiveRecord::Relation.
    def self.top_level
      where parent_id: nil
    end
  end

  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations

    has_many :scopes, foreign_key: "decidim_organization_id", class_name: "Scope"

    # Returns top level scopes for this organization.
    #
    # Returns an ActiveRecord::Relation.
    def top_scopes
      @top_scopes ||= scopes.top_level
    end
  end

  class Referendum < ApplicationRecord
    self.table_name = :decidim_referendums

    belongs_to :scoped_type,
               foreign_key: "scoped_type_id",
               class_name: "ReferendumsTypeScope"

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Organization"
  end

  def up
    Referendum.find_each do |referendum|
      referendum.scoped_type = ReferendumsTypeScope.find_by(
        decidim_referendums_types_id: referendum.type_id,
        decidim_scopes_id: referendum.decidim_scope_id || referendum.organization.top_scopes.first
      )

      referendum.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Can't undo initialization of mandatory attribute"
  end
end
