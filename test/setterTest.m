classdef setterTest < matlab.unittest.TestCase
    methods(Test)
        function addBlockDiagonallyInSizeRange(testCase)
            bmb = BlockMatrix(2,2);
            aMat = rand(2,2);
            bmb.setBlock(1,1,aMat);
            testCase.assertEqual(bmb.toMatrix(),aMat);
            
            anotherMat = rand(3,3);
            bmb.setBlock(2,2,anotherMat);
            testCase.assertEqual(bmb.toMatrix(),blkdiag(aMat,anotherMat));
            testCase.assertEqual(bmb.rowSizes, [2 3]');
            testCase.assertEqual(bmb.columnSizes, [2 3]'); 
        end
        
        function addBlockDiagonallyInRangeReverse(testCase)
            bmb = BlockMatrix(2,2);
           
            anotherMat = rand(3,3);
            bmb.setBlock(2,2,anotherMat);
            testCase.assertEqual(bmb.toMatrix(),anotherMat);
            
            aMat = rand(2,2);
            bmb.setBlock(1,1,aMat);
            
            testCase.assertEqual(bmb.toMatrix(),blkdiag(aMat,anotherMat));
            testCase.assertEqual(bmb.rowSizes, [2 3]');
            testCase.assertEqual(bmb.columnSizes, [2 3]'); 
        end
    end
end