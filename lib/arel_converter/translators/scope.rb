module ArelConverter
  module Translator
    class Scope < Base

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
