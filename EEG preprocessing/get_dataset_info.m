% zhipeng 12.12
datapath='W:\64 EEG\EEG_PROJECTS\eMID data for Zhipeng\RAW'

[path,file]=filesearch_regexp(datapath,'^*.bdf$')

info=NaN(length(path),17);
for n=1:length(file)
subname{n}=file{n}(1:end-4);
try
EEG = pop_biosig(fullfile(path{n},file{n}));  % ,'ref',48)
EEG = eeg_checkset( EEG );
info(n,1)=EEG.nbchan;
info(n,2)=length(EEG.urevent);
info(n,3)=size(EEG.data,1);
info(n,4)=size(EEG.data,2);
info(n,5)=EEG.srate;
    for eventi=1:length(EEG.urevent)
        event_matrix(eventi)=EEG.urevent(eventi).type;
    end
marks={'1','2','13',  '16',  '23'  ,'26' , '33' , '36' , '50' , '101',  '102',  '103'};
for marki=1:length(marks)
    info(n,marki+5)=sum(event_matrix==str2num(marks{marki}));
end
end
event_matrix=[];
end
save('info.mat')