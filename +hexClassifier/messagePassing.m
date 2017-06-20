function messages = messagePassing(cliqParents, childVariables, upPass, ...
    sumProduct, potentials, upMsgTable, downMsgTable)

% 10212016, modified by Kyle Min (yappi62@gmail.com)
% Original function name was 'pass_message'
% Changes only naming rule and interface of the function
% This function should be called after getting potentials)

% AUTORIGHTS
% ---------------------------------------------------------
% Copyright (c) 2015, Ronghang Hu (huronghang@hotmail.com)
%
% This file is part of the HEX Graph code and is available
% under the terms of the Simplified BSD License provided in
% LICENSE. Please retain this notice and LICENSE if you use
% this file (or any portion of it) in your project.
% ---------------------------------------------------------

numC = length(childVariables);

% all incoming messages (from its neighbors) of each clique
messages = cell(numC, 1);
%mTable = cell(numC, 1);

% first pass (up pass): pass message from leaves to root
for i = 1 : numC
    c = upPass(i);
    
    % order of neighbors: child_1, child_2, ..., parent
    nei = sumProduct{c};
    numState = size(nei, 2);
    
    % message vector of this clique
    vm = zeros(size(nei));
    
    % collect message from children cliques
    children = childVariables{c};
    
    % loop over each neighbor and each state (of this clique)
    for j = 1 : length(children)
        child = children(j);
        % the neighbor's number of (its own) neighbor
        % collect message from this child
        lenTable = length(upMsgTable{child});
        prodMsg = zeros(lenTable, 1);
        visited = false(lenTable, 1);
        for m = 1 : numState
            sumMsg = 0;
            vNei = nei{j, m};
            for n = 1 : size(vNei, 1)
                numNei = vNei(n);
                pNei = potentials{child}(numNei);
                
                idx = find(upMsgTable{child} == numNei);
                if ~visited(idx)
                    prodMsg(idx) = prod(messages{child}(1:end-1, numNei), 1);
                    visited(idx) = true;
                end
                
                sumMsg = sumMsg + pNei * prodMsg(idx);
                
                % product the message from all (its own) children, but not its parent
                % sumMsg = sumMsg + pNei * mTable{child}(upMsgTable{child} == numNei);
            end
            vm(j, m) = sumMsg;
        end
    end
    % set up message cell after passing messages
    messages{c} = vm;
    %{
    if i ~= numC
        for k = 1 : length(upMsgTable{c})
            mTable{c}(k) = prod(vm(1:end-1, upMsgTable{c}(k)), 1);
        end
    end
    %}
end

% second pass (down pass): pass message from root to leaves
% revert the up-pass sequence and skip the root
for i = (numC - 1) : -1 : 1
    c = upPass(i);
    
    % order of neighbors: child_1, child_2, ..., parent
    nei = sumProduct{c};
    numState = size(nei, 2);
    
    vm = messages{c};
    
    % collect message from parent clique
    cParent = cliqParents(c);
    
    lenTable = length(downMsgTable{cParent});
    prodMsg = zeros(lenTable, 1);
    visited = false(lenTable, 1);
    for j = 1:numState
        sumMsg = 0;
        vNei = nei{end, j};
        for k = 1 : size(vNei, 1)
            numNei = vNei(k);
            pNei = potentials{cParent}(numNei);
            idx = find(downMsgTable{cParent} == numNei);
            if ~visited(idx)
                prodMsg(idx) = prod(messages{cParent}(downMsgTable{c, 2}, numNei), 1);
                visited(idx) = true;
            end
            
            sumMsg = sumMsg + pNei * prodMsg(idx);
        end
        vm(end, j) = sumMsg;
    end
    
    % set up message cell after passing messages
    messages{c} = vm;
end