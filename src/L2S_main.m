function L2S_main

%% Loading and data formating

numSim = 1;
load('L2S_results_1.mat');

totalConfigs = length(L2SStruct.chan_multipath)*length(L2SStruct.version)*...
    length(L2SStruct.w_channel)*length(L2SStruct.cyclic_prefix)*...
    length(L2SStruct.data_len);
totalSims = L2SStruct.maxChannRea*totalConfigs;

SNRp_mtx = zeros([size(SNRp) L2SStruct.maxChannRea]);
per_mtx_pre = zeros([size(per) L2SStruct.maxChannRea]);

for simIdx = numSim:(numSim + L2SStruct.maxChannRea - 1)
    chanIdx = mod(simIdx,L2SStruct.maxChannRea) + 1;
    
    SNRp_mtx(:,:,chanIdx) = SNRp;
    per_mtx_pre(:,:,chanIdx) = per;
    
    filename = ['L2S_results_' num2str(simIdx + 1) '.mat'];
    load(filename);
    
end % Channel realizations loop

per_mtx = permute(per_mtx_pre,[3 2 1]);

snrAWGN_mtx = zeros([length(c_sim.drates) length(c_sim.EbN0s)]);
for mcs = c_sim.drates
    drP = hsr_drate_param(mcs,false);
    snrAWGN_mtx(mcs,:) = (c_sim.EbN0s).*(drP.data_rate)/c_sim.w_channel;
end % Data rates loop

numSim = numSim + L2SStruct.maxChannRea;

%% Beta calculation

rmse_vec = zeros(size(L2SStruct.betas));

for mcs = c_sim.drates
    
    per = per_mtx(:,:,mcs);
    snrAWGN = snrAWGN_mtx(mcs,:);
    perAWGN = perAWGN_mtx(mcs,:);
    
    j = 1;
    
    for beta = L2SStruct.betas
        
        SNReff_mtx = L2S_SNReff(SNRp_mtx,beta);
        SNReff = permute(per_mtx_pre,[1 3 2]);
        
        rmse_vec(j) = L2S_rmse(SNReff,per,snrAWGN,perAWGN);
        
        j = j + 1;
    end
end

end