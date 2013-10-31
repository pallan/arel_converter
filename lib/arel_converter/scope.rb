module ArelConverter
  class Scope < Base

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
      raw_named_scopes = `grep -H -r "^\s*scope" #{file}`

      return if raw_named_scopes == ''

      failures = []

      named_scopes = raw_named_scopes.split("\n")
      new_scopes =  named_scopes.map do |scope|
                      scope = scope.gsub("#{file}:",'').strip
                      next unless verify_line(line)
                      begin
                        [scope, process_line(scope)]
                      rescue SyntaxError => e
                        failures << "SyntaxError when evaluatiing options for #{scope}"
                        nil
                      rescue => e
                        failures << "#{e.class} #{e.message} when evaluatiing options for \"#{scope}\""
                        nil
                      end
                    end.compact

      Formatter.alert(file, new_scopes, failures) unless (new_scopes.nil? || new_scopes.empty?) && failures.empty?

      # update_file(file, new_scopes)
    end

    def process_line(line)
      new_scope = ArelConverter::Translator::Scope.translate(line)
      new_scope.gsub(/scope\((.*)\)$/, 'scope \1')
    end

    def update_file(file, new_scopes)
      new_lines = []
      f = File.new(file)
      f.each do |line|
        new_scopes.each do |scope|
          line.gsub!(scope[0], scope[1]) if line.include?(scope[0])
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
