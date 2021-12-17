# frozen_string_literal: true
include CertificatoElettoraleHelper
module Decidim
  module Referendums
    require "wicked"

    class ReferendumSignaturesController < Decidim::Referendums::ApplicationController
      layout "layouts/decidim/referendum_signature_creation"

      include Wicked::Wizard
      include Decidim::Referendums::NeedsReferendum
      include Decidim::FormFactory

      prepend_before_action :set_wizard_steps
      before_action :authenticate_user!

      helper ReferendumHelper

      helper_method :referendum_type, :extra_data_legal_information

      # GET /referendums/:referendum_id/referendum_signatures/:step
      def show
        group_id = params[:group_id] || (session[:referendum_vote_form] ||= {})["group_id"]
        enforce_permission_to :sign_referendum, :referendum, referendum: current_referendum, group_id: group_id, signature_has_steps: signature_has_steps?
        send("#{step}_step", referendum_vote_form: session[:referendum_vote_form])
      end

      # PUT /referendums/:referendum_id/referendum_signatures/:step
      def update
        group_id = params.dig(:referendums_vote, :group_id) || session[:referendum_vote_form]["group_id"]
        enforce_permission_to :sign_referendum, :referendum, referendum: current_referendum, group_id: group_id, signature_has_steps: signature_has_steps?
        send("#{step}_step", params)
      end

      # POST /referendums/:referendum_id/referendum_signatures
      def create
        group_id = params[:group_id] || session[:referendum_vote_form]&.dig("group_id")
        enforce_permission_to :vote, :referendum, referendum: current_referendum, group_id: group_id
        if !check_elettore_abilitato(current_user.codice_fiscale)
          @error_message = 1
          respond_to do |format|
            format.js
          end
        else
          @form = form(Decidim::Referendums::VoteForm)
                      .from_params(
                          referendum_id: current_referendum.id,
                          author_id: current_user.id,
                          group_id: group_id
                      )

          VoteReferendum.call(@form, current_user) do
            on(:ok) do
              current_referendum.reload
              render :update_buttons_and_counters
            end

            on(:invalid) do
              render json: {
                  error: I18n.t("create.error", scope: "decidim.referendums.referendum_votes")
              }, status: :unprocessable_entity
            end
          end
        end
      end

      private

      def fill_personal_data_step(_unused)
        @form = form(Decidim::Referendums::VoteForm)
                    .from_params(
                        referendum_id: current_referendum.id,
                        author_id: current_user.id,
                        group_id: params[:group_id]
                    )
        session[:referendum_vote_form] = {group_id: @form.group_id}
        skip_step unless referendum_type.collect_user_extra_fields
        render_wizard
      end

      def sms_phone_number_step(parameters)
        if parameters.has_key?(:referendums_vote) || !fill_personal_data_step?
          build_vote_form(parameters)
        else
          check_session_personal_data
        end
        clear_session_sms_code

        if @vote_form.invalid?
          flash[:alert] = I18n.t("personal_data.invalid", scope: "decidim.referendums.referendum_votes")
          jump_to(previous_step)
        end

        @form = Decidim::Verifications::Sms::MobilePhoneForm.new
        render_wizard
      end

      def sms_code_step(parameters)
        check_session_personal_data if fill_personal_data_step?
        @phone_form = Decidim::Verifications::Sms::MobilePhoneForm.from_params(parameters.merge(user: current_user))
        @form = Decidim::Verifications::Sms::ConfirmationForm.new
        render_wizard && return if session_sms_code.present?

        ValidateMobilePhone.call(@phone_form, current_user) do
          on(:ok) do |metadata|
            store_session_sms_code(metadata)
            render_wizard
          end

          on(:invalid) do
            flash[:alert] = I18n.t("sms_phone.invalid", scope: "decidim.referendums.referendum_votes")
            redirect_to wizard_path(:sms_phone_number)
          end
        end
      end

      def finish_step(parameters)
        if parameters.has_key?(:referendums_vote) || !fill_personal_data_step?
          build_vote_form(parameters)
        else
          check_session_personal_data
        end

        if sms_step?
          @confirmation_code_form = Decidim::Verifications::Sms::ConfirmationForm.from_params(parameters)

          ValidateSmsCode.call(@confirmation_code_form, session_sms_code) do
            on(:ok) { clear_session_sms_code }

            on(:invalid) do
              flash[:alert] = I18n.t("sms_code.invalid", scope: "decidim.referendums.referendum_votes")
              jump_to :sms_code
              render_wizard && return
            end
          end
        end

        VoteReferendum.call(@vote_form, current_user) do
          on(:ok) do
            session[:referendum_vote_form] = {}
          end

          on(:invalid) do |vote|
            logger.fatal "Failed creating signature: #{vote.errors.full_messages.join(", ")}" if vote
            flash[:alert] = I18n.t("create.invalid", scope: "decidim.referendums.referendum_votes")
            jump_to previous_step
          end
        end
        render_wizard
      end

      def build_vote_form(parameters)
        @vote_form = form(Decidim::Referendums::VoteForm).from_params(parameters).tap do |form|
          form.referendum_id = current_referendum.id
          form.author_id = current_user.id
        end

        session[:referendum_vote_form] = session[:referendum_vote_form].merge(@vote_form.attributes_with_values)
      end

      def session_vote_form
        raw_birth_date = session[:referendum_vote_form]["date_of_birth"]
        return unless raw_birth_date

        @vote_form = form(Decidim::Referendums::VoteForm).from_params(
            session[:referendum_vote_form].merge("date_of_birth" => Date.parse(raw_birth_date))
        )
      end

      def referendum_type
        @referendum_type ||= current_referendum&.scoped_type&.type
      end

      def extra_data_legal_information
        @extra_data_legal_information ||= referendum_type.extra_fields_legal_information
      end

      def check_session_personal_data
        return if session[:referendum_vote_form].present? && session_vote_form&.valid?

        flash[:alert] = I18n.t("create.error", scope: "decidim.referendums.referendum_votes")
        jump_to(:fill_personal_data)
      end

      def store_session_sms_code(metadata)
        session[:referendum_sms_code] = metadata
      end

      def session_sms_code
        session[:referendum_sms_code]
      end

      def clear_session_sms_code
        session[:referendum_sms_code] = {}
      end

      def sms_step?
        current_referendum.validate_sms_code_on_votes?
      end

      def fill_personal_data_step?
        referendum_type.collect_user_extra_fields?
      end

      def set_wizard_steps
        initial_wizard_steps = [:finish]
        initial_wizard_steps.unshift(:sms_phone_number, :sms_code) if sms_step?
        initial_wizard_steps.unshift(:fill_personal_data) if fill_personal_data_step?

        self.steps = initial_wizard_steps
      end
    end
  end
end
