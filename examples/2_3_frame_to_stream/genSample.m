function [o_data,o_valid,o_cnt] = genSample(nsamples,i_ready,rseed,restart)%#codegen
% Copyright 2024 The MathWorks, Inc.

%Declare persistent variables
persistent p_cnt p_state p_data_vec;

% State
ST_IDLE = 0;
ST_SEND = 1;
ST_DONE = 2;

if(isempty(p_state))
    rng(rseed);
    p_state    = ST_IDLE;
    p_cnt      = uint16(0);
    p_data_vec = zeros(1,nsamples,'uint8'); 
    coder.varsize('p_data_vec',[1 256],[0 1]);  
end

   data_cnt = nsamples;

   o_cnt = p_cnt;
   o_data = uint8(0);
   if(p_state == ST_SEND)
    o_data  = p_data_vec(p_cnt);
   end
 
   o_valid = boolean(p_state == ST_SEND);
   o_state = p_state;

   switch(p_state)
       case ST_IDLE
                   p_state(:) = ST_SEND;
                   p_cnt(:) = p_cnt + 1;
                   p_data_vec(:) = genFrame(nsamples);
                
       case ST_SEND
             if(i_ready && (p_cnt < data_cnt))
                    p_cnt(:) = p_cnt + 1;
               elseif (p_cnt == data_cnt)
                    p_state(:) = ST_DONE;
                    p_cnt(:) = 0;                    
             end     

       case ST_DONE 
            if(restart)
                p_state(:) = ST_IDLE;
            end
            
   end
                  

end