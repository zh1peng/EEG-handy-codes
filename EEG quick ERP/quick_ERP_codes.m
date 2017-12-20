%test intermediate files
addpath('V:\my code\TEST CODE')
load('V:\my code\TEST CODE\chanlocs.mat')
% chanlocs(69:70)=[];
data_path='W:\64 EEG\EEG_PROJECTS\eMID data Zhipeng\Final';
[path,filename]=filesearch_regexp(data_path,'^Final\w*.set$');

marks={'101','102','103','10150','10250','10350','13','16','23','26','33','36'}
for n=1:4
ORIG = pop_loadset(filename{n},path{n});
ORIG = eeg_checkset( ORIG );
for marki=1:length(marks)
try
tmp_EEG = pop_epoch( ORIG, marks(marki), [-0.2  2]);
%EEG = pop_selectevent( EEG, ''latency'',''-0.2<=2'',''type'',101,''deleteevents'',''off'',''deleteepochs'',''on'',''invertepochs'',''off'');'
tmp_EEG = eeg_checkset( tmp_EEG );
tmp_EEG = pop_rmbase(tmp_EEG, [-199.2188  0]); %-200?
tmp_EEG = eeg_checkset( tmp_EEG );
%  tmp_EEG = pop_reref( tmp_EEG, [69 70] );
%  tmp_EEG = eeg_checkset( tmp_EEG );
data=tmp_EEG.data;
eval(sprintf('event_%s(:,:,n)=squeeze(mean(data,3));',marks{marki}))
eval(sprintf('trialn_%s(n,1)=size(data,3);',marks{marki}))
tmp_EEG=[];
data=[];
    catch
        error_sub{n,1}=filename{n};
        error_mark{n,marki}=num2str(marki);
    end
end
ORIG=[];
end
marks={'101','102','103','13','16','23','26','33','36'}
        for marki=1:length(marks)
    eval(sprintf('m%s=squeeze(mean(event_%s,3));',marks{marki},marks{marki}));
        end
        
Fnorm=12/(512/2)
df=designfilt('lowpassfir','FilterOrder',15,'CutoffFrequency',Fnorm)
for chan=38
% chan_label=chaninfo(chan).labels;

 x=1:1126;
       x1=m101(chan,x)%-mean(m101(chan,1:102));
       x2=m102(chan,x)%-mean(m102(chan,1:102));
       x3=m103(chan,x)%-mean(m103(chan,1:102));
xx = 0:1:1125;
xx1 = filter(df,x1)
xx2= filter(df,x2)
xx3= filter(df,x3)
figure
plot(xx,xx1,'g',xx,xx2,'r',xx,xx3,'b');
hline(0,'b-')
vline(102,'b-')
 legend('green cue','red cue',	'blue cue')
 title(chanlocs(chan).labels)
 ylim([-10,30])
set(gca,'YDir','reverse')   
set(gca,'xtick',[0:51:1126],'xticklabel',[-200:100:2000])
end

chanlocs(end-1:end)=[];
figure; topoplot(squeeze(mean(m101(:,282:409),2)),chanlocs);
title(num2str('green cue 350-600'))

figure; topoplot(squeeze(mean(m102(:,282:409),2)),chanlocs);
title(num2str('red cue 350-600'))

figure; topoplot(squeeze(mean(m103(:,282:409),2)),chanlocs);
title(num2str('blue cue 350-600'))