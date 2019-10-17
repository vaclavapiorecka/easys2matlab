% This set of functions was created based on the reference manual to the
% EASYS2 file format: EASYS2 Reference Manual. 3rd edition. Praha: Neuroscience Technology Research, 2002.
%
% AUTHOR:   Vaclava Piorecka
% CONTACT:  vaclava.piorecka@fbmi.cvut.cz, vaclava.piorecka@nudz.cz
% DATE:     2018/08/28

clc; clear; close all;

[fileNames,pathName] = uigetfile({'*.d','EASYS2 (*.d)'; ...
                '*.*',  'All Files (*.*)'}, ...
                'Select a File',...
                'MultiSelect', 'on');

numOfFiles = size(fileNames,2);

fwait = waitbar(0,'Please wait...');

for nof = 1 : 1 : numOfFiles
    fullPath = fullfile(pathName,fileNames{1,nof});
    
    standardHeader  = readSHeaderEASYS2(fullPath);                  % Get stnadard header
    extendedHeader  = readXHeaderEASYS2(fullPath,standardHeader );  % Get extended header
    
    % Get data
    dataCalib       = readDataEASYS2(fullPath, standardHeader, extendedHeader);
    
    % Conversion of the data structure to the EEGLAB / FieldTrip.
    dataEEGLAB      = easys2eeglab( fullPath, standardHeader, extendedHeader, dataCalib );
    dataFieldtrip   = easys2fieldtrip( fullPath, standardHeader, extendedHeader, dataCalib );
    
    save([pathName,fileNames{1,nof}(1:end-2),'.mat'],'dataFieldtrip','-v7.3');
    waitbar(nof / numOfFiles)
end