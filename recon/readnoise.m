datafile_noise='/mnt/storage/yonglihe/transfer/20250127/ylhe_e06573_s00011_18944/P18944.7';
D=readraw(datafile_noise,scanner);
%D=reshape(D,[],nc);
fn = [save_root 'noise.h5'];   % used by recon_timeseries.m as well
np = 10;
hmriutils.epi.io.draw2hdf(D, etl, np, fn, 'maxFramesPerFile', 50);


%%
mb=6;
clear draw dfr
fn=[save_root 'noise.h5'];
draw = hmriutils.epi.io.readframe(fn, 1);
dfr = hmriutils.epi.rampsampepi2cart(draw, kxo, kxe, nx, fov(1)*100, 'nufft'); 
dfr = hmriutils.epi.epiphasecorrect(dfr, a);    %  [nx etl np nc]
% caipi_path='/home/yonglihe/Documents/MATLAB/gre3d_IVsat/paper-ovs-compare/EPI/SSAD/mb6_beta/caipi.mat';
% d_noise=fillCaipi(dfr,caipi_path);
% I_noise=zeros(nx,ny,nz);
% I_noise=bart('pics -l1 -r0.001',d_noise,smap);


%% mean and variance
D=reshape(dfr,[],nc);
mu_noise=mean(D,1);
cov_noise=((D-mu_noise)'*(D-mu_noise))/(size(D,1)-1);
% mu_noise=mean(real(D),1)+1i*mean(imag(D),1); %mean of the noise; two ch's: real and imag
% cov_noise=cov(real(D))+1i*cov(imag(D)); %covariance matrix; complex
