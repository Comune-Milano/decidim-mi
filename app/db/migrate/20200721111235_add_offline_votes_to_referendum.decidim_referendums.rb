# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20171031183855)

class AddOfflineVotesToReferendum < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_referendums,
               :offline_votes, :integer
  end
end
