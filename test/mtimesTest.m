classdef mtimesTest < matlab.unittest.TestCase
    methods(Test)
        function mtimesWithCompatibleSizes(testCase)
            A = randi(20,4);
            B = randi(20,4);
            blkA = BlockMatrix.fromMatrix(A, [2 2], [2 2]);
            blkB = BlockMatrix.fromMatrix(B, [2 2], [2 2]);
            got = blkA * blkB;
            expected = A * B;
            testCase.assertEqual(got.toMatrix(), expected);
        end
    end
end