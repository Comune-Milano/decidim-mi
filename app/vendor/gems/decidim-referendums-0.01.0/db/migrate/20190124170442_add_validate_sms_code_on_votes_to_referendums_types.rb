# frozen_string_literal: true

class AddValidateSmsCodeOnVotesToReferendumsTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums_types, :validate_sms_code_on_votes, :boolean, default: false
  end
end
