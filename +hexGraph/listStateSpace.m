function [stateSpace, varTable] = listStateSpace(Ehd, Eed, cliques)

% 10282016, modified by Kyle Min (yappi62@gmail.com)
% Original function name was 'list_state_space'
% Lines from 30 ~ end are added(and some minor changes of names).
% This function should be called after junctionTree and sparsifyDensify
% (Because this function needs densified HEX graph)

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

% List state space of all cliques.
% For each clique cell, state space matrix is a logical matrix. Each row
% is a state vector. The order of variables in each row is the same as in
% 'cliques'.
stateSpace = cell(numC, 1);
% the variable-state table of each clique, to compute marginal probability
% of a variable within a clique
varTable = cell(numC, 1);

% List state space using densified graph
for c = 1 : numC
    cliq = cliques{c};
    lenCliq = length(cliq);
    % Preallocation of matrix that includes information about states
    sC = zeros(0, lenCliq);
    % Call recursive function
    [states, ~, ~] = listCliqueState(cliq, sC, sC, false(1, lenCliq), cliq, Ehd, Eed);
    
    % list the variable-state table for each clique
    % record the states associated with a variable
    table = cell(lenCliq, 1);
    for v = 1:lenCliq
        table{v} = find(states(:, v));
    end
    
    % store them
    stateSpace{c} = states;
    varTable{c} = table;
end
fprintf('listStateSpace Complete, tooks %.2f\n', toc);
end


function [states, sCO, sMat] = listCliqueState(qC, sC, states, sMat, cliq, Ehd, Eed)
    lenCliq = length(cliq);
    qC0 = qC; % Queue for setting fixed nodes as 0
    qC1 = qC; % Queue for setting fixed nodes as 1
    qS = [];
    qT = [];
    
    % Fix 0 itself and its children
    [qC0, value] = mQueue.poll(qC0);
    qT = mQueue.add(qT, value);
    while ~isempty(qT)
        [qT, s] = mQueue.poll(qT);
        for i = 1 : length(qC0)
            t = qC0(i);
            if Ehd(s, t)
                qT = mQueue.add(qT, t);
            end
        end
        
        for i = 1 : length(qT)
            qC0 = mQueue.remove(qC0, qT(i));
        end
        qS = mQueue.add(qS, s);
    end
    smat = zeros(2, lenCliq);
    smat(1, 1:length(qS)) = qS;
    sCO = cat(1, sC, smat); % Set all fixed nodes
    if ~isempty(qC0)
        % Call itself to set subgraph
        [states, sCO, sMat] = listCliqueState(qC0, sCO, states, sMat, cliq, Ehd, Eed);
    else
        % This is to mark the last variable
        %sCO(end-1, :) = -sCO(end-1, :);
        if sCO(1,1) == cliq(1)
            sMat = sMat .* false;
        end
        for i = 1 : 2 : size(sCO, 1)
            for j = 1 : size(sCO, 2)
                p = sCO(i, j);
                if p
                    sMat(find(cliq == p)) = sCO(i+1, j);
                end
            end
        end
        states = cat(1, states, sMat);
        sCO = zeros(0, lenCliq);
    end
    qS = [];
    
    % Fix 1 itself and its parents
    [qC1, value] = mQueue.poll(qC1);
    qT = mQueue.add(qT, value);
    while ~isempty(qT)
        [qT, s] = mQueue.poll(qT);
        for i = 1 : length(qC1)
            t = qC1(i);
            if Ehd(t, s)
                qT = mQueue.add(qT, t);
            end
        end
        
        for i = 1 : length(qT)
            qC1 = mQueue.remove(qC1, qT(i));
        end
        qS = mQueue.add(qS, s);
    end
 
    % Fix 0 for exclusion
    for i = 1 : length(qS)
        s = qS(i);
        for j = 1 : length(qC1)
            t = qC1(j);
            if Eed(s, t)
                qT = mQueue.add(qT, t);
            end
        end
        for j = 1 : length(qT)
            qC1 = mQueue.remove(qC1, qT(j));
        end
    end
    
    smat = zeros(2, lenCliq);
    smat(1, 1:(length(qS)+length(qT))) = [qS qT];
    smat(2, 1:length(qS)) = 1;
    sCO = cat(1, sCO, smat);
    
    if ~isempty(qC1)
        % Call itself to set subgraph
        [states, sCO, sMat] = listCliqueState(qC1, sCO, states, sMat, cliq, Ehd, Eed);
    else
        % This is to mark the last variable
        %sCO(end-1, :) = -sCO(end-1, :);
        if sCO(1,1) == cliq(1)
            sMat = sMat .* false;
        end
        for i = 1 : 2 : size(sCO, 1)
            for j = 1 : size(sCO, 2)
                p = sCO(i, j);
                if p
                    sMat(find(cliq == p)) = sCO(i+1, j);
                end
            end
        end
        states = cat(1, states, sMat);
        sCO = zeros(0, lenCliq);
    end
end

