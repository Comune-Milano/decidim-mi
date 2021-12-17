class AddColumns2PdfSigneds < ActiveRecord::Migration[5.2]
  def change
    add_column :pdf_signeds, :protocollato, :boolean
    add_column :pdf_signeds, :numero_protocollo, :string
  end
end
