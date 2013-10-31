module ArelConverter
  module Translator
    class Finder < Ruby2Ruby

      def self.translate(klass_or_str, method = nil)
        sexp = klass_or_str.is_a?(String) ? self.parse(klass_or_str) : klass_or_str
        #puts sexp.inspect
        processor = self.new
        new_scope = processor.process(sexp)
        processor.post_processing(new_scope)
      end

      def self.parse(code)
        RubyParser.new.process(code)
      end

      def process_call(exp)
        case exp[1]
        when :all, :first
          parent = process(exp.shift)
          method = (exp.shift == :first ? 'first' : 'all')
          unless exp.empty?
            options = Options.translate(exp.shift).strip
            method = nil if method == 'all'
          end
          [parent, options, method].compact.join('.')
        when :find
          parent = process(exp.shift)
          exp.shift # Replacing so we can discard the :find definition
          first_or_all = process(exp.shift) == ':first' ? 'first' : nil
          options = Options.translate(exp.shift).strip unless exp.empty?
          [parent, options, first_or_all].compact.join('.')
        else
          super
        end
      end

      def post_processing(new_scope)
        new_scope
      end

    end
  end
end
