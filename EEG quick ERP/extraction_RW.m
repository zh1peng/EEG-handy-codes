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
