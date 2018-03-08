require 'test_helper'

require "test/unit"
 
class TestGallery < Test::Unit::TestCase
 
  def test_simple
    assert_equal("Room 0, 20 minutes average visit, 2 visitors total\n", Gallery.new("4\n 0 0 I 540\n 1 0 I 540 \n0 0 O 560\n 1 0 O 560").run)
  end

  def test_input_check
    assert_raise( RuntimeError ) { Gallery.new("0 0 I 540\n 1 0 I 540 \n0 0 O 560\n 1 0 O 560").run }
  end

end