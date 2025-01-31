function d_noise_rep=d_2_noisyd(d,mu_noise,cov_noise,N)
%create N replica of synthesized noisy k-space from "clean" data d
% Inputs:
% -d: (nx,etl,nz,nc) "clean" k-space
% -mu_noise: (1,nc) mean of noise
% -cov_noise: (nc,nc) covariance of noise
% -N: number of replica
[nx,etl,nz,nc]=size(d);
n=nx*etl*nz;
ny=etl;
d_noise_rep=zeros(nx,ny,nz,nc,N);
for i=1:N
    rng(i);
    noise_r_=mvnrnd(real(mu_noise),real(cov_noise),n); %(N,nc) real part
    rng(2*i);
    noise_i_=mvnrnd(imag(mu_noise),imag(cov_noise),n); %imaginary part
    noise_=noise_r_+1i*noise_i_;
    noise=zeros(nx,ny,nz,nc);
    noise(:,end-etl+1:end,:,:)=reshape(noise_,nx,etl,nz,nc);
    d_noise_rep(:,:,:,:,i)=d+noise;

end