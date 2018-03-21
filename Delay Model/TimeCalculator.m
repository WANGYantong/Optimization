function delay_time = TimeCalculator(cache_allocate,path,R_k,C_l,lambda,mu,...
    ce,Tpr,edge_clouds,server)

delay_link = GetWorstLinkDelay(C_l, R_k, path);

NF=length(cache_allocate);

lambda_e=zeros(size(edge_clouds));
label=zeros(size(cache_allocate));
for ii=1:length(edge_clouds)
    for kk=1:NF
        if cache_allocate(kk)==server
            label(kk)=1;
            continue 
        end
        if(edge_clouds(ii)==edge_clouds(cache_allocate(kk)))
            lambda_e(ii)=lambda_e(ii)+lambda(kk,ii);
        end
    end
end

delay_edge=zeros(size(edge_clouds));
for ii=1:length(edge_clouds)
    if(lambda_e(ii)>=ce(ii)*mu(ii))
        delay_edge(ii)=20;
    else
        delay_edge(ii)=MMC_Calculator(lambda_e(ii),mu(ii),ce(ii));
    end
end

delay_edge_max=max(delay_edge);
% delay_edge_max=0;
% for ii=1:length(edge_clouds)
%         delay_edge_max=delay_edge_max+delay_edge(ii);
% end

delay_time =delay_edge_max+delay_link+Tpr+20*sum(label);

end

function delay_edge=MMC_Calculator(lambda_e,mu,ce)

f1 = lambda_e^ce/(factorial(ce)*mu^ce);
f2 = (1-lambda_e/(ce*mu))*SumQueue(lambda_e,mu,ce)+f1;
f3 = ce*mu-lambda_e;
f4 = 1/mu;

delay_edge = f1/(f2*f3)+f4;

end

function f = SumQueue(lambda_e, mu, ce)

f=0;

for n=0:(ce-1)
    f=f+lambda_e^n/(factorial(n)*mu^n);
end

end