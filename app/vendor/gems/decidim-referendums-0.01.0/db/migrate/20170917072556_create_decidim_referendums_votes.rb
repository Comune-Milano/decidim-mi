# frozen_string_literal: true

class CreateDecidimReferendumsVotes < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_referendums_votes do |t|
      t.references :decidim_referendum, null: false, index: true
      t.references :decidim_author, null: false, index: true
      t.integer :scope, null: false, default: 0

      t.timestamps
    end
  end
end
