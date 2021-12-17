# frozen_string_literal: true

module Admin
  class PdfSignedsController < Decidim::Initiatives::Admin::ApplicationController

    def index

      @pdf_signeds = PdfSigned.where(component_id: params[:id] )
    end

    def new
      @pdf_signed = PdfSigned.new
    end

    def create
      @pdf_signed = PdfSigned.new(pdf_signed_params)
      @pdf_signed.component_id = params[:id]
      @pdf_signed.decidim_user_id = current_user.id.to_s
      if @pdf_signed.save
        redirect_to '/admin/initiatives_offline_signatures/pdf/' + params[:id], notice: "Il Pdf è stato caricato con successo."
      else
        render "new"
      end

    end

    def destroy
      @pdf_signed = PdfSigned.find(params[:id])
      @pdf_signed.destroy
      redirect_to pdf_signeds_path, notice: "The Pdfc #{@pdf_signed.id} has been deleted."
    end

    private

    def pdf_signed_params
      params.require(:pdf_signed).permit(:id, :attachment)
    end
  end
end

