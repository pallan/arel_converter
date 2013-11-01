module ArelConverter
  module Translator
    class Base < Ruby2Ruby

      LINE_LENGTH = 1_000

      def self.translate(klass_or_str, method = nil)
        sexp = klass_or_str.is_a?(String) ? self.parse(klass_or_str) : klass_or_str
        processor = self.new
        source = processor.process(sexp)
        processor.post_processing(source)
      end

      def self.parse(code)
        RubyParser.new.process(code)
      end

      def logger
        @logger ||= setup_logger
      end

      def post_processing(source)
        source
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
