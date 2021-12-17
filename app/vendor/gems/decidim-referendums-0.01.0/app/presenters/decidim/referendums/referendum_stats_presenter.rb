# frozen_string_literal: true

module Decidim
  module Referendums
    # A presenter to render statistics in the homepage.
    class ReferendumStatsPresenter < Rectify::Presenter
      attribute :referendum, Decidim::Referendum

      def supports_count
        referendum.referendum_supports_count
      end

      def offline_signature_count
        sql = "Select count(distinct codice_fiscale) from decidim_referendums_csv_signature_data where referendums_id = #{referendum.id} group by referendums_id;"
        records_array = ActiveRecord::Base.connection.select_all(sql)
        records_array.first["count"]
      end

      def comments_count
        Rails.cache.fetch(
          "referendum/#{referendum.id}/comments_count",
          expires_in: Decidim::Referendums.stats_cache_expiration_time
        ) do
          Decidim::Comments::Comment.where(root_commentable: referendum).count
        end
      end

      def meetings_count
        Rails.cache.fetch(
          "referendum/#{referendum.id}/meetings_count",
          expires_in: Decidim::Referendums.stats_cache_expiration_time
        ) do
          Decidim::Meetings::Meeting.where(component: meetings_component).count
        end
      end

      def assistants_count
        Rails.cache.fetch(
          "referendum/#{referendum.id}/assistants_count",
          expires_in: Decidim::Referendums.stats_cache_expiration_time
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
        @meetings_component ||= Decidim::Component.find_by(participatory_space: referendum, manifest_name: "meetings")
      end
    end
  end
end
