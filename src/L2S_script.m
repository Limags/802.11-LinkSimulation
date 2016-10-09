clc
clear all
close all

global c_sim;

%% Initialize variables

L2S = true; % Flag for L2S simulation

% Maximum number of channel realizations
L2SStruct.maxChannRea = 2;
% Channel models
L2SStruct.chan_multipath = {'B'};
% Standards to simulate
L2SStruct.version = {'802.11n' '802.11ac'};
% Channel bandwidths
L2SStruct.w_channel = [20];
% Cyclic prefixes
L2SStruct.cyclic_prefix = {'long'};
% Data length of PSDUs in bytes
L2SStruct.data_len = [1000];
% Beta range and resolution
L2SStruct.betas = 0:0.5:30;

% Display simulation status
L2SStruct.display = true;

hsr_script; % Initialize c_sim

%% Simulate to calculate SNRps and PERs

L2S_simulate(L2SStruct,parameters);

%% Optimize beta

configNum = length(L2SStruct.chan_multipath)*length(L2SStruct.version)*...
    length(L2SStruct.w_channel)*length(L2SStruct.cyclic_prefix)*...
    length(L2SStruct.data_len);
totalSimNum = chanNum*L2SStruct.maxChannRea;

for numSim = 1:L2SStruct.maxChannRea:(totalSimNum - L2SStruct.maxChannRea + 1)
    
    [SNRp_mtx,per_mtx,snrAWGN_mtx,perAWGN_mtx] = L2S_load(numSim);
    [minbeta,rmse,rmse_vec] = L2S_beta(SNRp_mtx,per_mtx,snrAWGN_mtx,perAWGN_mtx);
    
    filename = ['L2S_beta_results_' ...
        num2str(mod(numSim-1,L2SStruct.maxChannRea) + 1) '.mat'];
    save(filename,'L2SStruct','minbeta','rmse','rmse_vec');
    
end

