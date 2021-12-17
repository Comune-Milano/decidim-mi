# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # A form to temporaly upload csv census data
      class OfflineSignatureDataForm < Form
        mimic :offline_signature_data

        attribute :file

        def data
          Referendums::Data.new(file.path)
        end
      end
    end
  end
end
