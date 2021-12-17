# frozen_string_literal: true

module Admin
  class PdfSignedsController < Decidim::Admin::ApplicationController

    def index
      @component_id = params[:id]
      @component_type = params[:type]
      @pdf_signeds = PdfSigned.where(component_id: params[:id],component_type: @component_type )
    end

    def new
      @pdf_signed = PdfSigned.new
    end

    def create
      @component_id = params[:id]
      @component_type = params[:type]
      @pdf_signed = PdfSigned.new(pdf_signed_params)
      @pdf_signed.component_id = @component_id
      @pdf_signed.component_type = @component_type
      @pdf_signed.decidim_user_id = current_user.id.to_s
      if @pdf_signed.save
        redirect_to '/admin/offline_signatures/pdf/' + @component_id +"/" + @component_type.to_s, notice: "Il Pdf è stato caricato con successo."
      else
        render "new"
      end

    end

    def destroy
      @pdf_signed = PdfSigned.find(@component_id,@component_type)
      @pdf_signed.destroy
      redirect_to pdf_signeds_path, notice: "The Pdf has been deleted."
    end

    private

    def pdf_signed_params
      params.require(:pdf_signed).permit(:id, :attachment)
    end
  end
end

