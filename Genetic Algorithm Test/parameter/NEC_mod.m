function result = NEC_mod(solution,data)

NF=length(solution);

% parameter tailor
data.W_k=data.W_k(1:NF);
data.R_k=data.R_k(1:NF);
data.delta=data.delta(1:NF);
data.probability=data.probability(1:NF,:);

punish=log(max(data.delta)+50-data.delta)*200;

[result,solution_mod]=Nominal_mod(solution,data,punish);

delay_time=TimeCalculator(solution_mod,data);

for ii=1:NF
    if delay_time(ii) > data.delta(ii)
        result=result+(1/data.penalty)*punish(ii)*(delay_time(ii)-data.delta(ii));
    end
end


end

