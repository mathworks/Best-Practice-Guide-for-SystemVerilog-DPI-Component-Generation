function [o_data,o_valid,o_cnt,o_frame] = genFrame2Sample(Len, Fs,f1,f2,mode,i_ready,rst)%#codegen
% Copyright 2024 The MathWorks, Inc.

%Declare persistent variables
persistent p_cnt p_state p_data_vec;

% State
ST_IDLE = 0;
ST_SEND = 1;
ST_DONE = 2;

if(isempty(p_state))
    p_state    = ST_IDLE;
    p_cnt      = uint16(0);
    %p_data_vec = zeros(1,Len,'like', complex(fi(0,1,16,13))); 
    %coder.varsize('p_data_vec',[1 1024],[0 1]);  
    p_data_vec = zeros(1,1024,'like', fi(0,1,16,13)); % using fixed size to enable UVM build
    
end

   data_cnt = Len;

   o_cnt = p_cnt;
   %o_data = complex(fi(0,1,16,13));
   o_data = fi(0,1,16,13);
   if(p_state == ST_SEND)
    o_data  = p_data_vec(p_cnt);
   end
 
   o_valid = boolean(p_state == ST_SEND);
   o_state = p_state;

   %o_frame = zeros(1,Len,'like', complex(fi(0,1,16,13))); 
   %o_frame = zeros(1,Len,'double');
   %coder.varsize('o_frame',[1,1024],[0 1]);  
   o_frame = zeros(1,1024,'double');
   o_frame(:) = double(p_data_vec(:)); 
    
   switch(p_state)
       case ST_IDLE
                   p_state(:) = ST_SEND;
                   p_cnt(:) = 1;
                   [re,~] = genStim(Len, Fs,f1,f2,mode);
                   p_data_vec(1:Len) = re(1:Len);
                   
                
       case ST_SEND
             if(i_ready && (p_cnt < data_cnt))
                    p_cnt(:) = p_cnt + 1;
               elseif (p_cnt == data_cnt)
                    p_state(:) = ST_DONE;
                    p_cnt(:) = 0;                    
             end     

       case ST_DONE 
            if(rst)
                p_state(:) = ST_IDLE;
            end
            
   end
                  

end