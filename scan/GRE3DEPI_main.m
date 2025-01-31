% create SMS EPI sequence files, in the following order:
% 1. mb=6 sequence. Defines readout and adc events
% 2. calibration scan (blips off, for receive gain calibration and EPI ghost correction)
% 3. mb=1 2D
% 4. mb=1 2D SE blip up/down
% 5. EPI noise scan (no rf, except one at end to make seq2ge() happy)
% 6. 3D GRE B0 mapping
% 7. 3D EPI mb=6
% 8. 3D EPI mb=1

TODO = [1 1 0 0 0 0 1 1];

scanner = 'GE';
fatSat = true;
RFspoil = true;

% acquisition parameters
voxelSize = [2.4 2.4 2.4]*1e-3;   % m
%voxelSize= [2.4 1.2 1.2]*1e-3;
nx = 90; ny = nx; nz = 60;

alpha = 20;%52;
pf_ky = 1; %(nx-3*6)/nx;

TR = 0.8;                      % volume TR (sec)
%TR=0.82;                        %for high res/small FOV

if strcmp(scanner, 'GE')
    % Settings for GE scanners at U-Mich
    toGE = true;
    gySign = 1;
    freqSign = 1;
    fatFreqSign = -1;
    doConj = false;
    TE = 30e-3;                       % sec
    %TE=31e-3; %for high res/small FOV
else
    % Settings for Siemens Vida bay MR7 @ U-Mich University Hospital
    toGE = false;
    gySign = 1;
    freqSign = -1;
    fatFreqSign = -1;  % ?
    doConj = false;
    TE = 31e-3;                       % sec
end

sysGE = toppe.systemspecs();  % for plotting
%addpath ~/github/HarmonizedMRI/SMS-EPI/sequence/Pulseq/   % getsmspulse.m, rf2pulseq.m

% mb=6 sequence. Defines readout and adc events
% Design sub-sequence containing 40 shots = 4 frames 
% We choose 4 shots since RF spoiling phase (for rf_inc = 117) repeats every 80 RF shots
% (fat sat also spoils so only need 40 TRs not 80)
% RF spoiling anyhow probably isn't doing much since TR=0.8s
mb = 6; Ry = 1; Rz = mb; caipiShiftZ = 2;
nDummyFrames = 0;
nFrames = 4;
%ovs_path='/home/yonglihe/Documents/MATLAB/gre3d_IVsat/paper-ovs-compare/naive-AutoDiffPulses-pAD-seq.mat';
ovs_path='/home/yonglihe/Documents/MATLAB/gre3d_IVsat/paper-ivs-compare/IVS-naive-pAD-sphere_seq.mat';
if TODO(1)
    [gro, adc] = writeEPI(voxelSize, [nx ny nz], TE, TR, alpha, mb, pf_ky, Ry, Rz, caipiShiftZ, nFrames, nDummyFrames, '3D', ...
        'seqName', 'mb6_beta', ...
        'fatSat', fatSat, ...
        'RFspoil', RFspoil, ...
        'toGE', toGE, ...
        'gySign', gySign, ...
        'freqSign', freqSign, ...
        'fatFreqSign', fatFreqSign, ...
        'doConj', doConj, ...
        'doRefScan', false, ...
        'simulateSliceProfile', true, ...
        'ovs',true,'ovs_path',ovs_path);
    dur = 5*40 + 10;    % scan duration, sec
    dur = 5*60 + 10;    % scan duration, sec
    nRuns = dur/(nFrames*TR);     % CV8/opuser8 on UI
end

% For prescan (Rx gain) and EPI ghost calibration
% (reuse mb, Ry, etc from above)
nDummyFrames = 6;   % to allow signal to get close to steady state before using for Rx gain calibration
nFrames = 2;        % 1st frame is ghost calibration (y blips off)
if TODO(2)
    writeEPI(voxelSize, [nx ny nz], TE, TR, alpha, mb, pf_ky, Ry, Rz, caipiShiftZ, nFrames, nDummyFrames, '3D', ...
        'seqName', 'cal', ...
        'fatSat', fatSat, ...
        'RFspoil', RFspoil, ...
        'toGE', toGE, ...
        'gySign', gySign, ...
        'freqSign', freqSign, ...
        'fatFreqSign', fatFreqSign, ...
        'doConj', doConj, ...
        'doRefScan', true, ...  % if true, 1st frame is ghost calibration (blips off)
        'gro', gro, 'adc', adc);
end

