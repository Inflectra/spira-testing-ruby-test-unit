# Author:: Nathaniel Talbott.
# Copyright:: Copyright (c) 2000-2002 Nathaniel Talbott. All rights reserved.
# License:: Ruby license.

require 'test/unit'
require 'subtracter'

class TC_Subtracter < Test::Unit::TestCase
  def setup
    @subtracter = Subtracter.new(5)
  end
  def test_subtract__4
    assert_equal(3, @subtracter.subtract(2), "Should have subtracted correctly")
  end
    def test_subtracterror__5
    assert_equal(0, 1/0, "Should throw an error")
  end
  def teardown
    @subtracter = nil
  end
end
