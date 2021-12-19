# frozen_string_literal: true

module Decidim
  module Initiatives
    class CsvSignatureDatum < ApplicationRecord

      belongs_to :organization, foreign_key: :decidim_organization_id,
                 class_name: "Decidim::Organization"

      validates :email, format: {with: ::Devise.email_regexp}

      def self.inside(initiatives_id)
        where(initiatives_id: initiatives_id)
      end

      def self.search_user_email(organization, email)
        inside(organization)
            .where(email: email)
            .order(created_at: :desc, id: :desc)
            .first
      end

      def self.insert_all(organization, values, initiatives_id, current_user_id)
        @current_user = User.find_by(id: current_user_id)
		clean_insert = true
        #values.each { |value| create(email: value, organization: organization) }
        values.each { |value|
			begin
          firma_validata = false
          codice_fiscale = value[3]
		  
          stato = 'ok'
		  
          if @current_user.admin? || @current_user.role?("initiative_manager")
            stato = value[4] if !value[4].nil?
          end

          if codice_fiscale == nil || codice_fiscale.match(/^[a-zA-Z]{6}[0-9]{2}[abcdehlmprstABCDEHLMPRST]{1}[0-9]{2}([a-zA-Z]{1}[0-9]{3})[a-zA-Z]{1}$/).nil?
            stato = 'formato_codice_fiscale_non_valido'
          elsif !check_codicefiscale?(codice_fiscale, initiatives_id)
            stato = 'duplicato'
          end

          if checkFirmaOnline(initiatives_id,codice_fiscale)
            stato = "firmato online"
          end


          if stato == 'ok' && (@current_user.admin? || @current_user.role?("initiative_manager"))
            firma_validata = true
          end



          create!(
              :initiatives_id => initiatives_id,
              :decidim_user_id => current_user_id,
              :name => value[0],
              :surname => value[1],
              :email => value[2],
              :codice_fiscale => codice_fiscale,
              :stato => stato,
              :organization => organization,
              :validazione => firma_validata
          )
		  rescue StandardError => e
		  clean_insert = false
		  end
        }
		return clean_insert

      end

      def self.check_codicefiscale?(codice_fiscale, initiatives_id)
        sql = "Select count(id) from decidim_initiatives_csv_signature_data where initiatives_id = #{initiatives_id} and codice_fiscale = '#{codice_fiscale}';"
        records_array = ActiveRecord::Base.connection.execute(sql)
        numero_firme = records_array.first["count"]
        return true if numero_firme == 0
      end

      def self.clear(initiatives_id)
        sql = "Delete from public.decidim_initiatives_csv_signature_data where initiatives_id = #{initiatives_id};"
        records_array = ActiveRecord::Base.connection.execute(sql)
        #inside(initiatives_id).delete_all
      end

      def self.checkFirmaOnline(initiatives_id,codice_fiscale)
        user = Decidim::User.find_by(codice_fiscale: codice_fiscale)
        result = 0
        if user
          sql = "Select count(id) from decidim_initiatives_votes where decidim_initiative_id = #{initiatives_id} and decidim_author_id = '#{user.id}';"
          records_array = ActiveRecord::Base.connection.execute(sql)
          result = records_array.first["count"]

        end
        return true if result > 0
      end
    end
  end
end
