%prepare data to analyses
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




addpath('F:\Google Drive\zhipeng git folders\my-EEG-codes\EEG quick ERP')
load('F:\Google Drive\zhipeng git folders\my-EEG-codes\EEG quick ERP\chanlocs.mat')
chanlocs(69:70)=[];

% remove any bad sub if needed:
% marks={'101','102','103','10150','10250','10350','13','16','23','26','33','36'}
% for marki=1:length(marks)
%     eval(sprintf('event_%s(:,:,17)=[];',marks{marki}));
% end
        

 for marki=1:length(marks)
    eval(sprintf('m%s=squeeze(mean(event_%s,3));',marks{marki},marks{marki}));
 end


 
 
%% EMID info	
%   101	'green cue'
% 	102	'red cue'
% 	103	'blue cue'
% 	50	'target'
% 	13	'green positive feedback'
% 	16	'green negative feedback'
% 	23	'red positive feedback'
% 	26	'red negative feedback'
% 	33	'blue positive feedback'
% 	36	'blue negative feedback'
%  srate=512 % 1280/2500=0.512

 
 
 %% cue P3
Fnorm=12/(512/2)
df=designfilt('lowpassfir','FilterOrder',15,'CutoffFrequency',Fnorm)
for chan=32
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

figure; topoplot(squeeze(mean(m101(:,282:409),2)),chanlocs);
title(num2str('green cue 350-600'))

figure; topoplot(squeeze(mean(m102(:,282:409),2)),chanlocs);
title(num2str('red cue 350-600'))

figure; topoplot(squeeze(mean(m103(:,282:409),2)),chanlocs);
title(num2str('blue cue 350-600'))


%% target P3
Fnorm=12/(512/2)
df=designfilt('lowpassfir','FilterOrder',15,'CutoffFrequency',Fnorm)
for chan=32
% chan_label=chaninfo(chan).labels;

 x=1:1126;
       x1=m10150(chan,x)%-mean(m101(chan,1:102));
       x2=m10250(chan,x)%-mean(m102(chan,1:102));
       x3=m10350(chan,x)%-mean(m103(chan,1:102));
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

figure; topoplot(squeeze(mean(m10150(:,282:409),2)),chanlocs);
title(num2str('green target 350-600'))

figure; topoplot(squeeze(mean(m10250(:,282:409),2)),chanlocs);
title(num2str('red target 350-600'))

figure; topoplot(squeeze(mean(m10350(:,282:409),2)),chanlocs);
title(num2str('blue target 350-600'))

%% FB analyses
%1 . omitted gain vs. actual loss vs. neutral loss
% 16 vs. 26 vs. 36
Fnorm=12/(512/2)
df=designfilt('lowpassfir','FilterOrder',15,'CutoffFrequency',Fnorm)
for chan=32
% chan_label=chaninfo(chan).labels;

 x=1:1126;
       x1=m16(chan,x)%-mean(m101(chan,1:102));
       x2=m26(chan,x)%-mean(m102(chan,1:102));
       x3=m36(chan,x)%-mean(m103(chan,1:102));
xx = 0:1:1125;
xx1 = filter(df,x1)
xx2= filter(df,x2)
xx3= filter(df,x3)
figure
plot(xx,xx1,'g',xx,xx2,'r',xx,xx3,'b');
hline(0,'b-')
vline(102,'b-')
 legend('omitted gain', 'actual loss',	'neutral loss')
 title(chanlocs(chan).labels)
 ylim([-10,30])
set(gca,'YDir','reverse')   
set(gca,'xtick',[0:51:1126],'xticklabel',[-200:100:2000])
end


%2. actual gain  vs. avoided loss vs. neutral gain
% 13 vs.23 vs.33
for chan=32
% chan_label=chaninfo(chan).labels;

 x=1:1126;
       x1=m13(chan,x)%-mean(m101(chan,1:102));
       x2=m23(chan,x)%-mean(m102(chan,1:102));
       x3=m33(chan,x)%-mean(m103(chan,1:102));
xx = 0:1:1125;
xx1 = filter(df,x1)
xx2= filter(df,x2)
xx3= filter(df,x3)
figure
plot(xx,xx1,'g',xx,xx2,'r',xx,xx3,'b');
hline(0,'b-')
vline(102,'b-')
 legend('actual gain', 'avoided loss',	'neutral gain')
 title(chanlocs(chan).labels)
 ylim([-10,30])
set(gca,'YDir','reverse')   
set(gca,'xtick',[0:51:1126],'xticklabel',[-200:100:2000])
end