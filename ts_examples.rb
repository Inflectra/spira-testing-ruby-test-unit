# Author:: Nathaniel Talbott.
# Copyright:: Copyright (c) 2000-2002 Nathaniel Talbott. All rights reserved.
# License:: Ruby license.

require 'tc_adder'
require 'tc_subtracter'
require 'spiratestrunner'
require 'test/unit/testsuite'

class TS_Examples
	def self.suite
		suite = Test::Unit::TestSuite.new
		suite << TC_Adder.suite
		suite << TC_Subtracter.suite
		return suite
	end
end

#The following line runs the tests using the SpiraTest runner
projectId = 1
releaseId = -1
testSetId = -1
testRunner = Test::Unit::SpiraTest::TestRunner.new(TS_Examples, "http://sandman/SpiraTest", "fredbloggs", "fredbloggs", projectId, releaseId, testSetId)
testRunner.start

#The following line simply runs the tests using the standard console runner
#Test::Unit::UI::Console::TestRunner.run(TS_Examples)
