# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20171019103358)

class AddReferendumNotificationDates < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_referendums,
               :first_progress_notification_at, :datetime, index: true

    add_column :decidim_referendums,
               :second_progress_notification_at, :datetime, index: true
  end
end
