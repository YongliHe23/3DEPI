%% OVS off
filename=[save_root 'ovsoff-mb6-resting.mat'];
matObj=matfile(filename,'Writable',true);

nframe=size(dfr_mb6off_rest,5);
for i=0:ceil(nframe/nsubframe)-1
    i+1
    matObj.(['dfr_mb6off',num2str(i+1)])=dfr_mb6off_rest(:,:,:,:,1+i*nsubframe:(i+1)*nsubframe);
end

%% OVS on
filename=[save_root 'ovson-mb6-resting.mat'];
matObj=matfile(filename,'Writable',true);

nframe=size(dfr_SSmb6_rest,5);
for i=0:ceil(nframe/nsubframe)-1
    i+1
    matObj.(['dfr_SSmb6',num2str(i+1)])=dfr_SSmb6_rest(:,:,:,:,1+i*nsubframe:(i+1)*nsubframe);
end

%% filled data
filename=[save_root 'd_mb6off_rest.mat'];
matObj=matfile(filename,'Writable',true);

nframe=size(d_mb6off_rest,5);
for i=0:ceil(nframe/nsubframe)-1
    i+1
    matObj.(['d_mb6off',num2str(i+1)])=d_mb6off_rest(:,:,:,:,1+i*nsubframe:(i+1)*nsubframe);
end 

%% IVS on
filename=[save_root 'd_SSmb6_rest.mat'];
matObj=matfile(filename,'Writable',true);

nframe=size(d_SSmb6_rest,5);
for i=0:ceil(nframe/nsubframe)-1
    i+1
    matObj.(['d_SSmb6',num2str(i+1)])=d_SSmb6_rest(:,:,:,:,1+i*nsubframe:(i+1)*nsubframe);
end 