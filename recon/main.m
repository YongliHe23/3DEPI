
addpath /home/yonglihe/Documents/MATLAB/gre3d_IVsat/3d-epi/recon

% Get code from Github and local folders
get_code_and_set_paths;

%% set file names and path
set_experimental_parameters_ge;

% remove existing local .h5 and .mat files
% rm ghostcal*.h5 mb1*.h5 rest*.h5 task*.h5 *.mat

% 3D GRE (for sens map)
%get_b0;
nTE = 2;
D = readraw(datafile_b0, scanner);    % D = [100 32 2*100*(100+1)]
nc = size(D,2);
D = reshape(D, b0.N(1), nc, nTE*b0.N(2), b0.N(3)+b0.nzDummy);
D = D(:,:,:,(1+b0.nzDummy):end);
D = permute(D, [1 3 4 2]);

%downsample ndat of D from 248 to 100
% D_=reshape(D,248,[]); 
% D2=[D_(1,:);D_;D_(247:248,:)]; %[250,640000]
% xq=0.5:0.5:250;
% D3=interp1((0:250),D2,xq); %[500,640000]
% D100_=downsample(D3,5); %[100,640000]
% D100=reshape(D100_,[],size(D,2),size(D,3),size(D,4)); %[100,200,100,32]

% reconstruct coil images (complex) and root-sum-of-squares
%[b0.te1.coilims, b0.te1.mag] = toppe.utils.ift3(D(:,1:2:end,:,:));
%[ims.te2] = toppe.utils.ift3(D(:,2:2:end,:,:));

%% getsense
setenv('TOOLBOX_PATH', '/home/jfnielse/Programs/bart-0.7.00'); % getenv doesn't find it
addpath(strcat(getenv('TOOLBOX_PATH'), '/matlab'));

% Magnitude images
D100=D(:,1:2:end,:,:);
[~, spgr] = toppe.utils.ift3(D100);

% Compute sensitivity maps
m = 20;
fprintf('Computing sensitivity maps (this may take a while)\n');
tic; sense = bart(sprintf('ecalib -r %d', m), D100); toc;
smap = bart('slice 4 0', sense); % Equivalently: smap = squeeze(sense(:,:,:,:,1));

% crop
Nsense = size(smap(:,:,:,1));
N=[nx,ny,nz];
Npad = (Nsense - N)/2;
Rx = (Npad(1)+1):(Nsense(1)-Npad(1));
Ry = (Npad(2)+1):(Nsense(2)-Npad(2));
Rz = (Npad(3)+1):(Nsense(3)-Npad(3));
smap = smap(Rx, Ry, Rz, :);
spgr = spgr(Rx, Ry, Rz, :);

% Save result
save_root='/mnt/storage/yonglihe/h5files/20250125/';
if ~isempty('sense.mat')
    save([save_root sprintf('%s_%d.mat', 'sense', m)], 'smap', 'spgr', '-v7.3');
end

%%

% EPI ghost calibration. Saves linear ghost correction parameters in a.mat
% If you observe phase wraps in plots, change 'del' in set_experimental_params.m
D = readraw(datafile_ghostcal, scanner);
hmriutils.epi.io.draw2hdf(D, etl, np, [save_root 'ghostcal.h5']);
get_ghost_calibration_data;  

% Load and reconstruct fMRI resting run
%SS
D = readraw(datafile_SSmb1on, scanner);
fn = [save_root '3depi_SSmb1on.h5'];   % used by recon_timeseries.m as well
np = 60;
etl=90;
hmriutils.epi.io.draw2hdf(D, etl, np, fn, 'maxFramesPerFile', 40);

D = readraw(datafile_mb1off, scanner);
fn = [save_root '3depi_mb1off.h5'];   % used by recon_timeseries.m as well
np = 60;
etl=90;
hmriutils.epi.io.draw2hdf(D, etl, np, fn, 'maxFramesPerFile', 40);

D = readraw(datafile_SSmb6on, scanner);
fn = [save_root '3depi_SSmb6on.h5'];   % used by recon_timeseries.m as well
np = 10;
hmriutils.epi.io.draw2hdf(D, etl, np, fn, 'maxFramesPerFile', 50);

D = readraw(datafile_mb6off, scanner);
fn = [save_root '3depi_mb6off.h5'];   % used by recon_timeseries.m as well
%fn = '3depi_mb12off.h5';
np =10;
hmriutils.epi.io.draw2hdf(D, etl, np, fn, 'maxFramesPerFile', 50);

%naive
D = readraw(datafile_naive_mb1on, scanner);
fn = [save_root '3depi_naive_mb1on.h5'];   % used by recon_timeseries.m as well
np = 60;
etl=90;
hmriutils.epi.io.draw2hdf(D, etl, np, fn, 'maxFramesPerFile', 40);

D = readraw(datafile_naive_mb6on, scanner);
fn = [save_root '3depi_naive_mb6on.h5'];   % used by recon_timeseries.m as well
np = 10;
hmriutils.epi.io.draw2hdf(D, etl, np, fn, 'maxFramesPerFile', 50);

%% SENSE recon
etl=90;
fn = [save_root '3depi_SSmb1on.h5'];
draw = hmriutils.epi.io.readframe(fn, 2);
dfr = hmriutils.epi.rampsampepi2cart(draw, kxo, kxe, nx, fov(1)*100, 'nufft'); 
dfr = hmriutils.epi.epiphasecorrect(dfr, a);    %  [nx etl np nc]
d_SSmb1on=zeros(nx,ny,nz,32);
d_SSmb1on(:,end-etl+1:end,:,:)=dfr;
I_SSmb1on=zeros(nx,ny,nz);
I_SSmb1on=bart('pics -l1 -r0.001',d_SSmb1on,smap);

