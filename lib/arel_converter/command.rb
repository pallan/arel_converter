require 'optparse'

module ArelConverter

  class Command

    attr_accessor :options

    def initialize(*args)
      @translators = args.shift.split(',')
      @translators = ['scope','finder','association'] if @translators == ['all']
      @options = {}
      parse_argv(*args)
    end

    def run!
      if @translators.include?('association')
        puts "== Checking Associations"
        ArelConverter::Association.new(options[:type], options[:path]).run!
      end

      if @translators.include?('scope')
        puts "\n== Checking Scopes"
        ArelConverter::Scope.new(options[:type], options[:path]).run!
      end

      if @translators.include?('finder')
        puts "\n== Checking Finders"
        ArelConverter::ActiveRecordFinder.new(options[:type], options[:path]).run!
      end
    end

  private

    def parse_argv(*args)
      OptionParser.new do |opts|
        options[:directory] = '.'
        opts.on('-d', '--directory DIRECTORY', 'Specify the directory to parse') do |v|
          options[:path] = v
          options[:type] = :directory
        end
        opts.on('-f', '--file FILE', 'Specify a single file to run against') do |v| 
          options[:path] = v
          options[:type] = :file
        end
        opts.on('-h', '--help', 'Display this screen' ) do
          puts opts
          exit 0
        end
      end.parse!(args)
    end

  end

end
