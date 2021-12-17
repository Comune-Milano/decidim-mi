# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20171017091458)

class RemoveSupportsRequiredFromDecidimReferendumsTypes < ActiveRecord::Migration[5.1]
  def change
    remove_column :decidim_referendums_types, :supports_required, :integer, null: false
  end
end
