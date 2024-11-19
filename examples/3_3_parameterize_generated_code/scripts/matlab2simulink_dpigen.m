% matlab2simulink_dpigen - Takes a MATLAB function and builds a simulink
% system with the MATLAB function in one MATLAB function block, this makes
% it possible to use Simulink HDL Verifier to generate a parameterized
% interface so you can update the control portions less frequently than
% standard in/out signals
% functionname = name of the MATLAB function that we want to generate a
%               SystemVerilog DPI component out of
% ctrlports = cellarray of the signals on the function interface that are
%             to be parameters instead of normal in/out signals
% inputargs = cellarray containing the input arguments to the function, to
%             get correct type
% outputstructs = cellarray containing name of output that has a struct as return type
%                 The cellarray has format of {'name1', struct(), 'name2', struct...}
% DPIFixedPointDataType = 'BitVector'|'LogicVector'|'CompatibleCType(default)'
%              Sets the datatype used for fixedpoint datatypes in the DPI-C
%              SystemVerilog side
% outputfolder = all neccessary files are first copied into a tempfolder and
%              simulink model is built in that folder before moved back into 
%              this outputfolder (this way we're not interfering with an
%              already existing slprj folder)
% packfiles = 'true(default)|false' Uses the packNGo function from MATLAB  
%             to zip together all needed c source / header files for   
%             rebuilding the DPIC component standalone 
% packtype  = 'flat (default)|hierarchical' Sets the packing type of the c 
%             source/header files
% makeTB    = true/false. If true then we don't run the dpigen command but the model
%             is built with all inputs driven by From Workspace blocks and
%             they are driven by signals named as simin_<name of input>.
%             The idea here is to get a model that is close to simulation
%             ready, from that you can add the timeseries and then generate
%             the dpigen and also at the same time build a testbench for
%             the DPI-C component
% dpiassertions = cell array of format: { 'outputname', 
%                   {'Enabled:on/off',...
%                    'AssertionFailFcn:', ...
%                    'StopWhenAssertionFail:on/off',...
%                    'DPIAssertSeverity:error/warning/custom',...
%                    'DPIAssertCustomCommand:', ...
%                    'DPIAssertFailMessage:""' }}
% 
% The function to be converted must be able to have its file be renamed for the 
% duration of this script - this so that the dpigen component gets the correct
% naming. This means that if the function "myfunc" is defined in the file 
% myfunc.m then the file is briefly renamed to myfunc.m.tmp when the dpigen
% is building the DPI-C component.

