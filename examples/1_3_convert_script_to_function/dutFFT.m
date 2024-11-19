function [yOut,validOut] = dutFFT(yIn,validIn,FFTLength)
% Processes one sample of FFT data using the dsphdl.FFT System Object(TM)
% yIn is a fixed-point scalar or column vector. 
% validIn is a logical scalar value.
% You can generate HDL code from this function.

% Copyright 2024 The MathWorks, Inc.

  persistent fftN;
  if isempty(fftN)
    fftN = zeros(1,1024,'like',fi(0,1,16,13)); 
    coder.varsize("fftN",[1 1024]);
    fftN = dsphdl.FFT('FFTLength',FFTLength);
  end    
  [yOut,validOut] = fftN(yIn,validIn);
end
