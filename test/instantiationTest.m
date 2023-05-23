classdef instantiationTest < matlab.unittest.TestCase
    
    methods (Test)
        function createSizedBlockMatrix1var(testCase)
            bmb = BlockMatrix(2);
            testCase.assertEqual(bmb.rowSizes, zeros(2,1));
            testCase.assertEqual(bmb.columnSizes, zeros(2,1));
        end
        
        function createSizedBlockMatrix2var(testCase)
            bmb = BlockMatrix(2,2);
            assertClass(testCase, bmb, 'BlockMatrix');
            testCase.assertEqual(bmb.rowSizes, zeros(2,1));
            testCase.assertEqual(bmb.columnSizes, zeros(2,1));
        end
    end
end
