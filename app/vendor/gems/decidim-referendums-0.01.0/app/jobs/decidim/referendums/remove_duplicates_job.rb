# frozen_string_literal: true

module Decidim
  module Referendums
    class RemoveDuplicatesJob < ApplicationJob
      queue_as :default

      def perform(organization)
        duplicated_offline_signatures(organization).pluck(:email).each do |email|
          CsvDatum.inside(organization)
                  .where(email: email)
                  .order(id: :desc)
                  .all(1..-1)
                  .each(&:delete)
        end
      end

      private

      def duplicated_offline_signatures(organization)
        CsvDatum.inside(organization)
                .select(:email)
                .group(:email)
                .having("count(email)>1")
      end
    end
  end
end
