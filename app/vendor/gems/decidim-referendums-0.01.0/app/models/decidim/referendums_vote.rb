# frozen_string_literal: true

require "digest/sha1"

module Decidim
  # Referendums can be voted by users and supported by organizations.
  class ReferendumsVote < ApplicationRecord
    include Decidim::TranslatableAttributes

    belongs_to :author,
               foreign_key: "decidim_author_id",
               class_name: "Decidim::User"

    belongs_to :user_group,
               foreign_key: "decidim_user_group_id",
               class_name: "Decidim::UserGroup",
               optional: true

    belongs_to :referendum,
               foreign_key: "decidim_referendum_id",
               class_name: "Decidim::Referendum",
               inverse_of: :votes

    validates :referendum, uniqueness: { scope: [:author, :user_group] }

    after_commit :update_counter_cache, on: [:create, :destroy]

    scope :supports, -> { where.not(decidim_user_group_id: nil) }
    scope :votes, -> { where(decidim_user_group_id: nil) }

    # PUBLIC
    #
    # Generates a hashed representation of the referendum support.
    def sha1
      return unless decidim_user_group_id.nil?

      title = translated_attribute(referendum.title)
      description = translated_attribute(referendum.description)

      Digest::SHA1.hexdigest "#{authorization_unique_id}#{title}#{description}"
    end

    private

    def authorization_unique_id
      first_authorization = Decidim::Referendums::UserAuthorizations
                            .for(author)
                            .first

      first_authorization&.unique_id || author.email
    end

    def update_counter_cache
      referendum.referendum_votes_count = Decidim::ReferendumsVote
                                          .votes
                                          .where(decidim_referendum_id: referendum.id)
                                          .count

      referendum.referendum_supports_count = Decidim::ReferendumsVote
                                             .supports
                                             .where(decidim_referendum_id: referendum.id)
                                             .count

      referendum.save
    end
  end
end
