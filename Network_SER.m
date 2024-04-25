function y = Network_SER(C,k,T,f,p,ia,d)

% SER network simulation
% 
% C            = Matrix of coupling (NxN) between pairs of regions (can be directed and/or weighted)
% k            = Model threshold
% T            = Total time of simulated activity
% f            = Probability of spontaneous activation
% p            = Probability of recovery
% ia           = Initial conditions, can be a vector describing the initial state of each node or a single value representing the number of excited nodes (the remaining nodes are splitted in two equal size cohorts of susceptible and refractory nodes)
% d            = Initial time steps to remove (transient dynamics)
% 
% Convention is:
%       - susceptible node =  0
%       - excited node     =  1
%       - refractory node  = -1
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<7, d = 0; end
if nargin<6, ia = 1; end
if T<=d, error('Simulation time must be greater than the transient'); end
if ia>length(C), error('Initial active nodes must be equal to or lower than the total number of nodes'); end

N   = length(C);             % network size
y   = zeros(N,T,'int8');     % initialize timeseries

% Initialization

if length(ia)==N
    y(:,1) = ia;
else
    y(randsample(N,ia),1) = 1;
    y(randsample(find(y(:,1)==0),round((N-ia)/2)),1) = -1;
end

% Equations integration

for t = 1:T-1
    y(y(:,t)==1,t+1) = -1;
    y(y(:,t)==0 & (rand(N,1)<f | sum(C(:,y(:,t)==1),2)>k),t+1) = 1;
    y(y(:,t)==-1 & rand(N,1)>p,t+1) = -1;
end

y(:,1:d) = [];  % remove initial d steps of simulations to exclude transient dynamics
