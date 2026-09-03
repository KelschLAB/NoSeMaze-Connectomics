%% master_corr_GLM_to_NoSeMazeSH_reappraisal_jr.m
% Reinwald, Jonathan; 07/2023

% genera description:
% - script for correlation analysis with SPM12 between data from the NoSeMaze
%   and the BOLD response (to the reappraisal task)
% - here, the data from the social hierarchy assessed with the tube tests
%   is used as explanatory covariate

%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/07-GitHub_KelschLab'))

%% Load regressors of interest
%% For each animal, social hierarchy is used based on the 14 days before the scans
% read table for info on animals ID and pairing
T = readtable('/home/jonathan.reinwald/ICON_Autonomouse/07-recording_documentation/01_General_Overview.xlsx','Sheet',9,'ReadVariableNames', true);

% load different hierarchies
% animals in AM1 were scanned at different days (either D45 or D51)
% load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day3to16_12mice_withChasing.mat','DS_info','DS_info_chasing');
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day3to16_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat','DS_info','DS_info_chasing');
% tube hierarchy
DS_info1_3to16 = DS_info;
clear Idx Rank
[~,Idx]=sort([DS_info1_3to16.DS],'descend');
[~,Rank]=sort(Idx);
DS_info1_3to16.Rank = Rank;
DS_info1_3to16.DSzscored = zscore([DS_info1_3to16.DS]);
% chasing
DSchasing_info1_3to16 = DS_info_chasing;
clear Idx Rank
[~,Idx]=sort([DSchasing_info1_3to16.DS],'descend');
[~,Rank]=sort(Idx);
DSchasing_info1_3to16.Rank = Rank;
DSchasing_info1_3to16.DSzscored = zscore([DSchasing_info1_3to16.DS]);

load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day18to29_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat','DS_info','DS_info_chasing');
% tube hierarchy
DS_info1_18to29 = DS_info;
clear Idx Rank
[~,Idx]=sort([DS_info1_18to29.DS],'descend');
[~,Rank]=sort(Idx);
DS_info1_18to29.Rank = Rank;
DS_info1_18to29.DSzscored = zscore([DS_info1_18to29.DS]);

% load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day8to21_12mice_withChasing.mat','DS_info','DS_info_chasing');
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day8to21_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat','DS_info','DS_info_chasing');
DS_info1_8to21 = DS_info;
clear Idx Rank
% tube hierarchy
[~,Idx]=sort([DS_info1_8to21.DS],'descend');
[~,Rank]=sort(Idx);
DS_info1_8to21.Rank = Rank;
DS_info1_8to21.DSzscored = zscore([DS_info1_8to21.DS]);
% chasing
DSchasing_info1_8to21 = DS_info_chasing;
clear Idx Rank
[~,Idx]=sort([DSchasing_info1_8to21.DS],'descend');
[~,Rank]=sort(Idx);
DSchasing_info1_8to21.Rank = Rank;
DSchasing_info1_8to21.DSzscored = zscore([DSchasing_info1_8to21.DS]);

load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day23to35_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat','DS_info','DS_info_chasing');
% tube hierarchy
DS_info1_23to35 = DS_info;
clear Idx Rank
[~,Idx]=sort([DS_info1_23to35.DS],'descend');
[~,Rank]=sort(Idx);
DS_info1_23to35.Rank = Rank;
DS_info1_23to35.DSzscored = zscore([DS_info1_23to35.DS]);

% animals in AM1 were scanned at different days (either D44 and D45)
% load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day1to14_12mice_withChasing.mat','DS_info','DS_info_chasing');
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day1to14_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat','DS_info','DS_info_chasing');
% tube hierarchy
DS_info2 = DS_info;
clear Idx Rank
[~,Idx]=sort([DS_info2.DS],'descend');
[~,Rank]=sort(Idx);
DS_info2.Rank = Rank;
DS_info2.DSzscored = zscore([DS_info2.DS]);
% chasing
DSchasing_info2 = DS_info_chasing;
clear Idx Rank
[~,Idx]=sort([DSchasing_info2.DS],'descend');
[~,Rank]=sort(Idx);
DSchasing_info2.Rank = Rank;
DSchasing_info2.DSzscored = zscore([DSchasing_info2.DS]);

