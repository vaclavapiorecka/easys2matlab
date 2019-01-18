function [ standardHeader ] = readSHeaderEASYS2( filePath )
% READSHEADEREASYS2 Read the standard header of EASYS2 files (*.d).
% This set of functions was created based on the reference manual to the
% EASYS2 file format: EASYS2 Reference Manual. 3rd edition. Praha: Neuroscience Technology Research, 2002.
% 
% INPUTS:
%   filePath - whole path of the file
%
% OUTPUTS:
%   standardHeader - structure variable
%       - sign  - contains the signature of the program that created the data file, 
%       - ftype - contains a one-char identifier of the data file type
%       - nchan - contains the number of recording channels
%       - naux  - contains the number of auxiliary channels
%       - fsamp - contains the sampling frequency in samples per second
%       - nsamp - contains the total number of data samples in the data section
%       - unit  - contains the scaling factor used in the data recalibration
%       - zero  - contains the numerical code corresponding to the physical zero
%       - data_org - contains the offset of the data section, specified in paragraphs
%       - xhdr_org - contains the offset of the extended header specified in paragraphs
%       - d_val - structure variable, is a so called data validation field
%           - data_invalid_flag     - if set, the data cannot be considered valid
%           - data_packed_flag      - indicates that the data is compressed
%           - block_structure_flag  - set if the file has block structure
%           - polarity_flag         - set if physically negative values coded by higher numerical values
%           - data_calib_flag       - set if the data is recalibrated properly to ?Volts
%           - data_modified_flag    - used by external applications to signal EASKERN that data file has been modified
%           - data_cell_size        - 0 = undefined, otherwise log2 size + 1
%
% AUTHOR:   Vaclava Piorecka
% CONTACT:  vaclava.piorecka@fbmi.cvut.cz, vaclava.piorecka@nudz.cz
% DATE:     2018/08/01

    % Try open the the file.
    fid = fopen(filePath,'r');
    if fid<1
        fprintf('Can not open file: %s\n.',filePath);
        fclose(fid);
        return
    end
    
    standardHeader = struct;
    standardHeader.sign     = fread(fid,15,'*char');
    standardHeader.ftype    = fread(fid,1,'*char');
    standardHeader.nchan    = fread(fid,1,'uchar');
    standardHeader.naux     = fread(fid,1,'*uchar');
    standardHeader.fsamp    = fread(fid,1,'ushort');
    standardHeader.nsamp    = fread(fid,1,'ulong');
    dValHelp                = fread(fid,1,'*uchar');
    standardHeader.unit     = fread(fid,1,'uchar');
    standardHeader.zero     = fread(fid,1,'short');
    standardHeader.data_org = 16*fread(fid,1,'*ushort');   % specified in paragraphs (1 para = 16 bytes)
    standardHeader.xhdr_org = 16*fread(fid,1,'*ushort');   % specified in paragraphs (1 para = 16 bytes)

    % Set standartHeader.d_val properly.
    standardHeader.d_val = struct;
    standardHeader.d_val.data_invalid_flag      = bitget(dValHelp,8);
    standardHeader.d_val.data_packed_flag       = bitget(dValHelp,7);
    standardHeader.d_val.block_structure_flag   = bitget(dValHelp,6);
    standardHeader.d_val.polarity_flag          = bitget(dValHelp,5);
    standardHeader.d_val.data_calib_flag        = bitget(dValHelp,4);
    standardHeader.d_val.data_modified_flag     = bitget(dValHelp,3);
    standardHeader.d_val.data_cell_size         = bi2de(bitget(dValHelp,1:2));
    
    fclose(fid);
end

