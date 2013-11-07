module ArelConverter
  class Scope < Base

    def grep_matches_in_file(file)
      raw_named_scopes = `grep -h -r "^\s*scope\s*:" #{file}`
      raw_named_scopes.split("\n")
    end

    def process_line(line)
      new_scope = ArelConverter::Translator::Scope.translate(line)
      new_scope.gsub(/scope\((.*)\)$/, 'scope \1')
    end

    def verify_line(line)
      parser = RubyParser.new
      sexp   = parser.process(line)
      sexp[0] == :call && sexp[2] == :scope
    end

  end

end
