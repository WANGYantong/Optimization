function link_delay = GetLinkDelay(assignment,data,ops)

NF=length(assignment);
pi=zeros(NF,length(data.access_router),length(data.edge_cloud));

probability=data.probability;

if ops{1}==0 % not determine the access router
    for ii=1:NF
        if assignment(ii)==data.server
            continue;
        end
        for jj=1:3
            [~,index]=max(probability(ii,:));
            pi(ii,index,assignment(ii))=1;
            probability(ii,index)=0;
        end
    end
else
    for ii=1:NF
        if assignment(ii)==data.server
            continue;
        end
        pi(ii,ops{2}(ii),assignment(ii))=1;
    end
end

beta=GetPathLinkRel(data.graph,"undirected",data.path,length(data.access_router),...
    length(data.edge_cloud));
[m,n,l]=size(beta);
beta_omega=reshape(beta,1,m*n*l);
beta_omega=repmat(beta_omega,[NF,1]);
beta_omega=reshape(beta_omega,NF,m,n,l);
beta_omega=permute(beta_omega,[2,1,3,4]);

R_komega=repmat(data.R_k,[size(data.graph.Edges,1),1,...
    length(data.access_router),length(data.edge_cloud)]);

[m,n,l]=size(pi);
pi_omega=reshape(pi,1,m*n*l);
pi_omega=repmat(pi_omega,[size(data.graph.Edges,1),1]);
pi_omega=reshape(pi_omega,size(data.graph.Edges,1),m,n,l);

diff_l=data.C_l-sum(sum(sum(R_komega.*beta_omega.*pi_omega,4),3),2);
for ii=1:length(diff_l)
    if diff_l(ii)<0
        diff_l(ii)=0.9;
    end
end
    
diff_omega=repmat(diff_l,[1,NF,n,l]);

link_delay=sum(sum(sum(beta_omega.*pi_omega./diff_omega,4),3),1);

end

