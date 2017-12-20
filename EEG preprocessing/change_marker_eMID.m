% zhipeng insert new marks for 50
clear;clc
% addpath('/media/EEG/eMID project_zp/eeglab14_1_1b')
% addpath('/media/EEG/eMID project_zp/testing code')
datapath='C:\Users\Zhipeng\Desktop\test'
savepath='C:\Users\Zhipeng\Desktop\test\savepath'

if ~exist(savepath)
    mkdir(savepath)
end

[path,file]=filesearch_regexp(datapath,'^*.bdf$')



for n=1
    save_name=['pre_',file{n}(1:end-4)];
    
    %import data
    %visually checked badinfo, there is no 32 reported as bad
    EEG = pop_biosig(fullfile(path{n},file{n}),'ref',32);
    
    % resample-there are 3 datasets need to be resampled
    
    if EEG.srate>512
        try
            EEG = pop_resample( EEG, 512); 
            EEG = eeg_checkset( EEG );
        end
    end
    
    % select channels to use
    EEG = eeg_checkset( EEG );
    EEG = pop_select(EEG, 'channel', [1:70]);
    EEG = eeg_checkset( EEG ); 
    
    %read in location file and re-ref
    EEG=pop_chanedit(EEG, 'lookup','C:\Users\Zhipeng\Desktop\test\64_6_RW.ced');
    
    
    % put in new triggers
    [type, latency]=struct2vector(EEG.event);
    cue_idx=find(type==100|type==101|type==102|type==103);
    target_idx=find(type==50);
    
    cue_press=0
    
    for i=1:length(cue_idx)
        cue_lat=latency(cue_idx(i));
        upper_lat=latency(cue_idx(i))+1500;
        search_idx=find(latency>cue_lat&latency<upper_lat);
        results_idx=search_idx(find(type(search_idx)==50));
        if length(results_idx)==1
            EEG.event(results_idx).type=str2num(sprintf('%d%d',EEG.event(cue_idx(i)).type,EEG.event(results_idx).type));
            EEG = eeg_checkset( EEG );
            if type(results_idx-1)==1|type(results_idx-1)==2
                cue_press=cue_press+1
            end
        else
            continue
        end
    end
    cue_press_info(n)=cue_press;
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',save_name,'filepath',savepath);
    EEG = eeg_checkset( EEG );
    EEG=[]
end