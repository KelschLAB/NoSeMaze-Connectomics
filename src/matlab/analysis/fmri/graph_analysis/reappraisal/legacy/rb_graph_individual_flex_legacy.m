function gstruc=rb_graph_individual_flex(M,thr,normalize,calcat)

% calculate graph measures for one individual connectivity matrix (one
% subject at one threshold)
%
% M = connectivity matrix (without negative weights !!!)
% thr = threshold (fraction of edges preserved)
% normalize = 'max': normalze to maximum weight, 'bin': binarize, 'none': don't normalize
% calcat = cell array with categories of graph properties to calculate
%           'all' : calculate all
%           'smallworld' : Clustering coeff, characteristic path length, small world index
%           'efficiency' : global and local efficiencies
%           'centrality' : degree, strength, betweennness centrality
%           'modularity' : modularity, participation index
%           'norm' : generate random networks and normalized versions of
%                   properties chosen by other options
%
% gstruc = structure with graph properties
%       .l_[  ] = local properties
%       .g_[  ] = global properties
%       .o_[  ] = other stuff

% which properties of graph to calc?
diacutcalc=0; % Added by JR (keeps network connected)
modcalc=0;
swicalc=0;
nullcalc=0;
centcalc=0;
effcalc=0;
swpcalc=0; % Added by JR (swp)
resiliencecalc=0; % Added by JR (robusteness)


if any(strcmp('all',calcat))
    % calculate everything
    diacutcalc=1;
    modcalc=1;
    swicalc=1;
    nullcalc=1;
    centcalc=1;
    effcalc=1;
    swpcalc=1;
    resiliencecalc=1;
else
    diacutcalc=any(strcmp('diacutcalc',calcat));
    swicalc=any(strcmp('smallworld',calcat));
    effcalc=any(strcmp('efficiency',calcat));
    centcalc=any(strcmp('centrality',calcat));
    modcalc=any(strcmp('modularity',calcat));
    nullcalc=any(strcmp('norm',calcat));
    swpcalc=any(strcmp('swpcalc',calcat));
    resiliencecalc=any(strcmp('resiliencecalc',calcat));
end



% create output-structure with connectivity matrix, add more fields when
% calculating more stuff
gstruc=struct('o_CIJ',{M});

% thresholding
if thr>0 && diacutcalc==1
    M_thr=diacut(M,thr);
elseif thr>0 && diacutcalc==0
    M_thr=threshold_proportional(M,thr);
else
    M_thr=M;
end

gstruc.o_cutoffs=thr;

% normalization/binarization
switch normalize
    
    case 'max'
        gstruc.o_CIJ_thresh=M_thr;
        M_nrm=weight_conversion(M_thr,'normalize');
        M_thr=M_nrm;
        gstruc.o_CIJ_thr_nrm=M_thr;
        
    case 'bin'
        gstruc.o_CIJ_thresh=M_thr;
        M_thr=double(M_thr>0);
        gstruc.o_CIJ_bin=M_thr;
        
    case 'none'
        gstruc.o_CIJ_thresh=M_thr;
        
    otherwise
        error('Normalization option must be "none" or "bin" or "max"');
end

% Connection length matrix (needed for distance based measures like BCI and CPL)
L=weight_conversion(M_thr,'lengths');

if (swicalc || effcalc)
    % Distance matrix, local average pathlength
    
    switch normalize
        case 'bin'
            D=distance_bin(L);
            
        otherwise
            D=distance_wei(L);
    end
    
    [cpl,e_glob,ecc,radius,diameter]=charpath(D);
end

if centcalc
    
    % degree
    deg=degrees_und(M_thr);
    gstruc.l_degree=deg';
    
    switch normalize
        case 'bin'
            % betweeness centrality
            bci=betweenness_bin(M_thr);
            gstruc.l_bci=bci';
            
        otherwise
            % node strength
            strength=sum(M_thr);
            gstruc.l_strength=strength';
            
            % betweeness centrality
            bci=betweenness_wei(L);
            gstruc.l_bci=bci;
    end
end

