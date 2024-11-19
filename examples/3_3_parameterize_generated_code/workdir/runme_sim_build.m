% Copyright 2024 The MathWorks, Inc.

load('baseWorkspace.mat')
open_system('add_sub_top')
simStopTime = 10; % TODO: Set to the number of inputs you have

% Here are the inputs that needs to be set before running this script
simin_inputArg1 = timeseries(uint8(1:simStopTime), 1:simStopTime); % TODO: Change to your data in timeseries format
simin_inputArg2 = timeseries(uint8(randi(20,1,simStopTime)), 1:simStopTime); % TODO: Change to your data in timeseries format

% Renaming add_sub.m so the generated DPI-C gets correct name
[folder, filename, ext] = fileparts(which('add_sub'));
org_file = fullfile(folder,[filename ext]);
tmp_file = fullfile(folder,[filename ext '.tmp']);
movefile(org_file, tmp_file)

cs = getActiveConfigSet('add_sub_top');
cs.set_param('StartTime', '0')
cs.set_param('StopTime', num2str(simStopTime))
cs.set_param('FixedStep', '1')


sim('add_sub_top')
slbuild('add_sub_top/add_sub')

% Renaming add_sub.m.tmp to it's original name
movefile(tmp_file, org_file)
