function [o_state,o_cnt,o_f1_exp,o_f1_dut] = fftchecker(ref_frame,dut_re,dut_im,dut_valid,FFTLength,Fs,Threshold) %#codegen
% Copyright 2024 The MathWorks, Inc.


% define few states
ST_COLLECT = 0;
ST_CHECK = 1;


persistent p_state p_cnt p_frame f1_exp f1_dut;

if(isempty(p_state))
    p_state = ST_COLLECT;
    p_cnt = uint32(1);
    f1_exp = 0;
    f1_dut = 0;
    %p_frame = zeros(1,1024,"double");
    p_frame = zeros(1,FFTLength,"double");
    coder.varsize('p_frame',[1 1024],[0 1]);
end


% dummy

o_cnt = p_cnt;
o_state = p_state;
o_frame = p_frame;
o_f1_exp = f1_exp;
o_f1_dut = f1_dut;

switch(p_state)
    case ST_COLLECT
        if(p_cnt > FFTLength)
            p_state(:) = ST_CHECK;
        elseif(dut_valid ==1)
            dut_c = complex(double(dut_re), double(dut_im));
            p_frame(p_cnt) = abs(dut_c);
            p_cnt(:) = p_cnt + 1;
        end
    case ST_CHECK
        p_cnt(:) = 1;
        % Do self checking here
        % Calculate FFT for reference
        [f1_exp, f2_exp] = calc_fft(ref_frame,FFTLength,Fs,0); % Checker mode
        [f1_dut, f2_dut] = calc_fft(p_frame,FFTLength,Fs,1);   % DUT mode
        if(abs(f1_exp-f1_dut) > Threshold)
            fprintf("ERROR | Expected F1 = %f and DUT F1 = %f \n",f1_exp, f1_dut);
        end
        if(abs(f2_exp-f2_dut) > Threshold)
            fprintf("ERROR | Expected F2 = %f and DUT F2 = %f \n",f2_exp, f2_dut);
        end

        p_state(:) = ST_COLLECT;
end


end