function matlab2simulink_dpigen(NameValueArgs)
% Copyright 2024, The MathWorks, Inc.

    arguments
        NameValueArgs.functionname (1,:) char
        NameValueArgs.ctrlports (1,:) cell
        NameValueArgs.inputargs (1,:) cell
        NameValueArgs.outputstructs (1,:) cell = {}
        NameValueArgs.DPIFixedPointDataType (1,:) char = 'CompatibleCType'
        NameValueArgs.outputfolder (1,:) char = ''
        NameValueArgs.packfiles logical = true
        NameValueArgs.packtype (1,:) char = 'flat' 
        NameValueArgs.makeTB logical = false;
        NameValueArgs.dpiassertions (1,:) cell = {}
    end
    M2S_DPIC_VERSION = 'Version 1.5 2022-11-11';
    functionname = NameValueArgs.functionname;
    % Check if ctrlports was defined, if so set ctrlports to that
    ctrlports = {};
    if any(strcmp(fieldnames(NameValueArgs), 'ctrlports'))
        ctrlports = NameValueArgs.ctrlports;
    end
    inputargs = {};
    if any(strcmp(fieldnames(NameValueArgs), 'inputargs'))
        inputargs = NameValueArgs.inputargs;
    end
    DPIFixedPointDataType = NameValueArgs.DPIFixedPointDataType;
    
    cwd = pwd;
    % tmpfolder = tempname(fullfile(tempdir, 'matlab2simulink_dpigen'));
    tmpfolder = fullfile(tempdir, 'matlab2simulink_dpigen', char(datetime('now','Format','yMMMd_HHmmss')));
    description(tmpfolder, functionname, M2S_DPIC_VERSION);
    % First make sure we copy all necessary files to tmp folder
    if ~exist(tmpfolder, 'dir')
       mkdir(tmpfolder)
    end
    % Check that the outputfolder exists
    if ~isempty(NameValueArgs.outputfolder)
        if ~exist(NameValueArgs.outputfolder, 'dir')
            mkdir(NameValueArgs.outputfolder)
        end
    end

    neededfiles = matlab.codetools.requiredFilesAndProducts(functionname);
    for nn=1:numel(neededfiles)
        copyfile(neededfiles{nn},tmpfolder);
    end
    % now that the files are in a temporary folder lets remove the search
    % path to the original function folder
    % paths = path;
    % TODO: It might turn up on multiple path's?? Especially if something
    % has gone wrong in previous runs...
    [oldpath,~,~] = fileparts(which(functionname));
    s = pathsep;
    pathStr = [s, path, s];
    onPath  = contains(pathStr, [s, oldpath, s], 'IgnoreCase', ispc);
    % Hide the original path
    if onPath
        rmpath(oldpath);
    end
    cd(tempdir)
    % Check that we can't find the functionname anymore
    funcpaths = which(functionname,'-all');
    if ~isempty(funcpaths)
        warning backtrace off
        for nn=1:length(funcpaths)
            warning([functionname ' also found at: ' funcpaths{nn}])
        end
        warning backtrace on
        % remove the tmpfolder before erroring out
        delete_tmpdir(tmpfolder);
        error_msg = sprintf(['There are one or more paths containing the same function \n' ...
            'this would make the generated dpi component contain the wrong name\n' ...
            'Please remove if possible the paths listed above from MATLAB''s search path - Stopping']);
        error(error_msg);
    end
    addpath(tmpfolder);
    cd(tmpfolder)

    modelname = [functionname  '_top'];

    if NameValueArgs.makeTB
        % First we'll open a runme_sim_build.m file that is for simulating and
        % building the generated model
        fout = fopen('runme_sim_build.m', 'w');
        fprintf(fout, 'load(''baseWorkspace.mat'')\n');
        fprintf(fout, 'open_system(''%s'')\n', modelname);
        fprintf(fout, 'simStopTime = 10; %% TODO: Set to the number of inputs you have\n\n');
        fprintf(fout, '%% Here are the inputs that needs to be set before running this script\n');
    end
