function y = network_SER(C,k,T,f,p,ic)

% SER network simulation
% 
% C            = Connectivity matrix (can be directed and/or weighted)
% k            = Model threshold
% T            = Number of timesteps
% f            = Spontaneous excitation probability
% p            = Recovery probability
% ic           = Initial conditions, can be a vector describing the initial state of each node or a single value representing the number of excited nodes (the remaining nodes are splitted in two equal size cohorts of susceptible and refractory nodes)
% 
% Convention is:
%       susceptible node =  0
%       excited node     =  1
%       refractory node  = -1
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<6, ic = 1; end
if ic>length(C), error('Initial active nodes must be equal to or lower than the total number of nodes'); end

N   = length(C);             % network size
y   = zeros(N,T,'int8');     % initialize timeseries

% Initialization

if length(ic)==N
    y(:,1) = ic;
else
    y(randsample(N,ic),1) = 1;
    y(randsample(find(y(:,1)==0),round((N-ic)/2)),1) = -1;
end

% Equations integration

for t = 1:T-1
    y(y(:,t)==1,t+1) = -1;
    y(y(:,t)==0 & (rand(N,1)<f | sum(C(:,y(:,t)==1),2)>k),t+1) = 1;
    y(y(:,t)==-1 & rand(N,1)>p,t+1) = -1;
end
