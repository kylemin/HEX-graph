% 09282016, written by Kyle Min (yappi62@gmail.com)

%{
addpath ../stanford_dl_ex-master_BS/common
addpath ../stanford_dl_ex-master_BS/common/minFunc_2012/minFunc
addpath ../stanford_dl_ex-master_BS/common/minFunc_2012/minFunc/compiled

[train, test] = ex1_load_mnist(false);
train.y = train.y + 1;
test.y = test.y + 1;

numV = 10;
Eh = false(numV);
Ee = false(numV);
for i = 1 : 10
    for j = i+1 : 10
        Ee(i, j) = true;
    end
end
Ee = Ee | Ee';

[n, m] = size(train.X);
rng(0,'twister');
w = randn(n+1, numV)*0.001;

hexG = hexGraph(Eh, Ee);

options.epochs = 5;
options.minibatch = 1000;
options.alpha = 0.1;
options.momentum = .9;

tic;
w = minFuncSGD(@hexClassifier,hexG,w,train.X,train.y,options);
fprintf('Training took %f seconds.\n', toc);

[~,labels] = max(bsxfun(@plus,w(1:end-1,:)'*test.X,w(end,:)'), [], 1);
correct=sum(test.y == labels);
accuracy = correct / length(test.y);
fprintf('Test accuracy = %6.4f\n',accuracy);

clear all
%}

