%% generate simple random weighted graph
N = 100;                 % number of nodes
K = 4;                   % average degree

cij = single(triu(rand(N)<=K/(N-1) & ~eye(N)));
cij(cij>0) = rand(1,sum(cij(:)));
cij = cij + cij';

%% FHN model parameters
t = 100000;              % simulation time (ms)
dt = .1;                 % time step (ms)
subsamp = 10;            % subsampling factor
tau = 100;               % time constant (ms)
tol = 20;                % time window length to compute coactivations (ms)

alpha = .61;             % nullcline parameter
beta = 0.6;              % nullcline parameter
sigma = .05;             % Poisson noise firing rate (Hz)

cplthr = 0.0023;         % model threshold, it depends on alpha value (see detect_threshold_FHN.m)!!!!!

%% model threshold
n_mthr = 10; mthr = quantile(cij(cij~=0),n_mthr);
cpl = cplthr./mthr;

%% network threshold
n_gthr = 20; gthr = quantile(cij(cij~=0),n_gthr);

%% FHN simulation on weighted graph
fc = cell(1,n_mthr);
parfor i=1:n_mthr
    y = network_FHN(cij,cpl(i),tau,t,dt,subsamp,sigma,alpha,beta);
    y = [zeros(N,1) diff(y>0,1,2)>0];
    fc{i} = coactivation_FHN(y,dt*subsamp,tol);
end

%% FHN simulation on binary graphs
thrfc = cell(1,n_gthr);
parfor i=1:n_gthr
    cijtmp = double(cij>=gthr(i));
    y = network_FHN(cijtmp,1.2*cplthr,tau,t,dt,subsamp,sigma,alpha,beta);
    y = [zeros(N,1) diff(y>0,1,2)>0];
    thrfc{i} = coactivation_FHN(y,dt*subsamp,tol);
end

%% match simulations on weighted network and thresholded and binarized versions 
matching = corr(cell2mat(cellfun(@(x)squareform(x.*~eye(N))',thrfc,'UniformOutput',false)),cell2mat(cellfun(@(x)squareform(x.*~eye(N))',fc,'UniformOutput',false)));
[match,idthr] = max(matching);

%% display results
figure
subplot(221), imagesc(1-cij), axis off, colormap(hot), title('weighted random network')
subplot(222), imagesc(mthr,gthr,matching), colorbar, title('parameter space'), xlabel('model threshold'), ylabel('network threshold')
subplot(223), plot(mthr,match,'-*'), grid, ylim([0 1]), title('matching'), xlabel('model threshold'), ylabel('correlation')
subplot(224), plot(mthr,gthr(idthr),'-*',mthr,mthr,'k'), grid, title('threshold agreement'), xlabel('model threshold'), ylabel('predicted network threshold'), legend({'simu' 'theory'})
