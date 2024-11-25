% Copyright 2024 The MathWorks, Inc.

addpath(fullfile(pwd,'..','function_folder'));
addpath(fullfile(pwd,'..','scripts'));


%dpigen simple -args {logical(false), uint8(0), uint8(0)}

%matlab2simulink_dpigen('simple', {}, {logical(0), uint8(0), uint8(0)}, 'CompatibleCType')

matlab2simulink_dpigen(...
    functionname = 'simple',...
    ctrlports = {'valid', 'opt1'}, ...
    inputargs = {logical(0), uint8(1), uint8(0), uint8(0)},...
    DPIFixedPointDataType = 'BitVector', ...
    outputfolder = 'simpletestdir')
