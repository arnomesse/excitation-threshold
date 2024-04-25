%% FHN model parameters
t = 200;                                            % simulation time (ms)
dt = .1;                                            % time step (ms)
subsamp = 10;                                       % subsampling
tau = 100;                                          % time cconstant (ms)

ncpl = 200; cpl = linspace(.0015,.015,ncpl);        % coupling strength
na = 11; alpha = linspace(.6,.7,na);                % nullcline parameter
beta = 0.6;                                         % nullcline parameter
sigma = 0;                                          % Poisson noise firing rate (Hz)

Ii = zeros(2,ceil(t/dt)+1);                         % input impulse at 50 ms to trigger an excitation to the first node
ti = 50+1;
Ii(1,ti) = 1;

%% compute d
d = zeros(1,na);
for i=1:na
    xfp = roots([-1/3 0 1-1/beta -alpha(i)/beta]);
    xfp = real(xfp(imag(xfp)==0));
    yfp = xfp-(xfp^3)/3;

    rts = roots([-1/3 0 1 -yfp]);
    rts(abs(rts-xfp)<1e-6) = [];
    if length(rts)==1, xt = xfp; else, xt = min(rts); end

    d(i) = xt-xfp;
end

%% FHN simulation on a pair of connected nodes
inpthr = zeros(na,ncpl);
for z=1:na*ncpl
    [i,j] = ind2sub([na ncpl],z);
    y = Network_FHN(double(~eye(2)),cpl(j),tau,t,dt,subsamp,sigma,alpha(i),beta,Ii);
    y = [zeros(2,1) diff(y>0,1,2)>0];
    if ~isempty(find(y(2,ceil(ti/subsamp)+1:end), 1)), inpthr(z) = 1; end
end

%% extract threshold
cplthr = nan(1,na);
for i=1:na
    ids = find(inpthr(i,:),1);
    if ~isempty(ids), cplthr(i) = cpl(ids);end
end

%% display results
figure, suptitle('detect FHN threshold')
subplot(131), plot(alpha,d,'-*'), grid, xlabel('alpha'), ylabel('d')
subplot(132), plot(d,cplthr,'-*'), grid, xlabel('d'), ylabel('model threshold')
subplot(133), semilogx(logspace(-2,-1,10),cplthr(11)./logspace(-2,-1,10),'-*'), grid, xlabel('coupling strength'), ylabel('model threshold')
