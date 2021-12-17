# frozen_string_literal: true

class RemoveUnusedAttributesFromReferendum < ActiveRecord::Migration[5.1]
  def change
    remove_column :decidim_referendums, :banner_image, :string
    remove_column :decidim_referendums, :decidim_scope_id, :integer, index: true
    remove_column :decidim_referendums, :type_id, :integer, index: true
  end
end
