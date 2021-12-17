# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # A command with the business logic to create census data for a
      # organization.
      class CreateOfflineSignatureData < Rectify::Command

        def initialize(form, organization)
          @form = form
          @organization = organization
        end

        # Executes the command. Broadcast this events:
        # - :ok when everything is valid
        # - :invalid when the form wasn't valid and couldn't proceed-
        #
        # Returns nothing.
        def call
          return broadcast(:invalid, @form, "error1") unless @form.file
          return broadcast(:invalid, @form, "error2") unless @form.file.path.to_s.end_with?(".csv")

          if current_user.admin? || current_user.role?("initiative_manager")
            return broadcast(:invalid, @form, "error3") unless check_numero_firme(@form.id,  @form.data.values.count)
          end

          if current_user.admin? || current_user.role?("initiative_manager")
            CsvSignatureDatum.clear(params[:id])
          end
          CsvSignatureDatum.insert_all(@organization, @form.data.values,@form.id,current_user.id)
          #RemoveDuplicatesJob.perform_later(@organization)
          #RemoveDuplicatesOfflineJob.perform_later(@form.data.values,@form.id)
          return broadcast(:ok)
        end

        def check_numero_firme(referendum_id, values_count)
          sql = "Select count(decidim_referendums_csv_signature_data.id) from decidim_referendums_csv_signature_data
        where decidim_referendums_csv_signature_data.referendums_id = #{referendum_id};"
          records_array = ActiveRecord::Base.connection.select_all(sql)
          if(values_count == records_array.rows[0][0])
            return true
          else
            return false

          end
        end
      end
    end
  end
end
