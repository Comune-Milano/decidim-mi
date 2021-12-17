# frozen_string_literal: true

require_dependency "decidim/referendums/admin/application_controller"

module Decidim
  module Referendums
    module Admin
      # Controller used to manage the available referendum types for the current
      # organization.
      class ReferendumsTypesController < Decidim::Referendums::Admin::ApplicationController
        helper ::Decidim::Admin::ResourcePermissionsHelper
        helper_method :current_referendum_type

        # GET /admin/referendums_types
        def index
          enforce_permission_to :index, :referendum_type

          @referendums_types = ReferendumTypes.for(current_organization)
        end

        # GET /admin/referendums_types/new
        def new
          enforce_permission_to :create, :referendum_type
          @form = referendum_type_form.instance
        end

        # POST /admin/referendums_types
        def create
          enforce_permission_to :create, :referendum_type
          @form = referendum_type_form.from_params(params)
          CreateReferendumType.call(@form) do
            on(:ok) do |referendum_type|
              flash[:notice] = I18n.t("decidim.referendums.admin.referendums_types.create.success")
              redirect_to edit_referendums_type_path(referendum_type)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("decidim.referendums.admin.referendums_types.create.error")
              render :new
            end
          end
        end

        # GET /admin/referendums_types/:id/edit
        def edit
          enforce_permission_to :edit, :referendum_type, referendum_type: current_referendum_type
          @form = referendum_type_form
                  .from_model(current_referendum_type,
                              referendum_type: current_referendum_type)
        end

        # PUT /admin/referendums_types/:id
        def update
          enforce_permission_to :update, :referendum_type, referendum_type: current_referendum_type

          @form = referendum_type_form
                  .from_params(params, referendum_type: current_referendum_type)

          UpdateReferendumType.call(current_referendum_type, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("decidim.referendums.admin.referendums_types.update.success")
              redirect_to edit_referendums_type_path(current_referendum_type)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("decidim.referendums.admin.referendums_types.update.error")
              render :edit
            end
          end
        end

        # DELETE /admin/referendums_types/:id
        def destroy
          enforce_permission_to :destroy, :referendum_type, referendum_type: current_referendum_type
          current_referendum_type.destroy!

          redirect_to referendums_types_path, flash: {
            notice: I18n.t("decidim.referendums.admin.referendums_types.destroy.success")
          }
        end

        # GET /admin/signatures_upload
        #def edit
        #  enforce_permission_to :create, :referendum_type
        #  @form = referendum_type_form.instance
        #end

        private

        def current_referendum_type
          @current_referendum_type ||= ReferendumsType.find(params[:id])
        end

        def referendum_type_form
          form(Decidim::Referendums::Admin::ReferendumTypeForm)
        end
      end
    end
  end
end