%     zip('needed_m_files.zip', neededfiles);
    open_system(new_system(modelname));

    subsystemname = functionname ;
    subsystempath = [modelname '/' subsystemname];
    add_block('simulink/Ports & Subsystems/Subsystem', subsystempath)
    
    set_param(subsystempath, 'position',[315,120,395,200]);
    delete_line(subsystempath,'In1/1','Out1/1'); % Remove the line between input1 and output 1
    delete_block([subsystempath '/In1']);
    delete_block([subsystempath '/Out1']);
    
    % Add the MATLAB function block inside
    add_block('simulink/User-Defined Functions/MATLAB Function',[subsystempath '/cfunc'])
    
    % If something has gone wrong in the previous call then we still
    % have the .tmp file if so rename it to the original filename and
    % continue, but only do so if there is no functionname without .tmp
    % extension, should only occur when developing the code
    fname = [functionname '.m'];
    if (isfile([fname '.tmp']) && ~(isfile(fname)))
        movefile([fname '.tmp'], fname);
    end
    
    % Read in the original function code
    fname = which(functionname);
    fid = fopen(fname);
    tline = fgetl(fid);
    str = '';
    while ischar(tline)
        str=[str, tline, 10]; % 10 here is a newline
        tline = fgetl(fid);
    end
    fclose(fid);
    % temporary rename the function - rename back at end - This is so that
    % the original MATLAB function doesn't shadow the simulink system and
    % so that the generated code doesn't get an unneccessary rename in the
    % output
    movefile(fname, [fname '.tmp']);
    % Now populate this MATLAB function block with the correct code...
    rt = sfroot;
    block = find(rt,'-isa','Stateflow.EMChart', 'Path', [modelname '/' subsystemname '/cfunc']);
    block.Script = str;    

    % Now get the inputs / outputs of the MATLAB function block
    matlabcfuncH = get_param([subsystempath '/cfunc'], 'Handle');
    ihandles = find_system(matlabcfuncH, 'LookUnderMasks', 'on', 'FollowLinks', 'on', 'SearchDepth', 1, 'BlockType', 'Inport');
    ohandles = find_system(matlabcfuncH, 'LookUnderMasks', 'on', 'FollowLinks', 'on', 'SearchDepth', 1, 'BlockType', 'Outport');
    inportInfo = [get_param(ihandles, 'Name'), get_param(ihandles, 'Port')];
    % inportInfo is a cell array of names if there are more than one input,
    % and an empty cell array if no inputs
    % otherwise it is the name of the input
    if iscell(inportInfo)
        nrins = length(inportInfo);
    else
        nrins = 1;
    end
    outportInfo = [get_param(ohandles, 'Name'), get_param(ohandles, 'Port')];
    % outportInfo is a cell array of names if there are more than one
    % output otherwise it is the name of the output
    if iscell(outportInfo)
        nrouts = length(outportInfo);
    else
        nrouts = 1;
    end

    % Add inputs/outputs as needed
    portidx = 0;
    for nn=1:nrins
        if nrins == 1
            portname = inportInfo;
        else
            portname = inportInfo{nn};
        end
        porttype = [portname '_type'];
        if isstruct(inputargs{nn})
            assignin('base', porttype, inputargs{nn});
            % Need to create a bus and set the output datatype to that bus
            createBusFromStruct(evalin('base', porttype), porttype);
        end
        % TODO: Needs more testing, what about fixdt etc...
        % Detect the datatype for the input/control signal
        if isa(inputargs{nn}, 'embedded.fi')
            datatype = [ 'fixdt(' ...
                    num2str(inputargs{nn}.sign) ',' ...
                    num2str(inputargs{nn}.WordLength) ',' ...
                    num2str(inputargs{nn}.FractionLength) ')' ];
        elseif islogical(inputargs{nn})
            datatype = 'boolean';
        else
            datatype =  class(inputargs{nn});
        end

        if ~any(strcmp(ctrlports, portname)) % The portname is not part of the ctrlports so it's an input
            portidx = portidx + 1;
            add_block('simulink/Sources/In1', [subsystempath '/' portname]); % change the name of the inputs...
            set_param([subsystempath '/' portname], 'position',[100, 100+nn*30, 130, 114+nn*30]);
            add_line(subsystempath , [portname '/1'], ['cfunc/' num2str(nn)], 'autorouting', 'on')
            % Now add inputs on the up level as well
            portpath = [modelname '/' portname];
            if NameValueArgs.makeTB
                blocktype = 'simulink/Sources/From Workspace';
            else
                blocktype = 'simulink/Sources/In1';
            end
            add_block(blocktype, portpath); % change the name of the inputs...
            set_param(portpath, 'position', [100, 100+nn*30, 130, 114+nn*30]);
            add_line(modelname , [portname '/1'], [subsystemname '/' num2str(portidx)], 'autorouting', 'on')
            % Need to set the OutDataTypeStr to correct type on the inputs
            if isstruct(inputargs{nn})
                if NameValueArgs.makeTB
                    % Need to add one from workspace for each field...
                    % set how many inputs based on the struct fields...
                    set_param(portpath, 'OutDataTypeStr', ['Bus: ' porttype 'Bus']);
                    set_param(portpath, 'VariableName', ['simin_' portname]);
                    % now for each field add one from workspace block and
                    % connect to right input
                    fnames = fields(inputargs{nn});
                    for fieldidx=1:numel(fnames)
                        fprintf(fout, '%s = timeseries(0, 1:simStopTime); %% TODO: Change to your data in timeseries format\n', ['simin_' portname '.' fnames{fieldidx}]);
                    end

                else
                    set_param(portpath, 'OutDataTypeStr', ['Bus: ' porttype 'Bus']);
                    set_param(portpath, 'BusOutputAsStruct', 'on');
                end
            else
                if NameValueArgs.makeTB
                    set_param(portpath, 'VariableName', ['simin_' portname]);
                    fprintf(fout, '%s = timeseries(0, 1:simStopTime); %% TODO: Change to your data in timeseries format\n', ['simin_' portname]);
                end
                set_param(portpath, 'OutDataTypeStr', datatype);
                % complex input
                if ~isreal(inputargs{nn})
                    set_param(portpath, 'SignalType', 'complex');
                end
                % Set the size of the port if it's other than [1 1]
                zz = size(inputargs{nn});
                dimensions = length(zz);
                if dimensions > 1
                    str = '[';
                    for xx=1:dimensions
                        str = [str ' ' num2str(zz(xx))];
                    end
                    str = [str ' ]'];
                    if ~strcmp(str, '[ 1 1 ]')
                        set_param(portpath, 'PortDimensions', str);
                    end
                end
            end
        else
            % Control port... add constant block that is driven by a
            % Simulink.Parameter
            constantpath = [subsystempath '/' portname];
            add_block('simulink/Sources/Constant', constantpath);
            set_param(constantpath, 'position', [100, 100+nn*30, 130, 114+nn*30]);
            % set the Value to the name of the variable
            set_param(constantpath, 'Value', portname)
            add_line(subsystempath , [portname '/1'], ['cfunc/' num2str(nn)], 'autorouting', 'on')
            % In simulink we need the to set the output data type of the
            % constant block
            % if isstruct(evalin('base', porttype))
            if isstruct(inputargs{nn})
                % Need to create a bus and set the output datatype to that bus
                set_param(constantpath, 'OutDataTypeStr', ['Bus: ' porttype 'Bus']);
            else 
                assignin('base', porttype, inputargs{nn});
                set_param(constantpath, 'OutDataTypeStr', datatype);
            end
            evalin('base', [portname ' = Simulink.Parameter;']);
            evalin('base', [portname '.Value = ' porttype ';']);
            evalin('base', [portname '.set(''StorageClass'', ''Model default'');']);
            % TODO: Or should it be ExportedGlobal?
            % evalin('base', [portname '.set(''StorageClass'', ''ExportedGlobal'');']);
        end
    end
    % Now do the outputs...
    for nn=1:nrouts
        if nrouts == 1
            % if there is only one, then the name + portnumber is joined,
            % so the port name is really 1:end-1
            portname = outportInfo(1:end-1); 
        else
            portname = outportInfo{nn};
        end
        % Need to check if the portname is in the assertionlist if provided
        dpi_idx = 0;
        if ~isempty(NameValueArgs.dpiassertions)
            if any(strcmp(portname, NameValueArgs.dpiassertions))
                dpi_idx = find(strcmp(portname, NameValueArgs.dpiassertions));
            end
        end
        % Check if the portname is given in the outputstructs cell array
        add_bus_type = false;
        if any(strcmp(portname, NameValueArgs.outputstructs))
            % This output is a struct, we need to create the simulink bus
            % for it
            porttype = [portname '_type'];
            % Where is it? 
            idx = find(strcmp(portname, NameValueArgs.outputstructs));
            assignin('base', porttype, NameValueArgs.outputstructs{idx+1});
            % Need to create a bus and set the output datatype to that bus
            createBusFromStruct(evalin('base', porttype), porttype);
            add_bus_type = true;
        end
        % Add output port if not an assertion
        if (dpi_idx == 0)
            add_block('simulink/Sinks/Out1',[subsystempath '/'  portname]); 
            set_param([subsystempath '/' portname], 'position',[600, 100+nn*30, 630, 114+nn*30]);
            add_line(subsystempath , ['cfunc/' num2str(nn)], [portname '/1'], 'autorouting', 'on')
            % Now add outputs on the up level as well
            portpath = [modelname '/' portname];
            add_block('simulink/Sinks/Out1',portpath); 
            set_param(portpath, 'position',[600, 100+nn*30, 630, 114+nn*30]);
            add_line(modelname , [subsystemname '/' num2str(nn)], [portname '/1'], 'autorouting', 'on')
            if add_bus_type
                % The MATLAB function block is a stateflow object so we need to
                % define the output datatype a little bit differently
                rt = sfroot;
                obj = rt.find('-isa','Stateflow.EMChart');
                for yy=1:numel(obj)
                    if strcmp('cfunc', obj(yy).Name)
                        for xx=1:numel(obj(yy).Outputs)
                            if strcmp(portname, obj(yy).Outputs(xx).Name)
                                obj(yy).Outputs(xx).DataType = ['Bus: ' porttype 'Bus'];
                            end
                        end
                    end
                end
            end
        else
            % Insert dpi assert block
            add_block('dpiblklib/Assertion', [subsystempath '/' NameValueArgs.dpiassertions{dpi_idx} ]);
            set_param([subsystempath '/' portname], 'position',[600, 100+nn*30, 630, 114+nn*30]);
            add_line(subsystempath , ['cfunc/' num2str(nn)], [NameValueArgs.dpiassertions{dpi_idx} '/1'], 'autorouting', 'on')
            % Set the parameters on the Assertion block
            for xx=1:numel(NameValueArgs.dpiassertions{dpi_idx+1})
                arg = split(NameValueArgs.dpiassertions{dpi_idx+1}{xx},':');
                if (numel(arg) > 2)
                    error('Too many :''s in dpiassert command')
                    disp('Check the aruments for: ')
                    disp(NameValueArgs.dpiassertions{dpi_idx});
                else
                    if (numel(arg) ==2)
                        setting = arg{1};
                        value = arg{2};
                        set_param([subsystempath '/' NameValueArgs.dpiassertions{dpi_idx} ], setting, value);
                    end
                end
            end
