# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A command with all the business logic that updates an
      # existing initiative type scope.
      class UpdateInitiativeTypeScope < Rectify::Command
        # Public: Initializes the command.
        #
        # initiative_type: Decidim::InitiativesTypeScope
        # form - A form object with the params.
        def initialize(initiative_type_scope, form)
          @form = form
          @initiative_type_scope = initiative_type_scope
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
          type_id = initiative_type_scope.decidim_initiatives_types_id
          decidim_areas_id = form.decidim_areas_id
          dummy =  Decidim::InitiativesTypeScope.where("id != ? and decidim_initiatives_types_id = ? and decidim_areas_id = ?", id.to_s, type_id.to_s, decidim_areas_id.to_s).present?
          if dummy == true
		  form.errors.add("", "Errore: ambito presente.")
            return broadcast(:invalid)
          end


         initiative_type_scope.update(attributes)
         broadcast(:ok, initiative_type_scope)
        end

        private

        attr_reader :form, :initiative_type_scope

        def attributes
          {
            supports_required: form.supports_required,
            #decidim_scopes_id: form.decidim_scopes_id
            decidim_scopes_id: form.decidim_areas_id,
            decidim_areas_id: form.decidim_areas_id
          }
        end
      end
    end
  end
end
