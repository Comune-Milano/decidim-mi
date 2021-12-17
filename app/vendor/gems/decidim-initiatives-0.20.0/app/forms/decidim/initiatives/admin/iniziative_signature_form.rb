# frozen_string_literal: true

module Decidim
  module Initiatives
      module Admin
        # A form to temporaly upload csv census data
        class InitiativeSignatureForm < Form
          mimic :census_data

          attribute :file

          def data
            CsvCensus::Data.new(file.path)
          end
        end
      end
  end
end
