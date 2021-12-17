# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20181224101041)

class AddHashIdToDecidimReferendumsVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums_votes, :hash_id, :string
  end
end
