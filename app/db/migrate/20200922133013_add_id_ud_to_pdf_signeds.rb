class AddIdUdToPdfSigneds < ActiveRecord::Migration[5.2]
  def change
    add_column :pdf_signeds, :id_ud, :int
  end
end
