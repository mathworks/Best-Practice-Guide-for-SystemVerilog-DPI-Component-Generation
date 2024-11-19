function [smoothedSignal] =  wrapperMovingAvg(signal)
% Copyright 2024 The MathWorks, Inc.

movingAvgerageFilter = movingAverageFilter('WindowLength',10);
smoothedSignal = movingAvgerageFilter(signal);

end