function d=fillCaipi(dfr,Caipi_fn)
% Fill in caipi sampling locations d(mask) with acquired k-space data dfr
% In:
% dfr: (nx,etl,np,nc)
% Caipi_fn: .mat that has caipi  sampling mask
% Out:
% d: (nx,ny,nz,nc)


[ny,nz]=deal(90,60);
[nx,etl,np,nc]=size(dfr); %np=10, nc=32
mb=nz/np;

%load caipi sampling mask
load(Caipi_fn,'mask');
maskyz = mask;
maskyz(1:end-etl,:) = false;
mask = false(nx, ny, mb);
mask(:, maskyz(:,1:mb)) = true;

d=zeros(nx,ny,nz,32);
% Prepare the data for partition i.
% With no CAIPI sampling scheme, all the k-space data for a partition lies
% in a single kz plane. However, with CAIPI sampling, each ky line
% actually comes from a different kz plane. To account for this,
% first we replicate the k-space data, ending up with mb identical
% kz planes. Then we use the sampling mask to keep only the k-space
% samples that were actually acquired in each kz plane.
for i=0:np-1
    for c = 1:nc
        d(:,(end-etl+1):end,1+i*mb:mb+i*mb,c) = repmat(dfr(:,:,i+1,c), 1, 1, mb);
    end
    for c=1:nc
        d(:,:,1+i*mb:mb+i*mb,c)=d(:,:,1+i*mb:mb+i*mb,c).*mask;
    end
end

end