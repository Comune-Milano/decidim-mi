# frozen_string_literal: true

class SpidAccessLogger
  LogFile = Rails.root.join('log', 'spid_access.log')
  class << self
    cattr_accessor :logger
    delegate :debug, :info, :warn, :error, :fatal, to: :logger
  end
end
