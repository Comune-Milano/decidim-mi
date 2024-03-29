# frozen_string_literal: true

module Decidim
  module Initiatives
    # A presenter to render statistics in the homepage.
    class InitiativeStatsPresenter < Rectify::Presenter
      attribute :initiative, Decidim::Initiative

      def supports_count
        initiative.initiative_supports_count
      end

      def offline_signature_count
        sql = "Select count(distinct codice_fiscale) from decidim_initiatives_csv_signature_data where initiatives_id = #{initiative.id} group by initiatives_id;"
        records_array = ActiveRecord::Base.connection.select_all(sql)
        records_array.first["count"]
      end

      def comments_count
        Rails.cache.fetch(
          "initiative/#{initiative.id}/comments_count",
          expires_in: Decidim::Initiatives.stats_cache_expiration_time
        ) do
          Decidim::Comments::Comment.where(root_commentable: initiative).count
        end
      end

      def meetings_count
        Rails.cache.fetch(
          "initiative/#{initiative.id}/meetings_count",
          expires_in: Decidim::Initiatives.stats_cache_expiration_time
        ) do
          Decidim::Meetings::Meeting.where(component: meetings_component).count
        end
      end

      def assistants_count
        Rails.cache.fetch(
          "initiative/#{initiative.id}/assistants_count",
          expires_in: Decidim::Initiatives.stats_cache_expiration_time
        ) do
          result = 0
          Decidim::Meetings::Meeting.where(component: meetings_component).each do |meeting|
            result += meeting.attendees_count || 0
          end

          result
        end
      end

      private

      def meetings_component
        @meetings_component ||= Decidim::Component.find_by(participatory_space: initiative, manifest_name: "meetings")
      end
    end
  end
end
