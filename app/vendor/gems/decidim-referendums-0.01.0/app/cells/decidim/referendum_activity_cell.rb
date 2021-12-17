# frozen_string_literal: true

module Decidim
  # A cell to display when an referendum has been published.
  class ReferendumActivityCell < ActivityCell
    def title
      I18n.t "decidim.referendums.last_activity.new_referendum"
    end
  end
end
