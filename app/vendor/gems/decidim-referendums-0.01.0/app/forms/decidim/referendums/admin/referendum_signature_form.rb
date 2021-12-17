# frozen_string_literal: true

module Decidim
  module Referendums
      module Admin
        # A form to temporaly upload csv census data
        class ReferendumSignatureForm < Form
          mimic :census_data

          attribute :file

          def data
            CsvCensus::Data.new(file.path)
          end
        end
      end
  end
end
