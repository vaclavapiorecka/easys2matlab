function [ dataCalib,rawData ] = readDataEASYS2( filePath, standardHeader, extendedHeader, vChannels, beginSample, endSample )
% READDATAEASYS2 Read the standard header of EASYS2 files (*.d).
% This set of functions was created based on the reference manual to the
% EASYS2 file format: EASYS2 Reference Manual. 3rd edition. Praha: Neuroscience Technology Research, 2002.
% 
% INPUTS:
%   filePath - whole path of the file
%   standardHeader - standard header of the file
%   extendedHeader - extended header of the file
%   vChannels - optional parameter, row vector of position of concrete electrodes from extendedHeader.CN
%       - If this parameter is not set, function use all of the channels.
%   beginSample - optional parameter, begin sample of the data
%       - If this parameter is not set, function set this parametr to 1.
%   endSample - optional parameter, begin sample of the data
%       - If this parameter is not set, function set this parametr to standardHeader.nsamp.
%   
% OUTPUTS:
%   dataCalib - calibrated data
% 
%
% AUTHOR:   Vaclava Piorecka
% CONTACT:  vaclava.piorecka@fbmi.cvut.cz, vaclava.piorecka@nudz.cz
% DATE:     2018/08/01
    
    % If the number of input variables is lower than 4, set number of channels, begin sample and end sample.
    if nargin < 4
        beginSample = 1;
        endSample = standardHeader.nsamp;
        vChannels = 1 : 1 : standardHeader.nchan;
    end
        
    % Check the data_cell_size.
    switch standardHeader.d_val.data_cell_size 
        case 2
            precision  = 'bit16';
            numOfBytes = 2;
        case 3
            precision  = 'bit32';
            numOfBytes = 4;
        otherwise
            precision  = 'uint8';
            numOfBytes = 1;
    end

    % Get raw data
    numberOfSamples = endSample - beginSample + 1;
    fid = fopen(filePath,'r');
    dataPos = standardHeader.data_org + (beginSample-1)*numOfBytes*standardHeader.nchan;
    fseek(fid,dataPos,'bof');
    
    try
        rawData = fread(fid,numberOfSamples*standardHeader.nchan,precision);
    catch
        rawData   = [];
        dataCalib = [];
        fprintf('Error when reading raw data from the file. \nMaybe there is a problem with memory.\n')
        fclose(fid);
        return
    end
    
    switch isempty(extendedHeader.CA.calib_as_EEG)
        case 1
            % Check the data_calib_flag
            if standardHeader.d_val.data_calib_flag == 1
                dataCalib = (rawData - standardHeader.zero)/standardHeader.unit;
                dataCalib = reshape(dataCalib,standardHeader.nchan,numberOfSamples);
            else
                dataCalib = [];
                disp('Error in data acquisition. Data are not calibrated properly.')
                fclose(fid);
                return
            end
        case 0
            % Check the data_calib_flag
            if standardHeader.d_val.data_calib_flag == 1
                % v[i] = (u[i]-cal[i].zero)/cal[i].range * (float)ci.ampl;
                dataCalib = (rawData - extendedHeader.CI.ci_t.zero)/extendedHeader.CI.ci_t.range * extendedHeader.CI.ampl;
                dataCalib = reshape(dataCalib,standardHeader.nchan,numberOfSamples);
            else
                dataCalib = [];
                disp('Error in data acquisition. Data are not calibrated properly.')
                fclose(fid);
                return
            end
    end
    
    if size(vChannels,2) ~= standardHeader.nchan
        dataCalib = dataCalib(vChannels,:);
    end
    
    fclose(filePath);
end