% Enabled: 'on'
% AssertionFailFcn: ''
% StopWhenAssertionFail: 'on'
% DPIAssertCustomCommand: ''
% DPIAssertSeverity: 'error'
% DPIAssertFailMessage: ''            
        end
    end

    % Set systemverilog_dpi target and some other options specific for
    % SystemVerilog DPI target
    cs = getActiveConfigSet(modelname);
    switchTarget(cs,'systemverilog_dpi_grt.tlc',[]);
    cs.set_param('DPICompositeDataType', 'Structure');   % Composite data type 'Structure' / 'Flattened'
    cs.set_param('DPIPortConnection', 'Port list');      % Connection 'Interface' / 'Port list'
    cs.set_param('BusObjectLabelMismatch', 'error');     % Element name mismatch
    cs.set_param('DPIFixedPointDataType', DPIFixedPointDataType);   % Ports data type
    if NameValueArgs.makeTB
        cs.set_param('DPIGenerateTestBench', 'on')
    end
    % cs.set_param('PackageGeneratedCodeAndArtifacts', 'on') % Create a zip-file containing all
    
    % Resize the cfunc block so it looks better on the canvas
    maxheight = max(nrins,nrouts)*20 + 40;
    maxwidth = 150;
    % Set a position for the cfunc block
    set_param([subsystempath '/cfunc'], 'Position', [300 130 300+maxwidth 130+maxheight]);
    % Autoarrange the systems for cleaner layout
    Simulink.BlockDiagram.arrangeSystem(modelname);
    Simulink.BlockDiagram.arrangeSystem(subsystempath);
    % Save the system
    save_system(modelname);
    % Build the subsystem, i.e. create DPIGEN
    if ~NameValueArgs.makeTB
        slbuild(subsystempath);
        if NameValueArgs.packfiles
            % packNGo the needed files - check first that the buildInfo.mat file
            % exists
            if exist(fullfile(tmpfolder, [subsystemname '_build/buildInfo.mat']), 'file')
                load(fullfile(tmpfolder, [subsystemname '_build/buildInfo.mat']), 'buildInfo')
                if strfind(buildInfo.Settings.LocalAnchorDir, tmpfolder) % Check that the buildInfo references the correct tempdir
                    packNGo(buildInfo, 'packType', NameValueArgs.packtype) % Could be hiearchical if you want to keep dir-tree
                    movefile([subsystemname '.zip'], fullfile(cwd, NameValueArgs.outputfolder,[functionname '_dpic_c_sv_sourcefiles.zip']), 'f')
                else
                    warning('Something strange with buildInfo, seems to be from another build')
                end
            end
        end
    end
    if NameValueArgs.makeTB
        fprintf(fout, '\n%% Renaming %s.m so the generated DPI-C gets correct name\n', functionname);
        fprintf(fout, '[folder, filename, ext] = fileparts(which(''%s''));\n', functionname);
        fprintf(fout, 'org_file = fullfile(folder,[filename ext]);\n');
        fprintf(fout, 'tmp_file = fullfile(folder,[filename ext ''.tmp'']);\n');
        fprintf(fout, 'movefile(org_file, tmp_file)\n\n');
        fprintf(fout, 'cs = getActiveConfigSet(''%s'');\n', modelname);
        fprintf(fout, 'cs.set_param(''StartTime'', ''0'')\n');
        fprintf(fout, 'cs.set_param(''StopTime'', num2str(simStopTime))\n');
        fprintf(fout, 'cs.set_param(''FixedStep'', ''1'')\n');
        fprintf(fout, '\n');
        fprintf(fout, '\n');
        fprintf(fout, 'simout = sim(''%s'');\n', modelname);
        % TODO: If there are parameters they could be changed here
        % TODO: if so we need to save the in/out's into .dat files
        % use writematrix for that:
        % writematrix(dec2hex(simin_inputArg1.Data),'dpig_in1.dat','WriteMode', 'append')
        fprintf(fout, 'slbuild(''%s'')\n', subsystempath);
        fprintf(fout, '\n%% Renaming %s.m.tmp to it''s original name\n', functionname);
        fprintf(fout, 'movefile(tmp_file, org_file)\n');
        fclose (fout);
    end

    pause(2) % For giving the OS some time to close all file handles
    % Restore the original function file from the .tmp file we created 
    movefile([fname '.tmp'], fname);
    movefile([functionname '_top.slx'], fullfile(cwd, NameValueArgs.outputfolder), 'f')

    if ~NameValueArgs.makeTB
        movefile([functionname '_build'], fullfile(cwd, NameValueArgs.outputfolder), 'f')
    else
        movefile('runme_sim_build.m', fullfile(cwd, NameValueArgs.outputfolder), 'f')
    end
    % Save the workspace so we can rerun everything from the Simulink top
    fname = 'baseWorkspace.mat';
    str = ['save ' fname];
    evalin('base', str);
    copyfile('baseWorkspace.mat', fullfile(cwd, NameValueArgs.outputfolder), 'f')
    neededfiles{end+1} = fname;
    neededfiles{end+1} = fullfile(cwd, NameValueArgs.outputfolder, [functionname '_top.slx']);
    % Create replay script for building dpi-c from slx file
    create_replay_script('runme.m', subsystempath);
    neededfiles{end+1} = 'runme.m';
    zipname = [functionname '_original_m_slx_files.zip'];
    zip(zipname, neededfiles);
    movefile(zipname, fullfile(cwd, NameValueArgs.outputfolder), 'f');
    cd(cwd)
    % Cleanup after us ... Remove the tmp dir we used
    rmpath(tmpfolder);
    % Close the simulink system 
    close_system(modelname);
    pause(2) % For giving the OS some time to close all file handles
    delete_tmpdir(tmpfolder);
    if onPath
        addpath(oldpath)
    end
