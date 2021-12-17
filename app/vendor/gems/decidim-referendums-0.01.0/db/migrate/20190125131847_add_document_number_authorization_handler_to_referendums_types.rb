# frozen_string_literal: true

class AddDocumentNumberAuthorizationHandlerToReferendumsTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums_types, :document_number_authorization_handler, :string
  end
end
