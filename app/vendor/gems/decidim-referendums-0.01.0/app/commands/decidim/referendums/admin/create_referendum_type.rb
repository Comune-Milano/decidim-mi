# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # A command with all the business logic that creates a new referendum type
      class CreateReferendumType < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          referendum_type = create_referendum_type

          if referendum_type.persisted?
            broadcast(:ok, referendum_type)
          else
            form.errors.add(:banner_image, referendum_type.errors[:banner_image]) if referendum_type.errors.include? :banner_image
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def create_referendum_type
          referendum_type = ReferendumsType.new(
            organization: form.current_organization,
            title: form.title,
            description: form.description,
            signature_type: form.signature_type,
            undo_online_signatures_enabled: form.undo_online_signatures_enabled,
            promoting_committee_enabled: form.promoting_committee_enabled,
            minimum_committee_members: form.minimum_committee_members,
            banner_image: form.banner_image,
            collect_user_extra_fields: form.collect_user_extra_fields,
            extra_fields_legal_information: form.extra_fields_legal_information,
            validate_sms_code_on_votes: form.validate_sms_code_on_votes,
            document_number_authorization_handler: form.document_number_authorization_handler
          )

          return referendum_type unless referendum_type.valid?

          referendum_type.save
          referendum_type
        end
      end
    end
  end
end
