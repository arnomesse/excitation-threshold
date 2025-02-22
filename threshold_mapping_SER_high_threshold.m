%% generate simple random weighted graph
N = 100;                 % number of nodes
K = 8;                   % average degree

cij = single(triu(rand(N)<=K/(N-1) & ~eye(N)));
cij(cij>0) = rand(1,sum(cij(:)));
cij = cij + cij';

%% SER model parameters
tir = 50;              % number of runs
t = 10000;             % number of time step 
p = [.1 .143 .25];     % recovery probability
f = [0.01 0.05 0.1];   % spontaneous excitation probability

%% model threshold
n_mthr = 10; mthr = linspace(min(cij(cij~=0)),2.5*max(cij(:)),n_mthr);

%% network threshold
n_gthr = 20; gthr = quantile(cij(cij~=0),n_gthr);

%% effective number of neighbors and theoretical network threshold
[n,predthr] = multiple_neighbors(cij(cij~=0),K,mthr);
un = unique(n);
if any(un>3)
    warning('lot of neighbors required, results may be inaccurate')
    p(4:max(un)) = 1;
    f(4:max(un)) = 0.5;
end

%% SER simulation on weighted graph
fc = cell(1,n_mthr);
usage = cell(1,n_mthr);
parfor i=1:n_mthr
    fc{i} = zeros(N);
    usage{i} = zeros(1,N);
    for j=1:tir
        y = network_SER(cij,mthr(i),t,f(n(i)),p(n(i)),round(.1*N))==1;
        usage{i} = usage{i} + link_usage(y,cij,mthr(i));
        fc{i} = fc{i}+y*y';
    end
    fc{i} = fc{i}/tir/t;
    usage{i} = usage{i}/tir;
end
usage = cat(1,usage{:});
usage = usage./sum(usage,2);
[~,nsim] = max(usage,[],2);

%% SER simulation on binary graphs
thrfc = cell(length(un),n_gthr);
parfor z=1:length(un)*n_gthr
    [i,j] = ind2sub([length(un) n_gthr],z);
    thrfc{z} = zeros(N);
    cijtmp = double(cij>gthr(j));
    for zz=1:tir
        y = network_SER(cijtmp,un(i)-1,t,f(un(i)),p(un(i)),round(.1*N))==1;
        thrfc{z} = thrfc{z} + y*y';
    end
    thrfc{z} = thrfc{z}/tir/t;
end

%% match simulations on weighted network and thresholded and binarized versions
matching = zeros(n_gthr,n_mthr);
for i=1:length(un)
    matching(:,n==un(i)) = corr(cell2mat(cellfun(@(x)squareform(x.*~eye(N))',thrfc(i,:),'UniformOutput',false)),cell2mat(cellfun(@(x)squareform(x.*~eye(N))',fc(n==un(i)),'UniformOutput',false)));
end
[match,idthr] = max(matching);

%% display results
figure
subplot(231), imagesc(1-cij), axis off, colormap(hot), title('weighted random network')
subplot(232), imagesc(mthr,1:max(nsim),usage(:,1:max(nsim))'), colorbar, title('proportion of excitation explained by neighbors'), xlabel('model threshold'), ylabel('number of neighbors'), set(gca,'YTick',0:max(nsim)+1)
subplot(233), plot(mthr,nsim,'-*',mthr,n,'k'), grid, title('effective neighbors'), xlabel('model threshold'), ylabel('number of effective neighbors'), set(gca,'YTick',0:max(nsim)+1), legend({'simu' 'theory'})
subplot(234), imagesc(mthr,gthr,matching), colorbar, title('parameter space'), xlabel('model threshold'), ylabel('network threshold')
subplot(235), plot(mthr,match,'-*'), grid, ylim([0 1]), title('matching'), xlabel('model threshold'), ylabel('correlation')
subplot(236), plot(mthr,gthr(idthr),'-*',mthr,predthr,'k'), grid, title('threshold agreement'), xlabel('model threshold'), ylabel('predicted network threshold'), legend({'simu' 'theory'})
