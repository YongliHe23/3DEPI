fn = [save_root '3depi_mb1off.h5'];

ndummyshot=12;
nframe=2*25;
I_mb1off_rest=zeros(nx,ny,nz,nframe-ndummyshot);
d_mb1off_rest=zeros(nx,ny,nz,nc,nframe-ndummyshot);
for ifr=1:nframe-ndummyshot
    ifr
    draw = hmriutils.epi.io.readframe(fn, ifr+ndummyshot);
    dfr = hmriutils.epi.rampsampepi2cart(draw, kxo, kxe, nx, fov(1)*100, 'nufft'); 
    dfr = hmriutils.epi.epiphasecorrect(dfr, a);    %  [nx etl np nc]
    d_mb1off_rest(:,end-etl+1:end,:,:,ifr)=dfr;
    I_tmp=zeros(nx,ny,nz);
    I_tmp=bart('pics -l1 -r0.001',d_mb1off_rest(:,:,:,:,ifr),smap);
    % 
    I_mb1off_rest(:,:,:,ifr)=I_tmp;
end

%%
fn = [save_root '3depi_SSmb1on.h5'];
I_SSmb1_rest=zeros(nx,ny,nz,nframe-ndummyshot);
d_SSmb1_rest=zeros(nx,ny,nz,nc,nframe-ndummyshot);
for ifr=1:nframe-ndummyshot
    ifr
    draw = hmriutils.epi.io.readframe(fn, ifr+ndummyshot);
    dfr = hmriutils.epi.rampsampepi2cart(draw, kxo, kxe, nx, fov(1)*100, 'nufft'); 
    dfr = hmriutils.epi.epiphasecorrect(dfr, a);    %  [nx etl np nc]
    d_SSmb1_rest(:,end-etl+1:end,:,:,ifr)=dfr;
    I_tmp=zeros(nx,ny,nz);
    I_tmp=bart('pics -l1 -r0.001',d_SSmb1_rest(:,:,:,:,ifr),smap);
    % 
    I_SSmb1_rest(:,:,:,ifr)=I_tmp;
end

%% IFT
ndummyshot=2;
I_mb1off_ift=zeros(nx,ny,nz,nframe-ndummyshot);
I_SSmb1_ift=zeros(nx,ny,nz,nframe-ndummyshot);
for ifr=1:nframe-ndummyshot
    ifr
    [~,I_tmp1]=toppe.utils.ift3(d_mb1off_rest(:,:,:,:,ifr));
    [~,I_tmp2]=toppe.utils.ift3(d_SSmb1_rest(:,:,:,:,ifr));
    I_mb1off_ift(:,:,:,ifr)=I_tmp1;
    I_SSmb1_ift(:,:,:,ifr)=I_tmp2;
end