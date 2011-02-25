
module Appstats
  class Logger
    
    def self.reset
      @@filename_template = nil
      @@default_contexts = nil
    end
    
    def self.default_contexts
      @@default_contexts ||= {}
      @@default_contexts
    end
    
    def self.filename_template=(value)
      @@filename_template = value
    end
    
    def self.filename_template
      @@filename_template ||= 'appstats'
      @@filename_template
    end
    
    def self.filename
      "#{filename_template}_#{today}.log"
    end
    
    def self.raw_write(text)
      File.open(filename, "a") { |f| f.write("#{text}\n") }
    end
    
    def self.raw_read
      return [] unless File.exists?(filename)
      File.open(filename,"r").readlines.collect { |line| line.strip }
    end
    
    def self.entry_to_s(action,contexts = {})
      contexts = contexts.merge(default_contexts)
      section_delimiter, assign_delimiter, newline_delimiter = determine_delimiters(contexts.merge(:action => action))
      answer = "#{Appstats::VERSION} setup[#{section_delimiter},#{assign_delimiter},#{newline_delimiter}] "
      answer += "#{now} action#{assign_delimiter}#{format_input(action,newline_delimiter)}"
      contexts.keys.sort.each do |key|
        answer += " #{section_delimiter} #{key}#{assign_delimiter}#{format_input(contexts[key],newline_delimiter)}"
      end
      answer
    end
    
    def self.entry_to_hash(action_and_contexts)
      hash = { :action => "UNKNOWN_ACTION", :raw_input => action_and_contexts }
      return hash if action_and_contexts.nil?
      setup = action_and_contexts.match(/(.*?) setup\[(.*?),(.*?),(.*?)\] (.*? .*?) (.*)/)
      return hash if setup.nil?
      hash.delete(:action)
      hash.delete(:raw_input)
      full, version, section_delimiter, assign_delimiter, newline_delimiter, timestamp, input = setup.to_a
      
      hash[:timestamp] = timestamp
      input.split(section_delimiter).each do |pair|
        key,value = pair.strip.split(assign_delimiter)
        key_symbol = key.to_sym
        if hash[key_symbol].nil?
          hash[key.to_sym] = value  
        elsif hash[key_symbol].kind_of?(String)
          hash[key.to_sym] = [ hash[key_symbol], value ]
        else
          all_values = hash[key_symbol]
          all_values<< value
          hash[key.to_sym] = all_values
        end
      end
      hash[:action] = "UNKNOWN_ACTION" if hash[:action].nil?
      hash
    end
    
    def self.entry(action,contexts = {})
      raw_write(entry_to_s(action,contexts))
    end
    
    def self.exception_entry(error,contexts = {})
      raw_write(entry_to_s("appstats-exception",contexts.merge({:error => error.message})))
    end
    
    def self.today
      "#{Time.now.strftime('%Y-%m-%d')}"
    end
    
    def self.now
      "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    end
    
    private 
    
      def self.determine_delimiters(lookups)
        section_delimiter = ":"
        assign_delimiter = "="
        newline_delimiter = "-n"

        lookups.each do |pair|
          name = pair[1]
          next unless name.respond_to?("include?")
          while(name.include?(section_delimiter))
            section_delimiter += ":"
          end
          while(name.include?(assign_delimiter))
            assign_delimiter += "="
          end
          while(name.include?(newline_delimiter))
            newline_delimiter = "-#{newline_delimiter}"
          end
        end
        [section_delimiter,assign_delimiter,newline_delimiter]
      end
      
      def self.format_input(raw_input,newline_delimiter)
        return raw_input if raw_input.nil?
        return raw_input unless raw_input.kind_of?(String)
        raw_input.gsub(/\n/,newline_delimiter)
      end
    
  end
end



