% Copyright 2024 The MathWorks, Inc.
if ~contains(path, fullfile(pwd, '..', 'function_folder'))
    addpath(fullfile(pwd, '..', 'function_folder'));
end
if ~contains(path, fullfile(pwd, '..', 'scripts'))
    addpath(fullfile(pwd, '..', 'scripts'));
end

outputstructs_def = {'outputArg1', struct('a',uint8(1),'b',uint8(2))};

matlab2simulink_dpigen(...
    functionname = 'add_sub_struct',...
    ctrlports = {'mode'}, ...
    inputargs = {true, struct('a',uint8(1), 'b', uint8(1)), struct('a',uint8(1), 'b',uint8(0))},...
    outputstructs = outputstructs_def, ...
    DPIFixedPointDataType = 'BitVector', ...
    outputfolder = 'add_sub_struct_builddir', ...
    makeTB = false);



