# frozen_string_literal: true

module Decidim
  module Referendums
    require "wicked"

    # Controller in charge of managing the create referendum wizard.
    class CreateReferendumController < Decidim::Referendums::ApplicationController
      layout "layouts/decidim/referendum_creation"

      include Wicked::Wizard
      include Decidim::FormFactory
      include ReferendumHelper
      include TypeSelectorOptions

      helper Decidim::Admin::IconLinkHelper
      helper ReferendumHelper
      helper_method :similar_referendums
      helper_method :scopes
      helper_method :current_referendum
      helper_method :referendum_type
      helper_method :promotal_committee_required?

      steps :select_referendum_type,
            :previous_form,
            :show_similar_referendums,
            :fill_data,
            :promotal_committee,
            :finish

      def show
        enforce_permission_to :create, :referendum
        send("#{step}_step", referendum: session_referendum)
      end

      def update
        enforce_permission_to :create, :referendum
        send("#{step}_step", params)
      end

      private

      def select_referendum_type_step(_parameters)
        @form = form(Decidim::Referendums::SelectReferendumTypeForm).instance
        session[:referendum] = {}
        render_wizard
      end

      def previous_form_step(parameters)
        @form = build_form(Decidim::Referendums::PreviousForm, parameters)
        render_wizard
      end

      def show_similar_referendums_step(parameters)
        @form = build_form(Decidim::Referendums::PreviousForm, parameters)
        unless @form.valid?
          redirect_to previous_wizard_path(validate_form: true)
          return
        end

        if similar_referendums.empty?
          @form = build_form(Decidim::Referendums::ReferendumForm, parameters)
          redirect_to wizard_path(:fill_data)
        end

        render_wizard unless performed?
      end

      def fill_data_step(parameters)
        @form = build_form(Decidim::Referendums::ReferendumForm, parameters)
        render_wizard
      end

      def promotal_committee_step(parameters)
        skip_step unless promotal_committee_required?

        if session_referendum.has_key?(:id)
          render_wizard
          return
        end

        @form = build_form(Decidim::Referendums::ReferendumForm, parameters)

        CreateReferendum.call(@form, current_user) do
          on(:ok) do |referendum|
            session[:referendum][:id] = referendum.id
            if current_referendum.created_by_individual?
              render_wizard
            else
              redirect_to wizard_path(:finish)
            end

            # prendo l'id nella tabella decidim_referendums_type_scopes con gli id del tipo e dell'area
            # per aggiornare il campo scoped_type_id dell'iniziativa
            tid = @form.type_id
            dai = params[:area_id]
            #Rails.logger.info "\n\n"+tid.to_s+"\n\n"
            #Rails.logger.info "\n\n"+dai.to_s+"\n\n"
            begin
              new_scoped_type = Decidim::ReferendumsTypeScope.select(:id).where(["decidim_referendums_types_id = ? and decidim_areas_id = ?", tid, dai])
              referendum.scoped_type_id = new_scoped_type[0]["id"]
              referendum.save!
            rescue ActiveRecord::RecordNotFound
              flash.now[:alert] = I18n.t("referendums.update.error", scope: "decidim.referendums.admin")
              render :edit, layout: "decidim/admin/referendum"
            end

            ########################################################



          end

          on(:invalid) do |referendum|
            logger.fatal "Failed creating referendum: #{referendum.errors.full_messages.join(", ")}" if referendum
            redirect_to previous_wizard_path(validate_form: true)
          end
        end
      end


      def finish_step(_parameters)
        render_wizard
      end

      def similar_referendums
        @similar_referendums ||= Decidim::Referendums::SimilarReferendums
                                     .for(current_organization, @form)
                                     .all
      end

      def build_form(klass, parameters)
        @form = form(klass).from_params(parameters)
        attributes = @form.attributes_with_values
        session[:referendum] = session_referendum.merge(attributes)
        @form.valid? if params[:validate_form]

        @form
      end

      def scopes
        @scopes ||= ReferendumsTypeScope.where(decidim_referendums_types_id: @form.type_id)
      end

      def current_referendum
        Referendum.find(session_referendum[:id]) if session_referendum.has_key?(:id)
      end

      def referendum_type
        @referendum_type ||= ReferendumsType.find(session_referendum[:type_id] || @form&.type_id)
      end

      def session_referendum
        session[:referendum] ||= {}
        session[:referendum].with_indifferent_access
      end

      def promotal_committee_required?
        return false unless referendum_type.promoting_committee_enabled?

        minimum_committee_members = referendum_type.minimum_committee_members ||
            Decidim::Referendums.minimum_committee_members
        minimum_committee_members.present? && minimum_committee_members.positive?
      end
    end
  end
end