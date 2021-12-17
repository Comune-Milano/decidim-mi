# frozen_string_literal: true

class AddExtraFieldsLegalInformationToReferendumsTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums_types, :extra_fields_legal_information, :jsonb
  end
end
