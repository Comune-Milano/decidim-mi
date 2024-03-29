# frozen_string_literal: true

module Decidim
  module Referendums
    # A form object used to collect the data for a new referendum.
    class ReferendumForm < Form
      include TranslatableAttributes

      mimic :referendum

      attribute :title, String
      attribute :description, String
      attribute :type_id, Integer
      attribute :scope_id, Integer
      attribute :area_id, Integer
      attribute :decidim_user_group_id, Integer
      attribute :signature_type, String
      attribute :state, String

      validates :title, :description, presence: true
      validates :title, length: { maximum: 150 }
      validates :signature_type, presence: true
      validates :type_id, presence: true
      validate :scope_exists

      def map_model(model)
        self.type_id = model.type.id
        self.scope_id = model.scope&.id
      end

      def signature_type_updatable?
        state == "created" || state.nil?
      end

      def scope_id
        super.presence
      end

      private

      def scope_exists
        return if scope_id.blank?

        errors.add(:scope_id, :invalid) unless ReferendumsTypeScope.where(decidim_referendums_types_id: type_id, decidim_scopes_id: scope_id).exists?
      end
    end
  end
end

