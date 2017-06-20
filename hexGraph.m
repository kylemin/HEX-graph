function hexG = hexGraph(Eh, Ee)

% 10082016, written by Kyle Min (yappi62@gmail.com)
% If the structure of graph does not change(that is, Eh and Ee are
% constant, then save hexG as a .mat file after calling this function

hexGraph.checkConsistency(Eh, Ee);
[Ehs, Ees, Ehd, Eed] = hexGraph.sparsifyDensify(Eh, Ee);
[cliques, variables, numVar] = hexGraph.junctionGraph(Ehs, Ees);
[cliqParents, childVariables, upPass] = hexGraph.junctionTree(cliques, size(Eh, 1));
[stateSpace, varTable] = hexGraph.listStateSpace(Ehd, Eed, cliques);
sumProduct = hexGraph.recordSumProduct(cliques, stateSpace, cliqParents, childVariables);
[upMsgTable, downMsgTable] = hexGraph.messageTable(cliqParents, childVariables, upPass, sumProduct);

hexG.cliques = cliques;
hexG.variables = variables;
hexG.numVar = numVar;
hexG.cliqParents = cliqParents;
hexG.childVariables = childVariables;
hexG.upPass = upPass;
hexG.stateSpace = stateSpace;
hexG.varTable = varTable;
hexG.sumProduct = sumProduct;
hexG.upMsgTable = upMsgTable;
hexG.downMsgTable = downMsgTable;

end