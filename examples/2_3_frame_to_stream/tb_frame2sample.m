function tb_frame2sample
% Copyright 2024 The MathWorks, Inc.

nsamples = randi(10,'uint32');
o_data  = zeros(1,nsamples,'uint8');
o_valid = logical(zeros(1,nsamples));
o_cnt   = zeros(1,nsamples,'uint8');

%Random Seed 
rseed = 100;

for i = 1:nsamples
  
 [o_data(i),o_valid(i),o_cnt(i)] = genSample(nsamples,true,rseed,false);

 fprintf("%d %d %x %x \n", nsamples, o_cnt(i), o_data(i),o_valid(i));
 
end

  %Reset 
 clear genSample;

end