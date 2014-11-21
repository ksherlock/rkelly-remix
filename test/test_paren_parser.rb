require File.dirname(__FILE__) + "/helper"

class ParenParserTest < NodeTestCase

  def test_bad_paren_1
    # verify function parameters aren't allowed as a comma node.
    assert_raises(RKelly::SyntaxError) do
      RKelly::Parser.new.parse "(a,b, ...rest)"
    end
  end


  def test_bad_paren_2
    # verify function parameters aren't allowed as a comma node.
    assert_raises(RKelly::SyntaxError) do
      RKelly::Parser.new.parse "()"
    end
  end



  def test_bad_arrow_1
    # verify (expr) not allowed as arrow function arguments.
    assert_raises(RKelly::SyntaxError) do
      RKelly::Parser.new.parse "(x+1) => x"
    end
  end

end
