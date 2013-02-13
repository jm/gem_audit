$:.unshift(File.dirname(__FILE__))
require 'json'
require 'gem_audit/auditor'

module GemAudit
  VERSION = '0.0.1'

  class <<self
    def host
      ENV['DEV'] ? '127.0.0.1' : 'gemaudit.org'
    end

    def port
      ENV['DEV'] ? 9292 : 443
    end
  end
end