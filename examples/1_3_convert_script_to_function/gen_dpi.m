% Copyright 2024 The MathWorks, Inc.

% DPI-C component - Stimulus
dpigen -d simDPI -testbench  mlab_bench.m genframe2Sample.m -args {double(0), double(0),double(0),double(0),double(0),double(0),double(0)} -launchreport
% DPI-C component - Checker
dpigen -d checkerDPI fftchecker.m -args {double(ones(1,1024)),fi(0,1,16,13),fi(0,1,16,13),double(0),double(0),double(0),double(0)} 
