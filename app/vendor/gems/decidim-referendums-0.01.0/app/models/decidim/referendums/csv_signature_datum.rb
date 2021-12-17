# frozen_string_literal: true

module Decidim
  module Referendums
    class CsvSignatureDatum < ApplicationRecord

      belongs_to :organization, foreign_key: :decidim_organization_id,
                 class_name: "Decidim::Organization"

      validates :email, format: {with: ::Devise.email_regexp}

      def self.inside(referendums_id)
        where(referendums_id: referendums_id)
      end

      def self.search_user_email(organization, email)
        inside(organization)
            .where(email: email)
            .order(created_at: :desc, id: :desc)
            .first
      end

      def self.insert_all(organization, values, referendums_id, current_user_id)
        @current_user = User.find_by(id: current_user_id)

        #values.each { |value| create(email: value, organization: organization) }
        values.each { |value|
          firma_validata = false
          codice_fiscale = value[3]
          stato = nil
          buono = check_codicefiscale?(codice_fiscale, referendums_id)

          if @current_user.admin? || @current_user.role?("initiative_manager")
            stato = value[4] if !value[4].nil?
          end
          if check_codicefiscale?(codice_fiscale, referendums_id)
            stato = 'ok'
          else
            stato = 'duplicato'

          end
          if checkFirmaOnline(referendums_id, codice_fiscale)
            stato = "firmato online"
          end


          if !value[4].nil? && stato == 'ok' && (@current_user.admin? || @current_user.role?("initiative_manager"))
            firma_validata = true
          end


          create!(
              :referendums_id => referendums_id,
              :decidim_user_id => current_user_id,
              :name => value[0],
              :surname => value[1],
              :email => value[2],
              :codice_fiscale => codice_fiscale,
              :stato => stato,
              :organization => organization,
              :validazione => firma_validata
          )
        }

      end

      def self.check_codicefiscale?(codice_fiscale, referendums_id)
        sql = "Select count(id) from decidim_referendums_csv_signature_data where referendums_id = #{referendums_id} and codice_fiscale = '#{codice_fiscale}';"
        records_array = ActiveRecord::Base.connection.execute(sql)
        numero_firme = records_array.first["count"]
        return true if numero_firme == 0
      end

      def self.clear(referendums_id)
        sql = "Delete from public.decidim_referendums_csv_signature_data where referendums_id = #{referendums_id};"
        records_array = ActiveRecord::Base.connection.execute(sql)
        #inside(referendums_id).delete_all
      end

      def self.checkFirmaOnline(referendums_id, codice_fiscale)
        user = Decidim::User.find_by(codice_fiscale: codice_fiscale)
        result = 0
        if user
          sql = "Select count(id) from decidim_referendums_votes where decidim_referendum_id = #{referendums_id} and decidim_author_id = '#{user.id}';"
          records_array = ActiveRecord::Base.connection.execute(sql)
          result = records_array.first["count"]

        end
        return true if result > 0
      end

    end
  end
end
