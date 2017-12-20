function [info]=my_eMID_pipeline(dataset_name,dataset_path, known_bad_idx,save_path,log_path)
% zhipeng

if ~exist(save_path)
    mkdir(save_path)
end

if ~exist(log_path)
    mkdir(log_path)
end

try
save_ids=dataset_name(5:end-4);
save_name=['Final_',save_ids];

EEG = pop_loadset('filename',dataset_name,'filepath',dataset_path);
EEG = eeg_checkset( EEG );

EEG = pop_eegfiltnew(EEG, 0.1,32,16896,0,[],1);
EEG = eeg_checkset( EEG );

channel_list=channel_properties(EEG,[1:68],32);
chan_rej1=find(min_z(channel_list)==1);
chan_rej=[chan_rej1,known_bad_idx];

if ~isempty(chan_rej)
for badi=1:length(chan_rej)
    EEG = pop_interp(EEG,chan_rej(badi), 'spherical');
    EEG = eeg_checkset( EEG );
end
end

EEG = pop_epoch( EEG, {  '13'  '16'  '23'  '26'  '33'  '36' '101' '102' '103'  '10150'  '10250' '10350'}, [-0.2 2]);
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [-199.2188 0]);
EEG = eeg_checkset( EEG );

num_pca=68-length(chan_rej);
EEG=pop_runica(EEG,'extended', 1,'pca',num_pca); 
EEG = eeg_checkset(EEG);

ICA_list = component_properties(EEG,[65:68]);
IC_rej=find(min_z(ICA_list)==1);

if ~isempty(IC_rej)
EEG=pop_subcomp(EEG,IC_rej,0);
EEG = eeg_checkset( EEG );
end

EEG = pop_rmbase( EEG, [-199.2188 0]);
EEG = eeg_checkset( EEG );

%Find bad channels
channel_list=channel_properties(EEG,[1:68],32);
chan_rej_ICA=find(min_z(channel_list)==1);

if ~isempty(chan_rej_ICA)
for badi=1:length(chan_rej_ICA)
    EEG = pop_interp(EEG,chan_rej_ICA(badi), 'spherical');
    EEG = eeg_checkset( EEG );
end
end

%Find bad channels per epoch
bad_chan_cell=cell(size(EEG.data,3),1);
for epoch_i=1:size(EEG.data,3)
bad_chan_epoch_list=single_epoch_channel_properties(EEG,epoch_i,[1:64]);
tmp_bad=find(min_z(bad_chan_epoch_list)==1);
bad_chan_cell{epoch_i}=tmp_bad;
end

h_epoch_interp_spl(EEG, bad_chan_cell,[65:68]);

%Find bad epoches
epoch_list = epoch_properties(EEG,[1:64]);
epoch_rej=find(min_z(epoch_list)==1);

if ~isempty(epoch_rej)
            EEG = pop_rejepoch(EEG,epoch_rej,0);
            EEG = eeg_checkset( EEG );
end
EEG = pop_saveset( EEG, 'filename',save_name,'filepath',save_path);
EEG=[];
info{1}=save_ids;
info{2}=mat2str(chan_rej);
info{3}=mat2str(IC_rej);
info{4}=mat2str(chan_rej_ICA);
info{5}=mat2str(epoch_rej);
cell2csv(fullfile(log_path,[save_ids,'.csv']),info);
catch
    info{1}=save_ids;
    info{2}='error';
    cell2csv(fullfile(log_path,['error',save_ids,'.csv']),info);
    EEG=[];
    info=[];
end
end