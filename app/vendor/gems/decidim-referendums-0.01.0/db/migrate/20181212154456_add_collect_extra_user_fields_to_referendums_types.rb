# frozen_string_literal: true

class AddCollectExtraUserFieldsToReferendumsTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums_types, :collect_user_extra_fields, :boolean, default: false
  end
end
