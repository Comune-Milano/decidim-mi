class CreateDecidimReferendumsCommitteeMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_referendums_committee_members do |t|
      t.references :decidim_referendums, index: {
        name: "index_decidim_committee_members_referendum_"
      }
      t.references :decidim_users, index: {
        name: "index_decidim_committee_members_user_"
      }
      t.integer :state, index: true, null: false, default: 0

      t.timestamps
    end
  end
end
