classdef additionTest < matlab.unittest.TestCase
    methods(Test)
        function addWithCompatibleSizes(testCase)
            A = randi(20,10);
            B = randi(20,10);
            blkA = BlockMatrix.fromMatrix(A, [2 3 5], [4 2 4]);
            blkB = BlockMatrix.fromMatrix(B, [2 3 5], [4 2 4]);
            got = blkA + blkB;
            expected = A + B;
            testCase.assertEqual(got.toMatrix(), expected);
        end
    end
end