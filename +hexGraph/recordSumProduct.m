function sumProduct = recordSumProduct(cliques, stateSpace, cliqParents, childVariables)

% 10012016, modified by Kyle Min (yappi62@gmail.com)
% Original function name was 'record_sumprod'
% Changes only naming rule and interface of the function
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
tic;
numC = length(cliques);

% record how states in a clique is connected in states in neighbor cliques
sumProduct = cell(numC, 1);
for c = 1 : numC
    vc = cliques{c};
    % order of neighbors: child_1, child_2, ..., parent
    cNeis = childVariables{c};
    if cliqParents(c) > 0
        cNeis = cat(1, cNeis, cliqParents(c));
    end
    % states and state number of this clique
    statevc = stateSpace{c};
    numstate = size(statevc, 1);
    % visit all its neighbors
    neighbors = cell(length(cNeis), numstate);
    
    for n = 1 : length(cNeis)
        cNei = cNeis(n);
        vNei = cliques{cNei};
        % find intersection variables between current clique and neighbor
        % clique
        [~, v, vn] = intersect(vc, vNei);
        % states and state number of neighbor clique
        stateNei = stateSpace{cNei};
        numsNei = size(stateNei, 1);
        % for each s in this clique's s table, match it with associated
        % states in the neighbor's s table
        for i = 1 : numstate
            % state of intersection variables in this clique
            sIntersect = statevc(i, v);
            % state id list of matching neighbor states
            sid = [];
            for j = 1 : numsNei
                % state of intersection variables in neighbor clique
                sNeiIntersect = stateNei(j, vn);
                if all(sIntersect == sNeiIntersect)
                    sid = cat(1, sid, j);
                end
            end
            neighbors{n, i} = sid;
        end
    end
    sumProduct{c} = neighbors;
end
fprintf('recordSumProduct Complete, tooks %.2f\n', toc);
end