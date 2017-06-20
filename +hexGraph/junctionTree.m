function [cliqParents, childVariables, upPass] = junctionTree(cliques, numV)

% 09302016, modified by Kyle Min (yappi62@gmail.com)
% Original function name was 'max_span_tree'
% Changes only naming rule and interface of the function
% This function should be called after junctionGraph.

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

% Create junction graph and compute edge weights in junction graph. Edges
% are stored in num_edge*3 matrix edgesJG. Each row [i, j, w] are
% indices and weight of a edges in junction graph.
% Undirected edge is only stored once in edgesJG.
edgesJG = zeros(0, 3);
for c1 = 1 : numC - 1
    for c2 = c1 + 1 : numC
        % the weight of each edge is the variable number after intersection
        weight = length(intersect(cliques{c1}, cliques{c2}));
        if weight > 0
            edgesJG = cat(1, edgesJG, [c1, c2, weight]);
        end
    end
end

% Use Kruskal Algorithm to generate maximal spanning tree.
[Ej, Wj] = kruskal(edgesJG, numV);
fprintf('hexClassifier.junctionTree: junction tree weight: %d\n', Wj);

% Convert adjacency matrix by performing a depth-first search. Record each
% clique's parent and children, and clique sequence of up (first) message
% pass. The sequence of down (second) message pass is simply the revert.
% cliqParents records each clique's parent clique index (0 for root)
cliqParents = zeros(numC, 1);
% childVariables records eqch clique's children clique indices (empty
% for leaf)
childVariables = cell(numC, 1);
% the clique indices in up passage pass sequence.
upPass = [];

% depth-first search
% Select an arbitrary clique as root.
rootJT = 1;
visited = false(numC, 1);
cliq = rootJT;
while true
    cliqNei = find(Ej(:, cliq));
    % Visit all current clique's children who has not been visited yet.
    % If no children (leaf) or all children have been visited, then visit
    % current clique and back to parent.
    % message and to back to parents. If no parent (root), then stop.
    visitChild = false;
    cParent = cliqParents(cliq);
    for n = 1 : length(cliqNei)
        cChild = cliqNei(n);
        if (cChild ~= cParent) && (~visited(cChild))
            visitChild = true;
            break
        end
    end
    if visitChild
        % set up the parent node and separator of this child
        cliqParents(cChild) = cliq;
        % go down to its child clique
        cliq = cChild;
    else
        % visit current clique
        visited(cliq) = true;
        % set up current clique's children
        c_adjacency = Ej(:, cliq);
        if cParent > 0
            c_adjacency(cParent) = false;
        end
        childVariables{cliq} = find(c_adjacency);
        % add current clique to up-pass sequence
        upPass = cat(1, upPass, cliq);
        
        % go up to its parent clique if it is not root, otherwise stop.
        if cliqParents(cliq) > 0
            cliq = cliqParents(cliq);
        else
            break
        end
    end
end
assert(length(upPass) == numC);
fprintf('junctionTree Complete, tooks %.2f\n', toc);
end

function [Et, W] = kruskal(PV, numV)
% [Et, w] = kruskal(PV, numV)
%   Kruskal algorithm for finding maximum spanning tree
%
%   PV is nx3 martix. 1st and 2nd row's define the edge (2 vertices) and the
%   3rd is the edge's weight.
%   numV is number of vertices
%   Et is adjacency matrix of maximum spanning tree
%   w is maximum spanning tree's weight

% code modified from
% http://www.mathworks.com/matlabcentral/fileexchange/13457-kruskal-algorithm
% N.Cheilakos,2006

Et = false(numV);
if size(PV, 1) == 0
    W = 0;
    return
end

num_edge = size(PV,1);
% sort PV by descending weights order.
PV = fysalida(PV,3);
korif = zeros(1, numV);
insert_vec = true(num_edge, 1);
for i = 1 : num_edge
    % control if we insert edge[i,j] in the graphic. Then the graphic has
    % circle
    akmi = PV(i, [1 2]);
    [korif, c] = iscycle(korif, akmi);
    % insert the edge iff it does not introduce a circle
    insert_vec(i) = (c == 0);
    % Create maximum spanning tree's adjacency matrix
    if insert_vec(i)
        Et(PV(i, 1), PV(i, 2)) = true;
        Et(PV(i, 2), PV(i, 1)) = true;
    end
end
% Calculate maximum spanning tree's weight
W = sum(PV(insert_vec, 3));

end

function [korif, c] = iscycle(korif, akmi)
% [korif, c] = iscycle(korif, akmi)
%   Test whether there will be a circle if a new edge is added
%
%   korif is set of vertices in the graph
%   akmi is edge we insert in graph
%   c = 1 if we have circle, else c = 0

% code modified from
% http://www.mathworks.com/matlabcentral/fileexchange/13457-kruskal-algorithm
% N.Cheilakos,2006

g=max(korif)+1;
c=0;
n=length(korif);
if korif(akmi(1))==0 && korif(akmi(2))==0
    korif(akmi(1))=g;
    korif(akmi(2))=g;
elseif korif(akmi(1))==0
    korif(akmi(1))=korif(akmi(2));
elseif korif(akmi(2))==0
    korif(akmi(2))=korif(akmi(1));
elseif korif(akmi(1))==korif(akmi(2))
    c=1;
    return
else
    m=max(korif(akmi(1)),korif(akmi(2)));
    for i=1:n
        if korif(i)==m
            korif(i)=min(korif(akmi(1)),korif(akmi(2)));
        end
    end
end

end

function A = fysalida(A, col)
% A = fysalida(A, col)
%   swap matrix's rows, because we sort column (col) by descending order
%
%   A is matrix
%   col is column we want to sort

% code modified from
% http://www.mathworks.com/matlabcentral/fileexchange/13457-kruskal-algorithm
% N.Cheilakos,2006

[~, c] = size(A);
if col < 1 || col > c || fix(col) ~= col
    error(['error input value second argumment takes only integer values ' ...
        'between 1 & ' num2str(c)]);
end

[~, IX] = sort(A(:, col), 'descend');
A = A(IX, :);

end