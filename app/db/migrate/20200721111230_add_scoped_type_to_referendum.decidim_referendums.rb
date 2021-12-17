# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20171017094911)

class AddScopedTypeToReferendum < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_referendums,
               :scoped_type_id, :integer, index: true
  end
end
