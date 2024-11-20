% Copyright 2024 The MathWorks, Inc.

configObj = coder.config('dll');

if strcmp(version('-release'),'2024b')
     configObj.Toolchain = 'Siemens Questa/Modelsim (64-bit Windows)';
 else
     configObj.Toolchain = 'Mentor Graphics QuestaSim/Modelsim (64-bit Windows)';
 end

dpigen outerFcn -testbench outerFcn_tb -args {coder.typeof(1,[1 inf],[0 1]),[1 1],coder.typeof(1,[1 inf],[0 1]),[1 1]} -config configObj