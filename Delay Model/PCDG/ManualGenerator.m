% function ManualGenerator(NF,data)

% l=NF;
% g=size(data.graph.Edges,1);
% b=length(data.access_router);
% t=length(data.edge_cloud);
l=20;
g=24;
b=7;
t=10;

y=optimvar('y',l,g,'Type','integer',...
    'LowerBound',0,'UpperBound',1);
pi=optimvar('pi',l,b,t,...
    'Type','integer','LowerBound',0,'UpperBound',1);
psi=optimvar('psi',l,l,g,b,t,...
    'Type','integer','LowerBound',0,'UpperBound',1);

psi_define_constr1=optimconstr(l,l,g,b,t);
psi_define_constr2=optimconstr(l,l,g,b,t);
psi_define_constr3=optimconstr(l,l,g,b,t);
for ii=1:l
    for jj=1:l
        for kk=1:g
            for ll=1:b
                for mm=1:t
                    psi_define_constr1(ii,jj,kk,ll,mm)=psi(ii,jj,kk,ll,mm)<=pi(jj,ll,mm);
                    psi_define_constr2(ii,jj,kk,ll,mm)=psi(ii,jj,kk,ll,mm)<=y(ii,kk);
                    psi_define_constr3(ii,jj,kk,ll,mm)=psi(ii,jj,kk,ll,mm)>=pi(jj,ll,mm)+y(ii,kk)-1;
                end
            end
        end
    end
end

beep

% end