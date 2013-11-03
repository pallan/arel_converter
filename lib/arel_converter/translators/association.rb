module ArelConverter
  module Translator
    class Association < Base

      def process_call(exp)
        @association_type ||= exp[1]
        super
      end

      def process_hash(exp) # :nodoc:
        @options = []
        scopes = [:hash]
        
        until exp.empty?
          lhs = exp.shift
          rhs = exp.shift
          if option_nodes.include?(lhs)
            lhs = process(lhs)
            t   = rhs.first
            rhs = process rhs
            rhs = "(#{rhs})" unless [:lit, :str, :true, :false].include? t # TODO: verify better!

            @options << format_for_hash(lhs,rhs)
          else
            scopes += [lhs, rhs]
          end
        end
        @options = nil if @options.empty?
        @scopes  = Options.translate(Sexp.from_array(scopes)) unless scopes == [:hash]
        return ''
      end

      def post_processing(new_scope)
        new_scope.gsub!(/has_(many|one|and_belongs_to_many)\((.*)\)$/, 'has_\1 \2')
        new_scope.gsub!(/belongs_to\((.*)\)$/, 'belongs_to \1')
        [new_scope, format_scope(@scopes), @options].compact.join(', ')
      end

    protected

      def format_scope(scopes)
        return nil if scopes.nil? || scopes.empty?
        "-> { #{scopes.strip} }" unless scopes.nil? || scopes.empty?
      end

      def option_nodes
        [
          s(:lit, :counter_cache),
          s(:lit, :polymorphic),
          s(:lit, :touch),
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
          s(:lit, :validate),
          s(:lit, :association_foreign_key),
          s(:lit, :autosave),
          s(:lit, :join_table)
        ]
      end

    end
  end
end

