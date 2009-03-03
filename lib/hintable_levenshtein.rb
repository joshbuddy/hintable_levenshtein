class HintableLevenshtein

  def initialize(rule_set = nil)

    @rule_set = if rule_set
      rule_set
    else
      [
        RuleSet.new(1, Rule.delete),
        RuleSet.new(1, Rule.insert),
        RuleSet.new(1, Rule.substitute)
      ]
    end
    
    @rule_set_sizes = @rule_set.collect{|r| r.rules.size}.uniq.sort.reverse
    @largest_rule_size = @rule_set_sizes.first
  end
  
  def distance(s, t)
    d = Array.new(s.size + 1) {|i| Array.new(t.size + 1)}
    
    (0..s.size).each do |m|
      (0..t.size).each do |n|
        if m*n == 0
          d[m][n] = m + n
        else
          d[m][n] = [
            d[m-1][n] + 1,
            d[m][n-1] + 1,
            d[m-1][n-1] + (s[m-1] == t[n-1] ? 0 : 1)
          ].min
        end
      end
    end
    
    pos = [s.size, t.size]
    val = d[pos.first][pos.last]
    steps = []
    while d[pos.first][pos.last] != 0
      previous_pos = pos.clone
      if pos.first == 0
        pos = [pos.first, pos.last - 1]
      elsif pos.last == 0
        pos = [pos.first - 1, pos.last]
      else
        min = [d[pos.first-1][pos.last], d[pos.first][pos.last-1], d[pos.first-1][pos.last-1]].min
        if (min == d[pos.first-1][pos.last-1])
          pos = [pos.first - 1, pos.last - 1]
        elsif min == d[pos.first][pos.last-1]
          pos = [pos.first, pos.last - 1]
        else
          pos = [pos.first - 1, pos.last]
        end
      end
      
      if (val != d[pos.first][pos.last])
        val = d[pos.first][pos.last]
        if previous_pos.first == (pos.first + 1) && previous_pos.last == (pos.last + 1)
          steps << Event.new(:substitute, s[pos.first] => t[pos.last])
        elsif previous_pos.first == (pos.first + 1)
          steps << Event.new(:delete, s[pos.first].chr)
        else
          steps << Event.new(:insert, t[pos.last].chr)
        end
      end
    end
    
    steps.reverse!
    
    score = 0.0
    
    @rule_set_sizes.each do |set_size|
      @rule_set.select{|r| r.rules.size == set_size}.each do |rule|
        (0..(steps.size - set_size)).each do |offset|
          analyzed_set = steps[offset..(offset + set_size - 1)]
          unless analyzed_set.any?{|s| s.nil?}
            if rule.match?(analyzed_set)
              steps.fill(nil, offset, set_size)
              score += rule.score
            end
          end
        end
      end
    end
    score
  end
  
  class Event
    attr_reader :type, :chr, :from, :to
    def initialize(type, chr = nil)
      @type = type
      case type
      when :substitute
        unless chr.nil?
          @from = chr.keys.first
          @from = @from.chr unless @from.is_a?(String)
          @to = chr.values.first
          @to = @to.chr unless @to.is_a?(String)
        else
          @from = @to = nil
        end
      else
        @chr = chr.is_a?(String) ? chr : chr.chr
      end
    end
    
    def to_s
      if @from
        "#{@type} -> #{@from}..#{@to}"
      else
        "#{@type} -> #{@chr}"
      end
    end
  end
  
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
