% %load noise 
addpath ../recon/
readnoise;

n=nx*etl*nz; %

%load data.mat %d_mb1off d_mb1on d_mb6on d_mb6off
%d_mb1off_=reshape(d_mb1off,[],nc); %(nx*ny*nz,nc)

N=50; %number of pseudo replica

d_mb1off_noise=d_2_noisyd(d_mb1off,mu_noise,cov_noise,N);
d_SSmb1on_noise=d_2_noisyd(d_SSmb1on,mu_noise,cov_noise,N);

%produce a set of (fully-sampled)recon images
I_fs=zeros(nx,ny,nz,N);
I_fs_on=zeros(nx,ny,nz,N);
% for i=1:N
%     i
%     [~,I_fs(:,:,:,i)]=toppe.utils.ift3(d_mb1off_noise(:,:,:,:,i));
%     [~,I_fs_on(:,:,:,i)]=toppe.utils.ift3(d_SSmb1on_noise(:,:,:,:,i));
% end
for i=1:N
    i
    I_fs(:,:,:,i)=bart('pics -l1 -r0.001',d_mb1off_noise(:,:,:,:,i),smap);
    I_fs_on(:,:,:,i)=bart('pics -l1 -r0.001',d_SSmb1on_noise(:,:,:,:,i),smap);
end

%% add noise to the actual acquired undersampled k data
load /home/yonglihe/Documents/MATLAB/gre3d_IVsat/paper-ivs-compare/sphereIV/sinc-alpha/SSAD/mb6_beta/caipi.mat mask

mask=repmat(mask,[1,1,nx,nc]);
mask=permute(mask,[3,1,2,4]);

mask_pky=zeros(nx,ny,nz,nc);
mask_pky(:,end-etl+1:end,:,:)=mask(:,end-etl+1:end,:,:);
d_mb6off_noise=d_2_noisyd(d_mb6off,mu_noise,cov_noise,N);
d_mb6off_noise=d_mb6off_noise.*mask_pky;

d_SSmb6on_noise=d_2_noisyd(d_SSmb6on,mu_noise,cov_noise,N);
d_SSmb6on_noise=d_SSmb6on_noise.*mask_pky;

% a set of mb6 recon images with acquired k undersampling data added
% synthesized noises
    
I_mb6=zeros(nx,ny,nz,N);
I_mb6_on=zeros(nx,ny,nz,N);
parfor i=1:N,8
    i
    I_mb6(:,:,:,i)=bart('pics -l1 -r0.001',d_mb6off_noise(:,:,:,:,i),smap);
    I_mb6_on(:,:,:,i)=bart('pics -l1 -r0.001',d_SSmb6on_noise(:,:,:,:,i),smap);
end

%% normalization
% for i=1:N
%     I_fs(:,:,:,i)=I_fs(:,:,:,i)./(max(abs(I_fs(:,:,:,i)),[],'all'));
%     I_mb6(:,:,:,i)=I_mb6(:,:,:,i)./(max(I_mb6(:,:,:,i),[],'all'));
%     %I_mb6_acq(:,:,:,i)=I_mb6_acq(:,:,:,i)./(max(I_mb6_acq(:,:,:,i),[],'all'));
%     I_fs_on(:,:,:,i)=I_fs_on(:,:,:,i)./(max(abs(I_fs_on(:,:,:,i)),[],'all'));
%     I_mb6_on(:,:,:,i)=I_mb6_on(:,:,:,i)./(max(I_mb6_on(:,:,:,i),[],'all'));
% end

R=6;
std_fs=std(I_fs,0,4);
std_mb6acq=std(I_mb6,0,4);

%signal intensity estimation
signal_mask=zeros(nx,ny,nz);
signal_mask(30:60,30:60,20:40)=1;
signal_fs=mean(abs(I_mb1off).*signal_mask,'all');
signal_mb6=mean(abs(I_mb6off).*signal_mask,'all');

g_off=(signal_fs./std_fs)./(signal_mb6./std_mb6acq).*(1/sqrt(R));
g_off(g_off==inf)=0;

%ivs on
std_fs_on=std(I_fs_on,0,4);
std_mb6_on=std(I_mb6_on,0,4);

signal_mask=zeros(nx,ny,nz);
signal_mask(30:60,15:25,20:40)=1;
signal_fs_on=mean(abs(I_SSmb1on).*signal_mask,'all');
signal_mb6_on=mean(abs(I_SSmb6on).*signal_mask,'all');

g_on=(signal_fs_on./std_fs_on)./(signal_mb6_on./std_mb6_on).*(1/sqrt(R));
g_on(g_on==inf)=0;



