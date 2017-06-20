function opttheta = minFuncSGD(funObj, hexG, w, x, y, options)
% Runs stochastic gradient descent with momentum to optimize the
% parameters for the given objective.
%
% Parameters:
%  funObj     -  function handle which accepts as input theta,
%                data, labels and returns cost and gradient w.r.t
%                to theta.
%  theta      -  unrolled parameter vector
%  data       -  stores data in m x n x numExamples tensor
%  labels     -  corresponding labels in numExamples x 1 vector
%  options    -  struct to store specific options for optimization
%
% Returns:
%  opttheta   -  optimized parameter vector
%
% Options (* required)
%  epochs*     - number of epochs through data
%  alpha*      - initial learning rate
%  minibatch*  - size of minibatch
%  momentum    - momentum constant, defualts to 0.9


%%======================================================================
%% Setup
assert(all(isfield(options,{'epochs','alpha','minibatch'})),...
    'Some options not defined');
if ~isfield(options,'momentum')
    options.momentum = 0.9;
end;
epochs = options.epochs;
alpha = options.alpha;
minibatch = options.minibatch;
m = length(y); % training set size
% Setup for momentum
mom = 0.5;
momIncrease = 20;
velocity = zeros(size(w));
accuracy = 0;
%%======================================================================
%% SGD loop
fid=fopen('result.txt','wt');
numIter = floor(m/minibatch);
tic;
for e = 1:epochs
    if e > 1
        correct = 0;
        for i=1:minibatch:(m-minibatch+1)
            [~,labels] = max(bsxfun(@plus,w(1:end-1,:)'*max(x(:,i:i+minibatch-1),0),w(end,:)'), [], 1);
            correct=correct+sum(y(i:i+minibatch-1) == labels);
        end
        accuracy = correct / length(y);
    end
    
    tEpochS = tic;
    % randomly permute indices of data for quick minibatch sampling
    rp = randperm(m);
    it = 0;
    
    for s=1:minibatch:(m-minibatch+1)
        tIterS = tic;
        it = it + 1;
        
        % increase momentum after momIncrease iterations
        if it == momIncrease
            mom = options.momentum;
        elseif it == floor(numIter/3)
            alpha = max(alpha/5, 1e-8);
            correct = 0;
            for i=1:minibatch:(m-minibatch+1)
                [~,labels] = max(bsxfun(@plus,w(1:end-1,:)'*max(x(:,i:i+minibatch-1),0),w(end,:)'), [], 1);
                correct=correct+sum(y(i:i+minibatch-1) == labels);
            end
            accuracy = correct / length(y);
            %save(strcat('weights_third_',num2str(e+2)), 'w');
        elseif it == floor(numIter/3*2)
            alpha = max(alpha/2, 1e-8);
            correct = 0;
            for i=1:minibatch:(m-minibatch+1)
                [~,labels] = max(bsxfun(@plus,w(1:end-1,:)'*max(x(:,i:i+minibatch-1),0),w(end,:)'), [], 1);
                correct=correct+sum(y(i:i+minibatch-1) == labels);
            end
            accuracy = correct / length(y);
            %save(strcat('weights_twothird_',num2str(e+2)), 'w');
        end;
        
        % get next randomly selected minibatch
        mb_x = max([x(:, rp(s:s+minibatch-1));ones(1,minibatch)], 0);
        mb_labels = y(rp(s:s+minibatch-1));
        
        % evaluate the objective function on the next minibatch
        
        [cost, grad] = funObj(hexG,w,mb_x,mb_labels);
        velocity = mom * velocity + alpha * grad;
        w = w - velocity;
        
        tIterEnd = toc(tIterS);
        nIt = (e-1)*numIter+it;
        fprintf('Epoch %4d: Cost on iteration %8d = %8.4f, acc = %6.4f ',e,nIt,cost,accuracy);
        fprintf('tooks %.2f seconds.\n', tIterEnd);
        fprintf(fid,'Epoch %4d: Cost on iteration %8d = %8.4f, acc = %6.4f ',e,nIt,cost,accuracy);
        fprintf(fid,'tooks %.2f seconds.\n', tIterEnd);
    end;
    
    % aneal learning rate by factor of two after each epoch
    alpha = max(alpha*5, 1e-8);
    tEpochEnd = toc(tEpochS);
    fprintf('Epoch tooks %.2f seconds.\n', tEpochEnd);
    fprintf(fid,'Epoch tooks %.2f seconds.\n', tEpochEnd);
    %save(strcat('weights_',num2str(e+2)), 'w');
end;

tEnd = toc;
fprintf('Training tooks %.2f seconds.\n', tEnd);
fprintf(fid,'Training tooks %.2f seconds.\n', tEnd);

correct = 0;
for i=1:minibatch:(m-minibatch+1)
    [~,labels] = max(bsxfun(@plus,w(1:end-1,:)'*max(x(:,i:i+minibatch-1),0),w(end,:)'), [], 1);
    correct=correct+sum(y(i:i+minibatch-1) == labels);
end
accuracy = correct / length(y);

fprintf('Training acc = %6.4f\n',accuracy);
fprintf(fid,'Training acc = %6.4f\n',accuracy);

fclose(fid);
opttheta = w;

end
