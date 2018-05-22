function utilization = GenerateUtilization(edge_cloud)

rng(2);

utilization=rand(size(edge_cloud));
utilization(6:10)=utilization(6:10)*0.5;

end

