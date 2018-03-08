require 'test_helper'

require "test/unit"
 
class TestCrypto < Test::Unit::TestCase
 
  def test_simple
    assert_equal("78ad0fb2528d74e0de8477e23ff54625", Crypto.new.encrypt("hello", Rails.application.secrets.secret_key_base))
    assert_equal("hello", Crypto.new.decrypt("78ad0fb2528d74e0de8477e23ff54625", Rails.application.secrets.secret_key_base))
  end

  def test_input_check
    assert_raise( ArgumentError ) { Crypto.new.encrypt("", Rails.application.secrets.secret_key_base) }
    assert_raise( ArgumentError ) { Crypto.new.decrypt("", Rails.application.secrets.secret_key_base) }
  end

end