# frozen_string_literal: true

module Decidim
  # Data store the committee members for the referendum
  class ReferendumsCommitteeMember < ApplicationRecord
    belongs_to :referendum,
               foreign_key: "decidim_referendums_id",
               class_name: "Decidim::Referendum",
               inverse_of: :committee_members

    belongs_to :user,
               foreign_key: "decidim_users_id",
               class_name: "Decidim::User"

    enum state: [:requested, :rejected, :accepted]

    validates :state, presence: true
    validates :user, uniqueness: { scope: :referendum }

    scope :approved, -> { where(state: :accepted) }
    scope :non_deleted, -> { includes(:user).where(decidim_users: { deleted_at: nil }) }
    scope :excluding_author, -> { joins(:referendum).where.not("decidim_users_id = decidim_author_id") }
  end
end
