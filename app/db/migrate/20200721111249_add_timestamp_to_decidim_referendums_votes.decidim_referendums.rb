# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20181224100803)

class AddTimestampToDecidimReferendumsVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums_votes, :timestamp, :string
  end
end
