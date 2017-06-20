function checkConsistency(Eh, Ee)

% 09282016, modified by Kyle Min (yappi62@gmail.com)
% Original function name was 'check_consistency'
% Lines from 41 ~ end are added(and some minor changes of names).
% This function can be called anytime(usually at first)

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
numV = size(Eh, 1);

% Check whether the type and size of Eh and Ee are valid
assert(islogical(Eh) && islogical(Ee));
assert(numV == size(Eh, 2) && size(Ee, 1) == size(Ee, 2));
assert(numV == size(Ee, 1));

% Check that both Eh and Ee have no self-loops
assert(~any(diag(Eh, 0)));
assert(~any(diag(Ee, 0)));

% Check basic conditions for hierarchy and exclusion edges:
% Eh must satisfy that ~(Eh(i, j) && Eh(j, i)))
% Ee must satisfy that Ee(i, j) == Ee(j, i))
% Eh and Ee must satisify that Eh(i, j) && Ee(i, j) == 0, since
% hierarchy and exclusion cannot appear simutaneously
for i = 1:numV
    for j = 1:numV
        assert(~(Eh(i, j) && Eh(j, i)));
        assert(Ee(i, j) == Ee(j, i));
        assert(~(Eh(i, j) && Ee(i, j)));
    end
end

% Check that the graph is connected
qS = 1;
visited = false(numV, 1); % Start with marking all nodes as unvisited
while ~isempty(qS)
    [qS, s] = mQueue.poll(qS);
    for i = 1 : numV
        if ~mQueue.contains(qS, i) && ~visited(i)
            if Eh(s, i) || Eh(i, s) || Ee(i, s)
                qS = mQueue.add(qS, i);
            end
        end
    end
    visited(s) = true;
end
assert(sum(visited) == numV);

% Check there is no directed (hierarchy) loop
qS = []; % Queue for visited nodes
qU = 1:numV; % Queue for unvisited nodes

acyclic = true;
nEnd = true;
while acyclic
    visited = false(numV, 1);
    
    if isempty(qU)
        break;
    else
        [qU, u] = mQueue.poll(qU);
        qS = mQueue.add(qS, u);
    end
    
    while ~isempty(qS)
        [qS, s] = mQueue.poll(qS, false);
        for i = 1 : numV
            if Eh(s, i)
                % If visit visited node again, it means cyclic
                if visited(i) && ~mQueue.contains(qU, i)
                    acyclic = false;
                    break;
                end;
                if ~mQueue.contains(qS, i)
                    qS = mQueue.add(qS, i);
                end
                nEnd = false;
            end
        end
        
        visited(s) = true;
        qU = mQueue.remove(qU, s);
        if nEnd
            visited = visited.*false;
        else
            nEnd = true;
        end
    end
end
assert(acyclic);

% For each node, no exclusion edge between its ancestors or between
% itself and its ancestors
consistent = true;
for i = 1 : numV
    qT = i; % Temporary queue
    qA = i; % Ancestors queue
    
    while ~isempty(qT)
        [qT, k] = mQueue.poll(qT);
        for j = 1 : numV
            % Find every ancestors
            if Eh(j, k) && ~mQueue.contains(qA, j)
                qT = mQueue.add(qT, j);
                qA = mQueue.add(qA, j);
            end
        end
    end
    
    while length(qA) > 1
        [qA, k] = mQueue.poll(qA);
        for j = 1 : length(qA)
            if Ee(k, qA(j))
                consistent = false;
                break;
            end
        end
        if ~consistent
            break;
        end
    end
    
    if ~consistent
        break;
    end
end

assert(consistent);
fprintf('checkConsistency Complete, tooks %.2f\n', toc);
end