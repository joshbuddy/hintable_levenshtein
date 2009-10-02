class HintableLevenshtein
  class RuleSet
    
    include Comparable
    
    attr_reader :rules, :score
    def initialize(score, *rules)
      @rules = rules
      @score = score
    end
  
    def to_s
      "#{score} -> #{rules.collect{|r| r.to_s} * ', '}"
    end
  
    def match?(events)
      return if events.size != rules.size
      events.each_with_index do |e, idx|
        return unless rules[idx].match?(e)
      end
      true
    end
  end

  class Rule
    def self.delete(matcher = nil)
      new(:delete, matcher)
    end
    
    def self.insert(matcher = nil)
      new(:insert, matcher)
    end
  
    def self.substitute(matcher = {})
      new(:substitute, matcher)
    end
  
    attr_reader :type, :matcher
  
    def match?(event)
      if event.type == type
        case type
        when :delete, :insert
          ret = case matcher
          when nil
            true
          when String
            !matcher.index(event.chr).nil?
          when Array
            matcher.include?(event.chr)
          else
            matcher === event.chr
          end
        when :substitute
          matcher.empty? || matcher[event.from] == event.to || matcher[event.to] == event.from
        end
      end
    end
  
    def to_s
      "#{type} #{matcher.inspect}"
    end

    private
    def initialize(type, matcher)
      @type = type
      @matcher = matcher
    end
  end  
end