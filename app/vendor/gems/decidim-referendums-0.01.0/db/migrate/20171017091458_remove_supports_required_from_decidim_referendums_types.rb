# frozen_string_literal: true

class RemoveSupportsRequiredFromDecidimReferendumsTypes < ActiveRecord::Migration[5.1]
  def change
    remove_column :decidim_referendums_types, :supports_required, :integer, null: false
  end
end
