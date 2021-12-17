class AddColumnsSignatureLastDay < ActiveRecord::Migration[5.2]
  def change
    execute "ALTER TABLE decidim_initiatives ADD COLUMN signature_last_day date;"
  end
end
