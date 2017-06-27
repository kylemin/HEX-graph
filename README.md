# HEX graph: Hierarchy and Exclusion graph #
This code implements the HEX graph described in the paper of Large-Scale Object Classification using Label Relation Graphs, in ECCV 2014. This code is based on the code of Ronghang Hu's repository on hex-graph, and is written in MATLAB.

## Code structure ##
There are basically two classes in this code, which are hexGraph and hexClassifier. hexGraph makes the HEX structure based on the information of hierarchy and exclusion, and hexClassifier inferences based on the HEX graph and the data.

### Subclasses
There are the following subclasees for hexGraph and hexClassifier.
* `hexGraph.checkConsistency(Eh, Ee)` : It checks Eh and Ee are both square with no self loops and no any two nodes direct each other. Also, it makes sure there is no directed loop for Eh and no no exclusion between its ancestors or between itself and its ancestors. Additionaly, it examines that the graph is connected and Ee is symmetric.
* `hexGraph.sparsifyDensify(Eh, Ee)` : Based on Lemma 1 of the paper, it makes sparsified and densified graph of Eh and Ee. It gives us minimally sparse and maximally dense equivalent graph.
* `hexGraph.junctionGraph(Ehs, Ees)` : First, it makes undirected adjacency matrix by using sparsifed graph. Next, it generates a variable elimination sequence by the method of minimal fill heuristic. Following the sequence, it proceeds an elimination and makes cliques. During this whole procedure, it records which cliques each variable appears in and how many times each variable appears.
* `hexGraph.junctionTree(cliques, size(Eh, 1))` : It compute the weight of each pair of cliques(i.e. length of intersect). It uses Kruskal algorithm to generate maximum spanning tree, and records parents and children of each cliques. Then, it makes a sequence from children to parents.
* `hexGraph.listStateSpace(Ehd, Eed, cliques)` : It lists state space by using densified graph based on Algorithm 1 of the paper. It records every states of each variable.
* `hexGraph.recordSumProduct(cliques, stateSpace, cliqParents, childVariables)` : It records how states in a clique is connected in states in neighbor cliques.
* `hexClassifier.assignPotential(cliques, stateSpace, numVar, f)` : It creates potential table for each clique inside the tree. In order to boost the speed, a table for the energy is created and used.
* `hexClassifier.messagePassing(cliqParents, childVariables, upPass, sumProduct, potentials)` : It executes the bi-directional message passing. First, it passes messages from leaves to root, and passes reserve direction.
* `hexClassifier.marginalProbability(variables, cliques, varTable, messages, potentials)` : It calculates margianl probability, including partition function.

### Example
```matlab
% This HEX graph is an example of the paper (Fig. 3)
% First, specify Eh and Ee (hierarchy and exclusion relations, repectively)
numV = 6;
Eh = sparse(false(numV));
Eh(1, 2) = true;
Eh(2, 3) = true;
Eh(2, 4) = true;
Eh(1, 4) = true;
Eh(1, 5) = true;
Ee = sparse(false(numV));
Ee(1, 6) = true;
Ee(5, 6) = true;
Ee = Ee | Ee';

% Next, make random data for testing
n = 30;
m = 200;
rng(0, 'twister');
x = rand(n, m);
y = randi([3, numV]), 1, m);
w = rand(n, numV)*1e-2;

% Then, use hexGraph and hexClassifier classes and check if they work
hexG = hexGraph(Eh, Ee);
w = minFuncSGD(@hexClassifier, hexG, w, x, y);
```

## Performance ##
### On the VGG-fc7 output of imagenet-2012 dataset
According to the paper, Top 1 accuracy of softmax-all should be less than that of hex, except the case of relabeling 99%
(in the case, accuracy of two methods are expected to be same). In order to verify this, I tested softmax-all and hex on VGG-fc7 output of imagenet-2012 dataset. The following table describes the performance of HEX, HEX-all, and softmax-all on the dataset. The performance of HEX is obtained by connecting the data to the leaf nodes of the graph. That of HEX-all is obtained by connecting the data to all nodes of the pre-trained HEX graph. The figures in the parenthesis are soft accuracy at distance 2.

