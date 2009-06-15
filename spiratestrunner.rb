require 'test/unit/ui/testrunnermediator'
require 'test/unit/ui/testrunnerutilities'
require 'spiratestexecute'

module Test
	module Unit
		module SpiraTest

			#	This defines the 'TestRunner' class that allows Ruby's Test::Unit to record its
			#	test results in SpiraTest or SpiraTeam
			#
			#	Author		Inflectra Corporation
			#	Version		2.0.1

			class TestRunner
				extend Test::Unit::UI::TestRunnerUtilities
        
        #define the runner name that's reported back to SpiraTest
        TEST_RUNNER_NAME = "Ruby Test::Unit"

			  # Creates a new TestRunner for running the passed
			  # suite. If quiet_mode is true, the output while
			  # running is limited to progress dots, errors and
			  # failures, and the final result. io specifies
			  # where runner output should go to; defaults to
			  # STDOUT.
			  def initialize(suite, baseUrl, userName, password, projectId, releaseId, output_level=Test::Unit::UI::NORMAL, io=STDOUT)
				if (suite.respond_to?(:suite))
				  @suite = suite.suite
				else
				  @suite = suite
				end
        @baseUrl = baseUrl
				@userName = userName
				@password = password
				@projectId = projectId
        @releaseId = releaseId
				@output_level = output_level
				@io = io
				@already_outputted = false
				@faults = []
        @finishedTests = []
			  end

			  # Begins the test run.
			  def start
				setup_mediator
				attach_to_mediator
				return start_mediator
			  end

			  private
			  def setup_mediator
				@mediator = create_mediator(@suite)
				suite_name = @suite.to_s
				if ( @suite.kind_of?(Module) )
				  suite_name = @suite.name
				end
				output("Loaded suite #{suite_name}")
			  end
	          
			  def create_mediator(suite)
				return Test::Unit::UI::TestRunnerMediator.new(suite)
			  end
	          
			  def attach_to_mediator
				@mediator.add_listener(TestResult::FAULT, &method(:add_fault))
				@mediator.add_listener(Test::Unit::UI::TestRunnerMediator::STARTED, &method(:started))
				@mediator.add_listener(Test::Unit::UI::TestRunnerMediator::FINISHED, &method(:finished))
				@mediator.add_listener(TestCase::STARTED, &method(:test_started))
				@mediator.add_listener(TestCase::FINISHED, &method(:test_finished))
			  end
	          
			  def start_mediator
				return @mediator.run_suite
			  end
	          
			  def add_fault(fault)
				@faults << fault
				output_single(fault.single_character_display, Test::Unit::UI::PROGRESS_ONLY)
				@already_outputted = true
			  end
	          
			  def started(result)
				@result = result
				output("Starting Test Run...")
			  end
	          
			  def finished(elapsed_time)
				nl
				output("Finished Test Run in #{elapsed_time} seconds. Sending Test Results to SpiraTest...")
				@faults.each_with_index do |fault, index|
				  nl
				  output("%3d) %s" % [index + 1, fault.long_display])
				end
				nl
        
        #instantiate the class used to communicate with SpiraTest
        spiraTestExecute = Test::Unit::SpiraTest::SpiraTestExecute.new(@baseUrl, @userName, @password, @projectId)
        
        #loop through the test results and send them to SpiraTest
        @finishedTests.each do |testName|
          #if we can find it in the faults collection then it's a failure, otherwise it's a success
          executionStatusId = 2
          message = "Success"
          assertCount = 0
          stackTrace = ""
          startDate = DateTime.now
          #convert from seconds to days
          elapsed_days = elapsed_time / (60*60*24)
          endDate = startDate + elapsed_days
            
          @faults.each do |fault|
            if fault.test_name == testName then
              executionStatusId = 1
              message = fault.message
              assertCount = 1
              stackTrace = fault.long_display
            end
          end          
  
          #now transmit the result to SpiraTest
          testerUserId = -1 #default to the userName
     
          #extract the test case id from the name (separated by two underscores)
          if testName.include? "__" then
            testCaseId = testName.split("__")[1].to_i
            spiraTestExecute.recordTestRun(testerUserId, testCaseId, @releaseId, startDate, endDate, executionStatusId, TEST_RUNNER_NAME, testName, assertCount, message, stackTrace)
          end
        end
        nl
				output(@result.to_s + " successfully transmitted to SpiraTest")
			  end
	          
			  def test_started(name)
				output_single(name + ": ", Test::Unit::UI::VERBOSE)
			  end
	          
			  def test_finished(name)
				output_single(".", Test::Unit::UI::PROGRESS_ONLY) unless (@already_outputted)
				nl(Test::Unit::UI::VERBOSE)
				@already_outputted = false
        @finishedTests << name
			  end
	          
			  def nl(level=Test::Unit::UI::NORMAL)
				output("", level)
			  end
	          
			  def output(something, level=Test::Unit::UI::NORMAL)
				@io.puts(something) if (output?(level))
				@io.flush
			  end
	          
			  def output_single(something, level=Test::Unit::UI::NORMAL)
				@io.write(something) if (output?(level))
				@io.flush
			  end
	          
			  def output?(level)
				level <= @output_level
			  end
			end
		end
	end
end