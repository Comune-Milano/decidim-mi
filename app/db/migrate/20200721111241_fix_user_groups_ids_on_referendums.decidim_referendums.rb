# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20181003082010)

class FixUserGroupsIdsOnReferendums < ActiveRecord::Migration[5.2]
  # rubocop:disable Rails/SkipsModelValidations
  def change
    Decidim::UserGroup.find_each do |group|
      old_id = group.extended_data["old_user_group_id"]
      next unless old_id

      Decidim::Referendum
        .where(decidim_user_group_id: old_id)
        .update_all(decidim_user_group_id: group.id)
      Decidim::ReferendumsVote
        .where(decidim_user_group_id: old_id)
        .update_all(decidim_user_group_id: group.id)
    end
  end
  # rubocop:enable Rails/SkipsModelValidations
end
