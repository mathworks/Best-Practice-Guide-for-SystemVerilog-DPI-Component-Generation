function testMovingAvg
% Copyright 2024 The MathWorks, Inc.

t = (1:250)';
signal = randn(250,1);
smoothedSignal = wrapperMovingAvg(signal);
%plot(t,signal,t,smoothedSignal);
%legend(["Input","Satlaboothed input"])
end