
module Appstats
  class Parser

    attr_reader :rules, :raw_rules, :results, :raw_results, :constants

    def initialize(data = {})
      @raw_rules = data[:rules]
      @results = nil
      @raw_results = nil
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
      
      while !@text_so_far.blank?
        process_constant_if_present
        break if @rule_index > @max_rule_index
        rule = @rules[@rule_index]
        @rule_index += 1
        
        if rule.kind_of?(Hash)
          if rule[:stop] == :constant
            was_found = false
            @remaining_constants.each_with_index do |k,index|
              p = Parser.parse_word(@text_so_far,k,true)
              if p[0].nil?
                unset_rules_until(k)
              else
                (index-1).downto(0) do |i|
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
            p = Parser.parse_word(@text_so_far,rule[:stop],false)
            add_results(rule[:rule],p[0])
            @text_so_far = p[1]
          end
          
        end
        return false if @previous_text_so_far == @text_so_far
        @previous_text_so_far = @text_so_far
      end
      unset_rules_until(nil)
      true
    end
    
    def self.parse_constant(current_text,constant)
      answer = [nil,nil]
      return answer if current_text.blank? || constant.nil?
      current_text.strip!
      m = current_text.match(/^(#{constant})(.*)$/i)
      answer[0] = m[1] unless m.nil?
      answer[1] = m.nil? ? current_text : m[2]
      clean_parsed_word(answer)
    end
    
    def self.parse_word(current_text,stop_on,strict = false)
      answer = [nil,nil]
      return answer if current_text.blank? || stop_on.nil?
      current_text.strip!
      if stop_on == :end
        answer[0] = current_text
      elsif stop_on == :space
        m = current_text.match(/^([^\s]*)\s*(.*)$/)
        answer[0] = m[1]
        answer[1] = m[2]
      else
        m = current_text.match(/^(.*)\s*((#{stop_on}).*)$/i)
        if strict
          answer[0] = m[1] unless m.nil?
          answer[1] = m.nil? ? current_text : m[2]
        else
          answer[0] = m.nil? ? current_text : m[1]
          answer[1] = m[2] unless m.nil?
        end
      end
      clean_parsed_word(answer)
    end
    
    private
      
      def self.clean_parsed_word(answer)
        answer[0] = answer[0].strip unless answer[0].nil?
        answer[1] = answer[1].strip unless answer[1].nil?
        answer[0] = nil if answer[0].blank?
        answer[1] = nil if answer[1].blank?
        answer 
      end
      
      def process_constant_if_present
        to_delete = nil
        @remaining_constants.each do |k|
          p = Parser.parse_constant(@text_so_far,k)
          next if p[0].nil?
          to_delete = k
          unset_rules_until(k)
          @text_so_far = p[1]
        end
        @remaining_constants.delete(to_delete) unless to_delete.nil?
      end
      
      def unset_rules_until(k)
        @rules[@rule_index..-1].each do |rule|
          @rule_index += 1
          break if rule.eql?(k)
          add_results(rule[:rule],nil) if rule.kind_of?(Hash)
        end
      end
      
      def update_rules
        @rules = []
        @constants = []
        current_rule = nil
        return if @raw_rules.blank?
        @raw_rules.split(" ").each do |rule|

          if rule.starts_with?(":") && rule.size > 1
            current_rule = { :rule => rule[1..-1].to_sym, :stop => :end }
            previous_stop_on = :space
          else
            current_rule = rule.upcase
            constants<< current_rule
            previous_stop_on = :constant
          end

          if @rules.last.kind_of?(Hash)
            @rules.last[:stop] = previous_stop_on   
          end
          
          @rules<< current_rule
        end
      end

      def add_results(rule_name,value)
        @raw_results<< { rule_name => value }
        @results[rule_name] = value
      end

  end
end