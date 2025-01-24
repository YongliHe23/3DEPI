if ~exist('cal','dir')
    mkdir('cal');
end
% if ~exist('noise','dir')
%     mkdir('noise');
% end
if ~exist('mb1_beta','dir')
    mkdir('mb1_beta');
end
if ~exist('mb6_beta','dir')
    mkdir('mb6_beta');
end
% if ~exist('b0','dir')
%     mkdir('b0');
% end

copyfile cal.tar ./cal/
cd cal/
system('tar xf cal.tar')
cd ../

% copyfile noise.tar ./noise/
% cd noise/
% system('tar xf noise.tar')
% cd ../

copyfile 3dmb1_beta.tar ./mb1_beta/
cd mb1_beta/
system('tar xf *.tar')
cd ../

copyfile 3dmb6_beta.tar ./mb6_beta/
cd mb6_beta/
system('tar xf *.tar')
cd ../

% copyfile b0.tar ./b0/
% cd b0/
% system('tar xf *.tar')
% cd ../
