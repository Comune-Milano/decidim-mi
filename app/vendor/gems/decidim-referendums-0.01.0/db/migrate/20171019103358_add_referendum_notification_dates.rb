# frozen_string_literal: true

class AddReferendumNotificationDates < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_referendums,
               :first_progress_notification_at, :datetime, index: true

    add_column :decidim_referendums,
               :second_progress_notification_at, :datetime, index: true
  end
end
