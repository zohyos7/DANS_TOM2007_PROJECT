function [] = tom2007_1stLevel()

% tom2007_1stLevel.m
% First-level analysis of Tom et al (2007) Science data
% download and add "tsvread.m" from https://kr.mathworks.com/matlabcentral/fileexchange/32782-tsvread-importing-tab-separated-data?focused=a53e9d7b-eac4-4992-21fa-d380115d33e5&tab=function

%clear all  % clear workspace
clear matlabbatch; clc;

%% set ID, def_path
defThres = 0.2;   % default threshold
stimDuration = 0;   % stimulus duration (0 sec = delta function);
smoothing = [8 8 8];  % smoothing 
currApproach = ['tom2007_d_7' num2str(stimDuration)];  % current approach.. 

[data_path ID] = fileparts(pwd);  % e.g., ID = '576-D-1';
%data_path = '/mnt/nfs/proj/visuperc/wahn/data/';  % CHECK THIS PATH!!
def_path = fullfile(data_path, ID);

% reg_path - where regressor *.tsv files exist
reg_path = fullfile(def_path, 'func');

% data_path - where trial-by-trial data exist
data_path = '/Users/zohyoonseo/tom-data/behav_data';

disp( ['ID = ' ID ] );
disp( ['Approach = ' currApproach] );
disp( ['pwd = ' pwd ])

%% gunzip all nii.gz files first
gunzip(fullfile(reg_path, '*.gz'))

disp('All functional image files are unzipped for SPM analysis')

%% Path containing data
% path for confounding factors
move_path_origin1 = fullfile(reg_path, [ID '_task-mixedgamblestask_run-01_bold_confounds.tsv'] ); 
move_path_origin2 = fullfile(reg_path, [ID '_task-mixedgamblestask_run-02_bold_confounds.tsv'] ); 
move_path_origin3 = fullfile(reg_path, [ID '_task-mixedgamblestask_run-03_bold_confounds.tsv'] ); 
disp('movement path defined')
%% create "R" variable from movement_regressor matrix and save
% run1
[data1, header1, ] = tsvread(move_path_origin1);
R = data1(2:end, (end-5):end);  % remove the first row, 26-31 columns --> movement regressors
save func/movement_regressors_for_epi_01.mat R 
move_path_run1 = fullfile(reg_path, 'movement_regressors_for_epi_01.mat');

% run2
[data2, header2, ] = tsvread(move_path_origin2);
R = data2(2:end, (end-5):end);  % remove the first row, 26-31 columns --> movement regressors
save func/movement_regressors_for_epi_02.mat R 
move_path_run2 = fullfile(reg_path, 'movement_regressors_for_epi_02.mat');

% run3
[data3, header3, ] = tsvread(move_path_origin3);
R = data3(2:end, (end-5):end);  % remove the first row, 26-31 columns --> movement regressors
save func/movement_regressors_for_epi_03.mat R 
move_path_run3 = fullfile(reg_path, 'movement_regressors_for_epi_03.mat');

%% Load regressors
% onset
% duration
% parametric loss
% distance from indifference
% parametric gain
% gain
% loss
% PTval
% respnum
% respcat: 1=accept, 0=reject
% response_time: RT

[run1_a, header_run1_a, ] = tsvread( fullfile(data_path, [ID, '_accept_run-001.tsv']));
[run1_r, header_run1_r, ] = tsvread( fullfile(data_path, [ID, '_reject_run-001.tsv']));
[run2_a, header_run2_a, ] = tsvread( fullfile(data_path, [ID, '_accept_run-002.tsv']));
[run2_r, header_run2_r, ] = tsvread( fullfile(data_path, [ID, '_reject_run-002.tsv']));
[run3_a, header_run3_a, ] = tsvread( fullfile(data_path, [ID, '_accept_run-003.tsv']));
[run3_r, header_run3_r, ] = tsvread( fullfile(data_path, [ID, '_reject_run-003.tsv']));
%load( fullfile(reg_path, [ID '_IQ_run1.mat'] ) )
%load( fullfile(reg_path, [ID '_IQ_run2.mat'] ) )

disp('Runs 1-3 values loaded')


%% Initialise SPM defaults
spm('defaults', 'FMRI');
spm_jobman('initcfg'); % SPM8 only

