module ArelConverter
  class Base

    attr_accessor :options

    def initialize(path, options = {})
      @path    = path
      @options = {dry_run: false}.merge(options)
    end

    def run!
      File.directory?(@path) ? parse_directory(@path) : parse_file(@path)
    end

    def parse_directory(path)
      Dir[File.join(path, '**/*.rb')].each do |file|
        begin
          parse_file(file)
        rescue => e
          Formatter.alert(file, [])
        end
      end
    end

    def parse_file(file)

      lines_to_process = grep_matches_in_file(file)

      return if lines_to_process.empty?

      replacements = process_lines(lines_to_process)

      unless (replacements.nil? || replacements.empty?)
        Formatter.alert(file, replacements)
        update_file(file, replacements) unless @options[:dry_run]
      end
    end

    def process_lines(lines)
      lines.map do |line|
        r = Replacement.new(line)
        begin
          next unless verify_line(line)
          r.new_content = process_line(line)
        rescue SyntaxError => e
          r.error = "SyntaxError when evaluating options for #{line}"
        rescue Exception => e
          r.error = "#{e.class} #{e.message} when evaluating options for \"#{line}\"\n#{e.backtrace.first}"
        end
        r
      end.compact
    end

    def update_file(file, line_replacements)
      contents = File.read(file)
      line_replacements.each do |r|
        contents.gsub!(r.old_content, r.new_content) if r.valid?
      end

      File.open(file, 'w') do |f|
        f.puts contents
      end
    end

    def grep_matches_in_file(file)
      [] # abstract method overriden by subclasses
    end

  protected

    def verify_line(line)
      true
    end

  end
end
