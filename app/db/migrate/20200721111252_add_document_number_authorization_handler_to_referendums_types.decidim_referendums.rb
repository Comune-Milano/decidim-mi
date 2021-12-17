# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20190125131847)

class AddDocumentNumberAuthorizationHandlerToReferendumsTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums_types, :document_number_authorization_handler, :string
  end
end
