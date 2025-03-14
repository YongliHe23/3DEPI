function pickNumFrame(I)
% determine how many frames would be sufficient for tsnr estimation

nmin=20; %minimal # of frames
nstep=10;

[nx,ny,nz,nfr]=size(I);
avg_t=zeros(1,floor((nfr-nmin)/10)+1);
var_t=zeros(1,floor((nfr-nmin)/10)+1);

for i=nmin:nstep:nfr
    i
    tsnr=mean(I(:,:,:,1:i))./std(I(:,:,:,1:i),0,4);
    avg=mean(tsnr(nx/2-10:nx/2+10,ny/2-10:ny/2+10,nz/2-3:nz/2+3),'all');
    var=std(tsnr(nx/2-10:nx/2+10,ny/2-10:ny/2+10,nz/2-3:nz/2+3),0,'all');

    avg_t(floor((i-nmin)/10)+1)=abs(avg);
    var_t(floor((i-nmin)/10)+1)=abs(var);

end

figure;
plot(avg_t);
xlabel('# of frames')
ylabel('Average of estimated tSNR in IV')

figure;
plot(var_t);
xlabel('# of frames')
ylabel('Std of estimated tSNR in IV')
end