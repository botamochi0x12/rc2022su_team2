# test_score.rb
require 'test-unit'
require_relative '../lib/Score.rb'

class ScoreTest < Test::Unit::TestCase
    def test1
        "Score(1) SHOULD equal to 1" 
        assert_equal(Score.new(1), Score.new(1))
    end
    def test2
        "Score(0) SHOULD equal to 0" 
        assert_equal(Score.new(1).value, 1)
    end
    def test3
        "Score(1) SHOULD equal to 1" 
        assert_equal(Score.new(1), 1)
    end
    def test1b
        "Score(1) SHOULD not equal to 2" 
        assert(Score.new(1) != Score.new(2))
    end
    def test3b
        "Score(1) SHOULD not equal to 2" 
        assert(Score.new(1) != 2)
    end
    def test4
        "Score(1) + Score(1) SHOULD be equal to Score(2)" 
        assert_equal(Score.new(1) + Score.new(1), Score.new(2))
    end
    def test5
        "Score(1) + 1 SHOULD be equal to 2" 
        assert_equal(Score.new(1) + 1, 2)
    end
    def test6
        "Score(1) SOULD be smaller than Score(2)"
        assert(Score.new(1) < Score.new(2))
    end
    def test7
        "Score(2) SOULD be larger than Score(1)"
        assert(Score.new(2) > Score.new(1))
    end
end

ScoreTest