if swicalc
    
    % clustering coefficients
    switch normalize
        case 'bin'
            lcc=clustering_coef_bu(M_thr);
        otherwise
            lcc=clustering_coef_wu(M_thr);
    end
    
    gcc=mean(lcc);
    gstruc.l_cc=lcc;
    gstruc.g_cc=gcc;
    
    % characteristic path length
    gstruc.g_cpl=cpl;
    
    % Small-worldness
    swi=gcc/cpl;
    gstruc.g_swi=swi;
end

if effcalc
    % local and global efficiencies
    switch normalize
        case 'bin'
            e_loc=efficiency_bin(M_thr,1);
        otherwise
            e_loc=efficiency_wei(M_thr,1);
    end
    
    e_loglo=e_loc./e_glob;
    e_loc_m=mean(e_loc);
    
    gstruc.l_E_loc=e_loc;
    gstruc.g_E_loc=e_loc_m;
    gstruc.l_E_logl=e_loglo;
    gstruc.g_E_glob=e_glob;
end




if nullcalc
    switch normalize
        case 'bin'
            % Create random nullmodel (according to "Weight-conserving characterization ...", Rubinov, Sporns (2011)
            N_null=100;         % number of nullmodels for averaging
            bin_swap=5;         % rewire each edge 5 times
            
            
            for jnull=1:N_null
                
                %random order of nodes
                rord=randperm(length(M_thr));
                
                %calculate nullmodel
                if diacutcalc == 1
                    [M_null,R]=randmio_und_connected(M_thr(rord,rord),bin_swap);
                elseif diacutcalc == 0
                    [M_null,R]=randmio_und(M_thr(rord,rord),bin_swap);
                end
                
                M_null_alle{jnull}=M_null;
                R_alle(jnull)=R(1);
                
                % Alternative Option:
                % [M_null]=random_matrix_generator(M_thr); %% Function in
                % Matlab_jr auf flstorage
                
                if swicalc
                    %clustering coef of nullmodels
                    lcc_null_alle(jnull,:)=clustering_coef_bu(M_null);
                end
                
                if swicalc || effcalc
                    %CPL + global efficiency
                    cL_null=weight_conversion(M_null,'lengths');
                    d_null=distance_bin(cL_null);
                    [cpl_null_alle(jnull),eglob_null_alle(jnull),~,~,~]=charpath(d_null);
                end
                
                if effcalc
                    % local eff
                    e_loc_null_alle(jnull,:)=efficiency_bin(M_null,1);
                end
            end
            
            
        otherwise
            % Create random nullmodel (according to "Weight-conserving characterization ...", Rubinov, Sporns (2011)
            N_null=100;         % number of nullmodels for averaging
            bin_swap=5;         % rewire each edge 5 times
            wei_freq=1;         % reorder weights every run (necessary for small networks)
            
            for jnull=1:N_null
                
                %random order of nodes
                rord=randperm(length(M_thr));
                
                %calculate nullmodel
                [M_null,R]=null_model_und_sign(M_thr(rord,rord),bin_swap,wei_freq);
                
                M_null_alle{jnull}=M_null;
                R_alle(jnull)=R(1);
                
                % Alternative Option:
                % [M_null]=random_matrix_generator(M_thr); %% Function in
                % Matlab_jr auf flstorage
                
                if swicalc
                    %clustering coef of nullmodels
                    lcc_null_alle(jnull,:)=clustering_coef_wu(M_null);
                end
                
                if swicalc || effcalc
                    %CPL + global efficiency
                    cL_null=weight_conversion(M_null,'lengths');
                    d_null=distance_wei(cL_null);
                    [cpl_null_alle(jnull),eglob_null_alle(jnull),~,~,~]=charpath(d_null);
                end
                
                if effcalc
                    % local eff
                    e_loc_null_alle(jnull,:)=efficiency_wei(M_null,1);
                end
            end
    end
    
    if swicalc
        % Clustering and Pathlength and efficiencies of random network (averaging over N_null random
        % networks)
        lcc_null=mean(lcc_null_alle,1)';
        gcc_null=mean(lcc_null);
        cpl_null=mean(cpl_null_alle(~isinf(cpl_null_alle)));
        
        gstruc.l_cc_null=lcc_null;
        gstruc.g_cc_null=gcc_null;
        gstruc.g_cpl_null=cpl_null;
        %SWI
        swi_null=gcc_null/cpl_null;
        gstruc.g_swi_null=swi_null;
        
        % normalize CC,CPL,SWI to nullmodel
        lcc_norm=(lcc./lcc_null).*(lcc~=0);
        gcc_norm=gcc/gcc_null;
        swi_norm=swi/swi_null;
        cpl_norm=cpl/cpl_null;
        
        gstruc.l_cc_norm=lcc_norm;
        gstruc.g_cc_norm=gcc_norm;
        gstruc.g_swi_norm=swi_norm;
        gstruc.g_cpl_norm=cpl_norm;
        
    end
    
    if effcalc
        eglob_null=mean(eglob_null_alle);
        eloc_null=mean(e_loc_null_alle,1);
        eloc_m_null=mean(eloc_null);
        gstruc.g_Eglob_null=eglob_null;
        gstruc.l_Eloc_null=eloc_null';
        gstruc.g_Eloc_null=eloc_m_null;
        
        % normalize efficiencies to nullmodel
        eglob_norm=e_glob/eglob_null;
        eloc_m_norm=e_loc_m/eloc_m_null;
        eloc_norm=e_loc./eloc_null';
        
        gstruc.g_E_glob_norm=eglob_norm;
        gstruc.g_E_loc_m_norm=eloc_m_norm;
        gstruc.o_E_loc=eloc_norm;
        
    end
end




if modcalc
    % detection of modularity partition
    % calculate Nrun partitions and Q-values, use Nmod with highest Q for averaging
    %=> Q, intramodule-likelyhood matrix modp
    Nrun=100;      % number of runs = number of partitions calculated
    Nmax=100;      % maximum number of runs (abortion-condition)
    Nout=10;       % number of highest.modularity partitions to be taken into account
    Nmod=2;         % minimum number of modules necessary for not rejecting a partition
    
    [modp,Qmax,Nmodu,q_all,affil_all,Nmodu_all]=rb_modp_best({M_thr},Nrun,Nmax,Nout,Nmod);
    
    %find optimal partition by partitioning modp (intramodule likelihood)
    
    %     [mod_affil,~]=modularity_louvain_und_sign(modp{1});
    [mod_affil,~]=community_louvain(modp{1});
    
    gstruc.o_modp_mat=modp;
    gstruc.g_modularity=cell2mat(Qmax);
    gstruc.o_mod_affil=mod_affil';
    gstruc.o_mod_affil_all=affil_all;
    gstruc.o_mod_q_all=q_all;
    gstruc.o_mod_Nmodu_all=Nmodu_all;
    
    gstruc.g_mod_n_modu_mean=mean(Nmodu_all{1,:});
    gstruc.g_mod_n_modu_std=std(Nmodu_all{1,:});
    temp_mat=affil_all{1};
    for kx=1:size(temp_mat,1);
        numb_mod(kx)=max(temp_mat(kx,:));
        for lx=1:numb_mod(kx);
            module_size(lx)=length(find(temp_mat(1,:)==lx));
        end;
        mean_module_size(kx)=mean(module_size);
        std_module_size(kx)=std(module_size);
        clear module_size;
        clear numb_mod;
    end;
    gstruc.o_mod_module_size_mean_all=mean_module_size;
    gstruc.g_mod_module_size_mean=mean(mean_module_size);
    gstruc.o_mod_module_size_std_all=std_module_size;
    gstruc.g_mod_module_size_std=mean(std_module_size);
    
    % Participation
    PI=participation_coef(M_thr,mod_affil);
    gstruc.l_PI=PI;
end

if swpcalc
    switch normalize
        case 'bin'
            % small world propensity
            [SWP,delta_C,delta_L,reg_path,rand_path,net_path,reg_clus,rand_clus,net_clus,W_reg,W_rand] = small_world_propensity(M_thr,'bin');
            gstruc.g_swp=SWP;
            gstruc.g_delta_C=delta_C;
            gstruc.g_delta_L=delta_L;
            gstruc.g_reg_path=reg_path;
            gstruc.g_rand_path=rand_path;
            gstruc.g_net_path=net_path;
            gstruc.g_reg_clus=reg_clus;
            gstruc.g_rand_clus=rand_clus;
            gstruc.g_net_clus=net_clus;
            gstruc.o_W_reg=W_reg;
            gstruc.o_W_rand=W_rand;
            %SWP with connected network: START
            A = (gstruc.g_cpl - rand_path);
            if A < 0
                A = 0;
            end
            diff_path =  A/ (reg_path - rand_path);
            if gstruc.g_cpl == Inf || rand_path == Inf || reg_path == Inf
                diff_path = 1;
            end
            if diff_path > 1
                diff_path = 1;
            end
            B = (reg_clus - gstruc.g_cc);
            if B < 0
                B = 0;
            end
            diff_clus = B / (reg_clus - rand_clus);
            if isnan(reg_clus) || isnan(rand_clus) || isnan(gstruc.g_cc)
                diff_clus = 1;
            end
            if diff_clus > 1
                diff_clus = 1;
            end
            gstruc.g_swp_JR = 1 - (sqrt(diff_clus^2 + diff_path^2)/sqrt(2));
            gstruc.g_delta_C_JR=diff_clus;
            gstruc.g_delta_L_JR=diff_path;
            %SWP with connected network: END
            
            
        otherwise
            % small world propensity
            [SWP,delta_C,delta_L,reg_path,rand_path,net_path,reg_clus,rand_clus,net_clus,W_reg,W_rand] = small_world_propensity(M_thr);
            gstruc.g_swp=SWP;
            gstruc.g_delta_C=delta_C;
            gstruc.g_delta_L=delta_L;
            gstruc.g_reg_path=reg_path;
            gstruc.g_rand_path=rand_path;
            gstruc.g_net_path=net_path;
            gstruc.g_reg_clus=reg_clus;
            gstruc.g_rand_clus=rand_clus;
            gstruc.g_net_clus=net_clus;
            gstruc.o_W_reg=W_reg;
            gstruc.o_W_rand=W_rand;
            %SWP with connected network: START
            A = (gstruc.g_cpl - gstruc.g_cpl_null);
            if A < 0
                A = 0;
            end
            diff_path =  A/ (reg_path - gstruc.g_cpl_null);
            if gstruc.g_cpl == Inf || gstruc.g_cpl_null == Inf || reg_path == Inf
                diff_path = 1;
            end
            if diff_path > 1
                diff_path = 1;
            end
            B = (reg_clus - gstruc.g_cc);
            if B < 0
                B = 0;
            end
            diff_clus = B / (reg_clus - gstruc.g_cc_null);
            if isnan(reg_clus) || isnan(gstruc.g_cc_null) || isnan(gstruc.g_cc)
                diff_clus = 1;
            end
            if diff_clus > 1
                diff_clus = 1;
            end
            gstruc.g_swp_JR = 1 - (sqrt(diff_clus^2 + diff_path^2)/sqrt(2));
            gstruc.g_delta_C_JR=diff_clus;
            gstruc.g_delta_L_JR=diff_path;
            %SWP with connected network: END
    end
end

if resiliencecalc
    % resilience against targeted and random attack
    [R_targ,R_rnd,E_norm,E_norm_rnd,E_comp,C_comp,R_comp,R_comp_size]= network_resilience_jr(M_thr);
    
    gstruc.g_R_comp_size=R_comp_size;
    gstruc.g_R_comp=R_comp;
    gstruc.o_E_comp=E_comp';
    gstruc.o_C_comp=C_comp';
    gstruc.g_R_targ=R_targ;
    gstruc.g_R_rnd=R_rnd;
    gstruc.o_E_norm=E_norm';
    gstruc.o_E_norm_rnd=E_norm_rnd';
end







