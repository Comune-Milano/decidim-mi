# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      require "csv"

      # Controller used to manage the referendums
      class ReferendumsController < Decidim::Referendums::Admin::ApplicationController

        include Decidim::Referendums::NeedsReferendum
        include Decidim::Referendums::TypeSelectorOptions

        helper Decidim::Referendums::ReferendumHelper
        helper Decidim::Referendums::CreateReferendumHelper


        # GET /admin/referendums
        def index
          enforce_permission_to :list, :referendum

          @query = params[:q]
          @state = params[:state]
          @referendums = ManageableReferendums
                         .for(
                           current_organization,
                           current_user,
                           @query,
                           @state
                         )
                         .page(params[:page])
                         .per(15)
        end

        # GET /admin/referendums/:id
        def show
          enforce_permission_to :read, :referendum, referendum: current_referendum
        end

        # GET /admin/referendums/:id/edit
        def edit
          enforce_permission_to :edit, :referendum, referendum: current_referendum
          @form = form(Decidim::Referendums::Admin::ReferendumForm)
                  .from_model(
                    current_referendum,
                    referendum: current_referendum
                  )

          render layout: "decidim/admin/referendum"
        end

        # PUT /admin/referendums/:id
        def update
          enforce_permission_to :update, :referendum, referendum: current_referendum

          params[:id] = params[:slug]
          @form = form(Decidim::Referendums::Admin::ReferendumForm)
                  .from_params(params, referendum: current_referendum)

          UpdateReferendum.call(current_referendum, @form, current_user) do
            on(:ok) do |referendum|
              flash[:notice] = I18n.t("referendums.update.success", scope: "decidim.referendums.admin")
              redirect_to edit_referendum_path(referendum)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("referendums.update.error", scope: "decidim.referendums.admin")
              render :edit, layout: "decidim/admin/referendum"
            end
          end
        end

        # POST /admin/referendums/:id/publish
        def publish
          enforce_permission_to :publish, :referendum, referendum: current_referendum
          PublishReferendum.call(current_referendum, current_user) do
            on(:ok) do
              i = Decidim::Referendum.find(current_referendum.id)
              i.signature_last_day = i.signature_end_date + 30.days
              i.save!
              redirect_to decidim_admin_referendums.edit_referendum_path(current_referendum)
            end
          end
        end

        # DELETE /admin/referendums/:id/unpublish
        def unpublish
          enforce_permission_to :unpublish, :referendum, referendum: current_referendum

          UnpublishReferendum.call(current_referendum, current_user) do
            on(:ok) do
              redirect_to decidim_admin_referendums.edit_referendum_path(current_referendum)
            end
          end
        end

        # DELETE /admin/referendums/:id/discard
        def discard
          enforce_permission_to :discard, :referendum, referendum: current_referendum
          current_referendum.discarded!
          redirect_to decidim_admin_referendums.edit_referendum_path(current_referendum)
        end

        # POST /admin/referendums/:id/accept
        def accept
          enforce_permission_to :accept, :referendum, referendum: current_referendum
          current_referendum.accepted!
          redirect_to decidim_admin_referendums.edit_referendum_path(current_referendum)
        end

        # DELETE /admin/referendums/:id/reject
        def reject
          enforce_permission_to :reject, :referendum, referendum: current_referendum
          current_referendum.rejected!
          redirect_to decidim_admin_referendums.edit_referendum_path(current_referendum)
        end

        # GET /admin/referendums/:id/send_to_technical_validation
        def send_to_technical_validation
          enforce_permission_to :send_to_technical_validation, :referendum, referendum: current_referendum

          SendReferendumToTechnicalValidation.call(current_referendum, current_user) do
            on(:ok) do
              redirect_to edit_referendum_path(current_referendum), flash: {
                notice: I18n.t(
                  "success",
                  scope: %w(decidim referendums admin referendums edit)
                )
              }
            end
          end
        end

        # GET /admin/referendums/:id/export_votes
        def export_votes
          enforce_permission_to :export_votes, :referendum, referendum: current_referendum

          votes = current_referendum.votes.votes.map(&:sha1)
          csv_data = CSV.generate(headers: false) do |csv|
            votes.each do |sha1|
              csv << [sha1]
            end
          end

          respond_to do |format|
            format.csv { send_data csv_data, file_name: "votes.csv" }
          end
        end

        # GET /admin/referendums/:id/export_pdf_signatures.pdf
        def export_pdf_signatures
          enforce_permission_to :export_pdf_signatures, :referendum, referendum: current_referendum

          @votes = current_referendum.votes.votes

          output = render_to_string(
            pdf: "votes_#{current_referendum.id}",
            layout: "decidim/admin/referendums_votes",
            template: "decidim/referendums/admin/referendums/export_pdf_signatures.pdf.erb"
          )
          output = pdf_signature_service.new(pdf: output).signed_pdf if pdf_signature_service

          respond_to do |format|
            format.pdf do
              send_data(output, filename: "votes_#{current_referendum.id}.pdf", type: "application/pdf")
            end
          end
        end

        private

        def pdf_signature_service
          @pdf_signature_service ||= Decidim.pdf_signature_service.to_s.safe_constantize
        end
      end
    end
  end
end
