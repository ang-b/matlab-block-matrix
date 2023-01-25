function tests = blockMatrixBuilderTest
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testCase.TestData;
end

function teardownOnce(testCase)
%
end

function test_createSizedBlockMatrix1var(testCase)
    bmb = BlockMatrix(2);
    testCase.assertEqual(bmb.rowSizes, zeros(2,1));
    testCase.assertEqual(bmb.columnSizes, zeros(2,1));
end

function test_createSizedBlockMatrix2var(testCase)
    bmb = BlockMatrix(2,2);
    assertClass(testCase, bmb, 'BlockMatrix');
    testCase.assertEqual(bmb.rowSizes, zeros(2,1));
    testCase.assertEqual(bmb.columnSizes, zeros(2,1));
end

function test_addBlockDiagonallyInSizeRange(testCase)
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

function test_addBlockDiagonallyInRangeReverse(testCase)
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

function test_cannotConcatenateRows(testCase)
    bmb = BlockMatrix(2,2);
    aMat = rand(2,2);
    bmb.setBlock(1,1,aMat);
    testCase.assertError(@() bmb.setBlock(1,2,rand(3,3)), 'setBlock:cat');
end

function test_cannotConcatenateColumns(testCase)
    bmb = BlockMatrix(2,2);
    aMat = rand(2,2);
    bmb.setBlock(1,1,aMat);
    testCase.assertError(@() bmb.setBlock(2,1,rand(3,3)), 'setBlock:cat');
end

function test_concatenateRows(testCase)
    bmb = BlockMatrix(2,2);
    aMat = rand(2,2);
    anotherMat = rand(2,3);
    bmb.setBlock(1,1,aMat).setBlock(1,2,anotherMat);
    testCase.assertEqual(bmb.toMatrix(), [aMat, anotherMat]);
end

function test_concatenateColumns(testCase)
    bmb = BlockMatrix(2,2);
    aMat = rand(2,2);
    anotherMat = rand(3,2);
    bmb.setBlock(1,1,aMat).setBlock(2,1,anotherMat);
    testCase.assertEqual(bmb.toMatrix(), [aMat; anotherMat]);
end

function test_toMatrixHandlesEmptyBlocks(testCase)
    bm = BlockMatrix(3,2);
    mat11 = rand(3,3);
    mat32 = rand(3,2);
    bm.setBlock(1,1, mat11);
    bm.setBlock(3,2, mat32);
    M = bm.toMatrix();
    testCase.assertEqual(M, blkdiag(mat11,mat32));
end

function test_fromMatrixWithRightPartition(testCase)
    aMat = rand(10);
    bm = BlockMatrix.fromMatrix(aMat, [4 3 3], [2 3 5]);
    testCase.assertEqual(bm.getBlock(1,1), aMat(1:4, 1:2));
    testCase.assertEqual(bm.getBlock(3,3), aMat(8:10, 6:10));
    testCase.assertEqual(bm.getBlock(2,3), aMat(5:7, 6:10));
end

function test_getBlockUpperLeftAlignment(testCase)
    aMat = rand(12);
    % create 4-by-4 block matrix of 3-by-3 blocks
    bm = BlockMatrix.fromMatrix(aMat, ones(4,1)*3, ones(4,1)*3);
    aSlice = aMat(1:6, 1:6); % top left 2-by-2 block
    br = bm.getRange([1 2], [1 2]);
    testCase.assertEqual(br.toMatrix(), aSlice);
end

function test_getBlockUppeRightAlignment(testCase)
    aMat = rand(12);
    % create 4-by-4 block matrix of 3-by-3 blocks
    bm = BlockMatrix.fromMatrix(aMat, ones(4,1)*3, ones(4,1)*3);
    aSlice = aMat(1:6, 7:12); % top right 2-by-2 block
    br = bm.getRange([1 2], [3 4]);
    testCase.assertEqual(br.toMatrix(), aSlice);
end

function test_getBlockLowerLeftAlignment(testCase)
    aMat = rand(12);
    % create 4-by-4 block matrix of 3-by-3 blocks
    bm = BlockMatrix.fromMatrix(aMat, ones(4,1)*3, ones(4,1)*3);
    aSlice = aMat(7:12, 1:6); % top left 2-by-2 block
    br = bm.getRange([3 4], [1 2]);
    testCase.assertEqual(br.toMatrix(), aSlice);
end

function test_getBlockLowerRightAlignment(testCase)
    aMat = rand(12);
    % create 4-by-4 block matrix of 3-by-3 blocks
    bm = BlockMatrix.fromMatrix(aMat, ones(4,1)*3, ones(4,1)*3);
    aSlice = aMat(7:12, 7:12); % top right 2-by-2 block
    br = bm.getRange([3 4], [3 4]);
    testCase.assertEqual(br.toMatrix(), aSlice);
end

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

function test_blockHcat(testCase)
    aMat = rand(7);
    oMat = rand(7,4);
    abm = BlockMatrix.fromMatrix(aMat, [3 2 2], [3 4]);
    obm = BlockMatrix.fromMatrix(oMat, [3 2 2], 4);
    hbm = hcat(abm, obm);
    testCase.assertEqual(hbm.toMatrix(), [aMat oMat]);
end

function test_blockVcat(testCase)
    aMat = rand(7);
    oMat = rand(4,7);
    abm = BlockMatrix.fromMatrix(aMat, [3 2 2], [3 4]);
    obm = BlockMatrix.fromMatrix(oMat, 4, [3 4]);
    hbm = vcat(abm, obm);
    testCase.assertEqual(hbm.toMatrix(), [aMat; oMat]);
end

% TODO: growing data