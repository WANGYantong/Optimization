function utilization = GenerateUtilization(edge_cloud)

rng(2);

utilization=rand(size(edge_cloud))*0.5;
% utilization(6:9)=utilization(6:9)*0.5;

end

