classdef conversionTest < matlab.unittest.TestCase
    methods(Test)               
        function toMatrixHandlesEmptyBlocks(testCase)
            bm = BlockMatrix(3,2);
            mat11 = rand(3,3);
            mat32 = rand(3,2);
            bm.setBlock(1,1, mat11);
            bm.setBlock(3,2, mat32);
            M = bm.toMatrix();
            testCase.assertEqual(M, blkdiag(mat11,mat32));
        end
        
        function fromMatrixWithRightPartition(testCase)
            aMat = rand(10);
            bm = BlockMatrix.fromMatrix(aMat, [4 3 3], [2 3 5]);
            testCase.assertEqual(bm.getBlock(1,1), aMat(1:4, 1:2));
            testCase.assertEqual(bm.getBlock(3,3), aMat(8:10, 6:10));
            testCase.assertEqual(bm.getBlock(2,3), aMat(5:7, 6:10));
        end
    end
end
