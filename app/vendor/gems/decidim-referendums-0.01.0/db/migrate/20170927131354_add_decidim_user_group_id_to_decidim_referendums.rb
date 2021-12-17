# frozen_string_literal: true

class AddDecidimUserGroupIdToDecidimReferendums < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_referendums,
               :decidim_user_group_id, :integer, index: true
  end
end
