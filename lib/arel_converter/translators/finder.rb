module ArelConverter
  module Translator
    class Finder < Base

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

    end
  end
end
