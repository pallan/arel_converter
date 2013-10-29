module ArelConverter
  class Scope < Base

    def run
      Dir[File.join(@path, 'app/models/**/*')].each do |file|
        #['/Users/pallan/Programming/rails_apps/panda/core/app/models/vendor_purchase_order.rb'].each do |file|
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
        scope = scope.strip.gsub("#{file}:",'')
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
    end

    def process_line(line)
      case
      when line.include?('lambda')
        convert_lambda(line)
      else
        convert_arguments(line)
      end
    end

    def convert_lambda(line)
      full_method, arguments = extract_method(line)

      # if we can't parse out the lambda then raise
      raise RuntimeError, "can't parse due to unmatched braces" if full_method.nil?

      clean_arguments = arguments.gsub(/\|.*?\|/, '').strip
      line.gsub(clean_arguments, ArelConverter::Converter.translate(clean_arguments))
    end

    def convert_arguments(line)
      options = %Q{#{line.gsub(/^.*?,/, '').strip}}
      clean_arguments = %Q{{#{options}}} unless options =~ /^\{.*\}$/
      converted = "-> { #{ArelConverter::Converter.translate(clean_arguments)} }"
      line.gsub(options, converted)
    end

    def extract_method(line)
      i = line.index('lambda')
      braces = 0
      full_method = ''
      args = ''

      while i < line.length
        char = line[i].chr
        full_method << char
        args << char if braces > 0
        case char
        when '{'
          braces += 1
        when '}'
          braces -= 1
          if braces == 0
            args.chop!
            break
          end
        end
        i += 1
      end
      braces == 0 ? [full_method, args] : [nil,nil]
    end

  end

end