load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day17to28_12mice_withChasingAndDoubleChasing_thresh10_td15tt2s.mat','DS_info','DS_info_chasing');
% tube hierarchy
DS_info2_17to28 = DS_info;
clear Idx Rank
[~,Idx]=sort([DS_info2_17to28.DS],'descend');
[~,Rank]=sort(Idx);
DS_info2_17to28.Rank = Rank;
DS_info2_17to28.DSzscored = zscore([DS_info2_17to28.DS]);

clear info
counter=1;
for idxT = 1:size(T,1)
    % add info on IDs
    info.ID_own{counter}=T.AnimalIDCombined{idxT};
    % add infos on Davids Score and Rank for NoSeMaze 1
    if T.Autonomouse(idxT)==1
        info.NoSeMaze(counter)=1;
        info.AnimalNumb(counter)=T.AnimalNumber(idxT);
        if contains(T.DaysToConsider{idxT},'16')
            % tube hierarchy
            info.DS_own(counter)=DS_info1_3to16.DS(strcmp(DS_info1_3to16.ID,info.ID_own{counter}));
            info.Rank_own(counter)=DS_info1_3to16.Rank(strcmp(DS_info1_3to16.ID,info.ID_own{counter}));
            info.DSzscored_own(counter)=DS_info1_3to16.DSzscored(strcmp(DS_info1_3to16.ID,info.ID_own{counter}));
            % tube hierarchy after
            info.DS_own_after(counter)=DS_info1_18to29.DS(strcmp(DS_info1_18to29.ID,info.ID_own{counter}));
            info.Rank_own_after(counter)=DS_info1_18to29.Rank(strcmp(DS_info1_18to29.ID,info.ID_own{counter}));
            info.DSzscored_own_after(counter)=DS_info1_18to29.DSzscored(strcmp(DS_info1_18to29.ID,info.ID_own{counter}));
            % number/fraction of wins/losses
            clear help_n_wins help_n_losses help_fr_winner help_fr_losses
            help_n_wins = sum(DS_info1_3to16.match_matrix,2);
            help_n_losses = sum(DS_info1_3to16.match_matrix,1)';
            help_fr_winner = help_n_wins./sum(help_n_wins);
            help_fr_losses = help_n_losses./sum(help_n_losses);
            info.n_winner(counter)=help_n_wins(strcmp(DS_info1_3to16.ID,info.ID_own{counter}));
            info.n_loser(counter)=help_n_losses(strcmp(DS_info1_3to16.ID,info.ID_own{counter}));
            info.fr_winner(counter)=help_fr_winner(strcmp(DS_info1_3to16.ID,info.ID_own{counter}));
            info.fr_loser(counter)=help_fr_losses(strcmp(DS_info1_3to16.ID,info.ID_own{counter}));
            % winsProp and lossesProp
            clear match_matrix WinsProp LossesProp
            match_matrix = DS_info1_3to16.match_matrix;
            for i=1:size(match_matrix,1)
                for j=1:size(match_matrix,2)
                    int(i,j)=match_matrix(i,j)+match_matrix(j,i);
                end
            end
            P=match_matrix./int;
            W=sum(P,2,'omitnan')'; %%% w of each animal
            L=sum(P,1,'omitnan');  %%% l for each animal
            for i=1:length(W)
                W2(i,:)=P(i,:).*W;
            end
            for i=1:length(L)
                L2(i,:)=P(:,i)'.*L;
            end
            w2=sum(W2,2,'omitnan')';
            l2=sum(L2,2,'omitnan')';
            DS=W+w2-L-l2;
            WinsProp = W+w2;
            LossesProp = L+l2;
            info.WinsProp(counter)=WinsProp(strcmp(DS_info1_3to16.ID,info.ID_own{counter}));
            info.LossesProp(counter)=LossesProp(strcmp(DS_info1_3to16.ID,info.ID_own{counter}));
            % check for error
            if DS(strcmp(DS_info1_3to16.ID,info.ID_own{counter})) ~= info.DS_own(counter)
                error('Difference between Davids scores: Check for errors!')
            end
            % chasing
            info.DS_chasing(counter)=DSchasing_info1_3to16.DS(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));
            info.Rank_chasing(counter)=DSchasing_info1_3to16.Rank(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));
            info.DSzscored_chasing(counter)=DSchasing_info1_3to16.DSzscored(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));
            % number/fraction of chasings
            clear help_n_chaser help_n_chased help_fr_chaser help_fr_chased
            help_n_chaser = sum(DSchasing_info1_3to16.match_matrix,2);
            help_n_chased = sum(DSchasing_info1_3to16.match_matrix,1)';
            help_fr_chaser = help_n_chaser./sum(help_n_chaser);
            help_fr_chased = help_n_chased./sum(help_n_chased);
            info.n_chaser(counter)=help_n_chaser(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));
            info.n_chased(counter)=help_n_chased(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));
            info.fr_chaser(counter)=help_fr_chaser(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));   
            info.fr_chased(counter)=help_fr_chased(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));
        elseif contains(T.DaysToConsider{idxT},'21')
            % tube hierarchy
            info.DS_own(counter)=DS_info1_8to21.DS(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
            info.Rank_own(counter)=DS_info1_8to21.Rank(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
            info.DSzscored_own(counter)=DS_info1_8to21.DSzscored(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
            % tube hierarchy after
            info.DS_own_after(counter)=DS_info1_23to35.DS(strcmp(DS_info1_23to35.ID,info.ID_own{counter}));
            info.Rank_own_after(counter)=DS_info1_23to35.Rank(strcmp(DS_info1_23to35.ID,info.ID_own{counter}));
            info.DSzscored_own_after(counter)=DS_info1_23to35.DSzscored(strcmp(DS_info1_23to35.ID,info.ID_own{counter}));
            % number/fraction of wins/losses
            clear help_n_wins help_n_losses help_fr_winner help_fr_losses
            help_n_wins = sum(DS_info1_8to21.match_matrix,2);
            help_n_losses = sum(DS_info1_8to21.match_matrix,1)';
            help_fr_winner = help_n_wins./sum(help_n_wins);
            help_fr_losses = help_n_losses./sum(help_n_losses);
            info.n_winner(counter)=help_n_wins(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
            info.n_loser(counter)=help_n_losses(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
            info.fr_winner(counter)=help_fr_winner(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
            info.fr_loser(counter)=help_fr_losses(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
            % winsProp and lossesProp
            clear match_matrix WinsProp LossesProp
            match_matrix = DS_info1_8to21.match_matrix;
            for i=1:size(match_matrix,1)
                for j=1:size(match_matrix,2)
                    int(i,j)=match_matrix(i,j)+match_matrix(j,i);
                end
            end
            P=match_matrix./int;
            W=sum(P,2,'omitnan')'; %%% w of each animal
            L=sum(P,1,'omitnan');  %%% l for each animal
            for i=1:length(W)
                W2(i,:)=P(i,:).*W;
            end
            for i=1:length(L)
                L2(i,:)=P(:,i)'.*L;
            end
            w2=sum(W2,2,'omitnan')';
            l2=sum(L2,2,'omitnan')';
            DS=W+w2-L-l2;
            WinsProp = W+w2;
            LossesProp = L+l2;
            info.WinsProp(counter)=WinsProp(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
            info.LossesProp(counter)=LossesProp(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
            % check for error
            if DS(strcmp(DS_info1_8to21.ID,info.ID_own{counter})) ~= info.DS_own(counter)
                error('Difference between Davids scores: Check for errors!')
            end
            % chasing
            info.DS_chasing(counter)=DSchasing_info1_8to21.DS(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));
            info.Rank_chasing(counter)=DSchasing_info1_8to21.Rank(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));
            info.DSzscored_chasing(counter)=DSchasing_info1_8to21.DSzscored(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));
            % number/fraction of chasings
            clear help_n_chaser help_n_chased help_fr_chaser help_fr_chased
            help_n_chaser = sum(DSchasing_info1_8to21.match_matrix,2);
            help_n_chased = sum(DSchasing_info1_8to21.match_matrix,1)';
            help_fr_chaser = help_n_chaser./sum(help_n_chaser);
            help_fr_chased = help_n_chased./sum(help_n_chased);
            info.n_chaser(counter)=help_n_chaser(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));
            info.n_chased(counter)=help_n_chased(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));
            info.fr_chaser(counter)=help_fr_chaser(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));   
            info.fr_chased(counter)=help_fr_chased(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));
        end
        counter=counter+1;
        % add infos on Davids Score and Rank for NoSeMaze 2
    elseif T.Autonomouse(idxT)==2
        info.NoSeMaze(counter)=2;
        info.AnimalNumb(counter)=T.AnimalNumber(idxT);
        % tube hierarchy
        info.DS_own(counter)=DS_info2.DS(strcmp(DS_info2.ID,info.ID_own{counter}));
        info.Rank_own(counter)=DS_info2.Rank(strcmp(DS_info2.ID,info.ID_own{counter}));
        info.DSzscored_own(counter)=DS_info2.DSzscored(strcmp(DS_info2.ID,info.ID_own{counter}));
        % tube hierarchy after
        info.DS_own_after(counter)=DS_info2_17to28.DS(strcmp(DS_info2_17to28.ID,info.ID_own{counter}));
        info.Rank_own_after(counter)=DS_info2_17to28.Rank(strcmp(DS_info2_17to28.ID,info.ID_own{counter}));
        info.DSzscored_own_after(counter)=DS_info2_17to28.DSzscored(strcmp(DS_info2_17to28.ID,info.ID_own{counter}));
        % number/fraction of wins/losses
        clear help_n_wins help_n_losses help_fr_winner help_fr_losses
        help_n_wins = sum(DS_info2.match_matrix,2);
        help_n_losses = sum(DS_info2.match_matrix,1)';
        help_fr_winner = help_n_wins./sum(help_n_wins);
        help_fr_losses = help_n_losses./sum(help_n_losses);
        info.n_winner(counter)=help_n_wins(strcmp(DS_info2.ID,info.ID_own{counter}));
        info.n_loser(counter)=help_n_losses(strcmp(DS_info2.ID,info.ID_own{counter}));
        info.fr_winner(counter)=help_fr_winner(strcmp(DS_info2.ID,info.ID_own{counter}));
        info.fr_loser(counter)=help_fr_losses(strcmp(DS_info2.ID,info.ID_own{counter}));
        % winsProp and lossesProp
        clear match_matrix WinsProp LossesProp
        match_matrix = DS_info2.match_matrix;
        for i=1:size(match_matrix,1)
            for j=1:size(match_matrix,2)
                int(i,j)=match_matrix(i,j)+match_matrix(j,i);
            end
        end
        P=match_matrix./int;
        W=sum(P,2,'omitnan')'; %%% w of each animal
        L=sum(P,1,'omitnan');  %%% l for each animal
        for i=1:length(W)
            W2(i,:)=P(i,:).*W;
        end
        for i=1:length(L)
            L2(i,:)=P(:,i)'.*L;
        end
        w2=sum(W2,2,'omitnan')';
        l2=sum(L2,2,'omitnan')';
        DS=W+w2-L-l2;
        WinsProp = W+w2;
        LossesProp = L+l2;
        info.WinsProp(counter)=WinsProp(strcmp(DS_info2.ID,info.ID_own{counter}));
        info.LossesProp(counter)=LossesProp(strcmp(DS_info2.ID,info.ID_own{counter}));
        % check for error
        if DS(strcmp(DS_info2.ID,info.ID_own{counter})) ~= info.DS_own(counter)
            error('Difference between Davids scores: Check for errors!')
        end
        % chasing
        info.DS_chasing(counter)=DSchasing_info2.DS(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
        info.Rank_chasing(counter)=DSchasing_info2.Rank(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
        info.DSzscored_chasing(counter)=DSchasing_info2.DSzscored(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
        % number/fraction of chasings
        clear help_n_chaser help_n_chased help_fr_chaser help_fr_chased
        help_n_chaser = sum(DSchasing_info2.match_matrix,2);
        help_n_chased = sum(DSchasing_info2.match_matrix,1)';
        help_fr_chaser = help_n_chaser./sum(help_n_chaser);
        help_fr_chased = help_n_chased./sum(help_n_chased);
        info.n_chaser(counter)=help_n_chaser(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
        info.n_chased(counter)=help_n_chased(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
        info.fr_chaser(counter)=help_fr_chaser(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
        info.fr_chased(counter)=help_fr_chased(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
        counter=counter+1;
        
    end
end

ExplVar(1).name = 'DavidsScore';
ExplVar(1).values = info.DS_own';
ExplVar(1).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.DS_own','descend');
ExplVar(1).DS_sorted = DSv;
ExplVar(1).DS_sortedIndex = DSi;

ExplVar(2).name = 'Rank';
ExplVar(2).values = info.Rank_own';
ExplVar(2).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.Rank_own','descend');
ExplVar(2).DS_sorted = DSv;
ExplVar(2).DS_sortedIndex = DSi;

ExplVar(3).name = 'DavidsScore_zscored';
ExplVar(3).values = info.DSzscored_own';
ExplVar(3).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.DSzscored_own','descend');
ExplVar(3).DS_sorted = DSv;
ExplVar(3).DS_sortedIndex = DSi;

ExplVar(4).name = 'DavidsScoreChasing';
ExplVar(4).values = info.DS_chasing';
ExplVar(4).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.DS_chasing','descend');
ExplVar(4).DS_sorted = DSv;
ExplVar(4).DS_sortedIndex = DSi;

ExplVar(5).name = 'RankChasing';
ExplVar(5).values = info.Rank_chasing';
ExplVar(5).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.Rank_chasing','descend');
ExplVar(5).DS_sorted = DSv;
ExplVar(5).DS_sortedIndex = DSi;

ExplVar(6).name = 'DavidsScoreChasing_zscored';
ExplVar(6).values = info.DSzscored_chasing';
ExplVar(6).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.DSzscored_chasing','descend');
ExplVar(6).DS_sorted = DSv;
ExplVar(6).DS_sortedIndex = DSi;

ExplVar(7).name = 'n_chaser';
ExplVar(7).values = info.n_chaser';
ExplVar(7).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.n_chaser','descend');
ExplVar(7).DS_sorted = DSv;
ExplVar(7).DS_sortedIndex = DSi;

ExplVar(8).name = 'n_chased';
ExplVar(8).values = info.n_chased';
ExplVar(8).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.n_chased','descend');
ExplVar(8).DS_sorted = DSv;
ExplVar(8).DS_sortedIndex = DSi;

ExplVar(9).name = 'fr_chaser';
ExplVar(9).values = info.fr_chaser';
ExplVar(9).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.fr_chaser','descend');
ExplVar(9).DS_sorted = DSv;
ExplVar(9).DS_sortedIndex = DSi;

ExplVar(10).name = 'fr_chased';
ExplVar(10).values = info.fr_chased';
ExplVar(10).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.fr_chased','descend');
ExplVar(10).DS_sorted = DSv;
ExplVar(10).DS_sortedIndex = DSi;

ExplVar(11).name = 'n_winner';
ExplVar(11).values = info.n_winner';
ExplVar(11).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.n_winner','descend');
ExplVar(11).DS_sorted = DSv;
ExplVar(11).DS_sortedIndex = DSi;

ExplVar(12).name = 'n_loser';
ExplVar(12).values = info.n_loser';
ExplVar(12).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.n_loser','descend');
ExplVar(12).DS_sorted = DSv;
ExplVar(12).DS_sortedIndex = DSi;

ExplVar(13).name = 'fr_winner_boxcox';
ExplVar(13).values = boxcox(info.fr_winner'+0.001);
ExplVar(13).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.fr_winner','descend');
ExplVar(13).DS_sorted = DSv;
ExplVar(13).DS_sortedIndex = DSi;

ExplVar(14).name = 'fr_loser_boxcox';
ExplVar(14).values = boxcox(info.fr_loser'+0.001);
ExplVar(14).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.fr_loser','descend');
ExplVar(14).DS_sorted = DSv;
ExplVar(14).DS_sortedIndex = DSi;

ExplVar(15).name = 'WinsProp';
ExplVar(15).values = info.WinsProp';
ExplVar(15).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.WinsProp','descend');
ExplVar(15).DS_sorted = DSv;
ExplVar(15).DS_sortedIndex = DSi;

ExplVar(16).name = 'LossesProp';
ExplVar(16).values = info.LossesProp';
ExplVar(16).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.LossesProp','descend');
ExplVar(16).DS_sorted = DSv;
ExplVar(16).DS_sortedIndex = DSi;

ExplVar(17).name = 'DavidsScore_after';
ExplVar(17).values = info.DS_own_after';
ExplVar(17).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.DS_own_after','descend');
ExplVar(17).DS_sorted = DSv;
ExplVar(17).DS_sortedIndex = DSi;

ExplVar(18).name = 'Rank_after';
ExplVar(18).values = info.Rank_own_after';
ExplVar(18).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.Rank_own_after','descend');
ExplVar(18).DS_sorted = DSv;
ExplVar(18).DS_sortedIndex = DSi;

ExplVar(19).name = 'DavidsScore_zscored_after';
ExplVar(19).values = info.DSzscored_own_after';
ExplVar(19).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.DSzscored_own_after','descend');
ExplVar(19).DS_sorted = DSv;
ExplVar(19).DS_sortedIndex = DSi;

%% define ID and Animal numb for all regressors
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/11-correlation_to_NoSeMaze/AnimalNumb_to_ID.mat');
for ix=1:length(ExplVar)
    for jx=1:length(ExplVar(ix).ID)
        ExplVar(ix).AnimalNumb(jx,1) = AnimalNumb_to_ID(strcmp([AnimalNumb_to_ID.ID],ExplVar(ix).ID(jx))).AnimalNumb;
    end
end

%% Predefinitions for GLM selection
workDir = spm_select(1,'dir','Select Result Directory',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results');
outputDir = fullfile(workDir,'corr_SocialHierarchy');
if exist(outputDir)~=7
    mkdir(outputDir);
end
plot_David_score_in_group(ExplVar(2),ExplVar(2).ID);

%% plots
% for ix=1:length(ExplVar)
%     f = plot_David_score_in_group(ExplVar(ix),ExplVar(ix).ID);
%     exportgraphics(f, fullfile(outputDir,['rank_plot_day_' ExplVar(ix).name '.pdf']),'ContentType','vector','BackgroundColor','none');
%     close all;
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ------------------------ SECOND-LEVEL ANALYSIS ---------------------- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for varIdx = 2%1:length(ExplVar)
    %% 1. Create output directory
    outputDir_secondlevel = [outputDir filesep 'secondlevel_' ExplVar(varIdx).name];% '_7days'];
    if ~exist(outputDir_secondlevel)
        mkdir(outputDir_secondlevel)
    end
    
    %% 2. Load contrast_names.mat
    load([workDir filesep 'firstlevel' filesep 'contrast_info.mat'],'contrast_info');
    
    %% 3. Explicit mask
    %     explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing/DARTEL/mask_template_6.nii';
    explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished.nii';
    
    
    %% 4. Define firstlevel-result directory
    firstlevelDir = [workDir filesep 'firstlevel'];
    
    do_secondlevel_GLM_to_NoSeMaze_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask,ExplVar(varIdx))  
end











