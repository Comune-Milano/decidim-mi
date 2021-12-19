# frozen_string_literal: true
require 'csv'

module Admin
  class ManageSignatureController < Decidim::Admin::ApplicationController
    include Decidim::Initiatives

    #helper Decidim::Initiatives::InitiativeHelper

    before_action :set_layout
    def check_user_can_upload_csv (id_proposta, tipo_proposta)
      if (tipo_proposta == 'petizione')
        component = Decidim::Initiative.where(id: id_proposta)
      else
        if (tipo_proposta == 'referendum')
          component = Decidim::Referendum.where(id: id_proposta)
        end
      end
      return check_user_can_manage_signature(id_proposta, tipo_proposta) && component.is_data_fine_petizione_superata(id_proposta)
    end

    def check_user_can_manage_signature (id_proposta, tipo_proposta)
      user_richiedente = check_is_user_richiedente(id_proposta, tipo_proposta)
      user_admin = current_user.admin || current_user.role?("initiative_manager")
      return user_admin
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

    def set_layout
      if params[:type] == 'petizione'
        self.class.layout "decidim/admin/initiatives"
      else
        self.class.layout "decidim/admin/referendums"
      end
    end

    def index
      raise ActionController::RoutingError, "Not Found" if !check_user_can_manage_signature(params[:id], params[:type])
      @component_id = params[:id]
      @component_type = params[:type]
      #@initiative = Decidim::Initiative.where(id: params[:id])
      if @component_type == 'petizione'
        @component = Decidim::Initiative.where(id: params[:id])
      else
        @component = Decidim::Referendum.where(id: params[:id])
      end

      #@count_signature_validate = @initiative.offline_signature_count(params[:id])
      @pdfs = PdfSigned.where(component_id: @component_id,component_type: @component_type )
    end

    def new
    end

    def create
      raise ActionController::RoutingError, "Not Found" if !check_user_can_upload_csv(params[:id], params[:type])
      firme = load_firme(params[:id],params[:type])
      csv_data = CSV.generate(headers: false) do |csv|
        firme.each do |row|
          if current_user.admin? || current_user.role?("initiative_manager")
            csv << [row['name'],row['surname'],row['email'],row['codice_fiscale'],row['stato']]
          else
            csv << [row['name'],row['surname'],row['email'],row['codice_fiscale']]
          end
        end
      end

        send_data csv_data, filename: "firme_offline_id-#{params[:id]}.csv", disposition: :attachment

    end

    def destroy
    end

    def initiative

    end

    def load_firme(component_id,type)
      if type == 'petizione'
        table = 'decidim_initiatives_csv_signature_data'
        column = 'initiatives_id'
      else
        table = 'decidim_referendums_csv_signature_data'
        column = 'referendums_id'
      end
      sql = "SELECT name,surname,email,codice_fiscale,stato FROM public.#{table} where #{column} = #{component_id} order by id asc;"
      records_array = ActiveRecord::Base.connection.select_all(sql)

    end


    def accept_send_notification_custom
      if !current_user.nil? && (current_user.admin? || current_user.role?("initiative_manager"))
        component_id = params[:id]
        component_type = params[:type]
        componente = nil
        if component_type == 'petizione'
          componente = Decidim::Initiative.find(params[:id])
        else
          componente = Decidim::Referendum.find(params[:id])
        end
        componente.state = 5
          Decidim::EventsManager.publish(
              event: "decidim.events.signatures.signature_publish_proposta_ok_author",
              event_class: Decidim::Signatures::SignaturePublishPropostaOkAuthorEvent,
              resource: componente,
              affected_users: [componente.author],
			  force_send: true,
              )
        componente.mail_chiusura_mandata = true
        componente.save
        respond_to do |format|
          format.js
        end
      end
    end

    def reject_send_notification_custom
      if !current_user.nil? && (current_user.admin? || current_user.role?("initiative_manager"))
        component_id = params[:id]
        component_type = params[:type]
        componente = nil
        if component_type == 'petizione'
          componente = Decidim::Initiative.find(params[:id])
        else
          componente = Decidim::Referendum.find(params[:id])
        end
        componente.state = 4
          Decidim::EventsManager.publish(
              event: "decidim.events.signatures.signature_publish_proposta_ko_author",
              event_class: Decidim::Signatures::SignaturePublishPropostaKoAuthorEvent,
              resource: componente,
              affected_users: [componente.author],
              )
        componente.mail_chiusura_mandata = true
        componente.save
        respond_to do |format|
          format.js
        end
      end
    end

    def accept_send_notification_custom_municipale
      if !current_user.nil? && (current_user.admin? || current_user.role?("initiative_manager"))
        component_id = params[:id]
        component_type = params[:type]
        componente = nil
        event_string = ''
        extra_componente = {}
        if component_type == 'petizione'
          componente = Decidim::Initiative.find(params[:id])
          organization = componente.organization
          event_string = 'decidim.events.signatures.signature_publish_petizione_ok_author_municipale'
          event_class_string = Decidim::Signatures::SignaturePublishPetizioneOkAuthorMunicipaleEvent
          init_url = 'https://'+organization.host+'/initiatiaves/'+componente.slug
          extra_componente = {
              initiative_url: init_url
          }
        else
          componente = Decidim::Referendum.find(params[:id])
          organization = componente.organization
          event_string = 'decidim.events.signatures.signature_publish_referendum_ok_author_municipale'
          event_class_string = Decidim::Signatures::SignaturePublishReferendumOkAuthorMunicipaleEvent
          offline_total_comp = componente.get_offline_votes_total(params[:id])
          offline_validated_comp = componente.get_offline_votes_validated(params[:id])
          online_total_comp = componente.get_online_votes
          total_comp = online_total_comp + offline_validated_comp
          ref_url = 'https://'+organization.host+'/referendums/'+componente.slug
          extra_componente = {
              offline_total: offline_total_comp,
              offline_validated: offline_validated_comp,
              online_total: online_total_comp,
              total: total_comp,
              referendum_url: ref_url
          }
        end
        componente.state = 5
          Decidim::EventsManager.publish(
              event: event_string,
              event_class: event_class_string,
              resource: componente,
              affected_users: [componente.author],
              extra: extra_componente
              )
        componente.mail_chiusura_mandata = true
        componente.save
        respond_to do |format|
          format.js
        end
      end
    end

    def accept_send_notification_custom_comunale
      if !current_user.nil? && (current_user.admin? || current_user.role?("initiative_manager"))
        component_id = params[:id]
        component_type = params[:type]
        componente = nil
        event_string = ''
        extra_componente = {}
        if component_type == 'petizione'
          componente = Decidim::Initiative.find(params[:id])
          organization = componente.organization
          event_string = 'decidim.events.signatures.signature_publish_petizione_ok_author_comunale'
          event_class_string = Decidim::Signatures::SignaturePublishPetizioneOkAuthorComunaleEvent
          init_url = 'https://'+organization.host+'/initiatiaves/'+componente.slug
          extra_componente = {
              initiative_url: init_url
          }
        else
          componente = Decidim::Referendum.find(params[:id])
          organization = componente.organization
          event_string = 'decidim.events.signatures.signature_publish_referendum_ok_author_comunale'
          event_class_string = Decidim::Signatures::SignaturePublishReferendumOkAuthorComunaleEvent
          offline_total_comp = componente.get_offline_votes_total(params[:id])
          offline_validated_comp = componente.get_offline_votes_validated(params[:id])
          online_total_comp = componente.get_online_votes
          total_comp = online_total_comp + offline_validated_comp
          ref_url = 'https://'+organization.host+'/referendums/'+componente.slug
          extra_componente = {
              offline_total: offline_total_comp,
              offline_validated: offline_validated_comp,
              online_total: online_total_comp,
              total: total_comp,
              referendum_url: ref_url
          }
        end
        componente.state = 5
        Decidim::EventsManager.publish(
            event: event_string,
            event_class: event_class_string,
            resource: componente,
            affected_users: [componente.author],
              extra: extra_componente
            )
        componente.mail_chiusura_mandata = true
        componente.save
        respond_to do |format|
          format.js
        end
      end
    end

    def reject_send_notification_custom_municipale
      if !current_user.nil? && (current_user.admin? || current_user.role?("initiative_manager"))
        component_id = params[:id]
        component_type = params[:type]
        componente = nil
        event_string = ''
        extra_componente = {}
        if component_type == 'petizione'
          componente = Decidim::Initiative.find(params[:id])
          organization = componente.organization
          event_string = 'decidim.events.signatures.signature_publish_petizione_ko_author_municipale'
          event_class_string = Decidim::Signatures::SignaturePublishPetizioneKoAuthorMunicipaleEvent
          #init_url = Decidim::Initiative.initiative_url(componente, host: organization.host)
          init_url = 'https://'+organization.host+'/initiatiaves/'+componente.slug
          extra_componente = {
              initiative_url: init_url
          }
        else
          componente = Decidim::Referendum.find(params[:id])
          organization = componente.organization
          event_string = 'decidim.events.signatures.signature_publish_referendum_ko_author_municipale'
          event_class_string = Decidim::Signatures::SignaturePublishReferendumKoAuthorMunicipaleEvent
          offline_total_comp = componente.get_offline_votes_total(params[:id])
          offline_validated_comp = componente.get_offline_votes_validated(params[:id])
          online_total_comp = componente.get_online_votes
          total_comp = online_total_comp + offline_validated_comp
          ref_url = 'https://'+organization.host+'/referendums/'+componente.slug
          extra_componente = {
              offline_total: offline_total_comp,
              offline_validated: offline_validated_comp,
              online_total: online_total_comp,
              total: total_comp,
              referendum_url: ref_url
          }
        end
        componente.state = 4
          Decidim::EventsManager.publish(
              event: event_string,
              event_class: event_class_string,
              resource: componente,
              affected_users: [componente.author],
              extra: extra_componente
              )
        componente.mail_chiusura_mandata = true
        componente.save
        respond_to do |format|
          format.js
        end
      end
    end

    def reject_send_notification_custom_comunale
      if !current_user.nil? && (current_user.admin? || current_user.role?("initiative_manager"))
        component_id = params[:id]
        component_type = params[:type]
        componente = nil
        event_string = ''
        extra_componente = {}
        if component_type == 'petizione'
          componente = Decidim::Initiative.find(params[:id])
          organization = componente.organization
          event_string = 'decidim.events.signatures.signature_publish_petizione_ko_author_comunale'
          event_class_string = Decidim::Signatures::SignaturePublishPetizioneKoAuthorComunaleEvent
          init_url = 'https://'+organization.host+'/initiatiaves/'+componente.slug
          extra_componente = {
              initiative_url: init_url
          }
        else
          componente = Decidim::Referendum.find(params[:id])
          organization = componente.organization
          event_string = 'decidim.events.signatures.signature_publish_referendum_ko_author_comunale'
          event_class_string = Decidim::Signatures::SignaturePublishReferendumKoAuthorComunaleEvent
          offline_total_comp = componente.get_offline_votes_total(params[:id])
          offline_validated_comp = componente.get_offline_votes_validated(params[:id])
          online_total_comp = componente.get_online_votes
          total_comp = online_total_comp + offline_validated_comp
          ref_url = 'https://'+organization.host+'/referendums/'+componente.slug
          extra_componente = {
              offline_total: offline_total_comp,
              offline_validated: offline_validated_comp,
              online_total: online_total_comp,
              total: total_comp,
              referendum_url: ref_url
          }
        end
        componente.state = 4
        Decidim::EventsManager.publish(
            event: event_string,
            event_class: event_class_string,
            resource: componente,
            affected_users: [componente.author],
            extra: extra_componente
            )
        componente.mail_chiusura_mandata = true
        componente.save
        respond_to do |format|
          format.js
        end
      end
    end

    private


  end
end
