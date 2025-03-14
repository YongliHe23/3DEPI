%% ivs off
% get calib
fn=[save_root '3depi_mb1off.h5'];
draw = hmriutils.epi.io.readframe(fn, 4);
dfr = hmriutils.epi.rampsampepi2cart(draw, kxo, kxe, nx, fov(1)*100, 'nufft'); 
dfr = hmriutils.epi.epiphasecorrect(dfr, a);
d_mb1off=zeros(nx,ny,nz,32);
d_mb1off(:,end-etl+1:end,:,:)=dfr;
calib=permute(d_mb1off,[4,1,2,3]);
calib=calib(:,:,31:60,25:36);

%% input
caipi_path='/home/yonglihe/Documents/MATLAB/gre3d_IVsat/paper-ovs-compare/EPI/SSAD/mb6_beta/caipi.mat';
fn = [save_root '3depi_mb6off.h5'];

ndummyshot=12;
nframe=280;
I_mb6off_rest=zeros(nx,ny,nz,nframe-ndummyshot);
%dfr_mb6off_rest=zeros(nx,etl,np,nc,nframe-ndummyshot);
%nsubframe=50;

for ifr=1:nframe-ndummyshot
    fprintf('%d/%d',ifr,nframe-ndummyshot)
    draw = hmriutils.epi.io.readframe(fn, ifr+ndummyshot);
    dfr = hmriutils.epi.rampsampepi2cart(draw, kxo, kxe, nx, fov(1)*100, 'nufft'); 
    dfr = hmriutils.epi.epiphasecorrect(dfr, a);    %  [nx etl np nc]
    %dfr_mb6off_rest(:,:,:,:,ifr)=dfr;

    d_mb6off=fillCaipi(dfr,caipi_path);
    cwd=sprintf(pwd);
    cd /home/yonglihe/Documents/MATLAB/grappa-tools/grappa/
    recon=grappa_caipi(permute(d_mb6off,[4,1,2,3]),calib,[1,3,2],[5,3,2],indices);
    cd(cwd)
    [~,I_mb6off_rest(:,:,:,ifr)]=toppe.utils.ift3(permute(recon,[2,3,4,1]));
end

%% IVS SS
fn=[save_root '3depi_SSmb1on.h5'];
draw = hmriutils.epi.io.readframe(fn, 4);
dfr = hmriutils.epi.rampsampepi2cart(draw, kxo, kxe, nx, fov(1)*100, 'nufft'); 
dfr = hmriutils.epi.epiphasecorrect(dfr, a);
d_SSmb1on=zeros(nx,ny,nz,32);
d_SSmb1on(:,end-etl+1:end,:,:)=dfr;
calib_SS=permute(d_SSmb1on,[4,1,2,3]);
calib_SS=calib_SS(:,:,31:60,25:36);

%%
fn = [save_root '3depi_SSmb6on.h5'];
nframe=280;
I_SSmb6_rest=zeros(nx,ny,nz,nframe-ndummyshot);
%dfr_SSmb6_rest=zeros(nx,etl,np,nc,nframe-ndummyshot);
for ifr=1:nframe-ndummyshot
    fprintf('%d/%d\n',ifr,nframe-ndummyshot)
    draw = hmriutils.epi.io.readframe(fn, ifr+ndummyshot);
    dfr = hmriutils.epi.rampsampepi2cart(draw, kxo, kxe, nx, fov(1)*100, 'nufft'); 
    dfr = hmriutils.epi.epiphasecorrect(dfr, a);    %  [nx etl np nc]
    %dfr_mb6off_rest(:,:,:,:,ifr)=dfr;

    d_SSmb6on=fillCaipi(dfr,caipi_path);
    cwd=sprintf(pwd);
    cd /home/yonglihe/Documents/MATLAB/grappa-tools/grappa/
    recon=grappa_caipi(permute(d_SSmb6on,[4,1,2,3]),calib_SS,[1,3,2],[5,3,2],indices);
    cd(cwd)
    [~,I_SSmb6_rest(:,:,:,ifr)]=toppe.utils.ift3(permute(recon,[2,3,4,1]));
end
%% recon
d_mb6off_rest=zeros(nx,ny,nz,nc,size(dfr_mb6off_rest,5));
%I_mb6off_rest=zeros(nx,ny,nz,size(dfr_mb6off_rest,5));
for ifr=1:size(dfr_mb6off_rest,5)
    ifr
    d_mb6off_rest(:,:,:,:,ifr)=fillCaipi(dfr_mb6off_rest(:,:,:,:,ifr),caipi_path);
    %I_mb6off_rest(:,:,:,ifr)=bart('pics -l1 -r0.001',d_mb6off_rest,smap);
end

d_SSmb6_rest=zeros(nx,ny,nz,nc,size(dfr_mb6off_rest,5));
%I_mb6off_rest=zeros(nx,ny,nz,size(dfr_mb6off_rest,5));
for ifr=1:size(dfr_mb6off_rest,5)
    ifr
    d_SSmb6_rest(:,:,:,:,ifr)=fillCaipi(dfr_SSmb6_rest(:,:,:,:,ifr),caipi_path);
    %I_mb6off_rest(:,:,:,ifr)=bart('pics -l1 -r0.001',d_mb6off_rest,smap);
end


% %% IFT
% ndummyshot=2;
% I_mb1off_ift=zeros(nx,ny,nz,nframe-ndummyshot);
% I_SSmb1_ift=zeros(nx,ny,nz,nframe-ndummyshot);
% for ifr=1:nframe-ndummyshot
%     ifr
%     [~,I_tmp1]=toppe.utils.ift3(d_mb1off_rest(:,:,:,:,ifr));
%     [~,I_tmp2]=toppe.utils.ift3(d_SSmb1_rest(:,:,:,:,ifr));
%     I_mb1off_ift(:,:,:,ifr)=I_tmp1;
%     I_SSmb1_ift(:,:,:,ifr)=I_tmp2;
% end

