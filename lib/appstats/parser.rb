
module Appstats
  class Parser

    attr_reader :raw_rules, :rules, :repeating, :raw_tokenize, :results, :raw_results,
                :tokenize, :tokenize_no_spaces, :tokenize_regex, :tokenize_regex_no_spaces,  
                :constants, :constants_no_spaces

    def initialize(data = {})
      @raw_rules = data[:rules]
      @raw_tokenize = data[:tokenize]
      @repeating = data[:repeating] == true
      @results = {}
      @raw_results = []
      update_tokens
      update_rules
    end

    def parse(input)
      @results = {}
      @raw_results = []
      return false if input.nil?
      return false if @rules.size == 0

      @rule_index = 0
      @max_rule_index = @rules.size - 1
      @previous_text_so_far = input.strip
      @text_so_far = @previous_text_so_far
      @remaining_constants = @constants.dup
      @remaining_constants_no_spaces = @constants_no_spaces.dup
      
      while !@text_so_far.blank?
        process_constant_if_present
        break if @rule_index > @max_rule_index && !@repeating
        @rule_index = 0 if @rule_index > @max_rule_index

        rule = @rules[@rule_index]
        @rule_index += 1
        
        if rule.kind_of?(Hash)
          if rule[:stop] == :constant
            was_found = false
            @remaining_constants.each_with_index do |k,index|
              p = parse_word(@text_so_far,k,true)
              if p[0].nil?
                unset_rules_until(k)
              else
                (index-1).downto(0) do |i|
                  @remaining_constants_no_spaces.delete_at(i)
                  @remaining_constants.delete_at(i)
                end
                add_results(rule[:rule],p[0])
                @text_so_far = p[1]
                was_found = true
                break
              end
            end
            unless was_found
              add_results(rule[:rule],@text_so_far)
              @text_so_far = nil
            end
          else
            p = parse_word(@text_so_far,rule[:stop],false)
            add_results(rule[:rule],p[0]) unless p[0].nil?
            @text_so_far = p[1]
          end
        end
        break if @previous_text_so_far == @text_so_far
        @previous_text_so_far = @text_so_far
      end
      remove_tokens_at_start(@text_so_far)
      unset_rules_until(nil)
      true
    end
    
    def self.alpha?(raw_input)
      return false if raw_input.nil?
      !raw_input.match(/^[A-Za-z]+$/i).nil?
    end
    
    def self.parse_constant(current_text,constant)
      answer = [nil,nil]
      return answer if current_text.blank? || constant.nil?
      current_text.strip!
      
      remaining_text_index = -1
      if alpha?(constant)
        m = current_text.match(/^(#{constant})(\s|$)(.*)$/im)  
        remaining_text_index = 3
      else
        m = current_text.match(/^(#{constant})(.*)$/im)  
        remaining_text_index = 2
      end
      
      answer[0] = m[1] unless m.nil?
      answer[1] = m.nil? ? current_text : m[remaining_text_index]
      clean_parsed_word(answer)
    end
    
    def self.merge_regex_filter(inputs = [])
      inputs.collect! { |x| x unless x.blank? }.compact!
      return "" if inputs.empty?
      "(#{inputs.join('|')})"
    end
    
    def parse_word(current_text,stop_on,strict = false)
      answer = [nil,nil]
      return answer if current_text.blank? || stop_on.nil?
      current_text.strip!

      current_text = remove_tokens_at_start(current_text)
      
      if stop_on == :end
        filter = Parser.merge_regex_filter([nil,@tokenize_regex])
        m = current_text.match(/^(.*?)(#{filter}.*)$/im)
        if m.nil? || m[1].blank?
          answer[0] = current_text
        else
          answer[0] = m[1]
          answer[1] = m[2]
        end
      elsif stop_on == :space
        filter = Parser.merge_regex_filter(['\s',@tokenize_regex,remaining_constants_regex])
        m = current_text.match(/^(.*?)(#{filter}.*)$/im)
        if m.nil?
          answer[0] = current_text
        else
          answer[0] = m[1]
          answer[1] = m[2]
        end
      else
        filter = Parser.merge_regex_filter([stop_on,@tokenize_regex,remaining_constants_regex])
        m = current_text.match(/^(.*?)(#{filter}.*)$/im)
        if strict
          answer[0] = m[1] unless m.nil?
          answer[1] = m.nil? ? current_text : m[2]
        else
          answer[0] = m.nil? ? current_text : m[1]
          answer[1] = m[2] unless m.nil?
        end
      end
      answer = Parser.clean_parsed_word(answer)
      answer
    end
    
    private
      
      def self.clean_parsed_word(answer)
        answer[0].strip! unless answer[0].nil?
        answer[1].strip! unless answer[1].nil?
        answer[0] = nil if answer[0].blank?
        answer[1] = nil if answer[1].blank?
        answer 
      end
      
      def process_constant_if_present
        while process_tokens_if_present; end
        to_delete = nil
        @remaining_constants_no_spaces.each do |k|
          p = Parser.parse_constant(@text_so_far,k)
          next if p[0].nil?
          to_delete = k
          unset_rules_until(k)
          add_constant(p[0])
          @text_so_far = p[1]
        end
        @remaining_constants.delete(to_delete) unless to_delete.nil?
        @remaining_constants_no_spaces.delete(to_delete) unless to_delete.nil?
      end
      
      def process_tokens_if_present
        found = false
        @tokenize.each do |k|
          p = Parser.parse_constant(@text_so_far,k)
          next if p[0].nil?
          add_constant(p[0])
          @text_so_far = p[1]
          found = true
        end
        found
      end
      
      def unset_rules_until(k)
        @rules[@rule_index..-1].each do |rule|
          @rule_index += 1
          break if rule.eql?(k)
          add_results(rule[:rule],nil) if rule.kind_of?(Hash)
        end
      end
      
      def update_tokens
        @tokenize = []
        @tokenize_no_spaces = []
        @tokenize_regex = nil
        @tokenize_regex_no_spaces = nil
        return if @raw_tokenize.blank?
        is_multi_work_token = false
        current_token = nil
        @raw_tokenize.split(" ").each do |token|

          start_token = token.starts_with?("'")
          end_token = is_multi_work_token and token.ends_with?("'")
          mid_token = !start_token && !end_token && is_multi_work_token
          add_token = false
          
          if start_token
            current_token = token.upcase[1..-1]
            is_multi_work_token = true
          elsif mid_token
            current_token = "#{current_token}#{token.upcase}"
          elsif end_token
            current_token = "#{current_token}#{token.upcase.chop}"
            is_multi_work_token = false
            add_token = true
          else
            current_token = token.upcase
            add_token = true
          end

          current_token.gsub!("(",'\(')
          current_token.gsub!(")",'\)')
          current_token.gsub!("|",'\|')
          
          if add_token
            @tokenize_no_spaces<< current_token
            current_token = "\\s+#{current_token}(\\s|$)" unless current_token.match(/.*[a-z].*/i).nil?  
            @tokenize<< current_token
          else is_multi_work_token
             current_token = "#{current_token}\\s+"
          end
        end
        @tokenize_regex_no_spaces = @tokenize_no_spaces.join("|")
        @tokenize_regex = @tokenize.join("|")
      end
      
      def update_rules
        @rules = []
        @constants = []
        @constants_no_spaces = []
        current_rule = nil
        return if @raw_rules.blank?
        @raw_rules.split(" ").each do |rule|
          current_rule_no_spaces = nil  

          if rule.starts_with?(":") && rule.size > 1
            current_rule_no_spaces = { :rule => rule[1..-1].to_sym, :stop => :end }
            previous_stop_on = :space
          else
            current_rule = rule.upcase
            current_rule_no_spaces = current_rule
            @constants_no_spaces<< current_rule_no_spaces
            current_rule = "\\s+#{current_rule}(\\s|$)" unless current_rule.match(/.*[a-z].*/i).nil?
            @constants<< current_rule
            previous_stop_on = :constant
          end

          if @rules.last.kind_of?(Hash)
            @rules.last[:stop] = previous_stop_on   
          end
          
          @rules<< current_rule_no_spaces
        end
      end

      def add_constant(value)
        @raw_results<< value
      end

      def add_results(rule_name,value)
        @raw_results<< { rule_name => value }
        @results[rule_name] = value
      end

      def remove_tokens_at_start(current_text)
        return current_text if current_text.blank?
        current_text.blank?
        loop do
          break if @tokenize_regex.blank?
          m = current_text.match(/^(#{@tokenize_regex_no_spaces})(.*)$/im)
          break if m.nil? || m[1].blank?
          constant = m[1]
          current_text = m[2]
          if (!current_text.match(/^[^\s]/).nil? && !constant.match(/^[a-zA-Z]*$/).nil?)
            current_text = m[0]
            break
          end
          add_constant(constant)
          current_text.strip! unless current_text.nil?
        end
        current_text
      end
      
      def remaining_constants_regex
        return "" if @remaining_constants.nil?
        @remaining_constants.join("|")
      end
      
  end
end