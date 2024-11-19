% Copyright 2024 The MathWorks, Inc.

%% Mex generation 
%codegen call_moving_avg -args {ones(250,1)}

%% DPIC generation
dpigen -testbench testMovingAvg wrapperMovingAvg -args {ones(250,1)}