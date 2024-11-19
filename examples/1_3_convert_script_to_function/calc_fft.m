function [ f1, f2] = calc_fft(ref_frame,FFTLength,Fs,dut_mode) %#codegen
% Copyright 2024 The MathWorks, Inc.

coder.varsize('fft_calc',[1,1024],[0 1]);
coder.varsize('frange',[1,1024],[0 1]);

coder.varsize('frange',[1,1024],[0 1]);
coder.varsize('power',[1,1024],[0 1]);

coder.varsize('frange_half',[1,512],[0 1]);
coder.varsize('power_half',[1,512],[0 1]);


if(dut_mode ==1)
     fft_calc = ref_frame;
else
     fft_calc  = fft(ref_frame,FFTLength); % calculate FFT    
end
fft_ref  = fftshift(fft_calc);        % Shift fft_calc
frange = (-FFTLength/2:FFTLength/2-1)*(Fs/FFTLength); % 0-centered frequency range
power = abs(fft_ref).^2/FFTLength;  % 0 -centered power
frange_half = frange(FFTLength/2+1:FFTLength);
power_half = power(FFTLength/2+1:FFTLength);

[peaks,loc] = findpeaks(power_half,'MinPeakHeight',1);
for ii = 1:length(peaks)
    str = "REF_CALC";
    if(dut_mode ==1)
        str = "DUT_CALC";
    end
    fprintf("%s freq_%d = %6.6f \n", str,int8(ii),frange_half(loc(ii)));
end
   f1 = 0;f2 = 0;
   plen = length(peaks);
   if(plen>0)
    f1 = frange_half(loc(1));
   end
   if(plen>1)
    f2 = frange_half(loc(2));
   end
   if(plen>2)
       fprintf("INFO , Frequency Peaks = %d \n",int8(length(peaks)))
   end
end