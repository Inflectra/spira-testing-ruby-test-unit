require 'soap/wsdlDriver'

module Test
	module Unit
		module SpiraTest

			#	This defines the 'SpiraTestExecute' class that provides the Ruby facade
			#	for calling the SOAP web service exposed by SpiraTest
			#
			#	Author		Inflectra Corporation
			#	Version		2.3.0

			class SpiraTestExecute

				#define the web-service namespace and URL suffix constants
				WEB_SERVICE_NAMESPACE = "http://www.inflectra.com/SpiraTest/Services/v2.2/"
				WEB_SERVICE_URL_SUFFIX = "/Services/v2_2/ImportExport.asmx"

				#initialize the instance variables
				attr_accessor :baseUrl, :userName, :password, :projectId
				def initialize(baseUrl, userName, password, projectId)
					@baseUrl = baseUrl
					@userName = userName
					@password = password
					@projectId = projectId
				end

				#actually records a test result using the SOAP API
				def recordTestRun(testerUserId, testCaseId, releaseId, testSetId, startDate, endDate, executionStatusId, runnerName, runnerTestName, runnerAssertCount, runnerMessage, runnerStackTrace)

					#create the full url to the web service
					wsdl_url = baseUrl + WEB_SERVICE_URL_SUFFIX + "?WSDL"
					
					#create the class customized for the web service described by the WSDL
					soap = SOAP::WSDLDriverFactory.new(wsdl_url).create_rpc_driver
					
					#uncomment for debugging the web service call
					#soap.wiredump_file_base = "soapresult" 
					
					#now we call the methods on the web service, passing the parameters
					params = {"userName" => @userName, "password" => @password, "projectId" => projectId, "testerUserId" => testerUserId, "testCaseId" => testCaseId, "startDate" => startDate, "endDate" => endDate, "executionStatusId" => executionStatusId, "runnerName" => runnerName, "runnerTestName" => runnerTestName, "runnerAssertCount" => runnerAssertCount, "runnerMessage" => runnerMessage, "runnerStackTrace" => runnerStackTrace }
					#add any optional parameters
					if releaseId != -1
						params["releaseId"] = releaseId
					end
					if testSetId != -1
						params["testSetId"] = testSetId
					end

					result = soap.TestRun_RecordAutomated2(params)
					
					#display the results
					testRunId = result.TestRun_RecordAutomated2Result
					puts("Successfully recorded test run " + testRunId.to_s + " for test case: " + testCaseId.to_s)
				end
			end
		end
	end
end
