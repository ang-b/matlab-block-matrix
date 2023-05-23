import matlab.unittest.TestSuite
import matlab.unittest.TestRunner

runner = TestRunner.withTextOutput('OutputDetail', 2);

suiteFolder = TestSuite.fromFolder([pwd filesep 'test']);
result = runner.run(suiteFolder);

disp(result)