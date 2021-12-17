# frozen_string_literal: true

module Decidim
  module Initiatives
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

          CsvSignatureDatum.insert_all(@organization, @form.data.values,@form.id,current_user.id)
          #RemoveDuplicatesJob.perform_later(@organization)
          #RemoveDuplicatesOfflineJob.perform_later(@form.data.values,@form.id)
          return broadcast(:ok)
        end
      end
    end
  end
end
