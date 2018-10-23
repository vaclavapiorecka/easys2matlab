function [ dataEEGLAB ] = easys2eeglab( fullPath, standardHeader, extendedHeader, data )
% EASYS2EEGLAB This function converts EASYS2 files (*.d) to EEGLAB format.
% This set of functions was created based on the reference manual to the
% EEGLAB: https://sccn.ucsd.edu/wiki/EEGLAB.
% 
% INPUTS:
%   fullPath - whole path of the file
%   standardHeader - standard header of the file
%   extendedHeader - extended header of the file
%   data - matrix of recorded data
%
% OUTPUTS:
%   dataEEGLAB - structure variable, compatible with EEGLAB
%
%
% AUTHOR:   Vaclava Piorecka
% CONTACT:  vaclava.piorecka@fbmi.cvut.cz, vaclava.piorecka@nudz.cz
% DATE:     2018/08/28

[fpath,name,ext] = fileparts(fullPath);
dataEEGLAB.setname = [name,ext];
dataEEGLAB.filename = [name,ext];       
dataEEGLAB.filepath = fpath;
dataEEGLAB.pnts = size(data,2);
dataEEGLAB.nbchan = size(data,1);
dataEEGLAB.trials = 1;
dataEEGLAB.srate = standardHeader.fsamp;
dataEEGLAB.xmin = 0;
dataEEGLAB.xmax = (dataEEGLAB.pnts - 1)/dataEEGLAB.srate;
dataEEGLAB.data = double.empty(dataEEGLAB.nbchan,dataEEGLAB.pnts,0);
dataEEGLAB.data = data;
dataEEGLAB.icawinv = [];
dataEEGLAB.icasphere = [];
dataEEGLAB.icaweights = [];
dataEEGLAB.icaact = [];

for not = 1 : 1 : size(extendedHeader.TAG,2)
    if extendedHeader.TAG(not).pos <= dataEEGLAB.pnts
        dataEEGLAB.event(not,1).latency = extendedHeader.TAG(not).pos;
        dataEEGLAB.event(not,1).duration = 1;
        dataEEGLAB.event(not,1).channel = 0;
        dataEEGLAB.event(not,1).type = extendedHeader.TAGDEF(extendedHeader.TAG(not).class).abrv;
        dataEEGLAB.event(not,1).code = extendedHeader.TAGDEF(extendedHeader.TAG(not).class).text;
    end
end

dataEEGLAB.epoch = [];

for noch = 1 : 1 : dataEEGLAB.nbchan
    dataEEGLAB.chanlocs(noch).labels = deblank(extendedHeader.CN(noch,:));
end

dataEEGLAB.comments = [];
dataEEGLAB.averef = 'no';
dataEEGLAB.rt = [];
dataEEGLAB.eventdescription = {};
dataEEGLAB.epochdescription = {};
dataEEGLAB.specdata = [];
dataEEGLAB.specicaact = [];
dataEEGLAB.reject = struct;
dataEEGLAB.stats = struct;
dataEEGLAB.splinefile = [];
dataEEGLAB.ref = 'common';
dataEEGLAB.history = [];
dataEEGLAB.urevent = [];
dataEEGLAB.times = [];

end

