
% SMS-EPI acquisition parameters
% The number of temporal frames is not set here; 
% it is determined by the 'runs' parameter on the console
voxelSize = [2.4 2.4 2.4]*1e-3;   % m
nx = 90; ny = 90; nz = 60;        % matrix size
TE = 30e-3;                       % sec
alpha = 20;                       % flip angle (deg)
mb = 6;                           % multiband/SMS factor
pf_ky = 1;%72/90;                    % partial Fourier factor
TR = 0.8;                       % volume TR (sec)

etl = round(ny*pf_ky);
fov = voxelSize.*[nx ny nz];
np = nz/mb;  % number of partitions (SMS slice groups, or RF shots per temporal frame)
assert(~mod(np,1), 'nz must be a multiple of mb');

% odd/even echo k-space sampling locations (ramp sampling)
[rf,gx,gy,gz,desc,paramsint16,paramsfloat,hdr] = toppe.readmod(readout_trajectory_file);
nFID = hdr.rfres;   % number of data samples in ADC window
sysGE = toppe.systemspecs();
[kxo, kxe] = toppe.utils.getk(sysGE, readout_trajectory_file, nFID, kspace_delay);

