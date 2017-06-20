function potentials = assignPotential(cliques, stateSpace, numVar, f)

% 10202016, modified by Kyle Min (yappi62@gmail.com)
% Original function name was 'assign_potential'
% In order to boost the speed, I made a table for energy
% This function should be called after getting state space)

% AUTORIGHTS
% ---------------------------------------------------------
% Copyright (c) 2015, Ronghang Hu (huronghang@hotmail.com)
%
% This file is part of the HEX Graph code and is available
% under the terms of the Simplified BSD License provided in
% LICENSE. Please retain this notice and LICENSE if you use
% this file (or any portion of it) in your project.
% ---------------------------------------------------------

numC = length(cliques);

% create potential table for each clique inside the tree
potentials = cell(numC, 1);
eTable = bsxfun(@rdivide, f', numVar);

for i = 1 : numC
    vc = cliques{i};
    vs = stateSpace{i};
    potential = vs*eTable(vc);
    %potentials{i} = exp(potential - max(potential));
    potentials{i} = exp(potential);
end

end