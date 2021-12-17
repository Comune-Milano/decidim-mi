# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20190124170442)

class AddValidateSmsCodeOnVotesToReferendumsTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums_types, :validate_sms_code_on_votes, :boolean, default: false
  end
end
