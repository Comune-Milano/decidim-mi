# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      class ReferendumsPdfController < Decidim::Admin::ApplicationController
        #helper ::Decidim::Admin::ResourcePermissionsHelper
        layout "decidim/admin/referendums"

        #before_action :show_instructions,
        #unless: :csv_census_active?

        # GET /admin/offline_signatures/:id/pdf
        def index
          @offline_pdf = OfflinePdf.new
        end

        def create
          @offline_pdf = OfflinePdf.new(offline_pdf_params)

          if @offline_pdf.save
            redirect_to offline_pdf_path, notice: "The offline pdf #{@offline_pdf.name} has been uploaded."
          else
            render "new"
          end
        end

        def destroy_all
          @offline_pdf = Resume.find(params[:id])
          @offline_pdf.destroy
          redirect_to resumes_path, notice:  "The resume #{@offline_pdf.name} has been deleted."
        end

        def destroy
          @offline_pdf = Resume.find(params[:id])
          @offline_pdf.destroy
          redirect_to resumes_path, notice:  "The resume #{@offline_pdf.name} has been deleted."
        end

        private

        def show_instructions
          #enforce_permission_to :index, :referendum_offline_signature
          render :instructions
        end

        def csv_census_active?
          current_organization.available_authorizations.include?("csv_census")
        end

        def offline_pdf_params
          params.require(:resume).permit(:name, :attachment)
        end
      end
    end
  end
end
