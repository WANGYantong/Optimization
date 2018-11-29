function [edge_jam,link_jam] = JamCalculator(flow,matrix_X,data)

NF=length(flow);
ND=length(data.access_router);
NE=length(data.edge_cloud);
NL=height(data.graph.Edges);

pi_mid=zeros(NF,ND,NE);
y_mid=zeros(NF,NL);

%% calculate link congestion
for ii=1:NF
    for jj=1:ND
        for kk=1:NE
            if ((matrix_X(ii,kk)>0) && (data.probability(ii,jj)>0))
                pi_mid(ii,jj,kk)=1;
            end
        end
    end
end

BETA=GetPathLinkRel(data.graph,"undirected",data.path,ND,NE);
[m,n,l]=size(BETA);
BETA_y=reshape(BETA,1,m*n*l);
BETA_y=repmat(BETA_y,[NF,1]);
BETA_y=reshape(BETA_y,NF,m,n,l);

pi_y=repmat(pi_mid,[size(BETA,1),1,1,1]);
pi_y=reshape(pi_y,NF,size(BETA,1),ND,NE);

y_buffer=sum(sum(BETA_y.*pi_y,4),3);

for ii=1:NF
    for jj=1:NL
        if(y_buffer(ii,jj)>0)
            y_mid(ii,jj)=1;
        end
    end
end

link_jam=zeros(NL,1);
for ii=1:NL
    link_jam(ii)=(data.R_k*y_mid(:,ii))/data.C_l;
end

%% calculate edge congestion
edge_jam=zeros(NE,1);
for ii=1:NE
    edge_jam(ii)=sum(matrix_X(:,ii))/(data.ce(ii)*data.mu(ii));
end

end

