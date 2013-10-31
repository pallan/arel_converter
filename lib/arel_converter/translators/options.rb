module ArelConverter
  module Translator
    class Options < Ruby2Ruby

      LINE_LENGTH = 1_000

      def self.translate(klass_or_str, method = nil)
        # puts "OPENING EXPRESSION: #{klass_or_str}"
        sexp = klass_or_str.is_a?(String) ? self.parse(klass_or_str) : klass_or_str
        self.new.process(sexp).strip
      end

      def self.parse(code)
        RubyParser.new.process(code)
      end

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
          result << (@depth > 1 ? "#{lhs.sub(':','')}: #{rhs}" : hash_to_arel(lhs,rhs))
        end

        @depth -= 1

        if @depth > 0
          result.empty? ? "{}" : " #{result.join(', ')} "
        else
          result.empty? ? "" : "  #{result.join('.')}  "
        end
      end

      def hash_to_arel(lhs, rhs)
        case lhs
        when ':conditions'
          key = 'where'
        when ':include'
          key = 'includes'
        else
          key = lhs.sub(':','')
        end
        logger.debug("KEY: #{key}(#{rhs})")

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

      private

      def setup_logger(log_level = :info)
        logging = Logging::Logger[self]
        layout = Logging::Layouts::Pattern.new(:pattern => "[%d, %c, %5l] %m\n")

        stdout = Logging::Appenders.stdout
        stdout.level = log_level

        #file = Logging::Appenders::File.new("./log/converters.log")
        #file.layout = layout
        #file.level = :debug

        logging.add_appenders(stdout)
        logging
      end
    end

  end
end