| Relabelling  | HEX | HEX-all | Softmax-all |
| - | - | - | - |
| 0%  | 70.51% (75.80%) | 70.54% (75.81%) | 70.49% (75.84%) |
| 50%  | 70.22% (75.65%) | 70.33% (75.75%) | 69.61% (75.15%) |
| 90%  | 67.71% (73.80%) | 67.81% (73.86%) | 66.47% (72.66%) |
| 95%  | 65.84% (72.69%) | 65.87% (72.71%) | 63.91% (70.43%) |
| 99%  | 28.23% (54.10%) | 28.38% (54.13%) | 35.17% (45.82%) |

Since the HEX model of the paper is based on AlexNet, direct comparison of the performance is not possible. Also, the paper seems to have tested the model from scratch, but here the extracted output data of fc7 layer is used. Plus, this test utilizes WordNet hierarchy of 860 internal nodes, while the paper uses that of 820.
However, when it comes to the gain of accuracy compared to Softmax-all, it has the very similar trend with the paper's. This makes my code quite reasonable.

### On the cifar-100 dataset (from scratch)
For cifar-100 dataset, hex model gives much better result than softmax-all in every case. We can see that accuracy of HEX-all is higher than hex, while soft accuracy is lower. Unlike the case of imagenet-2012 dataset, the performances of HEX and HEX-all are better than Softmax-all in all cases, even in the case of relabelling 99%.

| Relabelling  | HEX | HEX-all | Softmax-all |
| - | - | - | - |
| 0%  | 41.12% (53.71%) | 43.58% (54.26%) | 41.37% (53.56%) |
| 50%  | 39.01% (53.03%) | 41.35% (52.90%) | 35.16% (48.64%) |
| 90%  | 33.48% (52.40%) | 35.45% (50.71%) | 23.67% (37.89%) |
| 95%  | 27.68% (51.22%) | 30.09% (49.22%) | 13.49% (27.85%) |
| 99%  | 15.51% (50.16%) | 15.79% (47.26%) | 3.66% (12.89%) |

### On the novel category data
| Relabelling  | HEX | HEX-all | Softmax-all |
| - | - | - | - |
| 0%  | 5.52% (20.67%) | 5.53% (20.69%) | 5.52% (20.65%) |
| 50%  | 5.47% (20.48%) | 5.48% (20.52%) | 8.69% (26.26%) |
| 90%  | 5.17% (20.01%) | 5.19% (20.06%) | 9.23% (28.56%) |
| 95%  | 4.98% (19.88%) | 4.98% (19.90%) | 9.25% (28.68%) |
| 99%  | 2.31% (17.55%) | 2.33% (17.60%) | 9.20% (28.64%) |

Performances of hex and hex-all on the novel categories are worse than softmax-all. The main difference of hex-all and softmax-all is that softmax-all on relabeled data always tends to indicate inner-class, so the predicted labels should be confined to leaf-classes (1~1000). If the predicted labels are not confined to leaf nodes, accuracy goes to 0. However, hex and hex-all don't depend on such constraint. Therefore, if test dataset doesn't contain a lot of novel category data, hex and hex-all should be better than softmax-all.

## Comment
By the above examinations, it is proved that HEX and HEX-all models can perform better than softmax in most relabelling cases, as argued in the original paper. However, HEX model cannot predict novel categories better than softmax. This is also the case for the HEX-all model. It seems that the inner nodes, or super categories, can help HEX and HEX-all models predict better only the leaf categories. Therefore, HEX models are not suitable for zero-shot inference. Even if this is not exactly the replication of the original paper, the result is quite reasonalbe. The differences with the paper are 1) this is on top of 16-layer VGGNet, while the paper is on AlexNet, 2) extracted output data of fc7 layer is used, while the paper seems to have tested the model from scratch, 3) the number of hierarchy of WordNet (here: 860, paper: 820). However, when it comes to the gain of accuracy compared to Softmax-all, it has the very similar trend with the paper's.
