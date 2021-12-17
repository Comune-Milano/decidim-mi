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


    def send_notification_custom
      if !current_user.nil? && (current_user.admin? || current_user.role?("initiative_manager"))
        component_id = params[:id]
        component_type = params[:type]
        componente = nil
        if component_type == 'petizione'
          componente = Decidim::Initiative.find(params[:id])
          table_offline = 'decidim_initiatives_csv_signature_data'
          column_offline = 'initiatives_id'
          table_online ='decidim_initiatives_votes'
          column_online ='decidim_initiative_id'
        else
          componente = Decidim::Referendum.find(params[:id])
          table_offline = 'decidim_referendums_csv_signature_data'
          column_offline = 'referendums_id'
          table_online ='decidim_referendums_votes'
          column_online ='decidim_referendum_id'
        end
        destinatari = []
        sql_online = "SELECT public.#{table_online}.decidim_author_id
        FROM public.#{table_online} WHERE public.#{table_online}.#{column_online} = #{component_id} "
        records_array_online = ActiveRecord::Base.connection.select_all(sql_online)
        records_array_online.each do |item|
          user = Decidim::User.find(item['decidim_author_id'])
          destinatari.push(user)
        end

        if componente.state == 5
          Decidim::EventsManager.publish(
              event: "decidim.events.signatures.signature_publish_proposta_ok",
              event_class: Decidim::Signatures::SignaturePublishPropostaOkEvent,
              resource: componente,
              affected_users: destinatari,
              )
          Decidim::EventsManager.publish(
              event: "decidim.events.signatures.signature_publish_proposta_ok_author",
              event_class: Decidim::Signatures::SignaturePublishPropostaOkAuthorEvent,
              resource: componente,
              affected_users: [componente.author],
              )
        else
          Decidim::EventsManager.publish(
              event: "decidim.events.signatures.signature_publish_proposta_ko",
              event_class: Decidim::Signatures::SignaturePublishPropostaKoEvent,
              resource: componente,
              affected_users: destinatari,
          #followers: @referendum.author.followers
              )
          Decidim::EventsManager.publish(
              event: "decidim.events.signatures.signature_publish_proposta_ko_author",
              event_class: Decidim::Signatures::SignaturePublishPropostaKoAuthorEvent,
              resource: componente,
              affected_users: [componente.author],
              )
        end
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
