# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20171023075942)

class CreateReferendumExtraData < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_referendums_extra_data do |t|
      t.references :decidim_referendum, null: false, index: true
      t.integer :data_type, null: false, default: 0
      t.jsonb :data, null: false
    end
  end
end
