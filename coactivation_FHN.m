function fc = coactivation_FHN(Y,dt,tol)

[R, T] = size(Y);
tt =  round(tol/dt);
fc = zeros(R);

for j=1:T-tt+1
    [id,id2] = ind2sub([R tt],find(Y(:,j:j+tt-1)==1));
    u = unique(id);
    fc(id(id2==1),u) = fc(id(id2==1),u)+repmat(histc(id,u)',sum(id2==1),1);
end
