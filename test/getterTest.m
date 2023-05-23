classdef getterTest < matlab.unittest.TestCase
    methods(Test)    
        function getBlockUpperLeftAlignment(testCase)
            aMat = rand(12);
            % create 4-by-4 block matrix of 3-by-3 blocks
            bm = BlockMatrix.fromMatrix(aMat, ones(4,1)*3, ones(4,1)*3);
            aSlice = aMat(1:6, 1:6); % top left 2-by-2 block
            br = bm.getRange([1 2], [1 2]);
            testCase.assertEqual(br.toMatrix(), aSlice);
        end
        
        function getBlockUppeRightAlignment(testCase)
            aMat = rand(12);
            % create 4-by-4 block matrix of 3-by-3 blocks
            bm = BlockMatrix.fromMatrix(aMat, ones(4,1)*3, ones(4,1)*3);
            aSlice = aMat(1:6, 7:12); % top right 2-by-2 block
            br = bm.getRange([1 2], [3 4]);
            testCase.assertEqual(br.toMatrix(), aSlice);
        end
        
        function getBlockLowerLeftAlignment(testCase)
            aMat = rand(12);
            % create 4-by-4 block matrix of 3-by-3 blocks
            bm = BlockMatrix.fromMatrix(aMat, ones(4,1)*3, ones(4,1)*3);
            aSlice = aMat(7:12, 1:6); % top left 2-by-2 block
            br = bm.getRange([3 4], [1 2]);
            testCase.assertEqual(br.toMatrix(), aSlice);
        end
        
        function getBlockLowerRightAlignment(testCase)
            aMat = rand(12);
            % create 4-by-4 block matrix of 3-by-3 blocks
            bm = BlockMatrix.fromMatrix(aMat, ones(4,1)*3, ones(4,1)*3);
            aSlice = aMat(7:12, 7:12); % top right 2-by-2 block
            br = bm.getRange([3 4], [3 4]);
            testCase.assertEqual(br.toMatrix(), aSlice);
        end
    end
end
