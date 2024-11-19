function [re,im] = genStim(Len, Fs,F1,F2,Mode) %#codegen
% Copyright 2024 The MathWorks, Inc.

% Generate Stimulus Data
MODE_SINE  = 0;
MODE_CHIRP = 1;
MODE_NOISE = 2;

coder.varsize('t',[ 1 1024] ,[0 1]);
t = (0:Len-1)/Fs;

rng('default');
switch Mode
    case MODE_SINE        
        x = 1.2*sin(2*pi*F1*t) + 1.5*cos(2*pi*F2*t); 
    case MODE_CHIRP
        x = chirp(t,F1,(Len-1)/Fs,F2);  %Chirp with linear instaneous freq deviation
    case MODE_NOISE 
         x = sin(2*pi*F1*t) + 0.75*cos(2*pi*F2*t) + 0.1*randn(size(t));
    otherwise
         x = 1.2*sin(2*pi*F1*t);
end
re = x;
im_zero = zeros(1,Len);
coder.varsize('im_zero',[ 1 1024] ,[0 1]);
re = fi(re,1,16,13);
im = fi(im_zero,1,16,13);


end

