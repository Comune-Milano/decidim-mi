# frozen_string_literal: true

module Decidim
  module Referendums
    # Controller in charge of managing committee membership
    class CommitteeRequestsController < Decidim::Referendums::ApplicationController
      include Decidim::Referendums::NeedsReferendum

      helper ReferendumHelper
      helper Decidim::ActionAuthorizationHelper

      layout "layouts/decidim/application"

      # GET /referendums/:referendum_id/committee_requests/new
      def new
        enforce_permission_to :request_membership, :referendum, referendum: current_referendum
      end

      # GET /referendums/:referendum_id/committee_requests/spawn
      def spawn
        enforce_permission_to :request_membership, :referendum, referendum: current_referendum

        form = Decidim::Referendums::CommitteeMemberForm
               .from_params(referendum_id: current_referendum.id, user_id: current_user.id, state: "requested")

        SpawnCommitteeRequest.call(form, current_user) do
          on(:ok) do
            redirect_to referendums_path, flash: {
              notice: I18n.t(
                "success",
                scope: %w(decidim referendums committee_requests spawn)
              )
            }
          end

          on(:invalid) do |request|
            redirect_to referendums_path, flash: {
              error: request.errors.full_messages.to_sentence
            }
          end
        end
      end
    end
  end
end
