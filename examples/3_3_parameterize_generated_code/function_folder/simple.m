function [outputArg1] = simple(valid, opt1, inputArg1, inputArg2)
% Copyright 2024 The MathWorks, Inc.

    if valid
        outputArg1 = inputArg1 + opt1;
    else
        outputArg1 = inputArg2 - opt1;
    end
end

