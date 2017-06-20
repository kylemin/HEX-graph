function [pMargin, z] = marginalProbability(variables, cliques, varTable, messages, potentials)

% 10072016, modified by Kyle Min (yappi62@gmail.com)
% Original function name was 'pass_message'
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

numV = length(variables);
numC = length(cliques);

% calculate cluster belief and partition function
cBelief = cell(numC, 1);
for c = 1 : numC
    pc = potentials{c};
    mc = messages{c};
    belief = pc .* prod(mc, 1)';
    cBelief{c} = belief;
end

% calculate partition function (from any clique, the result is same)
z = sum(cBelief{1});

% calculate marginal probability of each variable via marginalizing in (the
% first) clique containing this variable
pMargin = zeros(numV, 1);
for v = 1 : numV;
    c = variables{v}(1);
    var = varTable{c};
    belief = cBelief{c};
    pMargin(v) = sum(belief(var{cliques{c} == v}));
end

end