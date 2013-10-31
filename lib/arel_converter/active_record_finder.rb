module ArelConverter
  class ActiveRecordFinder < Base

    def run
      Dir[File.join(@path, 'app/**/*.rb')].each do |file|
        begin
          parse_file(file) unless File.directory?(file)
        rescue => e
          Formatter.alert(file, [], e.message)
        end
      end
    end

    def parse_file(file)
      raw_ar_finders = ''
      ["find(:all", "find(:first", "find.*:conditions =>", '\.all(', '\.first('].each do |v|
        raw_ar_finders += `grep -r '#{v}' #{file}`
      end

      ar_finders = raw_ar_finders.split("\n")

      unless ar_finders.empty?

        failures = []

        new_ar_finders =  ar_finders.map do |ar_finder|
                            ar_finder = ar_finder.gsub("#{file}:",'').strip
                            begin
                              new_line = process_line(ar_finder)
                              [ar_finder,new_line]
                            rescue SyntaxError => e
                              failures << "SyntaxError when evaluatiing options for #{ar_finder}"
                              nil
                            rescue => e
                              failures << "#{e.class} #{e.message} when evaluatiing options for \"#{ar_finder}\"\n#{e.backtrace.first}"
                              nil
                            end
                          end.compact
        Formatter.alert(file, new_ar_finders, failures) unless (new_ar_finders.nil? || new_ar_finders.empty?) && failures.empty?

        #update_file(file, new_ar_finders) #unless new_ar_finders.empty?
      end
    end

    def process_line(finder)
      new_finder = ArelConverter::Translator::Finder.translate(finder)
    end

  protected
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
  
  end

end
