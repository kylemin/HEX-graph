function [upMsgTable, downMsgTable] = messageTable(cliqParents, childVariables, upPass, sumProduct)

% 10212016, created by Kyle Min (yappi62@gmail.com)
% MsgTables and MsgIndice will be used to boost the speed of messagePassing
% This function should be called after getting sumProduct)
tic;
numC = length(childVariables);
upMsgTable = cell(numC, 1);

% first pass (up pass): message pass from leaves to root
for i = 1 : numC
    c = upPass(i);
    
    % order of neighbors: child_1, child_2, ..., parent
    nei = sumProduct{c};
    numState = size(nei, 2);
    children = childVariables{c};
    
    % loop over each neighbor and each state (of this clique)
    for j = 1 : length(children)
        child = children(j);
        % the neighbor's number of (its own) neighbor
        for m = 1 : numState
            vNei = nei{j, m};
            for n = 1 : length(vNei)
                numNei = vNei(n);
                
                exist = false;
                lenTable = length(upMsgTable{child});
                for k = 1 : lenTable;
                    if upMsgTable{child}(k) == numNei;
                        exist = true;
                        break;
                    end
                end
                
                if ~exist
                    upMsgTable{child}(lenTable+1) = numNei;
                end
            end
        end
    end
end

for i = 1 : numC
    upMsgTable{i} = sort(upMsgTable{i});
end


downMsgTable = cell(cell(numC, 2));

% second pass (down pass): message pass from root to leaves
% revert the up-pass sequence and skip the root
for i = (numC - 1) : -1 : 1
    c = upPass(i);
    
    % order of neighbors: child_1, child_2, ..., parent
    nei = sumProduct{c};
    numState = size(nei, 2);
    
    % collect message from parent clique
    cParent = cliqParents(c);
    prod_idx = (childVariables{cParent} ~= c);
    
    if cliqParents(cParent)
        prod_idx = [prod_idx; true];
    end
    
    downMsgTable{c, 2} = prod_idx;
    
    for j = 1:numState
        vNei = nei{end, j};
        for m = 1 : length(vNei)
            numNei = vNei(m);
            
            exist = false;
            lenTable = length(downMsgTable{cParent});
            for k = 1 : lenTable;
                if downMsgTable{cParent}(k) == numNei;
                    exist = true;
                    break;
                end
            end
            
            if ~exist
                downMsgTable{cParent}(lenTable+1) = numNei;
            end
        end
    end
end

for i = 1 : numC
    downMsgTable{i} = sort(downMsgTable{i});
end
fprintf('messageTable Complete, tooks %.2f\n', toc);
end