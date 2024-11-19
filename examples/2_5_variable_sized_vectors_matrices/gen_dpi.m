% Copyright 2024 The MathWorks, Inc.

configObj = coder.config('dll');
configObj.Toolchain = 'Mentor Graphics QuestaSim/Modelsim (64-bit Windows)';
dpigen outerFcn -testbench outerFcn_tb -args {coder.typeof(1,[1 inf],[0 1]),[1 1],coder.typeof(1,[1 inf],[0 1]),[1 1]} -config configObj