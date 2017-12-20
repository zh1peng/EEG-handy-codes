%zhipeng 

addpath(genpath('/home/users/caoz/codes/eeglab14_1_1b'))
addpath('/home/users/caoz/codes/to add')
addpath('/home/users/caoz/codes/FASTER')

data_path='/home/users/caoz/datasets';
save_path='/home/users/caoz/Final';
log_path='/home/users/caoz/Final/log_file'
load('/home/users/caoz/codes/bad_info204.mat')


[path,filenames]=filesearch_regexp(data_path,'^*.set$');
search_subid=cellfun(@(x) x(5:end-9),filenames,'Unif',0);

parpool(8)
parfor n=57:128
dataset_name=filenames{n};
known_bad_idx=cell2mat(bad_info204(strcmp(search_subid{n},bad_info204(:,1))==1,2));
my_eMID_pipeline(dataset_name,data_path, known_bad_idx,save_path,log_path);
end