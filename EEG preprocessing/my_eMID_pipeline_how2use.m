%zhipeng 
addpath('Y:\pre')


addpath('W:\64_EEG\EEG_PROJECTS\eMID data Zhipeng\eeglab14_1_1b')
addpath('W:\64_EEG\EEG_PROJECTS\eMID data Zhipeng\to add')
addpath('W:\64_EEG\EEG_PROJECTS\eMID data Zhipeng\FASTER')

data_path='W:\64_EEG\EEG_PROJECTS\eMID data Zhipeng\tmp_pre';
save_path='W:\64_EEG\EEG_PROJECTS\eMID data Zhipeng\Final';
log_path='W:\64_EEG\EEG_PROJECTS\eMID data Zhipeng\Final\log';
load('W:\64_EEG\EEG_PROJECTS\eMID data Zhipeng\info\bad_info204.mat')

[path,filenames]=filesearch_regexp(data_path,'^*.set$');

search_subid=cellfun(@(x) x(5:end-9),filenames,'Unif',0);
parfor n=1:2
dataset_name=filenames{n}
known_bad_idx=cell2mat(bad_info204(strcmp(search_subid{n},bad_info204(:,1))==1,2));
my_eMID_pipeline(dataset_name,data_path, known_bad_idx,save_path,log_path);
end