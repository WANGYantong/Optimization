function link_delay = GetLinkDelay(assignment,data,ops)

NF=length(assignment);
pi=zeros(NF,length(data.access_router),length(data.edge_cloud));
y=zeros(NF,size(data.graph.Edges,1));

probability=data.probability;

if ops{1}==0 % not determine the access router
    for ii=1:NF
        if assignment(ii)==data.server
            continue;
        end
        for jj=1:2
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

BETA=GetPathLinkRel(data.graph,"undirected",data.path,length(data.access_router),...
    length(data.edge_cloud));
[m,n,l]=size(BETA);
BETA_y=reshape(BETA,1,m*n*l);
BETA_y=repmat(BETA_y,[NF,1]);
BETA_y=reshape(BETA_y,NF,m,n,l);

pi_y=repmat(pi,[size(BETA,1),1,1,1]);
pi_y=reshape(pi_y,NF,size(BETA,1),length(data.access_router),length(data.edge_cloud));

buffer_y=sum(sum(BETA_y.*pi_y,4),3);

for ii=1:NF
    for jj=1:size(data.graph.Edges,1)
        if buffer_y(ii,jj)>=1
            y(ii,jj)=1;
        end
    end
end

num1=sum(BETA_y.*pi_y,4);

R_y=repmat(data.R_k,[size(BETA,1),1])';
num2=sum(R_y.*y,1);

dom=data.C_l-num2;

num2_y=repmat(num2,[NF,1,length(data.access_router)]);
dom_y=repmat(dom,[NF,1,length(data.access_router)]);

link_buffer=(num1.*num2_y)./dom_y;
link_buffer=squeeze(sum(link_buffer,2));

link_delay=max(link_buffer,[],2);

end

