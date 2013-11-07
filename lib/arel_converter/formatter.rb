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
        Formatter.basic_alert(title, culprits)
      else
        Formatter.color_alert(title, culprits)
      end
    end

    # Show an upgrade alert to the user.  If we're on Windows, we can't
    # use terminal colors, hence this method.
    def self.basic_alert(title, culprits)
      puts "** " + title
      Array(culprits).each do |c|
        puts c.valid? ? "  FROM: #{c.old_content}\n    TO: #{c.new_content}\n" :
                        "** ERROR - #{c.error}"
      end
      puts
    end

    # Show a colorful alert to the user
    def self.color_alert(file, culprits )
      puts "#{RED}#{BOLD}#{file}#{CLEAR}"
      Array(culprits).each do |c|
        puts c.valid? ? "#{YELLOW}  FROM: #{c.old_content}\n    TO: #{c.new_content}\n" :
                        "#{CYAN}#{BOLD}  - #{c.error}#{CLEAR}"

      end
    ensure
      puts "#{CLEAR}"
    end

  end
end

