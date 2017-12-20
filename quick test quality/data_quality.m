function quality_index=data_quality(EEG)
        maxindex = min(1000, EEG.pnts*EEG.trials);
        stds = std(EEG.data(:,1:maxindex),[],2);
        datastd = stds;
        stds = sort(stds);
        if length(stds) > 2
            stds = mean(stds(2:end-1));
        else
            stds = mean(stds);
        end;
        spacing = stds*3;
        if spacing > 10
            spacing = round(spacing);
        end
        quality_index=spacing;
end
    

% data_path='Z:\EEG_PREPROCESSED\EMID\TO QC'
% [path,name]=filesearch_regexp(data_path, '^Final*\w*.set')
% for n = 1: length(name)
%     filename=fullfile(path{n},name{n})
%     EEG=pop_loadset('filename',name{n},'filepath',path{n})
%     quality_index=data_quality(EEG)
%     results{n,1}=name{n};
%     results{n,2}=quality_index;
% end
% foldernames=cellfun(@(x) x(6:end-9),results(:,1),'Unif',0)
% foldernames(:,2)=results(:,2)
% xlswrite('Z:\eMID project\TO QC\qc_score.xls',foldernames)