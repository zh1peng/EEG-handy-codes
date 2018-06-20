% win_path='W:\64_EEG\EEG_data\Preprocessed\EMID'
linux_path='/media/EEG/64_EEG/EEG_data/Preprocessed/EMID/'

% data_path=win_path;
data_path=linux_path;

file_id=cellfun(@(x) strcat('qc_Finalretrig_filter_',x),cov(:,1),'Unif',0)
for subi=1:length(file_id)
    [file_path(subi,1),file_name(subi,1)]=filesearch_substring(data_path,[file_id{subi},'.set']);
end
marks={'101','102','103','51','52','53','13','16','23','26','33','36'}
for subi=1:length(file_name)
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
tmp_EEG = pop_epoch( ORIG, marks(marki), [-0.2 2]);
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

%% P2 COMP
    datapath='F:\TO QC\'
% [path,filename]=filesearch_regexp(datapath,'^qc\w*.set$');
load('good_sub.mat')

   for n=1:length(file_name)
        EEG=pop_loadset(file_name{n,1},file_path{n,1});
        [urtype]=struct2vector(EEG.urevent);
        cue_uridx=find(urtype==101|urtype==102|urtype==103);
        fb_uridx=find(urtype==13 |urtype==23 |urtype==33 |urtype==16 |urtype==26|urtype== 36);
        % remove any fb before cue
       cue_n(n,1)=length(cue_uridx);
       fb_n(n,1)=length(fb_uridx);

        if length(cue_uridx)~=144
            fb_uridx=fb_uridx(fb_uridx>cue_uridx(1));
            if length(cue_uridx)~=length(fb_uridx)
     %     record that and skip, maybe fix manually
            end
        end

        %% RW:
        cues=urtype(cue_uridx);
        cues(cues==101)=20;
        cues(cues==102)=-20;
        cues(cues==103)=0;

        fbs=urtype(fb_uridx);
        fbs(fbs==13)=20;
        fbs(fbs==16)=0;
        fbs(fbs==23)=0;
        fbs(fbs==26)=-20;
        fbs(fbs==33)=0;
        fbs(fbs==36)=0;

        eta=0.3;
        pg1=0.5;
        for trial_i=1:length(cues)
            ev(trial_i)=cues(trial_i)*pg1;
            pe(trial_i)=fbs(trial_i)-ev(trial_i);
            if cues(trial_i)==0
                pg1=pg1;
            else
                pg2=max(min(pg1+eta*(pe(trial_i)./cues(trial_i)),1.0),0.0);
                pg1=pg2;
            end
        end
        %% get unique epoch_num
        % Epoching is based on the first instance of the duplicated markers
        [type,latency,urcode,epoch_num]=struct2vector(EEG.event);
        [C,ia,ic] = unique(epoch_num);
        type=type(ia); latency=latency(ia); urcode=urcode(ia); epoch_num=C;
        %% Intersect by urcode
        [~,cue_epoch_idx,cue_ev_idx]=intersect(urcode,cue_uridx);
        EEG.RWinfo.left_cue=type(cue_epoch_idx);
        EEG.RWinfo.left_cue_epoch_num=epoch_num(cue_epoch_idx);
        EEG.RWinfo.left_cue_ev_value=ev(cue_ev_idx)';

        [~,fbs_epoch_idx,fbs_pe_idx]=intersect(urcode,fb_uridx);
        EEG.RWinfo.left_fbs=type(fbs_epoch_idx);
        EEG.RWinfo.left_fbs_epoch_num=epoch_num(fbs_epoch_idx);
        EEG.RWinfo.left_fbs_pe_value=pe(fbs_pe_idx)';

        EEG.RWinfo.pos_PE_epoch=EEG.RWinfo.left_fbs_epoch_num(EEG.RWinfo.left_fbs_pe_value>0);
        EEG.RWinfo.neg_PE_epoch=EEG.RWinfo.left_fbs_epoch_num(EEG.RWinfo.left_fbs_pe_value<0);

        EEG.RWinfo.cue_n=cue_n(n,1);
        EEG.RWinfo.fb_n=fb_n(n,1);
        EEG.RWinfo.pos_PE_n=length(EEG.RWinfo.pos_PE_epoch);
        EEG.RWinfo.neg_PE_n=length(EEG.RWinfo.neg_PE_epoch);
        eval(sprintf('RW_info.sub_%s=EEG.RWinfo', num2str(n)))
        
        
        %% Select
