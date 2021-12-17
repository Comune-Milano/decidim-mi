# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # A command with all the business logic that updates an
      # existing referendum type scope.
      class UpdateReferendumTypeScope < Rectify::Command
        # Public: Initializes the command.
        #
        # referendum_type: Decidim::ReferendumsTypeScope
        # form - A form object with the params.
        def initialize(referendum_type_scope, form)
          @form = form
          @referendum_type_scope = referendum_type_scope
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          id = form.id
          type_id = referendum_type_scope.decidim_referendums_types_id
          decidim_areas_id = form.decidim_areas_id
          dummy =  Decidim::ReferendumsTypeScope.where("id != ? and decidim_referendums_types_id = ? and decidim_areas_id = ?", id.to_s, type_id.to_s, decidim_areas_id.to_s).present?
          if dummy == true
            form.errors.add("", "Errore: l'ambito è già stato scelto.")
            return broadcast(:invalid)
          end


          referendum_type_scope.update(attributes)
          broadcast(:ok, referendum_type_scope)
        end

        private

        attr_reader :form, :referendum_type_scope

        def attributes
          {
              supports_required: form.supports_required,
              #            decidim_scopes_id: form.decidim_scopes_id
              decidim_scopes_id: form.decidim_areas_id,
              decidim_areas_id: form.decidim_areas_id
          }
        end

      end
    end
  end
end
