% This script is for GE data

%% Edit this section

scanner = 'GE';  % 'GE' or 'Siemens' (for now!)

% odd/even k-space delay (samples) to avoid phase wrap in fit
kspace_delay =-1.5;  

% echo readout gradient waveform file
%readout_trajectory_file = '/export/jfnielse/github/scanLog/HarmonizedMRI/fMRI/readout_Jan2024.mod';
readout_trajectory_file ='/home/yonglihe/Documents/MATLAB/gre3d_IVsat/paper-ivs-compare/SSAD/cal/module10.mod';

dataDir = '/mnt/storage/yonglihe/transfer/20250311/Exam6811/';

% data file names
datafile_ghostcal = [dataDir 'Series3/ScanArchive_7347633TMRFIX_20250311_145827443.h5'];%'Series17/ScanArchive_7347633TMRFIX_20250311_155035425.h5'];
datafile_SSmb1on = [dataDir 'Series18/ScanArchive_7347633TMRFIX_20250311_155129739.h5'];
datafile_mb1off=[dataDir 'Series19/ScanArchive_7347633TMRFIX_20250311_155217968.h5'];
datafile_SSmb6on=[dataDir 'Series21/ScanArchive_7347633TMRFIX_20250311_155354280.h5'];
datafile_mb6off=[dataDir 'Series22/ScanArchive_7347633TMRFIX_20250311_155807647.h5'];
datafile_naive_mb1on=[dataDir 'Series20/ScanArchive_7347633TMRFIX_20250311_155252612.h5'];
datafile_naive_mb6on=[dataDir 'Series23/ScanArchive_7347633TMRFIX_20250311_160222010.h5'];
%datafile_noise=[dataDir ];

datafile_b0 = [dataDir 'Series16/ScanArchive_7347633TMRFIX_20250311_154742368.h5'];
b0.deltaTE = 1000/440*1e-3;   % sec
b0.N = [100 100 100];         % matrix size
b0.fov = [24 24 24]*1e-2;     % m
b0.nzDummy = 1;               % dummy z loops (for setting receive gain on GE)

set_common_parameters;   % in ../recon/

return


% data root directory for all sessions
datrootdir = '/mnt/storage/jfnielse/HarmonizedMRI/fMRI/';
datrootdir = '';

% Pulseq scans series numbers
IDb0 = 1; IDcal = 2; IDnoise = 3; ID2d = 4; IDrest = 5; IDtask1 = 6;
S(IDb0)    = 5;   % b0
S(IDcal)   = 6;   % EPI ghost cal (and Rx calibration for GE)
S(IDnoise) = 7;   % noise
S(ID2d)    = 8;   % 2d calibration scan for slice GRAPPA
S(IDrest)  = 9;   % resting run
S(IDtask1:IDtask1+3) = [12 15 18 21];   % task runs

% b0 mapping
b0.deltaTE = 1000/440*1e-3;   % sec
b0.N = [100 100 100];         % matrix size
b0.fov = [24 24 24]*1e-2;     % m
b0.nzDummy = 1;               % dummy z loops (for setting receive gain on GE)


%% No need to edit below this line

% session name and exam number
curdir = pwd;
pathparts = strsplit(curdir, '/');
session_name = pathparts{end};
snp = strsplit(session_name, '_');
examnum = snp{end};

% data directory. Note trailing slash.
datadir = [datrootdir session_name '/Exam' examnum '/'];

curdir = pwd;

% b0 mapping (3D GRE)
pth = [datadir 'Series' num2str(S(IDb0)) '/'];
D = dir(pth);
datafile_b0= [pth D(end).name];

% EPI ghost calibration scan (and GE receive gain)
pth = [datadir 'Series' num2str(S(IDcal)) '/'];
D = dir(pth);
datafile_ghostcal = [pth D(end).name];

% 2D EPI reference scan for slice GRAPPA recon
pth = [datadir 'Series' num2str(S(ID2d)) '/'];
D = dir(pth);
datafile_mb1 = [pth D(end).name];

% resting fMRI run
pth = [datadir 'Series' num2str(S(IDrest)) '/'];
D = dir(pth);
datafile_rest = [pth D(end).name];

% task run(s)
clear datafile_task
nTaskRuns = length(S(IDtask1:end));
for ii = 1:nTaskRuns
    pth = [datadir 'Series' num2str(S(IDtask1+ii-1)) '/'];
    D = dir(pth);
    datafile_task{ii} = [pth D(end).name];
end

% set common parameters
set_common_parameters;   % in ../recon/

