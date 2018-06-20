% win_path='W:\64_EEG\EEG_data\Preprocessed\EMID'
linux_path='/media/EEG/64_EEG/EEG_data/Preprocessed/EMID/'

% data_path=win_path;
data_path=linux_path;

file_id=cellfun(@(x) strcat('qc_Finalretrig_filter_',x),cov(:,1),'Unif',0)
for subi=1:length(file_id)
    [file_path(subi,1),file_name(subi,1)]=filesearch_substring(data_path,[file_id{subi},'.set']);
end
marks={'101','102','103','51','52','53','13','16','23','26','33','36'}
for subi=1:length(file_id)
    ORIG = pop_loadset(file_name{subi,1},file_path{subi,1});
    ORIG = eeg_checkset( ORIG );
    try
    ORIG= pop_reref(ORIG, [69 70] );
    ORIG = eeg_checkset( ORIG );
    catch
        continue
    end
for marki=1:length(marks)
try
tmp_EEG = pop_epoch( ORIG, marks(marki), [-0.2  0.8]);
%EEG = pop_selectevent( EEG, ''latency'',''-0.2<=2'',''type'',101,''deleteevents'',''off'',''deleteepochs'',''on'',''invertepochs'',''off'');'
tmp_EEG = eeg_checkset( tmp_EEG );
tmp_EEG = pop_rmbase(tmp_EEG, [-200  0]); %-200?
tmp_EEG = eeg_checkset( tmp_EEG );
data=tmp_EEG.data;
eval(sprintf('event_%s(:,:,subi)=squeeze(mean(data,3));',marks{marki}))
eval(sprintf('trialn_%s(subi,1)=size(data,3);',marks{marki}))
tmp_EEG=[];
data=[];
    catch
        error_sub{subi,1}=file_name{subi};
        error_mark{subi,marki}=num2str(marki);
    end
end
ORIG=[];
end
