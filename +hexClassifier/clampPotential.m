function potentials = clampPotential(potentials, variables, cliques, varTable, y)

% 10142016, modified by Kyle Min (yappi62@gmail.com)
% Original function name was 'clamp_potential'
% Changes only naming rule and interface of the function
% This function should be called after getting messages)

% AUTORIGHTS
% ---------------------------------------------------------
% Copyright (c) 2015, Ronghang Hu (huronghang@hotmail.com)
% 
% This file is part of the HEX Graph code and is available 
% under the terms of the Simplified BSD License provided in 
% LICENSE. Please retain this notice and LICENSE if you use 
% this file (or any portion of it) in your project.
% ---------------------------------------------------------

% set potentials of all states in which y_l = 0 to be zero
c_vec_containing_l = variables{y};
for cid = 1:length(c_vec_containing_l);
  c = c_vec_containing_l(cid);
  var_state_cell = varTable{c};
  
  % all the states that y_l = 1
  vid_idx = (cliques{c} == y);
  sid_vec = var_state_cell{vid_idx};
  
  % all the states that y_l = 0
  num_state = length(potentials{c});
  idx = true(num_state, 1);
  idx(sid_vec) = false;
  
  % set the potentials of y_l = 0 states to be zero
  potentials{c}(idx) = 0;
end

end