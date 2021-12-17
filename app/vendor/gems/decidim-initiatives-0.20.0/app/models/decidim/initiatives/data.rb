# frozen_string_literal: true

require "csv"

module Decidim
  module Initiatives
      # A data processor for get emails data form a csv file
      #
      # Enable this methods:
      #
      # - .error with an array of rows with errors in the csv file
      # - .values an array with emails readed from the csv file
      #
      # Returns nothing
      class Data
        attr_reader :errors, :values
        def initialize(file)
          @file = file
          @values = []
          @errors = []

          CSV.foreach(@file) do |row|
            if !row.blank?
              if row.first.include? ';'
                values << row.first.split(';')
              else
                values << row
              end
              #process_row(row)
            end
          end
        end

        private

        def process_row(row)
          #user_mail = row.first
          #if user_mail.present? && user_mail.match?(Devise.email_regexp)
          #  values << user_mail
          #else
          #  errors << row
          #end
          codice_fiscale = row.last
          #check_codice_fiscale(codice_fiscale)
          if check_codice_fiscale?(codice_fiscale)
            values << row
          else
            errors << row
          end
        end

        def self.check_codice_fiscale?(codice_fiscale)
          sql = "Select count(id) from decidim_initiatives_csv_signature_data where initiatives_id = 3 and codice_fiscale = '#{codice_fiscale}';"
          records_array = ActiveRecord::Base.connection.execute(sql)
          numero_firme = records_array.first["count"]
          Rails.logger.info("+++---6")
          Rails.logger.info(numero_firme)
          return true if numero_firme == 0
        end

      end
  end
end
