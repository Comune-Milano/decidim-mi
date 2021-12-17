# frozen_string_literal: true

class AddDecidimUserGroupIdToDecidimReferendumsVotes < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_referendums_votes,
               :decidim_user_group_id, :integer, index: true
  end
end
