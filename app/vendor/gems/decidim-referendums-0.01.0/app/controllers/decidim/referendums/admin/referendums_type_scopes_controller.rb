# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # Controller used to manage the available referendum type scopes
      class ReferendumsTypeScopesController < Decidim::Referendums::Admin::ApplicationController
        helper_method :current_referendum_type_scope

        # GET /admin/referendums_types/:referendums_type_id/referendums_type_scopes/new
        def new
          enforce_permission_to :create, :referendum_type_scope
          @form = referendum_type_scope_form.instance
        end

        # POST /admin/referendums_types/:referendums_type_id/referendums_type_scopes
        def create
          enforce_permission_to :create, :referendum_type_scope
          @form = referendum_type_scope_form
                  .from_params(params, type_id: params[:referendums_type_id])

          CreateReferendumTypeScope.call(@form) do
            on(:ok) do |referendum_type_scope|
              flash[:notice] = I18n.t("decidim.referendums.admin.referendums_type_scopes.create.success")
              redirect_to edit_referendums_type_path(referendum_type_scope.type)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("decidim.referendums.admin.referendums_type_scopes.create.error")
              render :new
            end
          end
        end

        # GET /admin/referendums_types/:referendums_type_id/referendums_type_scopes/:id/edit
        def edit
          enforce_permission_to :edit, :referendum_type_scope, referendum_type_scope: current_referendum_type_scope
          @form = referendum_type_scope_form.from_model(current_referendum_type_scope)
        end

        # PUT /admin/referendums_types/:referendums_type_id/referendums_type_scopes/:id
        def update
          enforce_permission_to :update, :referendum_type_scope, referendum_type_scope: current_referendum_type_scope
          @form = referendum_type_scope_form.from_params(params)

          UpdateReferendumTypeScope.call(current_referendum_type_scope, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("decidim.referendums.admin.referendums_type_scopes.update.success")
              redirect_to edit_referendums_type_path(referendum_type_scope.type)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("decidim.referendums.admin.referendums_type_scopes.update.error")
              render :edit
            end
          end
        end

        # DELETE /admin/referendums_types/:referendums_type_id/referendums_type_scopes/:id
        def destroy
          enforce_permission_to :destroy, :referendum_type_scope, referendum_type_scope: current_referendum_type_scope
          current_referendum_type_scope.destroy!

          redirect_to edit_referendums_type_path(current_referendum_type_scope.type), flash: {
            notice: I18n.t("decidim.referendums.admin.referendums_type_scopes.destroy.success")
          }
        end

        private

        def current_referendum_type_scope
          @current_referendum_type_scope ||= ReferendumsTypeScope.find(params[:id])
        end

        def referendum_type_scope_form
          form(Decidim::Referendums::Admin::ReferendumTypeScopeForm)
        end
      end
    end
  end
end
