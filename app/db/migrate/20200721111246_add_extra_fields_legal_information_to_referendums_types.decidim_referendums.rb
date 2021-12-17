# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20181212155740)

class AddExtraFieldsLegalInformationToReferendumsTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums_types, :extra_fields_legal_information, :jsonb
  end
end
