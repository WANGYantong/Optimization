function solution = Randomized(Flows,data,alpha,punish)

edge_clouds=data.edge_cloud;
Wsize=data.W_k;
Rspace=data.Zeta_e;
Rtotal=data.Zeta_t;
delta=data.delta;

TIMES_HARDCODE = 1000;

solution = Greedy(Flows,data,alpha,punish);

time_delay_ori = TimeCalculator(solution,data);

cache_node = solution.allocation;
total_cost = solution.total_cost;

% if(time_delay_ori <= delta)
%     TIMES_HARDCODE = 10;
% end

for ii = 1:TIMES_HARDCODE
    flow = randi(length(Flows));
    pos = randi(length(edge_clouds));
    solution.allocation(flow) = pos;
    
    legal_flag = check_space(solution.allocation,Wsize,Rspace,Rtotal);
    
    %     if(legal_flag == 1)
    pre_cost_mid = CostCalculator(solution,data,alpha,punish);
    time_delay_pre_mid = TimeCalculator(solution,data);
    if(legal_flag == 1)  % make runing time trend increasing
        pre_cost=pre_cost_mid;
        time_delay_pre=time_delay_pre_mid;
        if all(time_delay_pre <= delta)
            if any(time_delay_ori > delta) || ...
                    (all(time_delay_ori <= delta) && all(pre_cost < total_cost))
                cache_node = solution.allocation;
                total_cost = pre_cost;
                solution.allocation=cache_node;
                solution.total_cost=total_cost;
                %                 return
            end
        else
            if (sum(time_delay_ori <= delta) < sum(time_delay_pre <= delta)) ...
                    && (sum(pre_cost) <= sum(total_cost))
                cache_node = solution.allocation;
                total_cost = pre_cost;
                %                 time_delay_ori = time_flag_pre;
            end
        end
    end
end

solution.allocation=cache_node;
solution.total_cost=total_cost;

end

function legal_flag=check_space(pre_allocate,Wsize,Rspace,Rtotal)

NF=length(pre_allocate);
flow_flag=zeros(size(pre_allocate));

for ii=1:NF
    if(Wsize(ii) < Rspace(pre_allocate(ii))) && (Rtotal > Wsize(ii))
        Rspace(pre_allocate(ii))=Rspace(pre_allocate(ii))-Wsize(ii);
        Rtotal=Rtotal - Wsize(ii);
        flow_flag(ii)=1;
    end
end

legal_flag=all(flow_flag);

end
