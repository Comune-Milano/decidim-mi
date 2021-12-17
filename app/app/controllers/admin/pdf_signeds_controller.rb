# frozen_string_literal: true
include AurigaHelper
module Admin
  class PdfSignedsController < Decidim::Admin::ApplicationController

    def index
      @component_id = params[:id]
      @component_type = params[:type]
      @pdf_signeds = PdfSigned.where(component_id: params[:id],component_type: @component_type )
    end

    def new
      @id = params[:id]
      @type = params[:type]
      @pdf_signed = PdfSigned.new
    end

    def download
      id_pdf_signed = params[:id]
      pdf_signed = PdfSigned.find(id_pdf_signed)
      stream_content = scarica_auriga_file(pdf_signed.id_ud)
      send_data stream_content, :filename => pdf_signed.attachment.to_s()
    end

    def create
      @component_id = params[:id]
      @component_type = params[:type]
      @pdf_signed = PdfSigned.new(pdf_signed_params)
      @pdf_signed.component_id = @component_id
      @pdf_signed.component_type = @component_type
      @pdf_signed.decidim_user_id = current_user.id.to_s

      if @pdf_signed.save
        protocollo = protocolla_auriga_file(@pdf_signed.id, @pdf_signed.attachment)
        Rails.logger.info "\n\n\n"+protocollo.to_json
        PdfSigned.find(@pdf_signed.id).update(:protocollato => true)
        PdfSigned.find(@pdf_signed.id).update(:numero_protocollo => protocollo[0]['protocollo_id'])
        PdfSigned.find(@pdf_signed.id).update(:id_ud => protocollo[0]['id_ud'])
        @var = protocollo[0]['protocollo_id']
        mailer = ActionMailer::Base.new
        mailer.delivery_method
        mailer.smtp_settings
        body = 'Il protocollo è ok e il numero è ' + @var
        mailer.mail(from: 'noreply', to: @current_user.email, subject: 'Protocollo ok', body: body).deliver
        respond_to do |format|
          format.js
        end
      else
        respond_to do |format|
          format.js
        end
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

