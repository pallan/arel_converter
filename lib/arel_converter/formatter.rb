module ArelConverter
  class Formatter

    # Terminal colors, borrowed from Thor
    CLEAR      = "\e[0m"
    BOLD       = "\e[1m"
    RED        = "\e[31m"
    YELLOW     = "\e[33m"
    CYAN       = "\e[36m"
    WHITE      = "\e[37m"

    # Show an upgrade alert to the user
    def self.alert(title, culprits, errors=nil)
      if RbConfig::CONFIG['host_os'].downcase =~ /mswin|windows|mingw/
        Formatter.basic_alert(title, culprits, errors)
      else
        Formatter.color_alert(title, culprits, errors)
      end
    end

    # Show an upgrade alert to the user.  If we're on Windows, we can't
    # use terminal colors, hence this method.
    def self.basic_alert(title, culprits, errors=nil)
      puts "** " + title
      puts "\t** " + error if error
      Array(culprits).each do |c|
        puts "\t- #{c}"
      end
      puts
    end

    # Show a colorful alert to the user
    def self.color_alert(file, culprits, errors=nil)
      puts "#{RED}#{BOLD}#{file}#{CLEAR}"
      Array(errors).each do |error|
        puts "#{CYAN}#{BOLD}  - #{error}#{CLEAR}"
      end
      Array(culprits).each do |c|
        puts c.is_a?(Array) ? "#{YELLOW}  FROM: #{c[0]}\n    TO: #{c[1]}\n" : "#{YELLOW}  #{c[0]}\n"
      end
    ensure
      puts "#{CLEAR}"
    end

  end
end

