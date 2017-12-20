%zhipeng 2017/12/04


clear;clc
% addpath('/media/EEG/eMID project_zp/eeglab14_1_1b')
% addpath('/media/EEG/eMID project_zp/testing code')
datapath='W:\64 EEG\EEG_PROJECTS\eMID preprocessing test\raw data'
savepath='W:\64 EEG\EEG_PROJECTS\eMID preprocessing test\preprocessed_5'
if ~exist(savepath)
    mkdir(savepath)
end
[path,file]=filesearch_regexp(datapath,'^*.bdf$')
parpool(2)
for n=1
save_name=['pre_',file{n}(1:end-4)];
EEG = pop_biosig(fullfile(path{n},file{n}));  % ,'ref',48)
EEG = eeg_checkset( EEG );
EEG = pop_select( EEG,'nochannel',{'EXG7' 'EXG8'});
EEG = eeg_checkset( EEG );
EEG=pop_chanedit(EEG, 'lookup','W:\64 EEG\EEG_PROJECTS\eMID preprocessing test\64_6_RW.ced');
EEG = eeg_checkset( EEG );
EEG = pop_reref( EEG, [69 70] );
EEG = eeg_checkset( EEG );
EEG = pop_eegfiltnew(EEG, 0.1,15,16896,0,[],1);
EEG = eeg_checkset( EEG );
EEG = pop_epoch( EEG, {  '13'  '16'  '23'  '26'  '33'  '36'  '50'  '101'  '102'  '103'  }, [-0.5 2]);
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [-199.2188 0]);
EEG = eeg_checkset( EEG );
EEG=pop_runica(EEG,'extended', 1);
EEG = eeg_checkset(EEG);
EEG = pop_saveset( EEG, 'filename',save_name,'filepath',savepath);
EEG = eeg_checkset( EEG );
EEG=[]
end

