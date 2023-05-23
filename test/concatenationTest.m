classdef concatenationTest < matlab.unittest.TestCase
    
    methods (Test)
        function cannotConcatenateRows(testCase)
            bmb = BlockMatrix(2,2);
            aMat = rand(2,2);
            bmb.setBlock(1,1,aMat);
            testCase.assertError(@() bmb.setBlock(1,2,rand(3,3)), 'setBlock:cat');
        end

        function cannotConcatenateColumns(testCase)
            bmb = BlockMatrix(2,2);
            aMat = rand(2,2);
            bmb.setBlock(1,1,aMat);
            testCase.assertError(@() bmb.setBlock(2,1,rand(3,3)), 'setBlock:cat');
        end

        function concatenateRows(testCase)
            bmb = BlockMatrix(2,2);
            aMat = rand(2,2);
            anotherMat = rand(2,3);
            bmb.setBlock(1,1,aMat).setBlock(1,2,anotherMat);
            testCase.assertEqual(bmb.toMatrix(), [aMat, anotherMat]);
        end

        function concatenateColumns(testCase)
            bmb = BlockMatrix(2,2);
            aMat = rand(2,2);
            anotherMat = rand(3,2);
            bmb.setBlock(1,1,aMat).setBlock(2,1,anotherMat);
            testCase.assertEqual(bmb.toMatrix(), [aMat; anotherMat]);
        end

        function blockHcat(testCase)
            aMat = rand(7);
            oMat = rand(7,4);
            abm = BlockMatrix.fromMatrix(aMat, [3 2 2], [3 4]);
            obm = BlockMatrix.fromMatrix(oMat, [3 2 2], 4);
            hbm = hcat(abm, obm);
            testCase.assertEqual(hbm.toMatrix(), [aMat oMat]);
        end
        
        function blockVcat(testCase)
            aMat = rand(7);
            oMat = rand(4,7);
            abm = BlockMatrix.fromMatrix(aMat, [3 2 2], [3 4]);
            obm = BlockMatrix.fromMatrix(oMat, 4, [3 4]);
            hbm = vcat(abm, obm);
            testCase.assertEqual(hbm.toMatrix(), [aMat; oMat]);
        end

    end
end