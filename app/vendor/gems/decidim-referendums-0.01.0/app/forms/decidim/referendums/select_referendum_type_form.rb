# frozen_string_literal: true

module Decidim
  module Referendums
    # A form object used to collect the referendum type for an referendum.
    class SelectReferendumTypeForm < Form
      mimic :referendum

      attribute :type_id, Integer

      validates :type_id, presence: true
    end
  end
end
