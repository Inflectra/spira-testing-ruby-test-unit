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
					params = {}
          params["userName"] = @userName
          params["password"] = @password
          params["projectId"] = @projectId
          params["testerUserId"] = testerUserId
          params["testCaseId"] = testCaseId
          params["startDate"] = startDate
          params["endDate"] = endDate
          params["executionStatusId"] = executionStatusId
          params["runnerName"] = runnerName
          params["runnerTestName"] = runnerTestName
          params["runnerAssertCount"] = runnerAssertCount
          params["runnerMessage"] = runnerMessage
          params["runnerStackTrace"] = runnerStackTrace
          #these pass -1 if optional which is handled correctly by the service
          params["releaseId"] = releaseId
					params["testSetId"] = testSetId


          result = soap.testRun_RecordAutomated2(params)
					
					#display the results
					testRunId = result.testRun_RecordAutomated2Result
					puts("Successfully recorded test run " + testRunId.to_s + " for test case: " + testCaseId.to_s)
				end
			end
		end
	end
end
