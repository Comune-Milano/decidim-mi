# frozen_string_literal: true

class AddHashtagToReferendums < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_referendums, :hashtag, :string, unique: true
  end
end
