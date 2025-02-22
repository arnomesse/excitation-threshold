function [n,predt,thr] = multiple_neighbors(d,k,thr,e)
if nargin<3, thr = []; end
if nargin<4, e = .05; end

%% pdf/cdf
w = cell(1,k); pdfw = w; cpdfw = w;

w{1} = linspace(min(d),max(d),1001/k);
pdfw{1} = histcounts(d(d~=0),w{1},'Normalization','probability');
pdfw{1} = pdfw{1}/sum(pdfw{1});
w{1} = w{1}(1:end-1)+diff(w{1})/2; % edges to centers
cpdfw{1} = min(1,cumsum(pdfw{1}));

for i=2:k
    w{i} = linspace(w{1}(1)+w{i-1}(1),w{1}(end)+w{i-1}(end),length(w{1})+length(w{i-1})-1);
    pdfw{i} = conv(pdfw{1},pdfw{i-1});
    cpdfw{i} = min(1,cumsum(pdfw{i}));
end

t = 0:.001:max(w{1});
x = 0:.01:max(w{k});
if min(thr)>=max(x) || max(thr)<=min(x), error('threshold values beyond valid range'), end

cpdfw_tmp = zeros(length(x),k);
for i=1:k
    cpdfw_tmp(:,i) = interp1(w{i},cpdfw{i},x);
    id = find(~isnan(cpdfw_tmp(:,i)),1,'first');
    if id~=1, cpdfw_tmp(1:id-1,i) = 0; end
    id = find(isnan(cpdfw_tmp(:,i)),1,'first');
    if ~isempty(id), cpdfw_tmp(id:end,i) = 1; end
end
cpdfw = max(0,min(1,cpdfw_tmp)); clear cpdfw_tmp

%% pdf/cdf for thresholded distribution
pdftw = cell(1,k); cpdftw = pdftw;

pdftw{1} = repmat(pdfw{1}',1,length(t));
pdftw{1}(w{1}'<t) = 0;
pdftw{1} = pdftw{1}./sum(pdftw{1},1);
pdftw{1}(isnan(pdftw{1})) = 0;
cpdftw{1} = min(1,cumsum(pdftw{1},1));

for j=2:k
    w{j} = linspace(w{1}(1)+w{j-1}(1),w{1}(end)+w{j-1}(end),length(w{1})+length(w{j-1})-1);
    for i=1:length(t), pdftw{j}(:,i) = conv(pdftw{1}(:,i),pdftw{j-1}(:,i)); end
    cpdftw{j} = min(1,cumsum(pdftw{j},1));
end

cpdftw_tmp = zeros(length(x),length(t),k);
for i=1:length(t)
    for j=1:k
        cpdftw_tmp(:,i,j) = interp1(w{j},cpdftw{j}(:,i),x);
        id = find(~isnan(cpdftw_tmp(:,i,j)),1,'first');
        if id~=1, cpdftw_tmp(1:id-1,i,j) = 0; end
        id = find(isnan(cpdftw_tmp(:,i,j)),1,'first');
        if ~isempty(id), cpdftw_tmp(id:end,i,j) = 1; end
    end
end
cpdftw = max(0,min(1,cpdftw_tmp)); clear cpdtftw_tmp

%% nb neighbor
n = binopdf(1:k,k,e).*(1-cpdfw);
[~,n] = max(n,[],2);

%% threshold
tprob = zeros(size(cpdftw));
for i=1:k, tprob(:,:,i) = (1-cpdftw(:,:,i)).*interp1(x,(1-cpdfw(:,1)).^i,t)./(1-cpdfw(:,i)) - cpdftw(:,:,i).*interp1(x,(1-cpdfw(:,1)).^i,t)./cpdfw(:,i); end
tprob(isnan(tprob)) = 0;

idt = nan(1,length(x));
for i=1:length(x), [~,idt(i)] = max(tprob(i,:,n(i))); end
predt = t(idt);

%% mapping
if isempty(thr), thr = x;
else
    n = interp1(x,n,thr,'nearest');
    predt = interp1(x,predt,thr);
end
