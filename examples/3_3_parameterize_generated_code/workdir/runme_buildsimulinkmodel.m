% Copyright 2024 The MathWorks, Inc.

addpath(fullfile(pwd,'..','function_folder'));
addpath(fullfile(pwd,'..','scripts'));

funcname = 'myfunction1';


matlab2simulink_dpigen(...
    functionname = funcname, ...
    ctrlports = {'ctrl_reg', 'ctrl_reg2'},... % What ports are the control ports and should be separated
    inputargs = {struct('valid1', logical(true), 'valid2', logical(false)), ... ctrl_reg input args to the function
        int8(0), ... data1
        struct('one', int8(0), 'two', int8(0)), ... data2 - test of struct as input
        complex(0,0), ... data3 test of complex data as input
        complex(1,1), ... data4 test of complex data as input
        fi(pi, 1, 11, 5), ... data5 - Test of fixed datatype
        fi(pi, 1, 11, 5), ... data6 - Test of fixed datatype
        uint8(zeros(2,3)), ...[uint8(1) uint8(2) uint8(3); uint8(2) uint8(3) uint8(4)], ...%data7 - Test for array on input
        uint8(7) , ... % ctrl_reg2 - this time not using struct
        logical(true) ... % data8
        }, ...
    DPIFixedPointDataType = 'BitVector', ... DPI data type port 'BitVector'|'LogicVector'|'CompatibleCType'
    ... packtype = 'hierarchical', ... % flat (default) or hierarchical
    ... packfiles = true, ... % true (default) or false
    outputfolder = 'dpic_builddir' ...
    )

