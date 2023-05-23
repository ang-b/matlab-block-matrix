classdef unaryOpTest < matlab.unittest.TestCase
    methods(Test)
        function test_blockApply(testCase)
            aMat = rand(12);
            % create 4-by-4 block matrix of 3-by-3 blocks
            bm = BlockMatrix.fromMatrix(aMat, ones(4,1)*3, ones(4,1)*3);
            op = @(x) x \ eye(size(x)); % block-inverse operation
            bi = bm.blockApply(op);
            % check just a few blocks
            testCase.assertEqual(bi.getBlock(1,1), op(aMat(1:3, 1:3)));
            testCase.assertEqual(bi.getBlock(2,3), op(aMat(4:6, 7:9)));
        end
    end
end
