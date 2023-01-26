classdef BlockMatrix < handle
    %BLOCKMATRIX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = public, SetAccess = private)
        rowSizes
        columnSizes
    end
    
    properties (Access = private)
        data; 
        matrixRep;
        cached;
    end
    
    methods
        function self = BlockMatrix(varargin)        
            self.rowSizes = 0;
            self.columnSizes = 0;
            self.matrixRep = [];
            self.cached = false;
            switch (nargin)
                case 0
                    self.data = cell(1);
                case 1 
                    n = varargin{1};
                    self.data = cell(n);
                    self.rowSizes = zeros(n,1);
                    self.columnSizes = zeros(n,1);
                case 2 
                    [m,n] = varargin{:};
                    self.data = cell(m,n);
                    self.rowSizes = zeros(m,1);
                    self.columnSizes = zeros(n,1);
                otherwise
                    error('Wrong input values');
            end
        end

        function n = nrowblocks(self)
            n = length(self.rowSizes);
        end

        function m = ncolblocks(self)
            m = length(self.columnSizes);
        end

        function n = nrows(self)
            n = sum(self.rowSizes);
        end

        function m = ncols(self)
            m = sum(self.columnSizes);
        end
        
        function self = setBlock(self, i, j, block)
            self.cached = false;
            blkRows = size(block, 1);
            blkCols = size(block, 2);
            if i <= size(self.data, 1) && j <= size(self.data, 2)
                if self.blockHasCompatibleRowDimensions(i, block) ...
                        && self.blockHasCompatibleColumnDimensions(j, block)
                    self.data{i,j} = block;
                    self.rowSizes(i) = blkRows;
                    self.columnSizes(j) = blkCols;
                else
                     error("setBlock:cat", "Block (%i,%i) has incompatible sizes", i,j);
                end
            else % else it needs to grow
                % intead of failing silently we explode
                error("setBlock:cat", "Index (%i,%i) is out of allocated size (unsupported)", i,j);
            end    
        end

        function blk = getBlock(self, i, j)
            self.checkSizeBounds(i,j)
            blk = self.data{i,j};
        end
        
        function blkMatrix = getRange(self, rowRange, colRange)
            self.checkSizeBounds(rowRange(1), colRange(1));
            self.checkSizeBounds(rowRange(2), colRange(2));
            blkMatrix = BlockMatrix(rowRange(2) - rowRange(1) + 1, ...
                colRange(2) - colRange(1) + 1);
            for i = rowRange(1):rowRange(2)
                for j = colRange(1):colRange(2)
                    blkMatrix.setBlock(i - rowRange(1) + 1, ...
                                       j - colRange(1) + 1, ...
                                       self.getBlock(i,j));
                end
            end
        end

        function blkMatrix = hcat(self, bm)
            if ~isa(bm,'BlockMatrix')
                error("BlockMatrix:hcat", "Cannot concatenate with other objects");
            end
            if self.nrowblocks() == bm.nrowblocks() && all(self.rowSizes == bm.rowSizes)
                blkMatrix = BlockMatrix(self.nrowblocks, self.ncolblocks() + bm.ncolblocks());
                for i = 1:self.nrowblocks()
                    for j = 1:self.ncolblocks()
                        blkMatrix.setBlock(i,j,self.getBlock(i,j));
                    end
                end
                offset = j;
                for i = 1:bm.nrowblocks()
                    for j=1:bm.ncolblocks()
                        blkMatrix.setBlock(i, j+offset, bm.getBlock(i,j));
                    end
                end
            else
                error("BlockMatrix:hcat", "Incompatible dimensions");
            end
        end

        function blkMatrix = vcat(self, bm)
            if ~isa(bm,'BlockMatrix')
                error("BlockMatrix:vcat", "Cannot concatenate with other objects");
            end
            if self.ncolblocks() == bm.ncolblocks() && all(self.columnSizes == bm.columnSizes)
                blkMatrix = BlockMatrix(self.nrowblocks()+bm.nrowblocks(), self.ncolblocks());
                for i = 1:self.nrowblocks()
                    for j = 1:self.ncolblocks()
                        blkMatrix.setBlock(i, j, self.getBlock(i,j));
                    end
                end
                offset = i;
                for i = 1:bm.nrowblocks()
                    for j=1:bm.ncolblocks()
                        blkMatrix.setBlock(i+offset, j, bm.getBlock(i,j));
                    end
                end
            else
                error("BlockMatrix:vcat", "Incompatible dimensions");
            end
        end

        function bm = blockApply(self,op)
            bm = BlockMatrix(self.nrowblocks(), self.ncolblocks());
            bm.data = cellfun(op, self.data, 'UniformOutput', false);
            rowSizesMat = cellfun(@(x) size(x,1), bm.data);
            colSizesMat = cellfun(@(x) size(x,2), bm.data);
            % if all rows have the same size, then min == max along columns
            % if all columns have the same size, then min == max along rows
            if all(min(rowSizesMat, [], 2) == max(rowSizesMat, [], 2)) ...
                    && all(min(colSizesMat, [], 1) == max(colSizesMat, [], 1))
                bm.rowSizes = rowSizesMat(:, 1);
                bm.columnSizes = colSizesMat(:, 1);
            else
                error("BlockMatrix:blockApply", "Somehow the return dimensions are not consistent");
            end
        end

        function bm = transpose(self)
            bm = self.transposeHelper(@transpose);
        end

        function bm = ctranspose(self)
            bm = self.transposeHelper(@ctranspose);
        end

        function s = size(self, varargin)
            if isempty(varargin)
                s = [self.nrows() self.ncols()];
            else
                switch varargin{1}
                    case 1
                        s = self.nrows();
                    case 2
                        s = self.ncols();
                    otherwise
                        error('BlockMatrix:size', 'Invalid index of dimension');
                end
            end
        end

        function disp(self)
            fprintf("(%i-by-%i Block Matrix)\n\n", length(self.rowSizes), ...
                length(self.columnSizes));
            disp(self.toMatrix());
        end

        function M = toMatrix(self)
            if ~self.cached
                for i = 1:self.nrowblocks()
                    for j = 1:self.ncolblocks()
                        if isempty(self.data{i,j})
                            self.data{i,j} = zeros(self.rowSizes(i), ...
                                                   self.columnSizes(j));
                        end
                    end
                end
                M = cell2mat(self.data);
                self.matrixRep = M;
                self.cached = true;
            else
                M = self.matrixRep;
            end
        end
    end

    methods(Static)
        function bm = fromMatrix(mat, rowSizes, colSizes)
            bm = BlockMatrix(length(rowSizes), length(colSizes));
            for i = 1:length(rowSizes)
                for j = 1:length(colSizes)
                    bm.setBlock(i,j, mat(...
                            sum(rowSizes(1:i-1)) + (1:rowSizes(i)), ...
                            sum(colSizes(1:j-1)) + (1:colSizes(j)) ...
                        ));
                end
            end
        end
    end
    
    methods (Access = private)
        function flag = blockHasCompatibleColumnDimensions(self, j, block)
            flag = size(block, 2) == ...
                    self.columnSizes(j) || self.columnSizes(j) == 0;
        end

        function flag = blockHasCompatibleRowDimensions(self, i, block)
            flag = size(block, 1) == ...
                    self.rowSizes(i) || self.rowSizes(i) == 0;
        end

        function checkSizeBounds(self, i, j)
            if i > self.nrowblocks() || j > self.ncolblocks() || i < 1 || j < 1
                error("out of bounds");
            end
        end

        function bm = transposeHelper(self, fun)
            bm = BlockMatrix(self.ncolblocks(), self.nrowblocks());
            bm.columnSizes = self.rowSizes;
            bm.rowSizes = self.columnSizes;
            bm.data = self.data';
            bm.data = cellfun(fun, bm.data, 'UniformOutput', false);
            if self.cached
                bm.cached = true;
                bm.matrixRep = fun(self.matrixRep);
            end
        end
    end
        
end