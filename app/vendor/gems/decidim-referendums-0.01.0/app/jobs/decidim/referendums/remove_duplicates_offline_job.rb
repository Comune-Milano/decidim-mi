# frozen_string_literal: true

module Decidim
  module Referendums
    class RemoveDuplicatesOfflineJob < ApplicationJob
      queue_as :default

      def perform(codice_fiscale)
        duplicated_offline_signatures(referendums_id).pluck(:codice_fiscale).each do |email|
          CsvSignatureDatum.inside(codice_fiscale)
                  .where(codice_fiscale: codice_fiscale,referendum_id: 3)
                  .order(id: :desc)
                  .all(1..-1)
                  .each(&:delete)
        end
      end

      private

      def duplicated_offline_signatures(codice_fiscale)
        CsvSignatureDatum.inside(codice_fiscale)
                .select(:codice_fiscale)
                .group(:referendum_id)
                .having("count(codice_fiscale)>1")
      end
    end
  end
end
