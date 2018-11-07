function [ dataFieldtrip ] = easys2fieldtrip( fullPath, standardHeader, extendedHeader, data )
% EASYS2FIELDTRIP This function converts EASYS2 files (*.d) to Fieldtrip format.
% This set of functions was created based on the reference manual to the
% Fieldtrip: http://www.fieldtriptoolbox.org/start.
% 
% INPUTS:
%   fullPath - whole path of the file
%   standardHeader - standard header of the file
%   extendedHeader - extended header of the file
%   data - matrix of recorded data
%
% OUTPUTS:
%   dataFieldtrip - structure variable, compatible with dataFieldtrip
%
%
% AUTHOR:   Vaclava Piorecka
% CONTACT:  vaclava.piorecka@fbmi.cvut.cz, vaclava.piorecka@nudz.cz
% DATE:     2018/08/28

dataFieldtrip = struct;
dataFieldtrip.fsample = standardHeader.fsamp;
dataFieldtrip.label = cellstr(extendedHeader.CN);
dataFieldtrip.time = mat2cell(0:(1/dataFieldtrip.fsample):((standardHeader.nsamp-1)/dataFieldtrip.fsample),1,size(data,1));

% Events
dataFieldtrip.event = struct;
for not = 1 : 1 : size(extendedHeader.TAG,2)
    if extendedHeader.TAG(not).pos <= standardHeader.nsamp
        dataFieldtrip.event(not,1).type = extendedHeader.TAGDEF(extendedHeader.TAG(not).class).abrv;
        dataFieldtrip.event(not,1).sample = extendedHeader.TAG(not).pos;
        dataFieldtrip.event(not,1).value = extendedHeader.TAGDEF(extendedHeader.TAG(not).class).text;
        dataFieldtrip.event(not,1).offset = 0;
        dataFieldtrip.event(not,1).duration = 1;
        dataFieldtrip.event(not,1).timestamp = []; % Optional
    end
end

% FieldTrip header
dataFieldtrip.hdr.Fs = dataFieldtrip.fsample;
dataFieldtrip.hdr.nChans = standardHeader.nchan;
dataFieldtrip.hdr.nSamples = standardHeader.nsamp;
dataFieldtrip.hdr.nSamplesPre = 0;
dataFieldtrip.hdr.nTrials = 1;
dataFieldtrip.hdr.label = dataFieldtrip.label;
dataFieldtrip.hdr.chantype = []; 
dataFieldtrip.hdr.chanunit = cell(dataFieldtrip.hdr.nChans,1); 
dataFieldtrip.hdr.chanunit(:) = {'uV'}; 

% Trial
dataFieldtrip.trial = mat2cell(data,dataFieldtrip.hdr.nChans);

end