%%{
numV = 13;
Eh = sparse(false(numV));
Eh(1, 2)= true;
Eh(1, 3)= true;
Eh(2, 4)= true;
Eh(3, 4)= true;
Eh(2, 9)= true;
Eh(3, 8)= true;
Eh(9, 5)= true;
Eh(4, 5)= true;
Eh(4, 6)= true;
Eh(8, 6)= true;
Eh(5, 7)= true;
Eh(6, 7)= true;
Eh(11,1)= true;
Eh(12,1)= true;
Eh(13,11)= true;
Eh(13,12)= true;
Ee = sparse(false(numV));
Ee(8, 10) = true;
Ee = Ee | Ee';

n = 30;
m = 500;
rng(0,'twister');
x = rand(n, m);
y = randi([1, numV], 1, m);
w = rand(n+1, numV)*0.001;

hexG = hexGraph(Eh, Ee);
%[loss, gradients] = hexClassifier(hexG, w(:), x, y);

options.epochs = 3;
options.minibatch = 100;
options.alpha = 0.1;
options.momentum = .9;

tic;
w = minFuncSGD(@hexClassifier,hexG,w,x,y,options);
%w = minFuncSGDsoft(@softmax,w,x,y,options);
fprintf('Training took %f seconds.\n', toc);

rng(1,'twister');
m = m/2;
xt = rand(n+1, m);
yt = randi([1, numV], 1, m);

[~,labels] = max(w'*xt, [], 1);
correct=sum(yt == labels);
accuracy = correct / length(yt);
fprintf('Test accuracy = %6.4f\n',accuracy);

%{
w = rand(n+1, numV)*0.001;
x = [x;ones(1,size(x,2))];
numCheckIter = 10;
error = gradCheck(@hexClassifier, hexG, w, numCheckIter, x, y);
fprintf('Gradient error is %f.\n', error);
%}
%}


%{
load taxonomy_from_wordnet.mat
hexG = hexGraph(full(is_a_mat), full(exclusive_mat));
save taxonomy_from_wordnet_hexG hexG
%}

%{
load taxonomy_ilsvrc2012.mat
hexG = hexGraph(full(is_a_mat), full(exclusive_mat));
save taxonomy_ilsvrc2012_hexG hexG
%}



%{
load taxonomy_from_wordnet.mat
load taxonomy_from_wordnet_hexG.mat
numV = size(hexG.numVar, 1);

%{
n = 20;
m = 50;
rng(0,'twister');
x = rand(n, m);
y = randi([1, 1000], 1, m);
rng(0,'twister');
w = rand(n+1, numV)*0.001;
%}


%load fc7_val.mat
num = 20;
x = zeros(4096, num*1000);
y = zeros(num*1000, 1);
for i = 1 : 1000
    j = 1+(i-1)*num;
    idx = 1+(i-1)*50;
    x(:, j:j+num-1) = data(:, idx:idx+num-1);
    y(j:j+num-1) = label(idx:idx+num-1);
end

options.epochs = 10;
options.minibatch = 200;
options.alpha = 1e-4;
options.momentum = .9;
rng(0,'twister');
w = randn(size(data,1)+1, numV)*1e-5;
w = minFuncSGD(@hexClassifier,hexG,w,x,y',options);
save weights w
%}

%{
parpool;
load /mnt/brain3/datasets/extra/imagenet2012/fc7/fc7_train.mat
[n, m] = size(data);

load taxonomy_from_wordnet_hexG.mat
numV = size(hexG.numVar, 1);

rng(0,'twister');
w = rand(n+1, numV)*0.0001;

options.epochs = 10;
options.minibatch = 5000;
options.alpha = 0.01;
options.momentum = .9;

w = minFuncSGD(@hexClassifier,hexG,w,data,label',options);
save weights w
delete(gcp('nocreate'));
%}

%{
rid = fopen('index.txt','r');
fid = fopen('index_50.txt','r');

C = textscan(rid,'%s %d');
nameList = C{1};
labelList = C{2};
fclose(rid);
fclose(fid);
%}

%{
load /mnt/brain3/datasets/extra/imagenet2012/fc7_train.mat
%load fc7_val.mat;
[n, m] = size(data);
load taxonomy_ilsvrc2012.mat;
%repercent = 0.5;
%repercent = 0.9;
%repercent = 0.95;
repercent = 0.99;
rng(1,'twister');
rp = randperm(m);
relabel = label;

for i = 1 : floor(m*repercent)
    j = rp(i);
    lparent = parents{relabel(j)};
    irand = randi(length(lparent));
    relabel(j) = lparent(irand);
end

save relabel_99_new relabel;

%{
numV = length(parents);
visited = false(1, numV);
for i = 1 : 1000
    lparent = parents{i};
    visited(lparent) = true;
end

a = find(visited);
% check result: 1001~1578 nodes are immediate parents.
%}

%}


%{
%load fc7_val.mat;

% From cpu_temp(deeplearn17) 80.10%, 70.01%
%load weights_backup.mat

% From cpu_temp(deeplearn17) 80.27%, 70.01%
%load weights_third_2_backup.mat;

% From cpu_temp(deeplearn17) 80.13%, 69.79%
%load weights_1_backup_17.mat;

% From cpu2(deeplearn6) 80.37%, 70.22%
%load weights_1.mat;

% From cpu2(deeplearn6) 80.49%, 70.07%
%load weights_third_2_backup_6.mat;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% From cpu_temp(deeplearn17) % 70.40%
%load weights_5_relabel_50.mat;


% From cpu(deeplearn4) % 68.29%
%load weights_5_relabel_90.mat;

% From cpu2(deeplearn6) % 57.70%
%load weights_5_relabel_95.mat;

% From cpu3(deeplearn4) % 32.17%
%load weights_5_relabel_99.mat;


%load weights_soft50.mat; % 69.67%
%load weights_soft90.mat; % 67.36%
%load weights_soft95.mat; % 65.37%
%load weights_soft99.mat; % 34.96%

correct = 0;
f = bsxfun(@plus,w(1:end-1,:)'*max(data,0),w(end,:)');
[~,labels] = max(f(1:1000, :), [], 1);
correct=correct+sum(label == labels');
accuracy = correct / length(label)



%}

%{
load /cifar-100-matlab/train.mat
fine_labels_train = fine_labels+1;
coarse_labels_train = coarse_labels+101;
meanD = mean(data);
data = bsxfun(@minus, double(data), meanD)';
data_train = reshape(data, 32, 32, 3, []);

rng(1,'twister');
rp = randperm(50000);
relabel = fine_labels_train;

for i = 1 : 49500
    j = rp(i);
    relabel(j) = coarse_labels_train(j);
    if i == 25000
        relabel_50 = relabel;
    elseif i == 45000
        relabel_90 = relabel;
    elseif i == 47500
        relabel_95 = relabel;
    end
end
relabel_99 = relabel;
clear rp;
clear relabel;
clear i;
clear j;

load /cifar-100-matlab/test.mat
fine_labels_test = fine_labels+1;
coarse_labels_test = coarse_labels+101;
meanD = mean(data);
data = bsxfun(@minus, double(data), meanD)';
data_test = reshape(data, 32, 32, 3, []);

clear fine_labels;
clear coarse_labels;
clear data;
clear ans;
clear batch_label;
clear filenames;
clear meanD;

save cifar100.mat




load cifar100.mat;

numV = 120;
Eh = false(numV);
Ee = false(numV);
for i = 1 : size(data_train, 4)
    child = fine_labels_train(i);
    parent = coarse_labels_train(i);
    Eh(parent, child) = true;
end
for i = 1 : size(data_test, 4)
    child = fine_labels_test(i);
    parent = coarse_labels_test(i);
    Eh(parent, child) = true;
end
for i = 1 : 100-1
    for j = i+1 : 100
        Ee(i, j) = true;
    end
end
for i = 101 : numV-1
    for j = i+1 : numV
        Ee(i, j) = true;
    end
end
for i = 101 : numV
    for j = 1 : 100
        if ~Eh(i, j)
            Ee(i, j) = true;
        end
    end
end
Ee = Ee | Ee';
hexG = hexGraph(sparse(Eh), sparse(Ee));
save cifar100_hexG hexG Eh Ee
%}

%{
load /mnt/brain2/scratch/kibok/private-homedir/taxonomy_v2/taxonomy/taxonomy_ilsvrc2012.mat

rid = fopen('index_ori.txt','r');
C = textscan(rid,'%s %d %d %d');
indexList = C{4};

m = length(indexList);
%repercent = 0.5;
%repercent = 0.9;
%repercent = 0.95;
repercent = 0.99;
rng(1,'twister');
rp = randperm(m);

for i = 1 : floor(m*repercent)
    j = rp(i);
    lparent = parents{indexList(j)+1};
    irand = randi(length(lparent));
    indexList(j) = lparent(irand)-1;
end

C{4} = indexList;

wid = fopen('index_99.txt','w');
for i = 1 : m
    saveline = [char(C{1}(i)), ' ', int2str(C{2}(i)), ' ', int2str(C{3}(i)), ' ' , int2str(C{4}(i)), '\n'];
    fprintf(wid, saveline);
end

fclose(wid);
fclose(rid);

%}

%{
load /mnt/brain2/scratch/kibok/private-homedir/taxonomy_v2/taxonomy/taxonomy_ilsvrc2012.mat

rid = fopen('index.txt','r');
tline = fgets(rid);
indexList = C{4};

m = length(indexList);
%repercent = 0.5;
%repercent = 0.9;
%repercent = 0.95;
repercent = 0.99;
rng(1,'twister');
rp = randperm(m);

for i = 1 : floor(m*repercent)
    j = rp(i);
    lparent = parents{indexList(j)+1};
    irand = randi(length(lparent));
    indexList(j) = lparent(irand)-1;
end

C{4} = indexList;

wid = fopen('index_99.txt','w');
for i = 1 : m
    saveline = [char(C{1}(i)), ' ', int2str(C{2}(i)), ' ', int2str(C{3}(i)), ' ' , int2str(C{4}(i)), '\n'];
    fprintf(wid, saveline);
end

fclose(wid);
fclose(rid);

%}