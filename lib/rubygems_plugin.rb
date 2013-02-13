require 'rubygems/command_manager'
require 'gem_audit'

Gem::CommandManager.instance.register_command :audit

module Gem
  module Commands
    class AuditCommand < Command
      def initialize
        super 'audit', "Audit the given gem"
      end

      def arguments
        <<-EOS.gsub(/^ *\|/, '')
          |NAME     name of the gem or "bundle"
          |VERSION  version of the gem (optional)
        EOS
      end

      def usage
        "#{program_name} (NAME or bundle) [VERSION]"
      end

      def default_str
        ''
      end

      def description
        <<-EOS.gsub(/^ *\|/, '')
          | Do stuff that's important.
        EOS
      end

      def execute
        GemAudit::Auditor.new.audit(options[:args])
      end
    end
  end
end