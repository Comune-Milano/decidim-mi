# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20181212154456)

class AddCollectExtraUserFieldsToReferendumsTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums_types, :collect_user_extra_fields, :boolean, default: false
  end
end
