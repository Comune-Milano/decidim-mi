# frozen_string_literal: true
require 'csv'

module Admin
  class ManageSignatureController < Decidim::Admin::ApplicationController
    include Decidim::Initiatives

    #helper Decidim::Initiatives::InitiativeHelper

    before_action :set_layout

    def set_layout
      if params[:type] == 'petizione'
        self.class.layout "decidim/admin/initiatives"
      else
        self.class.layout "decidim/admin/referendums"
      end
    end

    def index
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

      firme = load_firme(params[:id],params[:type])
      csv_data = CSV.generate(headers: false) do |csv|
        firme.each do |row|
          #if current_user.admin? || current_user.role?("initiative_manager")
            csv << [row['name'],row['surname'],row['email'],row['codice_fiscale'],row['stato']]
            #else
            #csv << [row['name'],row['surname'],row['email'],row['codice_fiscale']]
            #end
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

    private


  end
end
