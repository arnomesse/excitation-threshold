function usage = link_usage(y,cij,thr)

[R,T] = size(y);

usage = zeros(1,R);
for i=2:T
    cijtmp = sort(cij(y(:,i-1)==1,y(:,i)==1),'descend');
    for j=1:size(cijtmp,2)
        for k=1:size(cijtmp,1)
            if sum(cijtmp(1:k,j),1)>thr
                usage(k) = usage(k) + 1;
                break
            end
        end
    end
end
usage = usage./sum(sum(y(:,2:end)==1));
