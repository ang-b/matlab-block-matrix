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
    bmb = blockMatrixBuilder(2);
    assertEqual(testCase, bmb.rowSizes, zeros(2,1));
    assertEqual(testCase, bmb.columnSizes, zeros(2,1));
end

function test_createSizedBlockMatrix2var(testCase)
    bmb = blockMatrixBuilder(2,2);
    assertClass(testCase, bmb, 'blockMatrixBuilder');
    assertEqual(testCase, bmb.rowSizes, zeros(2,1));
    assertEqual(testCase, bmb.columnSizes, zeros(2,1));
end

function test_addBlockDiagonallyInSizeRange(testCase)
    bmb = blockMatrixBuilder(2,2);
    aMat = rand(2,2);
    bmb.addBlock(1,1,aMat);
    assertEqual(testCase,bmb.toMatrix(),aMat);
    
    anotherMat = rand(3,3);
    bmb.addBlock(2,2,anotherMat);
    assertEqual(testCase,bmb.toMatrix(),blkdiag(aMat,anotherMat));
    assertEqual(testCase,bmb.rowSizes, [2 3]');
    assertEqual(testCase,bmb.columnSizes, [2 3]'); 
end

function test_addBlockDiagonallyInRangeReverse(testCase)
    bmb = blockMatrixBuilder(2,2);
   
    anotherMat = rand(3,3);
    bmb.addBlock(2,2,anotherMat);
    assertEqual(testCase,bmb.toMatrix(),anotherMat);
    
    aMat = rand(2,2);
    bmb.addBlock(1,1,aMat);
    
    assertEqual(testCase,bmb.toMatrix(),blkdiag(aMat,anotherMat));
    assertEqual(testCase,bmb.rowSizes, [2 3]');
    assertEqual(testCase,bmb.columnSizes, [2 3]'); 
end

function test_cannotConcatenateRows(testCase)
    bmb = blockMatrixBuilder(2,2);
    aMat = rand(2,2);
    bmb.addBlock(1,1,aMat);
    assertError(testCase, @() bmb.addBlock(1,2,rand(3,3)), 'addBlock:cat');
end

function test_cannotConcatenateColumns(testCase)
    bmb = blockMatrixBuilder(2,2);
    aMat = rand(2,2);
    bmb.addBlock(1,1,aMat);
    assertError(testCase, @() bmb.addBlock(2,1,rand(3,3)), 'addBlock:cat');
end

function test_concatenateRows(testCase)
    bmb = blockMatrixBuilder(2,2);
    aMat = rand(2,2);
    anotherMat = rand(2,3);
    bmb.addBlock(1,1,aMat).addBlock(1,2,anotherMat);
    assertEqual(testCase, bmb.toMatrix(), [aMat, anotherMat]);
end

function test_concatenateColumns(testCase)
    bmb = blockMatrixBuilder(2,2);
    aMat = rand(2,2);
    anotherMat = rand(3,2);
    bmb.addBlock(1,1,aMat).addBlock(2,1,anotherMat);
    assertEqual(testCase, bmb.toMatrix(), [aMat; anotherMat]);
end

% TODO: concatenate reverse rows and columns
% TODO: growing data