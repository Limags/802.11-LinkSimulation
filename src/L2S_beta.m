function [minbeta,rmse,rmse_mtx] = L2S_beta(EbN0p_mtx,per_mtx,snrAWGN_mtx,perAWGN_mtx,L2SStruct)

global c_sim

rmse_mtx = zeros(length(c_sim.drates),length(L2SStruct.betas));

for mcs = c_sim.drates % MCS loop
    
    per = per_mtx(:,:,(mcs + 1));
    snrAWGN = snrAWGN_mtx((mcs + 1),:);
    perAWGN = perAWGN_mtx((mcs + 1),:);
    
    j = 1;
    
    for beta = L2SStruct.betas
        
        drP = hsr_drate_param(mcs,false);
        
        SNReff = L2S_SNReff(EbN0p_mtx.*(drP.data_rate/c_sim.w_channel),beta);
        
        rmse_mtx(mcs + 1,j) = L2S_rmse(SNReff,per,snrAWGN,perAWGN);
        
        j = j + 1;
    end
end

[rmse,minIdx] = min(rmse_mtx,[],2);
minbeta = L2SStruct.betas(minIdx);

end