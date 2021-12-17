# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # A command with all the business logic that creates a new referendum type scope
      class CreateReferendumTypeScope < Rectify::Command
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

          type_id = form.context.type_id
          decidim_areas_id = form.decidim_areas_id
          dummy = Decidim::ReferendumsTypeScope.where("decidim_referendums_types_id = ? and decidim_areas_id = ?", type_id.to_s, decidim_areas_id.to_s).present?
          if dummy == true
            form.errors.add("", "Errore: l'ambito è già stato scelto.")
            return broadcast(:invalid)
          end


          referendum_type_scope = create_referendum_type_scope

          if referendum_type_scope.persisted?
            broadcast(:ok, referendum_type_scope)
          else
            referendum_type_scope.errors.each do |attribute, error|
              form.errors.add(attribute, error)
            end

            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def create_referendum_type_scope
          referendum_type = ReferendumsTypeScope.new(
              decidim_scopes_id: form.decidim_areas_id,              # <-- AGGIUNTO LUCA
              supports_required: form.supports_required,
              decidim_areas_id: form.decidim_areas_id,
              decidim_referendums_types_id: form.context.type_id
          )

          return referendum_type unless referendum_type.valid?

          referendum_type.save
          referendum_type
        end

      end
    end
  end
end
