# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      class InitiativesOfflineSignaturesController < Decidim::Admin::ApplicationController
        #helper ::Decidim::Admin::ResourcePermissionsHelper
        layout "decidim/admin/initiatives"

        #before_action :show_instructions,
        #unless: :csv_census_active?

        # GET /admin/offline_signatures/:id
        def index
          #enforce_permission_to :index, :initiative_offline_signature

          @initiatives_id = params[:id]
          @initiative = Initiative.where(id: params[:id])
          @form = form(OfflineSignatureDataForm).instance
          @status = Status.new(current_organization)
        end

        def create
          #enforce_permission_to :create, :initiative_offline_signature
          #
          @form = form(OfflineSignatureDataForm).from_params(params)
		  
          CreateOfflineSignatureData.call(@form, current_organization) do
            on(:ok) do
              flash[:notice] = t(".success", count: @form.data.values.count, errors: @form.data.errors.count)
              redirect_to '/admin/offline_signatures/pdf/' + params[:id] + '/petizione', notice: "Le firme sono state caricate correttamente."
            end

            on(:invalid) do |_form,error|
			  flash[:error] = "Le firme sono state caricate ma potrebbe esserci un problema su una o pi? righe" if error == 'error4'
			  flash[:error] = "Il numero di firme caricate non corrisponde a quelle attualmente registrate" if error == 'error3'
              flash[:error] = "Il formato del file non è corretto, utilizzare solo file .csv" if error == 'error2'
              flash[:error] = t(".error") if error == "error1"
              redirect_to '/admin/offline_signatures/pdf/' + params[:id] + '/petizione'
            end
          end
          #redirect_to initiatives_offline_signatures_path(:id => @form.id.to_s)

        end

        def destroy_all
          #enforce_permission_to :destroy, :initiative_offline_signature
          CsvSignatureDatum.clear(current_organization)

          redirect_to initiatives_offline_signatures_path, notice: t(".success")
        end

        private

        def show_instructions
          #enforce_permission_to :index, :initiative_offline_signature
          render :instructions
        end

        def csv_census_active?
          current_organization.available_authorizations.include?("csv_census")
        end
      end
    end
  end
end
