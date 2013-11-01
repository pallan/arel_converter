module ArelConverter
  class Base
    def initialize(path = './')
      @path       = path
      @parser     = RubyParser.new
      @translator = Ruby2Ruby.new
    end

    def run
      Dir[File.join(@path, 'app/**/*.rb')].each do |file|
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

        #update_file(file, new_ar_finders) #unless new_ar_finders.empty?
      end
    end

    def update_file(file, line_replacements)
      new_lines = []
      f = File.new(file)
      f.each do |line|
        line_replacements.each do |new_line|
          line.gsub!(new_line[0], new_line[1]) if line.include?(new_line[0])
        end
        new_lines << line.chomp
      end
      f.close

      File.open(file, 'w') do |f|
        f.puts new_lines.join("\n")
      end
    end

  protected

    def verify_line(line)
      true
    end

  end
end
