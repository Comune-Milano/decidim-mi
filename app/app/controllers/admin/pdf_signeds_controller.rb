# frozen_string_literal: true
include AurigaHelper
include Decidim::PdfSigneds
module Admin
  class PdfSignedsController < Decidim::Admin::ApplicationController
    include Decidim::Initiatives

    def check_user_can_upload_pdf (id_proposta, tipo_proposta)
      if (tipo_proposta == 'petizione')
        component = Decidim::Initiative.where(id: id_proposta)
      else
        if (tipo_proposta == 'referendum')
          component = Decidim::Referendum.where(id: id_proposta)
        end
      end
      return check_user_can_download_pdf(id_proposta, tipo_proposta) && !component.is_data_ultima_superata(id_proposta)
    end

    def check_user_can_download_pdf (id_proposta, tipo_proposta)
      user_richiedente = check_is_user_richiedente(id_proposta, tipo_proposta)
      user_admin = current_user.admin || current_user.role?("initiative_manager")
      return user_richiedente || user_admin
    end

    def check_is_user_richiedente (id_proposta, tipo_proposta)
      if (tipo_proposta == 'petizione')
        component = Decidim::Initiative.find(id_proposta)
      else
        if (tipo_proposta == 'referendum')
          component = Decidim::Referendum.find(id_proposta)
        end
      end
      if(current_user.nil?)
        return false
      end
      author_id = component.author.id
      id_user = current_user.id
      return (author_id == id_user)
    end

    def index
      @component_id = params[:id]
      @component_type = params[:type]
      @pdf_signeds = PdfSigned.where(component_id: params[:id], component_type: @component_type)
    end

    def new
      raise ActionController::RoutingError, "Not Found" if !check_user_can_upload_pdf(params[:id], params[:type])
      @id = params[:id]
      @type = params[:type]
      @pdf_signed = PdfSigned.new
    end

    def download
      id_pdf_signed = params[:id]
      pdf_signed = PdfSigned.find(id_pdf_signed)
      raise ActionController::RoutingError, "Not Found" if !check_user_can_download_pdf(pdf_signed.component_id, pdf_signed.component_type)
      begin
        stream_content = scarica_auriga_file(pdf_signed.id_ud)
      rescue
        return
      end
      send_data stream_content, :filename => pdf_signed.attachment.to_s()
    end

    def create
      raise ActionController::RoutingError, "Not Found" if !check_user_can_upload_pdf(params[:id], params[:type])
      @component_id = params[:id]
      @component_type = params[:type]
      @pdf_signed = PdfSigned.new(pdf_signed_params)
      @pdf_signed.component_id = @component_id
      @pdf_signed.component_type = @component_type
      @pdf_signed.decidim_user_id = current_user.id.to_s

      if @pdf_signed.save
        begin
          protocollo = protocolla_auriga_file(@pdf_signed.id, @pdf_signed.attachment)
        rescue StandardError => e
          @pdf_signed.delete
          @error_message = 1
          respond_to do |format|
            format.js
          end
          return
        end
        Rails.logger.info "\n\n\n" + protocollo.to_json
        PdfSigned.find(@pdf_signed.id).update(:protocollato => true)
        PdfSigned.find(@pdf_signed.id).update(:numero_protocollo => protocollo[0]['protocollo_id'])
        PdfSigned.find(@pdf_signed.id).update(:id_ud => protocollo[0]['id_ud'])
        stringa_tipo = ''
        componente = nil
        if (@pdf_signed.component_type == 'petizione')
          componente = Decidim::Initiative.find(@pdf_signed.component_id)
          stringa_tipo = 'la petizione'
        else
          if (@pdf_signed.component_type == 'referendum')
            componente = Decidim::Referendum.find(@pdf_signed.component_id)
            stringa_tipo = 'il referendum'
          end
        end

        @protocollo = protocollo[0]['protocollo_id']
        @mail_utente = current_user.email
        @nome_utente = current_user.nickname
        Decidim::EventsManager.publish(
            event: "decidim.events.pdf_signeds.pdf_signeds_protocollo_auriga",
            event_class: Decidim::PdfSigneds::PdfSignedsProtocolloAurigaEvent,
            resource: componente,
            affected_users: [current_user],
            extra: {
                nome_utente: @nome_utente,
                data_corrente: Time.now.strftime('%d-%m-%Y %H:%M'),
                stringa_tipo: stringa_tipo,
                titolo_componente: componente.title['it'],
                protocollo: @protocollo
            }
        #followers: @referendum.author.followers
        )
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
      @pdf_signed = PdfSigned.find(@component_id, @component_type)
      @pdf_signed.destroy
      redirect_to pdf_signeds_path, notice: "The Pdf has been deleted."
    end

    private

    def pdf_signed_params
      params.require(:pdf_signed).permit(:id, :attachment)
    end
  end
end

