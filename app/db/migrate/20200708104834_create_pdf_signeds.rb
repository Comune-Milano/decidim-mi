class CreatePdfSigneds < ActiveRecord::Migration[5.2]
  def change
    create_table :pdf_signeds do |t|
      t.integer :component_id
      t.integer :decidim_user_id
      t.string :attachment

      t.timestamps
    end
  end
end
