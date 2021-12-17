# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryBot.define do
  factory :referendums_type, class: Decidim::ReferendumsType do
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    banner_image { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") }
    organization
    signature_type { :online }
    undo_online_signatures_enabled { true }
    promoting_committee_enabled { true }
    minimum_committee_members { 3 }

    trait :online_signature_enabled do
      signature_type { :online }
    end

    trait :online_signature_disabled do
      signature_type { :offline }
    end

    trait :undo_online_signatures_enabled do
      undo_online_signatures_enabled { true }
    end

    trait :undo_online_signatures_disabled do
      undo_online_signatures_enabled { false }
    end

    trait :promoting_committee_enabled do
      promoting_committee_enabled { true }
    end

    trait :promoting_committee_disabled do
      promoting_committee_enabled { false }
      minimum_committee_members { 0 }
    end

    trait :with_user_extra_fields_collection do
      collect_user_extra_fields { true }
      extra_fields_legal_information { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    end

    trait :with_sms_code_validation do
      validate_sms_code_on_votes { true }
    end
  end

  factory :referendums_type_scope, class: Decidim::ReferendumsTypeScope do
    type { create(:referendums_type) }
    scope { create(:scope, organization: type.organization) }
    supports_required { 1000 }

    trait :with_user_extra_fields_collection do
      type { create(:referendums_type, :with_user_extra_fields_collection) }
    end
  end

  factory :referendum, class: Decidim::Referendum do
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    organization
    author { create(:user, :confirmed, organization: organization) }
    published_at { Time.current }
    state { "published" }
    signature_type { "online" }
    signature_start_date { Date.current - 1.day }
    signature_end_date { Date.current + 120.days }

    scoped_type do
      create(:referendums_type_scope,
             type: create(:referendums_type, organization: organization, signature_type: signature_type))
    end

    after(:create) do |referendum|
      create(:authorization, user: referendum.author, granted_at: Time.now.utc) unless Decidim::Authorization.where(user: referendum.author).where.not(granted_at: nil).any?
      create_list(:referendums_committee_member, 3, referendum: referendum)
    end

    trait :created do
      state { "created" }
      published_at { nil }
      signature_start_date { nil }
      signature_end_date { nil }
    end

    trait :validating do
      state { "validating" }
      published_at { nil }
      signature_start_date { nil }
      signature_end_date { nil }
    end

    trait :published do
      state { "published" }
    end

    trait :unpublished do
      published_at { nil }
    end

    trait :accepted do
      state { "accepted" }
    end

    trait :discarded do
      state { "discarded" }
    end

    trait :rejected do
      state { "rejected" }
    end

    trait :online do
      signature_type { "online" }
    end

    trait :offline do
      signature_type { "offline" }
    end

    trait :acceptable do
      signature_start_date { Date.current - 3.months }
      signature_end_date { Date.current - 2.months }
      signature_type { "online" }

      after(:build) do |referendum|
        referendum.referendum_votes_count = referendum.scoped_type.supports_required + 1
      end
    end

    trait :rejectable do
      signature_start_date { Date.current - 3.months }
      signature_end_date { Date.current - 2.months }
      signature_type { "online" }

      after(:build) do |referendum|
        referendum.referendum_votes_count = referendum.scoped_type.supports_required - 1
      end
    end

    trait :with_user_extra_fields_collection do
      scoped_type do
        create(:referendums_type_scope,
               type: create(:referendums_type, :with_user_extra_fields_collection, organization: organization))
      end
    end
  end

  factory :referendum_user_vote, class: Decidim::ReferendumsVote do
    referendum { create(:referendum) }
    author { create(:user, :confirmed, organization: referendum.organization) }
  end

  factory :organization_user_vote, class: Decidim::ReferendumsVote do
    referendum { create(:referendum) }
    author { create(:user, :confirmed, organization: referendum.organization) }
    decidim_user_group_id { create(:user_group).id }
    after(:create) do |support|
      create(:user_group_membership, user: support.author, user_group: Decidim::UserGroup.find(support.decidim_user_group_id))
    end
  end

  factory :referendums_committee_member, class: Decidim::ReferendumsCommitteeMember do
    referendum { create(:referendum) }
    user { create(:user, :confirmed, organization: referendum.organization) }
    state { "accepted" }

    trait :accepted do
      state { "accepted" }
    end

    trait :requested do
      state { "requested" }
    end

    trait :rejected do
      state { "rejected" }
    end
  end
end
