class AlterTablePostMigration < ActiveRecord::Migration[5.2]
  def change
    execute "create sequence ssologin_tests_id_seq;"
    execute "alter table decidim_components
    add testo_originale boolean default false not null;"
    execute "comment on column decidim_users.codice_fiscale is 'Il codice fiscale dell''utente';"
    execute "comment on column decidim_users.form_inviato is 'La richiesta di partecipare';"
    execute "create table ssologin_tests (
    id bigint default nextval('public.ssologin_tests_id_seq'::regclass) not null
        constraint ssologin_tests_pkey
	    primary key,
    iv_user varchar,
    cdm_name varchar,
    cdm_surname varchar,
    cdm_cf varchar,
    created_at timestamp not null,
    updated_at timestamp not null );"
  end
end
