class AddColumnsPdfSigneds < ActiveRecord::Migration[5.2]
  def change
    add_column :pdf_signeds, :component_type, :string
  end
end
