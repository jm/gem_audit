require 'net/http'
require 'bundler'

module GemAudit
  class Auditor
    def audit(args)
      if args.first == 'bundle'
        audit_bundle
      else
        audit_gem(*args)
      end
    end

    def audit_gem(name, version = nil)
      version ||= get_latest_version_of(name)

      return puts("Can't find a good version for #{name}.") unless version

      request = Net::HTTP::Get.new("/advisories/#{name}/#{version}")

      http = Net::HTTP.new(GemAudit.host, GemAudit.port)
      http.use_ssl = true unless ENV['DEV']

      process_results(http.start {|h| h.request(request)}.body)
    end

    def get_latest_version_of(gem_name)
      specs = Gem::Specification.select {|s| s.name == gem_name}

      return false if specs.empty?
      specs.sort_by {|s| s.version }.last.version.to_s
    end

    def audit_bundle
      request = Net::HTTP::Post.new('/advisories', {'Content-Type' =>'application/json'})
      request.body = bundle_payload
      
      http = Net::HTTP.new(GemAudit.host, GemAudit.port)
      http.use_ssl = true unless ENV['DEV']

      process_results(http.request(request).body)
    end

    def process_results(results)
      results = JSON.parse(results)
      return puts("No advisories found.") if results.empty?

      results.each do |result|
        puts "#{result['gem']} -- ADVISORY #{result['cve_id']} (Score: #{result['score']})"
        puts
        puts result['summary']
        puts
        puts "Vulnerable versions: #{result['versions'].sort.join(", ")}"
        puts
        puts "References:"
        result['references'].each {|r| puts "- #{r}"}
        puts
        puts "-" * 60
        puts
      end      
    end

    def bundle_payload
      Bundler.load.specs.map {|spec| {'name' => spec.name, 'version' => spec.version}}.to_json
    end
  end
end