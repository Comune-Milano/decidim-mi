# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20171011152425)

class AddHashtagToReferendums < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_referendums, :hashtag, :string, unique: true
  end
end
