function generate_uvm_component(options)
% Copyright 2024, The MathWorks, Inc.

    arguments
        options.FunctionName  {mustBeText} = 1 % Name of the function you ran dpigen on
        options.CodegenDir  {mustBeText} = 1 
        options.TemplateFile  {mustBeText} = 1
        options.ClassName  {mustBeText} = 1 
        options.ClassDir {mustBeText} = 1
    end

    fcnname=options.FunctionName;
    codegendir=options.CodegenDir;
    templatefile = options.TemplateFile;
    classname = options.ClassName;
    classdir = options.ClassDir;

    svPkgFilename = fullfile( codegendir, [fcnname '_dpi_pkg.sv']);
    svPkgFileID = fopen(svPkgFilename);
    tline = fgetl(svPkgFileID);
    re_dpic = '^import "DPI-C" function (?<TYPE>chandle|void) (?<FUNCTION>.*)';
    dpic_init='';
    dpic_fcn='';
    dpic_reset='';
    dpic_terminate='';
    % We must find the DPI-C functions looking like:
    % import "DPI-C" function chandle DPI_myfunction1_initialize(chandle existhandle);
    % import "DPI-C" function void DPI_myfunction1_terminate(input chandle objhandle);

    % NOT this one: import "DPI-C" function chandle DPI_myfunction1_reset_f(input chandle objhandle,
    % function chandle DPI_myfunction1_reset(input chandle objhandle,

    % NOT this one: import "DPI-C" function void DPI_myfunction1_output_f(input chandle objhandle,
    % function void DPI_myfunction1_output(input chandle objhandle,

    % NOT this one: import "DPI-C" function void DPI_myfunction1_update_f(input chandle objhandle,
    % function void DPI_myfunction1_update(input chandle objhandle,

    % NOT this one: import "DPI-C" function void DPI_myfunction1_setparam_ctrl_reg_f(input chandle objhandle,
    % function void DPI_myfunction1_setparam_ctrl_reg(input chandle objhandle,

    % NOT this one: import "DPI-C" function void DPI_myfunction1_setparam_ctrl_reg2_f(input chandle objhandle,
    % function void DPI_myfunction1_setparam_ctrl_reg2(input chandle objhandle,

    while ischar(tline)
        % disp(tline)
        tokennames = regexp(tline, re_dpic, 'names');
        if ~isempty(tokennames)
            if (startsWith(tokennames.FUNCTION,['DPI_' fcnname '_initialize']))
                dpic_init=split(tokennames.FUNCTION(1:end-1),'('); % Remove last ;
                dpic_init{2} = ['(' dpic_init{2}];
                dpic_init{3} = tokennames.TYPE;
                % Replace the existhandle with objhandle
                dpic_init{2} = regexprep(dpic_init{2}, 'existhandle', 'objhandle');
                tmparr = split(dpic_init{2}(2:end-1),',');
                args = '';
                for nn=1:length(tmparr)
                    xx = split(tmparr{nn});
                    args = [args xx{end} ', '];
                end
                dpic_init{4} = ['(' args(1:end-2) ')']; % the args without specification
            elseif (startsWith(tokennames.FUNCTION,['DPI_' fcnname '_terminate']))
                dpic_terminate=split(tokennames.FUNCTION(1:end-1),'(');% Remove last ;
                dpic_terminate{2} = ['(' dpic_terminate{2}];
                dpic_terminate{3} = tokennames.TYPE;
                % Replace the existhandle with objhandle
                dpic_terminate{2} = regexprep(dpic_terminate{2}, 'existhandle', 'objhandle');
                tmparr = split(dpic_terminate{2}(2:end-1),',');
                args = '';
                for nn=1:length(tmparr)
                    xx = split(tmparr{nn});
                    args = [args xx{end} ', '];
                end
                dpic_terminate{4} = ['(' args(1:end-2) ')']; % the args without specification
            elseif (startsWith(tokennames.FUNCTION,['DPI_' fcnname '_reset_f']))
                dpic_reset=split(tokennames.FUNCTION(1:end-1),'(');% Remove last ;
                dpic_reset{2} = ['(' dpic_reset{2}];
                dpic_reset{3} = tokennames.TYPE;
                tmparr = split(dpic_reset{2}(2:end),',');
                args = '';
                for nn=1:length(tmparr)
                    xx = split(tmparr{nn});
                    args = [args xx{end} ', '];
                end
                dpic_reset{4} = ['(' args(1:end-2) ')']; % the args without specification
            elseif (startsWith(tokennames.FUNCTION,['DPI_' fcnname]))
                dpic_fcn=split(tokennames.FUNCTION(1:end-1),'(');% Remove last ;
                dpic_fcn{2} = ['(' dpic_fcn{2}];
                dpic_fcn{3} = tokennames.TYPE;
                tmparr = split(dpic_fcn{2}(2:end-1),',');
                args = '';
                for nn=1:length(tmparr)
                    xx = split(tmparr{nn});
                    args = [args xx{end} ', '];
                end
                dpic_fcn{4} = ['(' args(1:end-2) ')']; % the args without specification
            end
        end

        tline = fgetl(svPkgFileID);
    end
    fclose(svPkgFileID);

%     [filepath,filename, fileext] = fileparts(which(fcnname));

    templatefileID = fopen(templatefile);
    if ~exist(classdir, 'dir')
        mkdir(classdir);
    end
    classfileID = fopen(fullfile(classdir, [classname '.svh']), 'w');

    tline = fgetl(templatefileID);
    re_dpicimportdecl = '^\s*<DPIC_IMPORT_DECL>';
    re_classname = '<CLASSNAME>';
    re_dpicreset = '<DPIC_RESET>';
    re_dpicinit = '<DPIC_INIT>';
    re_dpicfcn = '<DPIC_FCN>';
    re_dpicterminate = '<DPIC_TERMINATE>';
    while ischar(tline)
        % disp(tline)
        if (regexp(tline, re_dpicimportdecl))
            tline = sprintf('import "DPI-C" function %s %s%s;\n', dpic_init{3}, dpic_init{1}, dpic_init{2});
            tline = sprintf('%simport "DPI-C" function %s %s%s;\n', tline, dpic_reset{3}, dpic_reset{1}, dpic_reset{2});
            tline = sprintf('%simport "DPI-C" function %s %s%s;\n', tline, dpic_fcn{3}, dpic_fcn{1}, dpic_fcn{2});
            tline = sprintf('%simport "DPI-C" function %s %s%s;\n', tline, dpic_terminate{3}, dpic_terminate{1}, dpic_terminate{2});
        elseif (regexp(tline, re_classname))
            tline = regexprep(tline, re_classname, classname);
        elseif (regexp(tline, re_dpicreset))
            tline = regexprep(tline, re_dpicreset, [dpic_reset{1} dpic_reset{4}]);
        elseif (regexp(tline, re_dpicinit))
            tline = regexprep(tline, re_dpicinit, [dpic_init{1} dpic_init{4}]);
        elseif (regexp(tline, re_dpicfcn))
            tline = regexprep(tline, re_dpicfcn, [dpic_fcn{1} dpic_fcn{4}]);
        elseif (regexp(tline, re_dpicterminate))
            tline = regexprep(tline, re_dpicterminate, [dpic_terminate{1} dpic_terminate{4}]);
        end
        fprintf(classfileID, '%s\n',tline);
        tline = fgetl(templatefileID);
    end
    fclose(templatefileID);
    fclose(classfileID);

end