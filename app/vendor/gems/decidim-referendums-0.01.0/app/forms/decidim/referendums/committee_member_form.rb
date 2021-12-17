# frozen_string_literal: true

module Decidim
  module Referendums
    # A form object used to collect the data for a new referendum committee
    # member.
    class CommitteeMemberForm < Form
      mimic :referendums_committee_member

      attribute :referendum_id, Integer
      attribute :user_id, Integer
      attribute :state, String

      validates :referendum_id, presence: true
      validates :user_id, presence: true
      validates :state, inclusion: { in: %w(requested rejected accepted) }, unless: :user_is_author?
      validates :state, inclusion: { in: %w(rejected accepted) }, if: :user_is_author?

      def user_is_author?
        referendum&.decidim_author_id == user_id
      end

      private

      def referendum
        @referendum ||= Decidim::Referendum.find_by(id: referendum_id)
      end
    end
  end
end