%%
%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------

% create a directory where data will be saved
mkdir( fullfile( def_path, currApproach) )

% delete SPM.mat file if it exists already
if exist( fullfile( def_path, currApproach, 'SPM.mat') )
    fprintf('\n SPM.mat exists in this directory. Overwriting SPM.mat file! \n\n')
    delete( fullfile( def_path, currApproach, 'SPM.mat') )
end


%% smooth files first...

% run1
matlabbatch = [];  % clear matlabbatch..
epipath = fullfile(def_path, 'func');  % location of the preprocessed files
tmpFiles = dir(fullfile(epipath, 'sub-*run-01*preproc.nii'));   % find the file
% Here lines differ for 3D vs. 4D %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is for 4D multiple files
% get herder information to read a 4D file
tmpHdr = spm_vol( fullfile(epipath, tmpFiles.name) );
f_list_length = size(tmpHdr, 1);  % number of 3d volumes
for jx = 1:f_list_length
    scanFiles{jx,1} = [epipath '/' tmpFiles.name ',' num2str(jx) ] ; % add numbers in the end
    % End of difference for 3D vs. 4D %%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
matlabbatch{1}.spm.spatial.smooth.data = scanFiles;
matlabbatch{1}.spm.spatial.smooth.fwhm = smoothing;
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';
spm_jobman('run', matlabbatch) 
disp('run 1 smoothing is complete')

% run2
matlabbatch = [];  % clear matlabbatch..
epipath = fullfile(def_path, 'func');  % location of the preprocessed files
tmpFiles = dir(fullfile(epipath, 'sub-*run-02*preproc.nii'));   % find the file
% Here lines differ for 3D vs. 4D %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is for 4D multiple files
% get herder information to read a 4D file
tmpHdr = spm_vol( fullfile(epipath, tmpFiles.name) );
f_list_length = size(tmpHdr, 1);  % number of 3d volumes
for jx = 1:f_list_length
    scanFiles{jx,1} = [epipath '/' tmpFiles.name ',' num2str(jx) ] ; % add numbers in the end
    % End of difference for 3D vs. 4D %%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
matlabbatch{1}.spm.spatial.smooth.data = scanFiles;
matlabbatch{1}.spm.spatial.smooth.fwhm = smoothing;
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';
spm_jobman('run', matlabbatch) 
disp('run 2 smoothing is complete')

% run3
matlabbatch = [];  % clear matlabbatch..
epipath = fullfile(def_path, 'func');  % location of the preprocessed files
tmpFiles = dir(fullfile(epipath, 'sub-*run-03*preproc.nii'));   % find the file
% Here lines differ for 3D vs. 4D %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is for 4D multiple files
% get herder information to read a 4D file
tmpHdr = spm_vol( fullfile(epipath, tmpFiles.name) );
f_list_length = size(tmpHdr, 1);  % number of 3d volumes
for jx = 1:f_list_length
    scanFiles{jx,1} = [epipath '/' tmpFiles.name ',' num2str(jx) ] ; % add numbers in the end
    % End of difference for 3D vs. 4D %%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
matlabbatch{1}.spm.spatial.smooth.data = scanFiles;
matlabbatch{1}.spm.spatial.smooth.fwhm = smoothing;
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';
spm_jobman('run', matlabbatch) 
disp('run 3 smoothing is complete')

matlabbatch = [];  % clear matlabbatch..

%% run 1

matlabbatch{1}.spm.stats.fmri_spec.dir = { fullfile( def_path, currApproach) };
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

% rescan files
tmpFiles = dir(fullfile(epipath, 'ssub*run-01*preproc.nii'));   % find the file
% Here lines differ for 3D vs. 4D %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is for 4D multiple files
% get herder information to read a 4D file
tmpHdr = spm_vol( fullfile(epipath, tmpFiles.name) );
f_list_length = size(tmpHdr, 1);  % number of 3d volumes
for jx = 1:f_list_length
    scanFiles{jx,1} = [epipath '/' tmpFiles.name ',' num2str(jx) ] ; % add numbers in the end
    % End of difference for 3D vs. 4D %%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = scanFiles;
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).name = 'accept';
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).onset =  run1_a(2:end, 13);

