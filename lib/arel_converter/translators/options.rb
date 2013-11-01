module ArelConverter
  module Translator
    class Options < Base

      LINE_LENGTH = 1_000

      def logger
        @logger ||= setup_logger
      end

      def process_hash(exp) # :nodoc:
        @depth ||= 0
        @depth += 1

        result = []

        until exp.empty?
          lhs = process(exp.shift)
          rhs = process(exp.shift)
          result << (@depth > 1 ? format_for_hash(lhs,rhs) : hash_to_arel(lhs,rhs))
        end

        @depth -= 1

        case @depth
        when 0
          result.empty? ? "" : result.join('.')
        else
          result.empty? ? "{}" : "{ #{result.join(', ')} }"
        end
      end

      def process_call(exp)
        # puts "#{@depth} #{exp.inspect}"
        if valid_arel_method?(exp[1])
          @depth ||= 0
          @depth += 1
        end
        super
      end

      def hash_to_arel(lhs, rhs)
        key = lhs.sub(':','')
        case key
        when 'conditions'
          key = 'where'
        when 'include'
          key = 'includes'
        when 'none', 'reverse_order'
          return key
        end
        rhs = rhs.gsub(/\A\[(.*)\]\z/, '\1').gsub(/\A\{(.*)\}\z/, '\1')
        "#{key}(#{rhs})"
      end

      # Have to override super class to get the overridden LINE_LENGTH
      # constant to work
      def process_iter(exp) # :nodoc:
        iter = process exp.shift
        args = exp.shift
        body = exp.empty? ? nil : process(exp.shift)

        args = case args
               when 0 then
                 " ||"
               else
                 a = process(args)[1..-2]
                 a = " |#{a}|" unless a.empty?
                 a
               end

        b, e = if iter == "END" then
                 [ "{", "}" ]
               else
                 [ "do", "end" ]
               end

        iter.sub!(/\(\)$/, '')

        # REFACTOR: ugh
        result = []
        result << "#{iter} {"
        result << args
        if body then
          result << " #{body.strip} "
        else
          result << ' '
        end
        result << "}"
        result = result.join
        return result if result !~ /\n/ and result.size < LINE_LENGTH

        result = []
        result << "#{iter} #{b}"
        result << args
        result << "\n"
        if body then
          result << indent(body.strip)
          result << "\n"
        end
        result << e
        result.join
      end

      def process_if(exp) # :nodoc:
        expand = Ruby2Ruby::ASSIGN_NODES.include? exp.first.first
        c = process exp.shift
        t = process exp.shift
        f = process exp.shift

        c = "(#{c.chomp})" if c =~ /\n/

        if t then
          unless expand then
            if f then
              r = "#{c} ? (#{t}) : (#{f})"
              r = nil if r =~ /return/ # HACK - need contextual awareness or something
            else
              r = "#{t} if #{c}"
            end
            return r if r and (@indent+r).size < LINE_LENGTH and r !~ /\n/
          end

          r = "if #{c} then\n#{indent(t)}\n"
          r << "else\n#{indent(f)}\n" if f
          r << "end"

          r
        elsif f
          unless expand then
            r = "#{f} unless #{c}"
            return r if (@indent+r).size < LINE_LENGTH and r !~ /\n/
          end
          "unless #{c} then\n#{indent(f)}\nend"
        else
          # empty if statement, just do it in case of side effects from condition
          "if #{c} then\n#{indent '# do nothing'}\nend"
        end
      end

      private

      def valid_arel_method?(m)
        %w[bind
          create_with
          eager_load
          extending
          from
          group
          having
          includes
          joins
          limit
          lock
          none
          offset
          order
          preload
          readonly
          references
          reorder
          reverse_order
          select
          distinct
          uniq
          where].include?(m.to_s)
      end

    end

  end
end
