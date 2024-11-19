function tb_moving_avg
% Copyright 2024 The MathWorks, Inc.

% Construct a noisy sine wave with 1024 samples.
x = sin((2*pi/1024)*(1:1024)) + 0.8*rand(1,1024);

%Calculate the smoothed output.
y = wrapper_moving_avg(x); 

% Plot input and output.
plot(x)
hold on
plot(17:1024,y,'r')
end