function [x, y] = network_FHN(C,k,tau,T,dt,subsamp,nfr,alpha,beta,I)

% Fitzhugh-Nagumo network simulation
% 
% C            = Connectivity matrix (can be directed and/or weighted) 
% k            = Coupling strength
% tau          = Time scale (ms)
% T            = Total time of simulated activity (ms)
% dt           = Integration step (ms)
% subsamp      = Subsampling factor
% nfr          = Firing rate of the Poisson noise (Hz)
% alpha        = Nullcline parameter
% beta         = Nullcline parameter
% I            = Input
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<10,  I       =  0; end
if nargin<9,   beta    = .6; end
if nargin<8,   alpha   = .8; end

N = size(C,1);                     % network size
ntp = ceil(T/dt)+1;                % total number of time steps
nstp = ceil(ntp/subsamp);          % total number of time steps after subsampling
x = zeros(N,nstp,'single'); y = x; % initialize timeseries
L = k*laplacian(C)*dt;             % scaled Laplacian
if I==0, I = zeros(N,ntp); end     % check input

% Compute fixed-points

xfp = roots([-1/3 0 1-1/beta -alpha/beta]);
xfp = real(xfp(imag(xfp)==0));
yfp = xfp-(xfp^3)/3;

% Initialization

x(:,1) = xfp;
y(:,1) = yfp;

tt = 2;
xtmp = xfp.*ones(N,1);
ytmp = yfp.*ones(N,1);

% Equations integration

for t = 1:ntp-1
    xtmp = xtmp + g(xtmp,ytmp)*dt + L*xtmp - 2*xfp.*double(abs(xtmp-xfp)<.1).*double(I(:,t)==1 | rand(N,1)<nfr*dt/1000);
    ytmp = ytmp + h(xtmp,ytmp,alpha,beta)*dt/tau;
    if mod(t,subsamp)==0
        x(:,tt) = xtmp;
        y(:,tt) = ytmp;
        tt = tt+1;
    end
end

function w = g(u,v),            w = u - (u.^3)/3 - v;
function w = h(u,v,alpha,beta), w = u - beta*v + alpha;
function L = laplacian(cij),    L = cij-diag(sum(cij,2));