end

function delete_tmpdir(tmpfolder)
    if exist(tmpfolder, 'dir') 
        % TODO: This doesn't work even though it should. Sometimes it fails 
        % to remove the empty folder, why? Seems to be a stale filehandle -
        % using try catch so we still run to completion
        try
            rmdir(tmpfolder, 's') % force remove directory
        catch
            disp(['This script used temporary folder: ' tmpfolder]);
            disp('Failed to remove it - please remove it after having closed MATLAB')
        end
    end
end

function createBusFromStruct(structIn, objectName)
    structIn = structIn(1);
    busname = sprintf('%sBus', objectName);
    if fnBaseWSExist(busname)
        warning OFF BACKTRACE
        warning('%s already exists in workspace - overwriting',busname)
        warning ON BACKTRACE
    end
    configBus = Simulink.Bus;
    configBus.Elements = [];
    temp = fieldnames(structIn);
    complexRealMap = {'real','complex'};
    for iReg = 1:numel(temp)
        tempReg = Simulink.BusElement;
        tempReg.Name = temp{iReg};
        tempReg.Dimensions = size(structIn.(temp{iReg}));
        % Check if field is struct which requires subBus
        if isstruct(structIn.(tempReg.Name)) || isobject(structIn.(tempReg.Name))
            subBusName = [objectName tempReg.Name];
            createBusFromStruct(structIn.(tempReg.Name), subBusName);
            tempReg.Complexity = 'real';
            tempReg.DataType = sprintf('Bus:%sBus',subBusName);
        else
            % Value Registers
            tempReg.Complexity = complexRealMap{~isreal(structIn.(temp{iReg}))+1};
            typeTemp = class(structIn.(temp{iReg}));
            % Must use strcmpi since it is strings that are being compared
            if strcmpi(typeTemp, 'logical')
                typeTemp = 'boolean';
            end
            tempReg.DataType = typeTemp;
        end
        % Assign element
        configBus.Elements = [configBus.Elements; tempReg];
    end
    % Assign the created bus into the base workspace
    assignin('base',busname,configBus);