%%% parametric modulators
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).duration = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).tmod = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).name = 'reject';
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).onset =  run1_r(2:end, 13);

%%% parametric modulators
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).duration = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).tmod = 0;


% Remaining details...
%matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).orth = 0;
%matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).orth = 0;% don't orthogonalize PM regressors
matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = {move_path_run1};
matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = 128;

%% run 2

epipath = fullfile(def_path, 'func');  % location of the preprocessed files
tmpFiles = dir(fullfile(epipath, 'ssub*run-02*preproc.nii'));   % find the file
% Here lines differ for 3D vs. 4D %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is for 4D multiple files
% get herder information to read a 4D file
tmpHdr = spm_vol( fullfile(epipath, tmpFiles.name) );
f_list_length = size(tmpHdr, 1);  % number of 3d volumes
for jx = 1:f_list_length
    scanFiles{jx,1} = [epipath '/' tmpFiles.name ',' num2str(jx) ] ; % add numbers in the end
    % End of difference for 3D vs. 4D %%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

matlabbatch{1}.spm.stats.fmri_spec.sess(2).scans = scanFiles;
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).name = 'accept';
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).onset =  run2_a(2:end, 13);

%%% parametric modulators
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).duration = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).tmod = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).name = 'reject';
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).onset =  run2_r(2:end, 13);

%%% parametric modulators
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).duration = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).tmod = 0;


% Remaining details...
%matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).orth = 0;   % don't orthogonalize PM regressors
%matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(2).orth = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess(2).regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi_reg = {move_path_run1};
matlabbatch{1}.spm.stats.fmri_spec.sess(2).hpf = 128;


%% run 3

epipath = fullfile(def_path, 'func');  % location of the preprocessed files
tmpFiles = dir(fullfile(epipath, 'ssub*run-03*preproc.nii'));   % find the file
% Here lines differ for 3D vs. 4D %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is for 4D multiple files
% get herder information to read a 4D file
tmpHdr = spm_vol( fullfile(epipath, tmpFiles.name) );
f_list_length = size(tmpHdr, 1);  % number of 3d volumes
for jx = 1:f_list_length
    scanFiles{jx,1} = [epipath '/' tmpFiles.name ',' num2str(jx) ] ; % add numbers in the end
    % End of difference for 3D vs. 4D %%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

matlabbatch{1}.spm.stats.fmri_spec.sess(3).scans = scanFiles;
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(1).name = 'accept';
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(1).onset =  run3_a(2:end, 13);

%%% parametric modulators
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(1).duration = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(1).tmod = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(2).name = 'reject';
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(2).onset =  run3_r(2:end, 1);

%%% parametric modulators
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(2).duration = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(2).tmod = 0;


% Remaining details...
%matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(1).orth = 0;   % don't orthogonalize PM regressors
%matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond(2).orth = 0;  
matlabbatch{1}.spm.stats.fmri_spec.sess(3).multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess(3).regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess(3).multi_reg = {move_path_run1};
matlabbatch{1}.spm.stats.fmri_spec.sess(3).hpf = 128;


%% These are for all 3 runs

matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.2;   % threshold
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

%% run categorical model specification
spm_jobman('run', matlabbatch) 
disp('categorical model is specified')

%% categorical model estimation
matlabbatch = [];
matlabbatch{1}.spm.stats.fmri_est.spmmat = { fullfile(def_path, currApproach, 'SPM.mat') };
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
spm_jobman('run', matlabbatch) 
disp('categorical model is estimated')

%% create contrasts 
% parametric modulation of gain & loss
% DON'T FORGET MOVEMENT REGRESSORS!! 

matlabbatch = [];
matlabbatch{1}.spm.stats.con.spmmat = { fullfile(def_path, currApproach, 'SPM.mat') };

matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'accept-reject_PM';  % 
matlabbatch{1}.spm.stats.con.consess{1}.tcon.convec = [1/3 -1/3  0 0 0 0 0 0  1/3 -1/3  0 0 0 0 0 0  1/3 -1/3 ];
matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.delete = 0;

spm_jobman('run', matlabbatch) 
disp([currApproach ' model: contrasts are generated'])

end

