function y  = wrapper_moving_avg(x)
% Copyright 2024 The MathWorks, Inc.

if coder.target('MATLAB')
  y = call_moving_avg_mex(x);
  fprintf('Function Running in MATLAB \n');
else
  disp(coder.target());  
  y = call_moving_avg(x);
  fprintf('Function Running in generated code \n');
end
end