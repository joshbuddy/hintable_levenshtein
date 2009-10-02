class HintableLevenshtein
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
      if from
        "#{type} -> #{from}..#{to}"
      else
        "#{type} -> #{chr}"
      end
    end
  end
end