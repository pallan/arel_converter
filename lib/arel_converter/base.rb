module ArelConverter
  class Base
    def initialize(type, path)
      @parse_type = type
      @path       = path
      @parser     = RubyParser.new
      @translator = Ruby2Ruby.new
    end

    def run!
      @parse_type == :file ? parse_file(@path) : parse_directory(path)
    end

    def parse_directory(path)
      Dir[File.join(path, 'app/**/*.rb')].each do |file|
        begin
          parse_file(file)
        rescue => e
          Formatter.alert(file, [], e.message)
        end
      end
    end

    def parse_file(file)

      lines_to_process = grep_matches_in_file(file)

      unless lines_to_process.empty?

        failures = []

        replacements =  lines_to_process.map do |line|
                          line = line.gsub("#{file}:",'').strip
                          begin
                            next unless verify_line(line)
                            [line, process_line(line)]
                          rescue SyntaxError => e
                            failures << "SyntaxError when evaluatiing options for #{line}"
                            nil
                          rescue Exception => e
                            failures << "#{e.class} #{e.message} when evaluating options for \"#{line}\"\n#{e.backtrace.first}"
                            nil
                          end
                        end.compact
        Formatter.alert(file, replacements, failures) unless (replacements.nil? || replacements.empty?) && failures.empty?

        update_file(file, replacements) unless replacements.empty?
      end
    end

    def update_file(file, line_replacements)
      contents = File.read(file)
      line_replacements.each do |new_line|
        contents.gsub!(new_line[0], new_line[1])
      end

      File.open(file, 'w') do |f|
        f.puts contents
      end
    end

  protected

    def verify_line(line)
      true
    end

  end
end
