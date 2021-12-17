# frozen_string_literal: true

class AddOfflineVotesToReferendum < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_referendums,
               :offline_votes, :integer
  end
end
