# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A form to temporaly upload csv census data
      class OfflineSignatureDataForm < Form
        mimic :offline_signature_data

        attribute :file

        def data
          Initiatives::Data.new(file.path)
        end
      end
    end
  end
end
