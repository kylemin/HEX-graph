function [Ehs, Ees, Ehd, Eed] = sparsifyDensify(Eh, Ee)

% 09292016, written by Kyle Min (yappi62@gmail.com)
% This function should be called after checking consistency.

%Ehs = sparse(Eh);
%Ehd = sparse(Eh);
%Ees = sparse(Ee);
%Eed = sparse(Ee);
tic;
Ehs = Eh;
Ehd = Eh;
Ees = Ee;
Eed = Ee;

numV = size(Eh, 1);

% About Eh (check directed path)

for i = 1 : numV
    qT = []; % Temporary queue
    qD = []; % Descendents queue
    for j = 1 : numV
        % Find every descendent
        if Eh(i, j)
            qT = mQueue.add(qT, j);
        end
    end
    
    % Find if there is a possible directed path
    while ~isempty(qT)
        [qT, t] = mQueue.poll(qT);
        for j = 1 : numV
            if Eh(t, j)
                qT = mQueue.add(qT, j);
                qD = mQueue.add(qD, j);
            end
        end
    end
    
    for j = 1 : length(qD)
        s = qD(j);
        if Eh(i, s)
            % Sparsify
            Ehs(i, s) = false;
        else
            % Densify
            Ehd(i, s) = true;
        end
    end
end

% About Ee (check exclusion edges)

for i = 1 : numV-1 % This is because Ee is symmetric matrix
    for j = i+1 : numV
        qi = [];  % Temporary queue
        qAi = []; % Queue for ancestors of node i
        qj = [];  % Temporary queue
        qAj = []; % Queue for ancestors of node j
        
        % Investigate only possible positions
        if ~Eh(i, j) && ~Eh(j, i)
            qi = mQueue.add(qi, i);
            qAi = mQueue.add(qAi, i); % Because qA should include the node i itself
            
            while ~isempty(qi)
                [qi, s] = mQueue.poll(qi);
                % Find every ancestors
                for k = 1 : numV
                    if Eh(k, s)
                        qi = mQueue.add(qi, k);
                        qAi = mQueue.add(qAi, k);
                    end
                end
            end
            
            qj = mQueue.add(qj, j);
            qAj = mQueue.add(qAj, j); % Because qA should include the node j itself
            
            while ~isempty(qj)
                [qj, s] = mQueue.poll(qj);
                % Find every ancestors
                for k = 1 : numV
                    if Eh(k, s)
                        qj = mQueue.add(qj, k);
                        qAj = mQueue.add(qAj, k);
                    end
                end
            end
        end
        
        exist = false;
        % Find if there is any e between nodes of qAi and qAj
        for m = 1 : length(qAi)
            s = qAi(m);
            for n = 1 : length(qAj)
                t = qAj(n);
                if Ee(s, t)
                    if ~(s==i&&t==j) && ~(s==j&&t==i)
                        exist = true;
                        break;
                    end
                end
            end
            if exist
                break;
            end
        end
        
        if exist
            if Ee(i, j)
                % Sparsify
                Ees(i, j) = false;
                Ees(j, i) = false;
            else
                % Densify
                Eed(i, j) = true;
                Eed(j, i) = true;
            end
        end
    end
end
fprintf('sparsifyDensify Complete, tooks %.2f\n', toc);
end