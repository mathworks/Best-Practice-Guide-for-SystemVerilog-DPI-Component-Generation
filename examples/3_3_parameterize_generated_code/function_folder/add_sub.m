function [outputArg1] = add_sub(mode, inputArg1, inputArg2)
% Copyright 2024 The MathWorks, Inc.
    if mode
        outputArg1 = inputArg1 + inputArg2;
    else
        outputArg1 = inputArg2 - inputArg1;
    end
end

