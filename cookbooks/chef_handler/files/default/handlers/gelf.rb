require 'rubygems'
require 'gelf'
require 'chef'
require 'chef/handler'
require 'chef/log'

class Chef
  module GELF
    class Handler < Chef::Handler
      attr_reader :notifier
      attr_reader :options

      def initialize(opts = {})
        @options = {
          :host => nil,
          :port => '12201',
          :facility => 'chef_client',
          :blacklist => {},
          :report_host => nil,
          :custom_fields => {}
        }
        @options.merge! opts

        Chef::Log.info "Initialised GELF handler for gelf://#{options[:host]}:#{options[:port]}/#{options[:facility]}"
        @notifier = ::GELF::Notifier.new(options[:host], options[:port], 'WAN', :facility => options[:facility])
      end

      def report
        begin
          if run_status.failed?
            Chef::Log.info "Notifying GELF server of FAILURE."
            @report_hash = { :short_message => "Chef run FAILED on #{node.name}. Updated #{changes[:count]} resources.",
                             :full_message => run_status.formatted_exception + "\n" + Array(backtrace).join("\n") + changes[:message],
                             :level => ::GELF::Levels::FATAL,
                             :status => "FAILURE",
                             :host => host_name,
                             :elapsed_time => elapsed_time,
                             :resources_updated => changes[:count],
                             :cookbook_versions => cookbook_versions }
            @notifier.notify!( @report_hash.merge options[:custom_fields] )
          else
            Chef::Log.info "Notifying GELF server of SUCCESS."
            @report_hash = { :short_message => "Chef run SUCCEEDED on #{node.name} in #{elapsed_time}. Updated #{changes[:count]} resources.",
                             :full_message => changes[:message],
                             :level => ::GELF::Levels::INFO,
                             :status => "SUCCESS",
                             :host => host_name,
                             :elapsed_time => elapsed_time,
                             :resources_updated => changes[:count],
                             :cookbook_versions => cookbook_versions }
            @notifier.notify!( @report_hash.merge options[:custom_fields] )
          end
        rescue Exception => e
          # Capture any exceptions that happen as a result of transmission. i.e. Host address resolution errors.
          Chef::Log.error("Error reporting to gelf server: #{e}")
        end
      end

      protected

      def host_name
        options[:report_host] || node[:fqdn]
      end

      def changes
        @changes unless @changes.nil?

        lines = run_status.updated_resources.collect do |resource|
          "recipe[#{resource.cookbook_name}::#{resource.recipe_name}] ran '#{resource.action}' on #{resource.resource_name} '#{resource.name}'"
        end

        count = lines.size

        message = if count > 0
          "Updated #{count} resources:\n\n#{lines.join("\n")}"
        else
          "No changes made."
        end

        @changes = { :count => count, :message => message }
      end

      def cookbook_versions
        cookbooks = run_context.cookbook_collection
        @cookbook_versions = cookbooks.keys.map {|x| cookbooks[x].name.to_s + " " + cookbooks[x].version}
      end

    end
  end
end
