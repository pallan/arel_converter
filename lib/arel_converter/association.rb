module ArelConverter
  class Association < Base

    def run
      Dir[File.join(@path, 'app/models/**/*')].each do |file|
        begin
          parse_file(file)
        rescue => e
          Formatter.alert(file, [], e.message)
        end
      end
    end

    def parse_file(file)
      raw = `grep -H -r "^\s*has_(many|one)" #{file}`

      return if raw == ''

      failures = []

      matches = raw.split("\n")
      replacements =  matches.map do |match|
                        match = match.gsub("#{file}:",'').strip
                        next unless verify_line(line)
                        begin
                          [match, process_line(match)]
                        rescue SyntaxError => e
                          failures << "SyntaxError when evaluatiing options for #{match}"
                          nil
                        rescue => e
                          failures << "#{e.class} #{e.message} when evaluatiing options for \"#{match}\""
                          nil
                        end
                      end.compact

      Formatter.alert(file, new_matches, failures) unless (new_matches.nil? || new_matches.empty?) && failures.empty?

      # update_file(file, new_matches)
    end

    def process_line(line)
      new_match = ArelConverter::Translator::Association.translate(line)
      puts new_match
      new_match.gsub(/has_many\((.*)\)$/, 'has_many \1')
    end

    def update_file(file, new_matches)
      new_lines = []
      f = File.new(file)
      f.each do |line|
        new_matches.each do |match|
          line.gsub!(match[0], match[1]) if line.include?(match[0])
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
      parser = RubyParser.new
      sexp   = parser.process(line)
      sexp.shift == :call
    end

  end

end

