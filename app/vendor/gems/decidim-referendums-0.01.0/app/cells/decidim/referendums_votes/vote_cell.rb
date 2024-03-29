# frozen_string_literal: true

module Decidim
  module ReferendumsVotes
    class VoteCell < Decidim::ViewModel
      delegate :timestamp, :hash_id, to: :model

      def show
        render
      end

      def referendum_id
        model.referendum.reference
      end

      def referendum_title
        translated_attribute(model.referendum.title)
      end

      def name_and_surname
        metadata[:name_and_surname]
      end

      def document_number
        metadata[:document_number]
      end

      def date_of_birth
        metadata[:date_of_birth]
      end

      def postal_code
        metadata[:postal_code]
      end

      def time_and_date
        model.created_at
      end

      protected

      def encryptor
        @encryptor ||= Decidim::Referendums::DataEncryptor.new(secret: "personal user metadata")
      end

      def metadata
        @metadata ||= model.encrypted_metadata ? encryptor.decrypt(model.encrypted_metadata) : {}
      end
    end
  end
end