end

function InBaseWS=fnBaseWSExist(var1)
  W = evalin('base','who');
  InBaseWS=0;
  for ii= 1:length(W)
    nm1=W{ii};
    InBaseWS=strcmp(nm1,var1)+InBaseWS;
  end
  InBaseWS = InBaseWS>0;
end

function description(tmpfolder, funcname, M2S_DPIC_VERSION)
    disp('############################################################')
    disp(['## matlab2simulink_dpigen - ' M2S_DPIC_VERSION])
    disp('## This function takes a MATLAB function and creates')
    disp('## a Simulink model containing that function.')
    disp('## From that Simulink Model dpigen is run to')
    disp('## generate a DPI-C component. You can keep structs and ')
    disp('## separate control ports from standard IO:s')
    disp('##')
    disp(['## The script needs to copy ' funcname ' and it''s dependencies'])
    disp('## to a temporary folder where it is renamed temporarily. ')
    disp('## Using temporary folder: ')
    disp(['## ' tmpfolder ])
    disp('############################################################')
end

function create_replay_script(filename, subsystempath)
    modelname = split(subsystempath, '/');
    topname = modelname{1};
    modelname = modelname{end};
    fid = fopen(filename,'w');
    fprintf(fid, '%% Load the workspace variables containing all buses / type definitions etc...\n');
    fprintf(fid, 'load baseWorkspace.mat\n');
    fprintf(fid, '%% Load the simulink system that was created\n');
    fprintf(fid, 'load_system(''%s'')\n', topname);
    fprintf(fid, '%% This just so that the generated DPI-C gets the correct name\n');
    fprintf(fid, 'movefile(''%s.m'', ''%s.m.tmp'');\n', modelname, modelname);
    fprintf(fid, 'slbuild(''%s'')\n', subsystempath);
    fprintf(fid, '%% After generation we can restore the correct name of the function\n');
    fprintf(fid, 'movefile(''%s.m.tmp'', ''%s.m'');\n', modelname, modelname);
    fclose(fid);
end