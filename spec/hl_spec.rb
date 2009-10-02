require 'lib/hintable_levenshtein'

describe HintableLevenshtein do
  it "should do this thing" do
    english_rules = [
      HintableLevenshtein::RuleSet.new(0.3, HintableLevenshtein::Rule.insert(/[\.,!]/)),
      HintableLevenshtein::RuleSet.new(0.3, HintableLevenshtein::Rule.delete(/[\.,!]/)),
      HintableLevenshtein::RuleSet.new(0.4, HintableLevenshtein::Rule.substitute('!' => '.')),
      HintableLevenshtein::RuleSet.new(0.4, HintableLevenshtein::Rule.substitute('!' => ',')),
      HintableLevenshtein::RuleSet.new(0.75, HintableLevenshtein::Rule.insert(' '), HintableLevenshtein::Rule.insert(' ')),
      HintableLevenshtein::RuleSet.new(0.5, HintableLevenshtein::Rule.insert(' ')),
      HintableLevenshtein::RuleSet.new(0.5, HintableLevenshtein::Rule.delete(' ')),
      HintableLevenshtein::RuleSet.new(0.7, HintableLevenshtein::Rule.substitute('z' => 's')),
      HintableLevenshtein::RuleSet.new(0.7, HintableLevenshtein::Rule.substitute('k' => 'c')),
      HintableLevenshtein::RuleSet.new(0.7, HintableLevenshtein::Rule.substitute('u' => 'o')),
      HintableLevenshtein::RuleSet.new(0.7, HintableLevenshtein::Rule.substitute('e' => 'a')),
      HintableLevenshtein::RuleSet.new(0.7, HintableLevenshtein::Rule.substitute('i' => 'y')),
      HintableLevenshtein::RuleSet.new(1, HintableLevenshtein::Rule.delete),
      HintableLevenshtein::RuleSet.new(1, HintableLevenshtein::Rule.insert),
      HintableLevenshtein::RuleSet.new(1, HintableLevenshtein::Rule.substitute)
    ]

    a = "hello kitten pizza!!"
    b = "hello    cittin pissssa.."

    HintableLevenshtein.new.distance(a, b).should == 11
    HintableLevenshtein.new(english_rules).distance(a, b).should == 7.15
    
  end
end