# Block Matrix
Object representing a block matrix.
It allows for easy block definition, handling, extraction, concatenation and transformations, without worrying to much about your indices.

The following methods are provided (see test file for examples):

## Constructors

`M = BlockMatrix(n, m)` constructs a block matrix with `n` row blocks and `m` column blocks. The block sizes are undetermined at construction. Size conformity is automatically determined by the insertions by the user, i.e. the first time a matrix is inserted in a row/column, it sets the conformable sizes for that row/column.

`M = BlockMatrix(n)` constructs a "square" block matrix with `n` row and column blocks.

`M = BlockMatrix()` constructs a single block matrix. Not very useful, since expansion is not supported **yet**.

## Instance Methods

`blk = getBlock(self, i, j)` returns the block (`i`,`j`) as a numeric matrix.

`setBlock(self, i, j, block)` assigns a matrix `block` at row `i` and column `j`.

`rng = getRange(self, rowRange, columnRange)` returns the block submatrix defined by the rows included in the 2-vector `rowRange` (of the form `[i1 i2]`) and the columns included in the 2-vector `columnRange` (of the form `[j1 j2]`). 

`C = hcat(self, bm)` returns the horizontally concatenated block matrix `self` and `bm` of conformable block sizes, i.e. C = [self, bm].

`C = vcat(self, bm)` returns the vertically concatenated block matrix `self` and `bm` of conformable block sizes, i.e. C = [self; bm].

`bm = blockApply(self, op)` applies operator `op` block-wise to matrix `self` and returns the result.

`M = toMatrix(self)` return numeric matrix representation of block matrix `self`.

`transpose`, `ctranspose`, `size`, `disp` as per Mathworks spec.

## Static Methods

`bm = BlockMatrix.fromMatrix(mat, rowSize, columnSize)` creates a block matrix from a numeric matrix, where block sizes for row and columns are specified in the vectors `rowSize` and `columnSize`.

# Caveats and limitations

This is ongoing work and features will be added as needed by the projects using this code. 
Currently unsupported features include:
- Operations between block matrices are not supported (e.g. addition, multiplication). For the everyday use, it would still be more efficient albeit verbose to use combinations of `toMatrix` and `fromMatrix`.
- Block matrices do not resize. One should allocate enough blocks on construction.
