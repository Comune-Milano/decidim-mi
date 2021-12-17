# frozen_string_literal: true

module Decidim
  module Referendums
    # Exposes the referendum vote resource so users can vote referendums.
    class ReferendumVotesController < Decidim::Referendums::ApplicationController
      include Decidim::Referendums::NeedsReferendum
      include Decidim::FormFactory

      before_action :authenticate_user!

      helper ReferendumHelper

      # POST /referendums/:referendum_id/referendum_vote
      def create
        enforce_permission_to :vote, :referendum, referendum: current_referendum, group_id: params[:group_id]
        @form = form(Decidim::Referendums::VoteForm).from_params(referendum_id: current_referendum.id, author_id: current_user.id, group_id: params[:group_id])
        VoteReferendum.call(@form, current_user) do
          on(:ok) do
            current_referendum.reload
            render :update_buttons_and_counters
          end

          on(:invalid) do
            render json: {
              error: I18n.t("referendum_votes.create.error", scope: "decidim.referendums")
            }, status: :unprocessable_entity
          end
        end
      end

      # DELETE /referendums/:referendum_id/referendum_vote
      def destroy
        enforce_permission_to :unvote, :referendum, referendum: current_referendum, group_id: params[:group_id]
        UnvoteReferendum.call(current_referendum, current_user, params[:group_id]) do
          on(:ok) do
            current_referendum.reload
            render :update_buttons_and_counters
          end
        end
      end
    end
  end
end
