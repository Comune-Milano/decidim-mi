# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20190213184301)

class AddUndoOnlineSignaturesEnabledToReferendumsTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums_types, :undo_online_signatures_enabled, :boolean, null: false, default: true
  end
end
