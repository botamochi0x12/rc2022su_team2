class Score
    attr_accessor :value

    def initialize(value=0)
        @value = value
    end
    def +(other)
        p other.class
        return self.class.new(@value + other) if other.is_a?(Integer)
        return self.class.new(@value + other.value) if other.is_a?(self.class)
        raise "Not supported class #{other.class}"
    end
    def -(other)
        raise "Not implemented!"
    end
    def ==(other)
        return true if other.is_a?(Integer) && other == @value
        return true if other.is_a?(self.class) && other.value == @value
        return false
    end
    def !=(other)
        return ! (self == other)
    end
    def <(other)
        return true if other.is_a?(Integer) && @value < other
        return true if other.is_a?(self.class) && @value < other.value
        return false
    end
    def >(other)
        return (self != other) && !(self < other)
    end
end
