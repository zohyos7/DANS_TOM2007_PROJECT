function [] = FirstLevel_all()

%clear all;clc;

addpath('~/DANS/DR_AHN/fmri_code')
rootDir = '/Users/zohyoonseo/tom-data/fmriprep/';

cd(rootDir);

subjIDs = {'01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16' }; 


numSubjs = length(subjIDs);

%%
Runs = cell(1,1);

for pIdx = 1:1
    Runs{pIdx} = pIdx:1:numSubjs;
end

%%
%for i=4:numSujs
for i = Runs{1}
    tmpID = strcat('sub-', subjIDs{i});
    disp(['SubjID = ', tmpID, ', working!']);
    tmpDir = fullfile(rootDir, tmpID);
    cd(tmpDir)
    tom2007_1stLevel()  
end

cd(rootDir)
disp('DONE with ALL subjects')


end
