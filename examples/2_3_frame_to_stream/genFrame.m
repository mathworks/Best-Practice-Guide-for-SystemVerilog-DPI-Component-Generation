function [data_vec] = genFrame(nsamples) %#codegen
% Copyright 2024 The MathWorks, Inc.

 data_vec = zeros(1,nsamples,'uint8');
 data_vec(:) = randi(255,1,nsamples,'uint8'); 
 coder.varsize('data_vec',[1 256],[0 1]);  


end