fn=[save_root '3depi_mb1off.h5'];
draw = hmriutils.epi.io.readframe(fn, 2);
dfr = hmriutils.epi.rampsampepi2cart(draw, kxo, kxe, nx, fov(1)*100, 'nufft'); 
%dfr = hmriutils.epi.epiphasecorrect(dfr, a);    %  [nx etl np nc]
dfr = hmriutils.epi.epiphasecorrect(dfr, a);
d_mb1off=zeros(nx,ny,nz,32);
d_mb1off(:,end-etl+1:end,:,:)=dfr;
I_mb1off=zeros(nx,ny,nz);
I_mb1off=bart('pics -l1 -r0.001',d_mb1off,smap);

%naive
fn = [save_root '3depi_naive_mb1on.h5'];
draw = hmriutils.epi.io.readframe(fn, 2);
dfr = hmriutils.epi.rampsampepi2cart(draw, kxo, kxe, nx, fov(1)*100, 'nufft'); 
dfr = hmriutils.epi.epiphasecorrect(dfr, a);    %  [nx etl np nc]
d_naive_mb1on=zeros(nx,ny,nz,32);
d_naive_mb1on(:,end-etl+1:end,:,:)=dfr;
I_naive_mb1on=zeros(nx,ny,nz);
I_naive_mb1on=bart('pics -l1 -r0.001',d_naive_mb1on,smap);
%% mb6
%SS
mb=6;
clear draw dfr
fn = [save_root '3depi_SSmb6on.h5'];
draw = hmriutils.epi.io.readframe(fn, 1);
dfr = hmriutils.epi.rampsampepi2cart(draw, kxo, kxe, nx, fov(1)*100, 'nufft'); 
dfr = hmriutils.epi.epiphasecorrect(dfr, a);    %  [nx etl np nc]

caipi_path='/home/yonglihe/Documents/MATLAB/gre3d_IVsat/paper-ovs-compare/EPI/SSAD/mb6_beta/caipi.mat';
d_SSmb6on=fillCaipi(dfr,caipi_path);
I_SSmb6on=zeros(nx,ny,nz);
I_SSmb6on=bart('pics -l1 -r0.001',d_SSmb6on,smap);

%beta off
fn = [save_root '3depi_mb6off.h5'];
draw = hmriutils.epi.io.readframe(fn, 1);
dfr = hmriutils.epi.rampsampepi2cart(draw, kxo, kxe, nx, fov(1)*100, 'nufft'); 
dfr = hmriutils.epi.epiphasecorrect(dfr, a);    %  [nx etl np nc]

d_mb6off=fillCaipi(dfr,caipi_path);
I_mb6off=zeros(nx,ny,nz);
I_mb6off=bart('pics -l1 -r0.001',d_mb6off,smap);

%naive
fn = [save_root '3depi_naive_mb6on.h5'];
draw = hmriutils.epi.io.readframe(fn, 1);
dfr = hmriutils.epi.rampsampepi2cart(draw, kxo, kxe, nx, fov(1)*100, 'nufft'); 
dfr = hmriutils.epi.epiphasecorrect(dfr, a);    %  [nx etl np nc]

caipi_path='/home/yonglihe/Documents/MATLAB/gre3d_IVsat/paper-ovs-compare/EPI/SSAD/mb6_beta/caipi.mat';
d_naive_mb6on=fillCaipi(dfr,caipi_path);
I_naive_mb6on=zeros(nx,ny,nz);
I_naive_mb6on=bart('pics -l1 -r0.001',d_naive_mb6on,smap);


%% fMRI recon
ndummyshot=12;
nrun=70;
frame_per_seq=4;
%nframe=frame_per_seq*nrun-ndummyshot;
cycle_time=40;%sec
frame_rate=0.8; %sec
n_cycle=3;
nframe=n_cycle*cycle_time/frame_rate;

fn = '3depi_mb6off.h5';
I_mb6off_fmri=zeros(nx,ny,nz,nframe);
d_mb6off_fmri=zeros(nx,ny,nz,nc,nframe);
for ifr=1:nframe
    ifr
    draw = hmriutils.epi.io.readframe(fn, ifr+ndummyshot);
    dfr = hmriutils.epi.rampsampepi2cart(draw, kxo, kxe, nx, fov(1)*100, 'nufft'); 
    dfr = hmriutils.epi.epiphasecorrect(dfr, a);    %  [nx etl np nc]
    d_mb6off=fillCaipi(dfr,caipi_path);
    d_mb6off_fmri(:,:,:,:,ifr)=d_mb6off;
    % I_mb6off=zeros(nx,ny,nz);
    % I_mb6off=bart('pics -l1 -r0.001',d_mb6off,smap);
    % 
    % I_mb6off_fmri(:,:,:,ifr)=I_mb6off;
end

%beta on
fn = '3depi_mb6.h5';
I_mb6on_fmri=zeros(nx,ny,nz,nframe);
d_mb6on_fmri=zeros(nx,ny,nz,nc,nframe);
for ifr=1:nframe
    ifr
    draw = hmriutils.epi.io.readframe(fn, ifr+ndummyshot);
    dfr = hmriutils.epi.rampsampepi2cart(draw, kxo, kxe, nx, fov(1)*100, 'nufft'); 
    dfr = hmriutils.epi.epiphasecorrect(dfr, a);    %  [nx etl np nc]
    d_mb6on=fillCaipi(dfr,caipi_path);
    d_mb6on_fmri(:,:,:,:,ifr)=d_mb6on;
    % I_mb6on=zeros(nx,ny,nz);
    % I_mb6on=bart('pics -l1 -r0.001',d_mb6on,smap);
    % 
    % I_mb6on_fmri(:,:,:,ifr)=I_mb6on;
end

