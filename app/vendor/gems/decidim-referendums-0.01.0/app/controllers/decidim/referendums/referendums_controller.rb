# frozen_string_literal: true

module Decidim
  module Referendums
    # This controller contains the logic regarding citizen referendums
    class ReferendumsController < Decidim::Referendums::ApplicationController
      include ParticipatorySpaceContext
      participatory_space_layout only: [:show]

      helper Decidim::WidgetUrlsHelper
      helper Decidim::AttachmentsHelper
      helper Decidim::FiltersHelper
      helper Decidim::OrdersHelper
      helper Decidim::ResourceHelper
      helper Decidim::IconHelper
      helper Decidim::Comments::CommentsHelper
      helper Decidim::Admin::IconLinkHelper
      helper Decidim::ResourceReferenceHelper
      helper PaginateHelper
      helper ReferendumHelper
      include ReferendumSlug

      include FilterResource
      include Paginable
      include Decidim::Referendums::Orderable
      include TypeSelectorOptions
      include NeedsReferendum
      include CertificatoElettoraleHelper

      helper_method :collection, :referendums, :filter, :stats

      # GET /referendums
      def index
        enforce_permission_to :list, :referendum
		@has_certificato_elettorale = false;
		if !current_user.nil? 
			@has_certificato_elettorale = check_elettore_abilitato(current_user.codice_fiscale)
		end
      end

      # GET /referendums/:id
      def show
        enforce_permission_to :read, :referendum, referendum: current_referendum
	# 4 è rifiutato e 5 è accettato
        @is_closed = Decidim::Referendum.where("id = #{current_referendum.id } and (state = 4 or state = 5)").present?
      end

      # GET /referendums/:id/signature_identities
      def signature_identities
        @voted_groups = ReferendumsVote
                        .supports
                        .where(referendum: current_referendum, author: current_user)
                        .pluck(:decidim_user_group_id)
        render layout: false
      end

      private

      alias current_referendum current_participatory_space

      def current_participatory_space
        @current_participatory_space ||= Referendum.find_by(id: id_from_slug(params[:slug]))
      end

      def referendums
        @referendums = search.results.includes(:scoped_type)
        @referendums = reorder(@referendums)
        @referendums = paginate(@referendums)
      end

      alias collection referendums

      def search_klass
        ReferendumSearch
      end

      def default_filter_params
        {
          search_text: "",
          state: "open",
          type: "all",
          author: "any",
          scope_id: nil
        }
      end

      def context_params
        {
          organization: current_organization,
          current_user: current_user
        }
      end

      def stats
        @stats ||= ReferendumStatsPresenter.new(referendum: current_referendum)
      end
    end
  end
end
