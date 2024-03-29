# frozen_string_literal: true

module Decidim
  # The data store for a Initiative in the Decidim::Initiatives component.
  class Initiative < ApplicationRecord
    include ActiveModel::Dirty
    include Decidim::Authorable
    include Decidim::Participable
    include Decidim::Publicable
    include Decidim::Scopable
    include Decidim::Comments::Commentable
    include Decidim::Followable
    include Decidim::HasAttachments
    include Decidim::HasAttachmentCollections
    include Decidim::Traceable
    include Decidim::Loggable
    include Decidim::Initiatives::InitiativeSlug
    include Decidim::Resourceable
    include Decidim::HasReference
    include Decidim::Randomable
    include Decidim::Searchable

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    belongs_to :scoped_type,
               foreign_key: "scoped_type_id",
               class_name: "Decidim::InitiativesTypeScope",
               inverse_of: :initiatives

    delegate :type, :scope, :scope_name, to: :scoped_type, allow_nil: true
    delegate :promoting_committee_enabled?, to: :type

    has_many :votes,
             foreign_key: "decidim_initiative_id",
             class_name: "Decidim::InitiativesVote",
             dependent: :destroy,
             inverse_of: :initiative

    has_many :committee_members,
             foreign_key: "decidim_initiatives_id",
             class_name: "Decidim::InitiativesCommitteeMember",
             dependent: :destroy,
             inverse_of: :initiative

    has_many :components, as: :participatory_space, dependent: :destroy

    # This relationship exists only by compatibility reasons.
    # Initiatives are not intended to have categories.
    has_many :categories,
             foreign_key: "decidim_participatory_space_id",
             foreign_type: "decidim_participatory_space_type",
             dependent: :destroy,
             as: :participatory_space

    enum signature_type: [:online, :offline, :any], _suffix: true
    enum state: [:created, :validating, :discarded, :published, :rejected, :accepted]

    validates :title, :description, :state, presence: true
    validates :signature_type, presence: true
    validate :signature_type_allowed

    validates :hashtag,
              uniqueness: true,
              allow_blank: true,
              case_sensitive: false

    scope :open, lambda {
      published
          .where.not(state: [:discarded, :rejected, :accepted])
          .where("signature_start_date <= ?", Date.current)
          .where("signature_end_date >= ?", Date.current)
    }
    scope :closed, lambda {
      published
          .where(state: [:discarded, :rejected, :accepted])
          .or(where("signature_start_date > ?", Date.current))
          .or(where("signature_end_date < ?", Date.current))
    }
    scope :published, -> { where.not(published_at: nil) }
    scope :with_state, ->(state) { where(state: state) if state.present? }

    scope :public_spaces, -> { published }
    scope :signature_type_updatable, -> { created }

    scope :order_by_most_recent, -> { order(created_at: :desc) }
    scope :order_by_supports, -> { order(Arel.sql("initiative_votes_count + coalesce(offline_votes, 0) desc")) }
    scope :order_by_most_commented, lambda {
      select("decidim_initiatives.*")
          .left_joins(:comments)
          .group("decidim_initiatives.id")
          .order(Arel.sql("count(decidim_comments_comments.id) desc"))
    }

    after_save :notify_state_change
    after_create :notify_creation

    searchable_fields({
                          participatory_space: :itself,
                          A: :title,
                          D: :description,
                          datetime: :published_at
                      },
                      index_on_create: ->(_initiative) { false },
                      # is Resourceable instead of ParticipatorySpaceResourceable so we can't use `visible?`
                      index_on_update: ->(initiative) { initiative.published? })

    def self.future_spaces
      none
    end

    def self.past_spaces
      closed
    end

    def self.log_presenter_class_for(_log)
      Decidim::Initiatives::AdminLog::InitiativePresenter
    end

    # PUBLIC
    #
    # Returns true when an initiative has been created by an individual person.
    # False in case it has been created by an authorized organization.
    #
    # RETURN boolean
    def created_by_individual?
      decidim_user_group_id.nil?
    end

    # PUBLIC
    #
    # RETURN boolean TRUE when the initiative is open, false in case its
    # not closed.
    def open?
      !closed?
    end

    # PUBLIC
    #
    # Returns when an initiative is closed. An initiative is closed when
    # at least one of the following conditions is true:
    #
    # * It has been discarded.
    # * It has been rejected.
    # * It has been accepted.
    # * Signature collection period has finished.
    #
    # RETURNS BOOLEAN
    def closed?
      discarded? || rejected? || accepted? || !votes_enabled?
    end

    # PUBLIC
    #
    # Returns the author name. If it has been created by an organization it will
    # return the organization's name. Otherwise it will return author's name.
    #
    # RETURN string
    def author_name
      user_group&.name || author.name
    end

    # PUBLIC author_avatar_url
    #
    # Returns the author's avatar URL. In case it is not defined the method
    # falls back to decidim/default-avatar.svg
    #
    # RETURNS STRING
    def author_avatar_url
      author.avatar&.url ||
          ActionController::Base.helpers.asset_path("decidim/default-avatar.svg")
    end

    # PUBLIC banner image
    #
    # Overrides participatory space's banner image with the banner image defined
    # for the initiative type.
    #
    # RETURNS string
    delegate :banner_image, to: :type

    delegate :document_number_authorization_handler, to: :type
    delegate :supports_required, to: :scoped_type

    def votes_enabled?
      published? &&
          signature_start_date <= Date.current &&
          signature_end_date >= Date.current
    end

    # Public: Check if the user has voted the question.
    #
    # Returns Boolean.
    def voted_by?(user)
      votes.where(author: user).any?
    end

    # Public: Checks if the organization has given an answer for the initiative.
    #
    # Returns Boolean.
    def answered?
      answered_at.present?
    end

    # Public: Overrides scopes enabled flag available in other models like
    # participatory space or assemblies. For initiatives it won't be directly
    # managed by the user and it will be enabled by default.
    def scopes_enabled?
      true
    end

    # Public: Overrides scopes enabled attribute value.
    # For initiatives it won't be directly
    # managed by the user and it will be enabled by default.
    def scopes_enabled
      true
    end

    # Public: Publishes this initiative
    #
    # Returns true if the record was properly saved, false otherwise.
    def publish!
      return false if published?

      update(
          published_at: Time.current,
          state: "published",
          signature_start_date: Date.current,
          signature_end_date: Date.current + Decidim::Initiatives.default_signature_time_period_length
      )
    end

    #
    # Public: Unpublishes this initiative
    #
    # Returns true if the record was properly saved, false otherwise.
    def unpublish!
      return false unless published?

      update(published_at: nil, state: "discarded")
    end

    # Public: Returns wether the signature interval is already defined or not.
    def has_signature_interval_defined?
      signature_end_date.present? && signature_start_date.present?
    end

    # Public: Returns the hashtag for the initiative.
    def hashtag
      attributes["hashtag"].to_s.delete("#")
    end

    def supports_count
      face_to_face_votes = offline_votes.nil? || online_signature_type? ? 0 : offline_votes
      digital_votes = offline_signature_type? ? 0 : (initiative_votes_count + initiative_supports_count)
      digital_votes + face_to_face_votes
    end

    def get_offline_votes_total(initiative_id)
      sql = "Select count(decidim_initiatives_csv_signature_data.id) from decidim_initiatives_csv_signature_data
        join decidim_initiatives ON decidim_initiatives.id = decidim_initiatives_csv_signature_data.initiatives_id
        where decidim_initiatives_csv_signature_data.initiatives_id = #{initiative_id}"
      records_array = ActiveRecord::Base.connection.select_all(sql)
      if records_array.present?
        records_array.first["count"]
      else
        return "0"
      end
    end

    def get_offline_votes_validated(initiative_id)
      sql = "Select count(decidim_initiatives_csv_signature_data.id) from decidim_initiatives_csv_signature_data
        join decidim_initiatives ON decidim_initiatives.id = decidim_initiatives_csv_signature_data.initiatives_id
        where decidim_initiatives_csv_signature_data.initiatives_id = #{initiative_id} and decidim_initiatives_csv_signature_data.validazione = true"
      records_array = ActiveRecord::Base.connection.select_all(sql)
      if records_array.present?
        records_array.first["count"]
      else
        return "0"
      end
    end

    def get_online_votes
      digital_votes = offline_signature_type? ? 0 : (initiative_votes_count + initiative_supports_count)
      return digital_votes
    end

    def offline_signature_count(initiative_id)
      sql = "Select count(decidim_initiatives_csv_signature_data.id) from decidim_initiatives_csv_signature_data
          JOIN decidim_initiatives ON decidim_initiatives.id = decidim_initiatives_csv_signature_data.initiatives_id
          where decidim_initiatives_csv_signature_data.initiatives_id = #{initiative_id}
          and decidim_initiatives_csv_signature_data.validazione = true
          and decidim_initiatives.mail_chiusura_mandata = true;"
      records_array = ActiveRecord::Base.connection.select_all(sql)
      if records_array.present?
        records_array.first["count"]
      else
        return "0"
      end
      #records_array.first["count"]
    end

    def is_offline_signature_date_passed(initiative_id)
      sql = "select now() >= signature_last_day from decidim_initiatives where id = #{initiative_id};"
      result = ActiveRecord::Base.connection.select_value(sql)
      return result
    end

    def is_gestione_firme_icona_visibile(user, initiative)
      if user.admin? or user.role?("initiative_manager")
        sql = "select true from decidim_initiatives WHERE id = #{initiative.id} and NOW() >= signature_last_day"
        result = ActiveRecord::Base.connection.select_value(sql)
        if result.present?
          return true
        else
          return false
        end
      end
      return false
      #if user.role?("initiative_manager")
      #  sql = "select true from decidim_initiatives WHERE id = #{initiative.id} and NOW() >= signature_last_day"
      #else
      #  sql = "select id from decidim_initiatives WHERE id = #{initiative.id} and NOW() BETWEEN signature_end_date AND signature_last_day"
      #end
      #result = ActiveRecord::Base.connection.select_value(sql)
      #if result.present?
      #  return true
      #else
      #  return false
      #end
    end

    def self.is_data_ultima_superata(initiative_id)
      sql = "select id from decidim_initiatives WHERE id = #{initiative_id} and NOW() >= signature_last_day"
      result = ActiveRecord::Base.connection.select_value(sql)
      if result.present?
        return true
      end
      return false
    end

    def is_data_ultima_superata_model(initiative_id)
      sql = "select id from decidim_initiatives WHERE id = #{initiative_id} and NOW() >= signature_last_day"
      result = ActiveRecord::Base.connection.select_value(sql)
      if result.present?
        return true
      end
      return false
    end

    def self.is_mail_chiusura_mandata(initiative_id)
      sql = "select id from decidim_initiatives WHERE id = #{initiative_id} and mail_chiusura_mandata = true"
      result = ActiveRecord::Base.connection.select_value(sql)
      if result.present?
        return true
      end
      return false
    end

    def self.is_data_fine_superata(initiative_id)
      sql = "SELECT case when
          (select true from decidim_initiatives WHERE id = #{initiative_id} and NOW() >= signature_end_date)
          then 'true' else 'false' end AS issuperata"
      result = ActiveRecord::Base.connection.select_value(sql)
      if result.to_s == "true"
        return true
      end
      return false
    end

    def self.is_data_fine_petizione_superata(initiative_id)
      sql = "SELECT case when
          (select true from decidim_initiatives WHERE id = #{initiative_id} and NOW() >= signature_end_date)
          then 'true' else 'false' end AS issuperata"
      result = ActiveRecord::Base.connection.select_value(sql)
      if result.to_s == "true"
        return true
      end
      return false
    end

    def check_pdf(initiative_id)
      sql = "SELECT attachment FROM public.pdf_signeds where component_id = #{initiative_id} and component_type = 'petizione';"
      records_array = ActiveRecord::Base.connection.select_all(sql)
      true if records_array.present?
    end

    def check_csv(initiative_id)
      sql = "SELECT id FROM public.decidim_initiatives_csv_signature_data where initiatives_id = #{initiative_id};"
      records_array = ActiveRecord::Base.connection.select_all(sql)
      true if records_array.present?
    end

    # Public: Returns the percentage of required supports reached
    def percentage
      return 100 if supports_goal_reached?

      supports_count * 100 / supports_required
    end

    # Public: Whether the supports required objective has been reached
    def supports_goal_reached?
      supports_count >= supports_required
    end

    # Public: Overrides slug attribute from participatory processes.
    def slug
      slug_from_id(id)
    end

    def to_param
      slug
    end

    # Public: Overrides the `comments_have_alignment?`
    # Commentable concern method.
    def comments_have_alignment?
      true
    end

    # Public: Overrides the `comments_have_votes?` Commentable concern method.
    def comments_have_votes?
      true
    end

    # PUBLIC
    #
    # Checks if user is the author or is part of the promotal committee
    # of the initiative.
    #
    # RETURNS boolean
    def has_authorship?(user)
      return true if author.id == user.id

      committee_members.approved.where(decidim_users_id: user.id).any?
    end

    def accepts_offline_votes?
      published? && (offline_signature_type? || any_signature_type?)
    end

    def accepts_online_votes?
      votes_enabled? && (online_signature_type? || any_signature_type?)
    end

    def accepts_online_unvotes?
      accepts_online_votes? && type.undo_online_signatures_enabled?
    end

    def minimum_committee_members
      type.minimum_committee_members || Decidim::Initiatives.minimum_committee_members
    end

    def enough_committee_members?
      committee_members.approved.count >= minimum_committee_members
    end

    # PUBLIC
    #
    # Checks if the type the initiative belongs to enables SMS code
    # verification step. Tis configuration is ignored if the organization
    # doesn't have the sms authorization available
    #
    # RETURNS boolean
    def validate_sms_code_on_votes?
      organization.available_authorizations.include?("sms") && type.validate_sms_code_on_votes?
    end

    private

    def signature_type_allowed
      return if published?

      errors.add(:signature_type, :invalid) if type.allowed_signature_types_for_initiatives.exclude?(signature_type)
    end

    def notify_state_change
      return unless saved_change_to_state?

      notifier = Decidim::Initiatives::StatusChangeNotifier.new(initiative: self)
      notifier.notify
    end

    def notify_creation
      notifier = Decidim::Initiatives::StatusChangeNotifier.new(initiative: self)
      notifier.notify
    end
  end
end