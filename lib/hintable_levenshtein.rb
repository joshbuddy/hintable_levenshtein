class HintableLevenshtein
  
  autoload :Event,   File.join(File.dirname(__FILE__), 'hintable_levenshtein', 'event')
  autoload :RuleSet, File.join(File.dirname(__FILE__), 'hintable_levenshtein', 'rule_set')
  
  def initialize(new_rule_set = nil, &block)
    @rule_set = []

    instance_eval(&block) if block
    
    if new_rule_set
      rule_set.concat(new_rule_set)
    end
    
    if rule_set.empty?
      rule_set << RuleSet.new(1, Rule.delete)
      rule_set << RuleSet.new(1, Rule.insert)
      rule_set << RuleSet.new(1, Rule.substitute)
    end
  end
  
  def rule_set_sizes
    @rule_set_sizes ||= rule_set.collect{|r| r.rules.size}.uniq.sort.reverse
  end

  def largest_rule_size
    rule_set_sizes.first
  end
  
  def delete(score, match)
    rule_set << RuleSet.new(score, Rule.delete(match))
  end
  
  def insert(score, match)
    rule_set << RuleSet.new(score, Rule.insert(match))
  end
  
  def substitute(score, match)
    rule_set << RuleSet.new(score, Rule.substitute(match))
  end
  
  Position = Struct.new(:x, :y)
  
  def distance(s, t)
    matrix = levenshtein_matrix(s, t)
    steps = calculate_steps(s, t, matrix)
    calculate_score(steps)
  end
  
  private
  
  attr_reader :rule_set
  
  def levenshtein_matrix(s, t)
    d = Array.new(s.size + 1) {|i| Array.new(t.size + 1)}
    
    (0..s.size).each do |m|
      (0..t.size).each do |n|
        if m * n == 0
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
    
    d
  end
  
  def calculate_steps(s, t, matrix)
    position = Position.new(s.size, t.size)
    value = matrix[position.x][position.y]
    steps = []
    while matrix[position.x][position.y] != 0
      previous_position = position.dup
      if position.x == 0
        position.y -= 1
      elsif position.y == 0
        position.x -= 1
      else
        possible_values = [matrix[position.x - 1][position.y], matrix[position.x][position.y - 1], matrix[position.x - 1][position.y - 1]]
        case possible_values.min
        when possible_values[2]
          position.x -= 1
          position.y -= 1
        when possible_values[1]
          position.y -= 1
        when possible_values[0]
          position.x -= 1
        end
      end

      next unless value != matrix[position.x][position.y]
      
      value = matrix[position.x][position.y]
      steps << if previous_position.x == position.x + 1 && previous_position.y == position.y + 1
        Event.new(:substitute, s[position.x] => t[position.y])
      elsif previous_position.x == (position.x + 1)
        Event.new(:delete, s[position.x].chr)
      else
        Event.new(:insert, t[position.y].chr)
      end
    end
    steps
  end
  
  def calculate_score(steps)
    score = 0.0
    rule_set_sizes.each do |set_size|
      rule_set.select{|r| r.rules.size == set_size}.each do |rule|
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
  
end
