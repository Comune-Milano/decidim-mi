# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # A form object used to collect the all the referendum type attributes.
      class ReferendumTypeForm < Decidim::Form
        include TranslatableAttributes

        mimic :referendums_type

        translatable_attribute :title, String
        translatable_attribute :description, String
        attribute :banner_image, String
        attribute :signature_type, String
        attribute :undo_online_signatures_enabled, Boolean
        attribute :promoting_committee_enabled, Boolean
        attribute :minimum_committee_members, Integer
        attribute :collect_user_extra_fields, Boolean
        translatable_attribute :extra_fields_legal_information, String
        attribute :validate_sms_code_on_votes, Boolean
        attribute :document_number_authorization_handler, String

        validates :title, :description, translatable_presence: true
        validates :undo_online_signatures_enabled, :promoting_committee_enabled, inclusion: { in: [true, false] }
        validates :minimum_committee_members, numericality: { only_integer: true }, allow_nil: true
        validates :banner_image, presence: true, if: ->(form) { form.context.referendum_type.nil? }

        def minimum_committee_members=(value)
          super(value.presence)
        end

        def minimum_committee_members
          return 0 unless promoting_committee_enabled?

          super
        end

        def signature_type_options
          Referendum.signature_types.keys.map do |type|
            [
              I18n.t(
                type,
                scope: %w(activemodel attributes referendum signature_type_values)
              ), type
            ]
          end
        end
      end
    end
  end
end
