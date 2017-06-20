function [loss, gradients] = hexClassifier(hexG, w, x, y)

% 10082016, written by Kyle Min (yappi62@gmail.com)
% Only this function is needed during learning. Also, before calling this
% function, loading hexG from a .mat file is required.

m = size(x, 2);
f = x'*w;
%f(:, 6:end) = 0;
%f = [x'*w, zeros(m, 8)];
lossA = zeros(1,m);
gradients = zeros(size(f));

cliques = hexG.cliques;
stateSpace = hexG.stateSpace;
numVar = hexG.numVar;
cliqParents = hexG.cliqParents;
childVariables = hexG.childVariables;
upPass = hexG.upPass;
sumProduct = hexG.sumProduct;
variables = hexG.variables;
varTable = hexG.varTable;
upMsgTable = hexG.upMsgTable;
downMsgTable = hexG.downMsgTable;

%sumPot = 0;
%sumMsg = 0;
%sumMar = 0;
%sumClp = 0;
for i = 1 : m
    %tic;
    potentials = hexClassifier.assignPotential(cliques, stateSpace, numVar, f(i, :));
    %sumPot = sumPot + toc; tic;
    messages = hexClassifier.messagePassing(cliqParents, childVariables, upPass, ...
        sumProduct, potentials, upMsgTable, downMsgTable);
    %sumMsg = sumMsg + toc; tic;
    [prMargin, z] = hexClassifier.marginalProbability(variables, cliques, varTable, messages, potentials);
    %sumMar = sumMar + toc;
    pMargin = prMargin/z;
    
    if prMargin(y(i)) == 0 || z == 0 || pMargin(y(i)) == 0 || z == inf
        fprintf('Continue at %d\n', i);
        continue;
    end
    
    %tic;
    potentials = hexClassifier.clampPotential(potentials, variables, cliques, varTable, y(i));
    %sumClp = sumClp + toc; tic;
    messages = hexClassifier.messagePassing(cliqParents, childVariables, upPass, ...
        sumProduct, potentials, upMsgTable, downMsgTable);
    %sumMsg = sumMsg + toc; tic;
    [prJoint, ~] = hexClassifier.marginalProbability(variables, cliques, varTable, messages, potentials);
    %sumMar = sumMar + toc;

    lossA(i) = - log(pMargin(y(i)));
    gradients(i, :) = - (prJoint ./ prMargin(y(i)) - pMargin)';
end
%fprintf('SumPot tooks %.2f seconds.\n', sumPot);
%fprintf('SumMsg tooks %.2f seconds.\n', sumMsg);
%fprintf('SumMar tooks %.2f seconds.\n', sumMar);
%fprintf('SumClp tooks %.2f seconds.\n', sumClp);
lambda = 1e-3;
loss = sum(lossA)/m+lambda*sumsqr(w)/2;
%gradients = gradients(:, 1:5);
gradients = x*gradients/m+lambda*w;
end