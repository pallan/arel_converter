module ArelConverter
  class Association < Base

    def grep_matches_in_file(file)
      raw_named_scopes = `grep -hr "^\s*has_\\|belongs_to" #{file}`
      raw_named_scopes.split("\n")
    end

    def process_line(line)
      ArelConverter::Translator::Association.translate(line)
    end

  protected

    def verify_line(line)
      parser = RubyParser.new
      sexp   = parser.process(line)
      sexp.shift == :call
    end

  end

end

