# frozen_string_literal: true
require 'csv'

module Admin
  class ManageSignatureController < Decidim::Initiatives::Admin::ApplicationController
    include Decidim::Initiatives

    #helper Decidim::Initiatives::InitiativeHelper
    #layout "decidim/admin/initiative"

    def index
      @component_id = params[:id]
      @initiative = Decidim::Initiative.where(id: params[:id])
      #@count_signature_validate = @initiative.offline_signature_count(params[:id])
      @pdfs = PdfSigned.where(component_id: @component_id )
    end

    def new
    end

    def create

      firme = load_firme(params[:id])
      csv_data = CSV.generate(headers: false) do |csv|
        firme.each do |row|
          if current_user.admin? || current_user.role?("initiative_manager")
            csv << [row['name'],row['surname'],row['email'],row['codice_fiscale'],row['stato']]
          else
            csv << [row['name'],row['surname'],row['email'],row['codice_fiscale']]
          end
        end
      end

        send_data csv_data, filename: "firme_offline-initiative_id-#{params[:id]}.csv", disposition: :attachment

    end

    def destroy
    end

    def initiative

    end

    def load_firme(initiative_id)
      sql = "SELECT name,surname,email,codice_fiscale,stato FROM public.decidim_initiatives_csv_signature_data where initiatives_id = #{initiative_id} order by id asc;"
      records_array = ActiveRecord::Base.connection.select_all(sql)

    end

    private


  end
end
