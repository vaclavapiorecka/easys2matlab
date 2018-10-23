% This set of functions was created based on the reference manual to the
% EASYS2 file format: EASYS2 Reference Manual. 3rd edition. Praha: Neuroscience Technology Research, 2002.
%
% AUTHOR:   Vaclava Piorecka
% CONTACT:  vaclava.piorecka@fbmi.cvut.cz, vaclava.piorecka@nudz.cz
% DATE:     2018/08/28

clc; clear; close all;

fullPath = 'C:/my_folder/my_file.d';

standardHeader  = readSHeaderEASYS2(fullPath);                  % Get stnadard header
extendedHeader  = readXHeaderEASYS2(fullPath,standardHeader );  % Get extended header

% Get data
dataCalib       = readDataEASYS2(fullPath, standardHeader, extendedHeader);
% Another way to get data - get concrete samples.
% dataCalib       = readDataEASYS2(fullPath, standardHeader, extendedHeader,1:1:standardHeader.nchan,1,10000);

% Conversion of the data structure to the EEGLAB / FieldTrip.
dataEEGLAB      = easys2eeglab( fullPath, standardHeader, extendedHeader, dataCalib );
dataFieldtrip   = easys2fieldtrip( fullPath, standardHeader, extendedHeader, dataCalib );