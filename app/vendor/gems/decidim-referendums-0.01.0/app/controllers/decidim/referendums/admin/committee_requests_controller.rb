# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # Controller in charge of managing committee membership
      class CommitteeRequestsController < Decidim::Referendums::Admin::ApplicationController
        include ReferendumAdmin

        # GET /admin/referendums/:referendum_id/committee_requests
        def index
          enforce_permission_to :index, :referendum_committee_member
        end

        # GET /referendums/:referendum_id/committee_requests/:id/approve
        def approve
          enforce_permission_to :approve, :referendum_committee_member, request: membership_request
          membership_request.accepted!

          redirect_to referendum_committee_requests_path(membership_request.referendum)
        end

        # DELETE /referendums/:referendum_id/committee_requests/:id/revoke
        def revoke
          enforce_permission_to :revoke, :referendum_committee_member, request: membership_request
          membership_request.rejected!
          redirect_to referendum_committee_requests_path(membership_request.referendum)
        end

        private

        def membership_request
          @membership_request ||= ReferendumsCommitteeMember.find(params[:id])
        end
      end
    end
  end
end
