module ArelConverter
  class ActiveRecordFinder < Base

    def grep_matches_in_file(file)
      raw_ar_finders = ''
      ["find(:all", "find(:first", "find.*:conditions =>", '\.all(', '\.first('].each do |v|
        raw_ar_finders += `grep -hr '#{v}' #{file}`
      end

      raw_ar_finders.split("\n")
    end

    def process_line(finder)
      ArelConverter::Translator::Finder.translate(finder)
    end

  end

end
