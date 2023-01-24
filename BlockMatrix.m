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
                     error('setBlock:cat','Cannot add block of different size');
                end
            end % else it needs to grow
                
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
                    blkMatrix.setBlock(i,j,self.getBlock(i,j));
                end
            end
        end

        function blkMatrix = hcat(self, bm)
            if ~isa(bm,'BlockMatrix')
                error("BlockMatrix:hcat", "Cannot concatenate with other objects");
            end
            thisRows = self.rowSizes;
            otherRows = bm.rowSizes;
            if length(thisRows) == length(otherRows) ...
                    && all(thisRows == otherRows)
                blkMatrix = BlockMatrix(length(thisRows), ...
                        length(self.columnSizes) + length(bm.columnSizes));
                for i = 1:length(thisRows)
                    for j = 1:length(self.columnSizes)
                        blkMatrix.setBlock(i,j,self.getBlock(i,j));
                    end
                end
                offset = j;
                for i = 1:length(thisRows)
                    for j=1:length(bm.columnSizes)
                        blkMatrix.setBlock(i, j+offset, bm.getBlock(i,j));
                    end
                end
            else
                error("BlockMatrix:hcat", "Incompatible dimensions");
            end
        end

        function s = size(self, varargin)
            if isempty(varargin)
                s = [length(self.rowSizes) length(self.columnSizes)];
            else
                switch varargin{1}
                    case 1
                        s = length(self.rowSizes);
                    case 2
                        s = length(self.columnSizes);
                    otherwise
                        error('BlockMatrix:size', 'Invalid index of dimension');
                end
            end
        end

        function disp(self)
            disp(self.toMatrix());
        end

        function M = toMatrix(self)
            if ~self.cached
                for i = 1:length(self.rowSizes)
                    for j = 1:length(self.columnSizes)
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
            if i > length(self.rowSizes) || j > length(self.columnSizes) ...
                    || i < 1 || j < 1
                error("out of bounds");
            end
        end
    end
        
end