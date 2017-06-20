function [cliques, variables, numVar] = junctionGraph(Ehs, Ees)

% 09302016, modified by Kyle Min (yappi62@gmail.com)
% Original function name was 'triangularize'
% Lines from 26 ~ 51 are added(and some minor changes of names).
% This function should be called after checking consistency.
% Also, usually after sparsifyDensify

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
% triangularize using sparsified HEX Graph to make cliques small
numV = size(Ehs, 1);

% Convert Ehs to undirected edges and combine with Ees to obtain the
% (undirected) adjacency matrix of all edges for variable elimination
Eelim = Ehs | Ehs' | Ees;

% Generate a variable elimination sequence by the method of minimal fill
% heuristic.
unvisited = true(numV, 1);
elimOrder = zeros(numV, 1);
Etemp = Eelim;
k = 0;
while k ~= numV
    numNei = sum(Etemp, 2);
    minNode = min(numNei(unvisited));
    for i = 1 : numV
        % Find minimal fill
        if unvisited(i) && numNei(i) == minNode
            for j = 1 : numV
                if Etemp(i, j)
                    Etemp(i, j) = false;
                    Etemp(j, i) = false;
                end
            end
            unvisited(i) = false;
            k = numV - sum(unvisited);
            elimOrder(k) = i;
        end
    end
end

% One can test the effect of heuristic order by setting just the following
% elimOrder = 1:numV;

% eliminate nodes to get elimination cliques
cliques = cell(numV, 0);
widthJT = 0;
for vid = 1 : numV
    v = elimOrder(vid);
    
    % Find its neighbours and form a clique.
    vNei = find(Eelim(:, v));
    numVN = length(vNei);
    
    % For a connected graph, a node should always have neighbors (except for
    % the last node) during the elimination process.
    assert((numVN >= 1) || (vid == numV));
    
    % Sorting is needed because of using priority queue later.
    %cliques{v} = sort([v; vNei]);
    cliques{v} = [v; vNei];
    
    % the junction tree width is the variable number (minus 1) of the largest
    % clique
    widthJT = max(widthJT, numVN);
    
    % connect all its neighbors and then eliminate the node in adjacency
    % matrix
    for n1 = 1 : numVN
        for n2 = (n1+1) : numVN
            Eelim(vNei(n1), vNei(n2)) = true;
            Eelim(vNei(n2), vNei(n1)) = true;
        end
    end
    Eelim(:, v) = false;
    Eelim(v, :) = false;
end
fprintf('hexClassifier.junctionGraph: junction tree width: %d\n', widthJT);

% Find maximal cliques from all elimination cliques.
numC = length(cliques);
keep = true(numC, 1);
for c1 = 1 : numC
    for c2 = (c1+1) : numC
        if ~keep(c1) || ~keep(c2)
            continue
        end
        % take intersection of two cliques
        cIntersect = intersect(cliques{c1}, cliques{c2});
        
        % if one clique contains another, then remove the small one
        if length(cIntersect) == length(cliques{c1})
            keep(c1) = false;
        elseif length(cIntersect) == length(cliques{c2})
            keep(c2) = false;
        end
    end
end
cliques = cliques(keep);
fprintf('hexClassifier.junctionGraph: clique number: %d\n', length(cliques));

% Record which cliques each variable appears in, so that it can be
% marginalized efficiently.
numC = length(cliques);
variables = cell(numV, 1);
for c = 1 : numC
    vc = cliques{c};
    for vid = 1 : length(vc)
        v = vc(vid);
        variables{v} = cat(1, variables{v}, c);
    end
end

% record how many times a variable appears
numVar = zeros(numV, 1);
for v = 1 : numV
    numVar(v) = length(variables{v});
end

fprintf('junctionGraph Complete, tooks %.2f\n', toc);
end