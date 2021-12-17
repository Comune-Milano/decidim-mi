# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20181016095744)

class MakeReferendumAuthorsPolymorphic < ActiveRecord::Migration[5.2]
  class Referendum < ApplicationRecord
    self.table_name = :decidim_referendums
  end

  def change
    remove_index :decidim_referendums, :decidim_author_id

    add_column :decidim_referendums, :decidim_author_type, :string

    reversible do |direction|
      direction.up do
        execute <<~SQL.squish
          UPDATE decidim_referendums
          SET decidim_author_type = 'Decidim::UserBaseEntity'
        SQL
      end
    end

    add_index :decidim_referendums,
              [:decidim_author_id, :decidim_author_type],
              name: "index_decidim_referendums_on_decidim_author"

    change_column_null :decidim_referendums, :decidim_author_id, false
    change_column_null :decidim_referendums, :decidim_author_type, false

    Referendum.reset_column_information
  end
end
