# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # Controller used to manage the referendums answers
      class AnswersController < Decidim::Referendums::Admin::ApplicationController
        include Decidim::Referendums::NeedsReferendum

        helper Decidim::Referendums::ReferendumHelper
        layout "decidim/admin/referendums"

        # GET /admin/referendums/:id/answer/edit
        def edit
          enforce_permission_to :answer, :referendum, referendum: current_referendum
          @form = form(Decidim::Referendums::Admin::ReferendumAnswerForm)
                  .from_model(
                    current_referendum,
                    referendum: current_referendum
                  )
        end

        # PUT /admin/referendums/:id/answer
        def update
          enforce_permission_to :answer, :referendum, referendum: current_referendum

          params[:id] = params[:slug]
          @form = form(Decidim::Referendums::Admin::ReferendumAnswerForm)
                  .from_params(params, referendum: current_referendum)

          UpdateReferendumAnswer.call(current_referendum, @form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("referendums.update.success", scope: "decidim.referendums.admin")
              redirect_to referendums_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("referendums.update.error", scope: "decidim.referendums.admin")
              render :edit
            end
          end
        end
      end
    end
  end
end
