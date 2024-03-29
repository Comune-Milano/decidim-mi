# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # A command with all the business logic that updates an
      # existing referendum type.
      class UpdateReferendumType < Rectify::Command
        # Public: Initializes the command.
        #
        # referendum_type: Decidim::ReferendumsType
        # form - A form object with the params.
        def initialize(referendum_type, form)
          @form = form
          @referendum_type = referendum_type
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          referendum_type.update(attributes)

          if referendum_type.valid?
            upate_referendums_signature_type
            broadcast(:ok, referendum_type)
          else
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :referendum_type

        def attributes
          result = {
            title: form.title,
            description: form.description,
            signature_type: form.signature_type,
            undo_online_signatures_enabled: form.undo_online_signatures_enabled,
            promoting_committee_enabled: form.promoting_committee_enabled,
            minimum_committee_members: form.minimum_committee_members,
            collect_user_extra_fields: form.collect_user_extra_fields,
            extra_fields_legal_information: form.extra_fields_legal_information,
            validate_sms_code_on_votes: form.validate_sms_code_on_votes,
            document_number_authorization_handler: form.document_number_authorization_handler
          }

          result[:banner_image] = form.banner_image unless form.banner_image.nil?
          result
        end

        def upate_referendums_signature_type
          referendum_type.referendums.signature_type_updatable.each do |referendum|
            referendum.update!(signature_type: referendum_type.signature_type)
          end
        end
      end
    end
  end
end