%         EEG =pop_select(EEG, 'channel',[1:64])
        EEG = pop_reref(EEG, [69 70] );
        
        tmp_EEG=pop_select(EEG, 'trial',  EEG.RWinfo.pos_PE_epoch,'time',[-0.2  2]);
        tmp_EEG = pop_rmbase(tmp_EEG, [-200  0]); %-200?
        tmp_EEG = eeg_checkset( tmp_EEG );
        data=tmp_EEG.data;
        eval('pos_PE(:,:,n)=squeeze(mean(data,3));')
        tmp_EEG=[]; data=[];

        tmp_EEG=pop_select(EEG, 'trial',  EEG.RWinfo.neg_PE_epoch,'time',[-0.2  2])
        
        tmp_EEG = pop_rmbase(tmp_EEG, [-200  0]); %-200?
        tmp_EEG = eeg_checkset( tmp_EEG );
        tmp_EEG = eeg_checkset( tmp_EEG );
        data=tmp_EEG.data;
        eval('neg_PE(:,:,n)=squeeze(mean(data,3));')
        tmp_EEG=[]; data=[];
    %     EEG = eeg_checkset( EEG );
    %     EEG = pop_saveset( EEG, 'filename',save_name,'filepath',savepath);
    %     EEG = eeg_checkset( EEG );
    end

addpath('F:\Google Drive\zhipeng git folders\my-EEG-codes\EEG quick ERP')
load('F:\Google Drive\zhipeng git folders\my-EEG-codes\EEG quick ERP\chanlocs.mat')
chanlocs(65:end)=[];
% chanlocs([15, 52])=[];


        
marks={'pos_PE', 'neg_PE'}
 for marki=1:length(marks)
    eval(sprintf('mean_%s=squeeze(mean(%s,3));',marks{marki},marks{marki}));
 end


 figure; topoplot([],chanlocs,'style','blank','electrodes','labelpoint');
 Fnorm=12/(512/2)
df=designfilt('lowpassfir','FilterOrder',15,'CutoffFrequency',Fnorm)
for chan=47
% chan_label=chaninfo(chan).labels;

 x=1:1125;
       x1=mean_pos_PE(chan,x)%-mean(m101(chan,1:102));
       x2=mean_neg_PE(chan,x)%-mean(m102(chan,1:102));
 
xx = 1:1:1125;
xx1 = filter(df,x1)
xx2= filter(df,x2)

figure
plot(xx,xx1,'g',xx,xx2,'r')
hline(0,'b-')
vline(102,'b-')
 title(chanlocs(chan).labels)
 ylim([-5,15])
set(gca,'YDir','reverse')   
set(gca,'xtick',[0:51:1126],'xticklabel',[-200:100:2000])
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
diff_PE=mean_pos_PE-mean_neg_PE;
time_points=[100,150,200,250,300,350,400]
for timei=1:length(time_points)
    start=(time_points(timei)+200)*0.512
    endpoint=(time_points(timei)+300)*0.512
% figure; topoplot(squeeze(mean(mean_pos_PE(:,start:endpoint),2)),chanlocs);
% title(sprintf('pos PE %s-%s', num2str(time_points(timei)),num2str(time_points(timei)+100)))
% 
% figure; topoplot(squeeze(mean(mean_neg_PE(:,start:endpoint),2)),chanlocs);
% title(sprintf('neg PE %s-%s', num2str(time_points(timei)),num2str(time_points(timei)+100)))


figure; topoplot(squeeze(mean(diff_PE(:,start:endpoint),2)),chanlocs);
title(sprintf('diff PE %s-%s', num2str(time_points(timei)),num2str(time_points(timei)+100)))
end
