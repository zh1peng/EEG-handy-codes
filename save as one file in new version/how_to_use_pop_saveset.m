data_path='Z:\eMID project'
[path,filename]=filesearch_substring(data_path,'fdt');
for indx=1:length(filename)
    data_path=path{indx};
            name=filename{indx};
            name_tmp=strcat(name(1,1:end-4),'.set');
            EEG = pop_loadset(name_tmp,data_path);
            EEG = eeg_checkset( EEG );
            
            setname=strcat(name(1,1:end-4));
            EEG = eeg_checkset( EEG );
            EEG = my_pop_saveset(EEG, 'filename',setname,'filepath',data_path);
            clear EEG
            delete(fullfile(path{indx},filename{indx}))
            disp(sprintf('processing %d / %d',indx,length(filename)));
end

