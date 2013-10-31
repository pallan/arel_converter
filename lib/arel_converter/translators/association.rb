module ArelConverter
  module Translator
    class Association < Ruby2Ruby

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
        if exp.size > 3
          old_options = exp.pop
          old_options.shift
          new_options = [:hash]
          new_scopes  = [:hash]
          old_options.each_slice(2) do |key,value|
            if option_nodes.include?(key)
              new_options << key
              new_options << value
            else
              new_scopes << key
              new_scopes << value
            end
          end
          @scopes  = Options.translate(Sexp.from_array(new_scopes)).strip if exp[1] == :has_many
          @options = process(Sexp.from_array(new_options)) unless new_options == [:hash]
        end
        super
      end

      def process_hash(exp) # :nodoc:
        result = []

        until exp.empty?
          lhs = process(exp.shift)
          rhs = exp.shift
          t = rhs.first
          rhs = process rhs
          rhs = "(#{rhs})" unless [:lit, :str].include? t # TODO: verify better!

          result << "#{lhs.sub(':','')}: #{rhs}"
        end

        return result.empty? ? "{}" : "#{result.join(', ')}"
      end

      def post_processing(new_scope)
        new_scope.gsub!(/has_many\((.*)\)$/, 'has_many \1')
        @scopes = nil if @scopes.nil? || @scopes.empty?
        [new_scope, @scopes, @options].compact.join(', ')
      end

      def option_nodes
        [
          s(:lit, :as),
          s(:lit, :autosave),
          s(:lit, :class_name),
          s(:lit, :dependent),
          s(:lit, :foreign_key),
          s(:lit, :inverse_of),
          s(:lit, :primary_key),
          s(:lit, :source),
          s(:lit, :source_type),
          s(:lit, :through),
          s(:lit, :validate)
        ]
      end

    end
  end
end

