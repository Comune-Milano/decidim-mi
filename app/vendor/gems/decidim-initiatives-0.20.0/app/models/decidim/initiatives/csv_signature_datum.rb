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

        #values.each { |value| create(email: value, organization: organization) }
        values.each { |value|
          firma_validata = false
          codice_fiscale = value[3]
          stato = nil
          buono = check_codicefiscale?(codice_fiscale, initiatives_id)

          if @current_user.admin? || @current_user.role?("initiative_manager")
            stato = value[4] if !value[4].nil?
          end
            if check_codicefiscale?(codice_fiscale, initiatives_id)
              stato = 'ok'
            else
              stato = 'duplicato'

            end

          if !value[4].nil? && stato == 'ok'
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
        }

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
    end
  end
end
