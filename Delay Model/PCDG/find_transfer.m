function t=find_transfer(x)

NF=size(x,1);

t=zeros(NF,1);

for ii=1:NF
    if any(x(ii,:))==1
        t(ii)=find(x(ii,:),1);
    end
end

end

