data_path='Z:\64 EEG\EEG_PREPROCESSED\EMID\TO QC'
[path,name]=filesearch_regexp(data_path, '^Final*\w*.set')
for n = 1: length(name)
    filename=fullfile(path{n},name{n})
    EEG=pop_loadset('filename',name{n},'filepath',path{n})
    quality_index=data_quality(EEG)
    results{n,1}=name{n};
    results{n,2}=quality_index;
end



foldernames=cellfun(@(x) x(6:end-9),results(:,1),'Unif',0)
foldernames(:,2)=results(:,2)

new_folders=foldernames;
new_folders(43:134,:)=[]
select=cell2mat(new_folders(:,2))<=25
select_foldername=new_folders(select,1);
select_foldername
src=fullfile(data_path,select_foldername)
des='Y:\backup1\TO QC_THEN'
for n=37:length(src)
    src_tmp=src{n};
    movefile(src_tmp,des,'f')
end
