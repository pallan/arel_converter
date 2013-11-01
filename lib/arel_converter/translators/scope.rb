module ArelConverter
  module Translator
    class Scope < Ruby2Ruby

      def self.translate(klass_or_str, method = nil)
        sexp = klass_or_str.is_a?(String) ? self.parse(klass_or_str) : klass_or_str
        processor = self.new
        new_scope = processor.process(sexp)
        processor.post_processing(new_scope)
      end

      def self.parse(code)
        RubyParser.new.process(code)
      end

      def process_call(exp)
        @options = Options.translate(exp.pop) if exp[1] == :scope
        super
      end

      def post_processing(new_scope)
        new_scope.gsub!(/scope\((.*)\)$/, 'scope \1')
        new_scope += format_options(@options)
      end

    protected

      def format_options(options)
        return if options.nil? || options.empty?
        ", " + (options.include?('lambda') ? options : "-> { #{options.strip} }")
      end

    end
  end
end
