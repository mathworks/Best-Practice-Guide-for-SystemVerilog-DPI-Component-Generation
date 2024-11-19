function y = call_moving_avg(x) %#codegen
% Copyright 2024 The MathWorks, Inc.

SRC_PATH = '$(START_DIR)\C_SRC'; % Path relative to codegen/mex/call_moving_avg folder
%External Source Code and Header
coder.updateBuildInfo('addIncludePaths',SRC_PATH);
coder.updateBuildInfo('addSourcePaths',SRC_PATH);
coder.cinclude('my_mean.h');
coder.updateBuildInfo('addSourceFiles','my_mean.c');

% Preallocation

y = zeros(1,length(x)-16);
%Moving average
for i = 1:length(x) -16
 x1 = x(i:i+16);
 y(i) = coder.ceval('my_mean',coder.ref(x1));

end