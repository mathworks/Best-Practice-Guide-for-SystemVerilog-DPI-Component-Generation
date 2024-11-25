% Copyright 2024 The MathWorks, Inc.

rootfolder = pwd;
zipfilename = ['matlab2simulink_dpigen.' date '.zip'];
zip(zipfilename, {...
    fullfile('function_folder', 'foo.m'),...
    fullfile('function_folder', 'myfunction1.m'),...
    fullfile('function_folder', 'add_sub.m'),...
    fullfile('function_folder', 'simple.m'),...
    fullfile('scripts', 'matlab2simulink_dpigen.m'),...
    fullfile('MATLAB2SIMULINK_DPIGEN_userguide.pdf'),...
    fullfile('workdir', 'runme_add_sub.m'),...
    fullfile('workdir', 'runme_add_sub_struct.m'),...
    fullfile('workdir', 'runme_simple.m'),...
    fullfile('workdir', 'runme_buildsimulinkmodel.m')...
    }, rootfolder)
