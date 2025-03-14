function [g]=gfactor_grappa_caipi(d_fs,d_us,indices,mu,sigma,N)
% use pseudo replica to estimate gfactor with GRAPPA recon
% - Inputs:
%   - d_fs: [nx,etl,nz,nc], complex fully-sampled data
%   - d_us: [nx,etl,nz,nc], complex under-sampled data
%   - indices: [etl 2] ky-kz locations of PE lines within one echo train
%   - mu: [1,nc], complex noise mean 
%   - sigma: [nc,nc], complex noise covariance matrix
%   - N: scalar, number of pseudo replica 

% author: Yongli He 2025 @ Univ. of Michigan
% email: yonglihe@umich.edu

%%
[nx,etl,nz,nc]=size(d_fs);

n=nx*etl*nz; %

ny=etl; %assume ny = etl(echo train length), i.e. partial fourier factor=1
%%
%produce a set of (fully-sampled)recon images
I_fs=zeros(nx,ny,nz,N);
fprintf("start generating %d replica of fully-sampled images...",N);
for i=1:N
    fprintf('\r%d/%d',i,N); %fprintf(%s%s,repmat('\b',size(msg)),msg)
    rng(i)
    noise_=mvnrnd_cmplx(mu,sigma,n);
    noise=reshape(noise_,nx,etl,nz,nc);
    d_fs_noisy=d_fs+noise;
    [~, I_fs(:,:,:,i)]=toppe.utils.ift3(d_fs_noisy);
end
fprintf('\n')

%%
%produce a set of (under-sampled)recon images
I_us=zeros(nx,ny,nz,N);

% undersample mask
load /home/yonglihe/Documents/MATLAB/gre3d_IVsat/paper-ivs-compare/sphereIV/sinc-alpha/SSAD/mb6_beta/caipi.mat mask
mask=repmat(mask,[1,1,nx,nc]);
mask=permute(mask,[3,1,2,4]);
mask_pky=zeros(nx,ny,nz,nc);
mask_pky(:,end-etl+1:end,:,:)=mask(:,end-etl+1:end,:,:);

% ACS data
calib=d_fs_noisy(:,31:60,25:36,:); %[nx,sy,sz,nc], sy=30, sz=12

cd /home/yonglihe/Documents/MATLAB/grappa-tools/grappa/
fprintf("start generating %d replica of under-sampled images...",N);
for i=1:N
    fprintf('\r%d/%d',i,N);
    rng(2*N+i)
    noise_=mvnrnd_cmplx(mu,sigma,n);
    noise=reshape(noise_,nx,etl,nz,nc);
    d_us_noisy=(d_us+noise).*mask_pky;
    d_us_grappa=grappa_caipi(permute(d_us_noisy,[4,1,2,3]),permute(calib,[4,1,2,3]),[1,3,2],[5,3,2],indices); %d_us_grappa=[nc,nx,ny,nz]
    [~,I_us(:,:,:,i)]=toppe.utils.ift3(permute(d_us_grappa,[2,3,4,1]));
end
fprintf('\n')
cd /home/yonglihe/Documents/MATLAB/3DEPI/gfactor_pseudorep/

%% calculate g factor
fprintf('calculating g-factor...');
R=sum(d_fs~=0,'all')./sum(d_us~=0,'all'); %R=6
std_fs=std(I_fs,0,4);
std_us=std(I_us,0,4);

%signal intensity estimation
signal_mask=zeros(nx,ny,nz);
signal_mask(30:60,30:60,20:40)=1;
signal_fs=mean(abs(I_fs(:,:,:,1)).*signal_mask,'all');
signal_us=mean(abs(I_us(:,:,:,1)).*signal_mask,'all');

g=(signal_fs./std_fs)./(signal_us./std_us).*(1/sqrt(R));
g(g==inf)=0;

end

function x = mvnrnd_cmplx(mu, Sigma, N)
    % Convert complex mean and covariance to real form
    mu_tilde = [real(mu), imag(mu)];
    Sigma_tilde = 0.5 * [real(Sigma), imag(Sigma); -imag(Sigma), real(Sigma)];
    
    % Generate real-valued samples
    X_tilde = mvnrnd(mu_tilde, Sigma_tilde, N);
    
    % Reconstruct complex samples
    x = X_tilde(:, 1:end/2) + 1j * X_tilde(:, end/2+1:end);
end