% 2D mb=1 sequence for reference (slice GRAPPA ACS)
mb = 1; Ry = 1; Rz = mb; caipiShiftZ = 0;
nDummyFrames = 0;
nFrames = 1; 
if TODO(3)
    writeEPI(voxelSize, [nx ny nz], TE, 2*6*TR, alpha, mb, pf_ky, Ry, Rz, caipiShiftZ, nFrames, nDummyFrames, 'SMS', ...
        'seqName', '2d', ...
        'fatSat', fatSat, ...
        'RFspoil', RFspoil, ...
        'toGE', toGE, ...
        'gySign', gySign, ...
        'freqSign', freqSign, ...
        'fatFreqSign', fatFreqSign, ...
        'doConj', doConj, ...
        'doRefScan', false, ...
        'simulateSliceProfile', true, ...
        'gro', gro, 'adc', adc);
end

% 2D mb=1 blip up/down spin-echo sequence for B0 correction
mb = 1; Ry = 1; Rz = mb; caipiShiftZ = 0;
nDummyFrames = 0;
nFrames = 2; 
if TODO(4)
    writeEPI(voxelSize, [nx ny nz], TE, 2*6*TR, 90, mb, pf_ky, Ry, Rz, caipiShiftZ, nFrames, nDummyFrames, 'SE', ...
        'seqName', '2dse', ...
        'fatSat', false, ...
        'RFspoil', false, ...
        'toGE', toGE, ...
        'gySign', gySign, ...
        'freqSign', freqSign, ...
        'fatFreqSign', fatFreqSign, ...
        'doConj', doConj, ...
        'doRefScan', false, ...
        'simulateSliceProfile', true, ...
        'gro', gro, 'adc', adc);
end

% noise scan
mb = 6; Ry = 1; Rz = mb; caipiShiftZ = 2;
nDummyFrames = 0;
nFrames = 1; 
if TODO(5)
    writeEPI(voxelSize, [nx ny nz], TE, TR, alpha, mb, pf_ky, Ry, Rz, caipiShiftZ, nFrames, nDummyFrames, 'SMS', ...
        'seqName', 'noise', ...
        'fatSat', false, ...
        'RFspoil', RFspoil, ...
        'toGE', toGE, ...
        'gySign', gySign, ...
        'freqSign', freqSign, ...
        'fatFreqSign', fatFreqSign, ...
        'doConj', doConj, ...
        'doRefScan', false, ...
        'doNoiseScan', true, ...
        'gro', gro, 'adc', adc);
end



%% 3D EPI
mb = 6; Ry = 1; Rz = mb; caipiShiftZ = 2;
nDummyFrames = 12;
nFrames = 4;
alpha = 20;
nx = 90; ny = nx; nz = 60;
if TODO(7)
     writeEPI(voxelSize, [nx ny nz], TE, TR, alpha, mb, pf_ky, Ry, Rz, caipiShiftZ, nFrames, nDummyFrames, '3D', ...
        'seqName', sprintf('3dmb%d_beta', mb), ...
        'fatSat', fatSat, ...
        'RFspoil', RFspoil, ...
        'toGE', toGE, ...
        'gySign', gySign, ...
        'freqSign', freqSign, ...
        'fatFreqSign', fatFreqSign, ...
        'doConj', doConj, ...
        'doRefScan', false, ...
        'simulateSliceProfile', true, ...
        'gro', gro, 'adc', adc, ...
        'ovs', true, 'ovs_path',ovs_path);
    dur = 5*60 + 10;    % scan duration, sec
    nRuns = dur/(nFrames*TR);     % CV8/opuser8 on UI
end
%%
% 3D EPI fully sampled reference
mb = 1; Ry = 1; Rz = mb; caipiShiftZ = 0;
nDummyFrames = 0;
nFrames = 2;
pf_ky=1.0;
if TODO(8)
     writeEPI(voxelSize, [nx ny nz], TE, 6*TR, alpha, mb, pf_ky, Ry, Rz, caipiShiftZ, nFrames, nDummyFrames, '3D', ...
        'seqName', sprintf('3dmb%d_beta', mb), ...
        'fatSat', fatSat, ...
        'RFspoil', RFspoil, ...
        'toGE', toGE, ...
        'gySign', gySign, ...
        'freqSign', freqSign, ...
        'fatFreqSign', fatFreqSign, ...
        'doConj', doConj, ...
        'doRefScan', false, ...
        'simulateSliceProfile', true, ...
        'gro', gro, 'adc', adc, ...
        'ovs', true, 'ovs_path',ovs_path);
    dur = 5*60 + 10;    % scan duration, sec
    nRuns = dur/(nFrames*TR);     % CV8/opuser8 on UI
end

% 3D GRE for B0 and sensitivity maps
if TODO(6)
    writeB0;
end
%ofn = sprintf('scans.tar');
%system(sprintf('rm %s', ofn));
%system(sprintf('tar cf %s *.seq *.tar', ofn));

