function delay_time = TimeCalculator(solution,data)

cache_allocate=solution.allocation;
path=data.path;
R_k=data.R_k;
C_l=data.C_l;
mu=data.mu;
ce=data.ce;
edge_clouds=data.edge_cloud;
server=data.server;

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
            lambda_e(ii)=lambda_e(ii)+1;
        end
    end
end

delay_edge=zeros(server,1);
for ii=1:length(edge_clouds)
    if(lambda_e(ii)>=ce(ii)*mu(ii))
        delay_edge(ii)=100;
    else
        delay_edge(ii)=MMC_Calculator(lambda_e(ii),mu(ii),ce(ii));
    end
end

delay_time=zeros(1,NF);
for ii=1:NF
    delay_time(ii) =delay_edge(cache_allocate(ii))+2*delay_link+100*label(ii);
end

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