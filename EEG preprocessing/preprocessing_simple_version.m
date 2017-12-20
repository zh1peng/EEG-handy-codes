% zhipeng preprocessing main part. FASTER is incorporated.
clear;clc
addpath('W:\64_EEG\EEG_PROJECTS\eMID data Zhipeng\eeglab14_1_1b')
addpath('W:\64_EEG\EEG_PROJECTS\eMID data Zhipeng\to add')
addpath('W:\64_EEG\EEG_PROJECTS\eMID data Zhipeng\FASTER')

data_path='W:\64_EEG\EEG_PROJECTS\eMID data Zhipeng\tmp_pre';
savepath='W:\64_EEG\EEG_PROJECTS\eMID data Zhipeng\Final';
load('W:\64_EEG\EEG_PROJECTS\eMID data Zhipeng\info\bad_info204.mat')
if ~exist(savepath)
    mkdir(savepath)
end

[path,filenames]=filesearch_regexp(data_path,'^*.set$');

search_subid=cellfun(@(x) x(5:end-9),filenames,'Unif',0);
save_ids=cellfun(@(x) x(5:end-4),filenames,'Unif',0);

info=mat2cell(NaN(length(filenames),5), ones(length(filenames),1),ones(1,5));


for n=1:204
    try
        disp(['****************',num2str(n),'********************']);
        save_name=['Final_',save_ids{n}];
        info{n,1}=save_ids{n};
        EEG = pop_loadset('filename',filenames{n},'filepath',data_path);
        EEG = eeg_checkset( EEG );
        EEG = pop_eegfiltnew(EEG, 0.1,32,16896,0,[],1);
        EEG = eeg_checkset( EEG );
        
        channel_list=channel_properties(EEG,[1:68],32);
        chan_rej1=find(min_z(channel_list)==1);
        chan_rej2=bad_info204(strcmp(search_subid{n},bad_info204(:,1))==1,2);
        chan_rej=[chan_rej1,cell2mat(chan_rej2)];
        info{n,2}=chan_rej;
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
        info{n,3}=IC_rej;
        if ~isempty(IC_rej)
            EEG=pop_subcomp(EEG,IC_rej,0);
            EEG = eeg_checkset( EEG );
        end
        
        EEG = pop_rmbase( EEG, [-199.2188 0]);
        EEG = eeg_checkset( EEG );
        
        %Find bad channels
        channel_list=channel_properties(EEG,[1:68],32);
        chan_rej_ICA=find(min_z(channel_list)==1);
        info{n,4}=chan_rej_ICA;
        if ~isempty(chan_rej_ICA)
            for badi=1:length(chan_rej_ICA)
                EEG = pop_interp(EEG,chan_rej_ICA(badi), 'spherical');
                EEG = eeg_checkset( EEG );
            end
        end
        
        %Find bad channels per epoch
        for epoch_i=1:size(EEG.data,3)
            bad_chan_epoch_list=single_epoch_channel_properties(EEG,epoch_i,[1:64]);
            tmp_bad=find(min_z(bad_chan_epoch_list)==1);
            bad_chan_cell{epoch_i}=tmp_bad;
        end
        
        h_epoch_interp_spl(EEG, bad_chan_cell,[65:68]);
        
        %Find bad epoches
        epoch_list = epoch_properties(EEG,[1:64]);
        epoch_rej=find(min_z(epoch_list)==1);
        info{n,5}=epoch_rej;
        if ~isempty(epoch_rej)
            EEG = pop_rejepoch(EEG,epoch_rej,0);
            EEG = eeg_checkset( EEG );
        end
        EEG = pop_saveset( EEG, 'filename',save_name,'filepath',savepath);
        EEG=[];
        
    catch
        EEG=[]
        continue
    end
end
save('job_info.mat','info');
