class AutorizzaUtenteTrigger < ActiveRecord::Migration[5.2]

  def change
    execute "CREATE OR REPLACE FUNCTION autorizza_utente_funzione() RETURNS trigger AS $BODY$ BEGIN insert into decidim_authorizations (name, decidim_user_id, created_at, updated_at, granted_at) values ('id_documents', NEW.id, now(), now(), now()); return new; END; $BODY$ LANGUAGE plpgsql VOLATILE"
    execute "CREATE TRIGGER autorizza_utente_trigger AFTER INSERT ON decidim_users FOR EACH ROW EXECUTE PROCEDURE autorizza_utente_funzione();"
  end

end
