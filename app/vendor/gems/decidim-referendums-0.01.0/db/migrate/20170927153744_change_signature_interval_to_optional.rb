# frozen_string_literal: true

class ChangeSignatureIntervalToOptional < ActiveRecord::Migration[5.1]
  def change
    change_column :decidim_referendums, :signature_start_time, :date, null: true
    change_column :decidim_referendums, :signature_end_time, :date, null: true
  end
end
