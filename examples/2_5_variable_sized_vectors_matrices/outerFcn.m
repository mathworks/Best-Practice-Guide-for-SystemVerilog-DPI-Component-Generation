function [vectorRes,sizeRes] = outerFcn(vectorA,sizeA,vectorB,sizeB) %#codegen
% Copyright 2024 The MathWorks, Inc.

res = innerFcn(reshape(vectorA,sizeA),reshape(vectorB,sizeB));
sizeRes = size(res);
vectorRes = reshape(res,[1 prod(sizeRes)]);
end

