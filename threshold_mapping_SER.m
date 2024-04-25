%% generate simple random weighted graph
N = 100;                 % number of nodes
K = 4;                   % average degree

cij = single(triu(rand(N)<K/N & ~eye(N)));
cij(cij>0) = rand(1,sum(cij(:)));
cij = cij + cij';

%% SER model parameters
tir = 50;              % number of runs
t = 10000;             % number of time step 
p = .1;                % recovery probability
f = 0.01;              % spontaneous excitation probability

%% model threshold
n_mthr = 10; mthr = quantile(cij(cij~=0),n_mthr);

%% network threshold
n_gthr = 20; gthr = quantile(cij(cij~=0),n_gthr);

%% SER simulation on weighted graph
fc = cell(1,n_mthr);
parfor i=1:n_mthr
    fc{i} = zeros(N);
    for j=1:tir
        y = Network_SER(cij,mthr(i),t,f,p,round(.1*N))==1;
        fc{i} = fc{i}+y*y';
    end
    fc{i} = fc{i}/tir;
end

%% SER simulation on binary graphs
thrfc = cell(1,n_gthr);
parfor i=1:n_gthr
    thrfc{i} = zeros(N);
    cijtmp = double(cij>gthr(i));
    for j=1:tir
        y = Network_SER(cijtmp,0,t,f,p,round(.1*N))==1;
        thrfc{i} = thrfc{i} + y*y';
    end
    thrfc{i} = thrfc{i}/tir;
end

%% match simulations on weighted network and thresholded and binarized versions 
matching = corr(cell2mat(cellfun(@(x)squareform(x.*~eye(N))',thrfc,'UniformOutput',false)),cell2mat(cellfun(@(x)squareform(x.*~eye(N))',fc,'UniformOutput',false)));
[match,idthr] = max(matching);

%% display results
figure
subplot(221), imagesc(1-cij), axis off, colormap(hot), title('weighted random network')
subplot(222), imagesc(mthr,gthr,matching), colorbar, title('parameter space'), xlabel('model threshold'), ylabel('network threshold')
subplot(223), plot(mthr,match,'-*'), grid, ylim([0 1]), title('matching'), xlabel('model threshold'), ylabel('correlation')
subplot(224), plot(mthr,gthr(idthr),'-*',mthr,mthr,'k'), grid, title('threshold agreement'), xlabel('model threshold'), ylabel('predicted network threshold')
