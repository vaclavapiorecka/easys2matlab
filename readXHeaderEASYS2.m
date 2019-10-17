function [ extendedHeader ] = readXHeaderEASYS2( filePath,standardHeader )
% READXHEADEREASYS2 Read the extended header of EASYS2 files (*.d).
% This set of functions was created based on the reference manual to the
% EASYS2 file format: EASYS2 Reference Manual. 3rd edition. Praha: Neuroscience Technology Research, 2002.
%
% INPUTS:
%   filePath - whole path of the file
%   standardHeader - standard header of the file
%
% OUTPUTS:
%   extendedHeader - structure variable
%       - AU - Authentication key
%       - BS - Blank Space: no valid data
%       - BV - Block Variable values list
%       - CA - Channel Attributes
%           - unsigned - data is unsigned
%           - reversed_polarity - data has reversed polarity
%           - reversed - reserved
%           - reversed_internal - reserved for internal usage by the data viewer
%           - calib_as_EEG - data is calibrated as EEG
%           - reversed2 - reserved
%       - CI - Calibration Info
%           - ncal - contains the number of calibrated channels
%           - ampl - contains the amplitude of calibration signal in uVolts
%           - ci_t
%               - zero - A/D values for zero voltage
%               - ampl - potential difference
%       - CN - Channel Names: an array holding list of 4-character channel identifiers
%       - DF - Dispose Flags, a bitmask keeping track of operations made on the file
%       - DI - Data Info: an ASCIIZ string containing a description of the data
%       - FL - File Links: a table of related files
%       - FS - Frequency of Sampling (fractional)
%       - ID - Patient’s ID number or PIC
%           - year - year of birth
%           - mm   - mont of birth
%           - dd   - day of birth
%           - sex  - male / female
%           - Y2K  - Y2K flag (from ver. 2.31 - in lower ver. is unused)
%           - SN   - serial number
%       - PJ - ProJect name used by EASREC
%       - RB - R-Block structure definition
%           - helpRB - help variable, read of the others variables is not complete
%           - flags - bit record of flags
%           - pflen - specifies the length of Block Prefix
%           - nchan - contains number of channels represented in the file
%           - blklen - contains length of the data block
%           - blkcnt - contains number of data blocks in the file
%           - org - specify the range of the block variable, can be undefined
%           - step - specify the range of the block variable, can be undefined
%           - bvar - contain descriptions of the block variable
%           - fvar - contain descriptions of the block variable
%           - xvar - contain descriptions of the block variable
%           - yvar - contain descriptions of the block variable
%       - SF - Source File: source data file spec
%       - TE - Text Record: plain text note
%       - TI - Time Info: date/time of the start of the recording
%           - yy - year of recording
%           - mm - month of recording
%           - dd - day of recording
%           - hh - hour of recording
%           - min - minutes of recording
%           - ss - seconds of recording
%       - TT - Tag Table: a reference to tag list in the file appendix
%           - def_len  - contain the length of the tag class definition table
%           - list_len - contain the file offset of the tag class definition table
%           - def_off  - contain the length of the Tag List
%           - list_off - contain the offset of the Tag List
%       - TX - Text Extension record: plain text note
%       - TAG - Tag List, include position (sample) and class definition
%       - TAGDEF - Tag Table, definition of Tag classes
%
% AUTHOR:   Vaclava Piorecka
% CONTACT:  vaclava.piorecka@fbmi.cvut.cz, vaclava.piorecka@nudz.cz
% DATE:     2018/08/01

fid = fopen(filePath,'r');
fseek(fid,standardHeader.xhdr_org,'bof');

extendedHeader = struct;
extendedHeader.AU = [];
extendedHeader.BS = [];
extendedHeader.BV = [];
extendedHeader.CA = struct;
extendedHeader.CA.unsigned = [];
extendedHeader.CA.reversed_polarity = [];
extendedHeader.CA.reserved = [];
extendedHeader.CA.reserved_internal = [];
extendedHeader.CA.calib_as_EEG = [];
extendedHeader.CA.reserved2 = [];
extendedHeader.CI = struct;
extendedHeader.CI.ncal = [];
extendedHeader.CI.ampl = [];
extendedHeader.CI.ci_t = struct;
extendedHeader.CI.ci_t.zero = [];
extendedHeader.CI.ci_t.range = [];
extendedHeader.CN = [];
extendedHeader.DF = [];
extendedHeader.DI = [];
extendedHeader.FL = [];
extendedHeader.FS = [];
extendedHeader.ID = struct;
extendedHeader.ID.year = [];
extendedHeader.ID.mm   = [];
extendedHeader.ID.dd   = [];
extendedHeader.ID.sex  = [];
extendedHeader.ID.Y2K  = [];
extendedHeader.ID.SN   = [];
extendedHeader.PJ = [];
extendedHeader.RB = struct;
extendedHeader.RB.flags = struct;
extendedHeader.RB.pflen = [];
extendedHeader.RB.nchan = [];
extendedHeader.RB.blklen = [];
extendedHeader.RB.blkcnt = [];
extendedHeader.RB.org = [];
extendedHeader.RB.step = [];
extendedHeader.RB.bvar = [];
extendedHeader.RB.fvar = [];
extendedHeader.RB.xvar = [];
extendedHeader.RB.yvar = [];
extendedHeader.SF = [];
extendedHeader.TE = [];
extendedHeader.TI = struct;
extendedHeader.TI.yy  = [];
extendedHeader.TI.mon = [];
extendedHeader.TI.dd  = [];
extendedHeader.TI.hh  = [];
extendedHeader.TI.min = [];
extendedHeader.TI.ss  = [];
extendedHeader.TT = struct;
extendedHeader.TT.def_len  = [];
extendedHeader.TT.list_len = [];
extendedHeader.TT.def_off  = [];
extendedHeader.TT.list_off = [];
extendedHeader.TX = [];
extendedHeader.TAG = [];
extendedHeader.TAGDEF = [];

while(true)
    reader = fread(fid,2,'*uint16');
    
    if(reader(1) == 0)
        break;
    end
    
    IDMnemo = dec2hex(reader(1));
    sizeMnemo = reader(2);
    
    switch IDMnemo
        case '5541' % mnemo = AU, Authentication key
            extendedHeader.AU = fread(fid,2,'*int32');
            disp(sizeMnemo)
        case '5342' % mnemo = BS, Blank Space: no valid data
            extendedHeader.BS = fread(fid,sizeMnemo,'*int32');
        case '5642' % mnemo = BV, Block Variable values list
            %! zavisi na RB records, kde je velikost
            extendedHeader.BV = fread(fid,sizeMnemo,'*int32');
            % fseek(fid,sizeMnemo,'cof');
        case '4143' % mnemo = CA, Channel Attributes for non-EGG channels
            valCA = fread(fid,sizeMnemo,'uint8');
            for ca = 1 : sizeMnemo
                helpCA = dec2bin(valCA(ca),8);
                extendedHeader.CA.unsigned(ca)              = bin2dec(helpCA(8));
                extendedHeader.CA.reversed_polarity(ca)     = bin2dec(helpCA(7));
                extendedHeader.CA.reserved(ca)              = bin2dec(helpCA(6));
                extendedHeader.CA.reserved_internal(ca)     = bin2dec(helpCA(3:5));
                extendedHeader.CA.calib_as_EEG(ca)          = bin2dec(helpCA(2));
                extendedHeader.CA.reserved2(ca)             = bin2dec(helpCA(1));
            end
        case '4943' % mnemo = CI, used for storage of Calibration Info
            helpCI = fread(fid,2,'*int8');
            extendedHeader.CI.ncal = helpCI(1);
            extendedHeader.CI.ampl = helpCI(2);     % amplitude of calibration signal in uVolts
            extendedHeader.CI.ci_t = struct;
            for ci = 1 : extendedHeader.CI.ncal
                helpcit = fread(fileID,2,'*single');
                extendedHeader.CI.ci_t(ci).zero = helpcit(1);
                extendedHeader.CI.ci_t(ci).range = helpcit(2);
            end
        case '4E43' % mnemo = CN, Channel Names: an array holding list of 4-character channel identifiers
            extendedHeader.CN = transpose(fread(fid,[4 standardHeader.nchan],...
                '*char'));
        case '4644' % mnemo = DF, Dispose Flags
            extendedHeader.DF = fread(fid,sizeMnemo,'*int8');
        case '4944' % mnemo = DI, Data Info: an ASCIIZ string containing a description of the data
            extendedHeader.DI = fread(fid,sizeMnemo,'*char')';
        case '4C46' % mnemo = FL, File Links: a table of related files
            extendedHeader.FL = fread(fid,...
                sizeMnemo,'*char');
        case '5346' % mnemo = FS, Frequency of Sampling (fractional)
            extendedHeader.FS = fread(fid,sizeMnemo...
                ,'*int16');
        case '4449' % mnemo = ID, Patient’s ID number or PIC
            helpID = fread(fid,1,'uint32');
            tempID = dec2bin(helpID,32);
            extendedHeader.ID.year      = bin2dec((tempID(1:7)))+1900;
            extendedHeader.ID.mm        = bin2dec((tempID(8:11)));
            extendedHeader.ID.dd        = bin2dec((tempID(12:16)));
            helpSex     = bin2dec((tempID(17))); % 0 = male, 1 = female
            if helpSex == 1
                extendedHeader.ID.sex   = 'F';
            else
                extendedHeader.ID.sex   = 'M';
            end
            extendedHeader.ID.Y2K       = bin2dec((tempID(18)));
            extendedHeader.ID.SN        = bin2dec((tempID(19:32)));
        case '4A50' % mnemo = PJ, ProJect name used by EASREC
            extendedHeader.PJ = char(fread(fid,sizeMnemo,'char')');
        case '4252' % mnemo = RB, R-Block structure definition
            %             This part needs improve. Not important yet.
            extendedHeader.RB.helpRB = fread(fid,sizeMnemo,'uint8');
            %             helpFlags = dec2bin(fread(fid,1,'*uchar'));
            %             extendedHeader.RB.flags.dual_data_flag = helpFlags(8); % 0 bit
            %             extendedHeader.RB.flags.complex_data_flag = helpFlags(7); % 1 bit
            %             extendedHeader.RB.flags.statistics_flag = helpFlags(6); % 2 bit
            %             extendedHeader.RB.flags.var_ids_flag = helpFlags(5); % 3 bit
            %             extendedHeader.RB.flags.block_var_flag = helpFlags(3:4); % 4-5 bit
            %             extendedHeader.RB.flags.file_var_flag = helpFlags(1:2); % 6-7 bit
            %             extendedHeader.RB.pflen = fread(fid,1,'*uchar');
            %             extendedHeader.RB.nchan = fread(fid,1,'ushort');
        case '4653' % mnemo = SF, Source File: source data file spec
            fseek(fid,sizeMnemo,'cof');
        case '4554' % mnemo = TE, Text Record: plain text note
            extendedHeader.TE = fread(fid,...
                sizeMnemo,'*char');
        case '4954' % mnemo = TI, Time Info: date/time of the start of the recording
            helpTI = fread(fid,1,'uint32');
            [extendedHeader.TI.yy, extendedHeader.TI.mm, extendedHeader.TI.dd, extendedHeader.TI.hh, extendedHeader.TI.min, extendedHeader.TI.ss] = datevec(helpTI/(60*60*24)+datenum('01.01.1970','dd.mm.yy'));
        case '5454' % mnemo = TT, Tag Table
            % The TAG Table will be created later, here only position and
            % deffinitons and real tags.
            % extendedHeader.TT = struct;
            extendedHeader.TT.def_len   = fread(fid,1,'uint16');
            extendedHeader.TT.list_len  = fread(fid,1,'uint16');
            extendedHeader.TT.def_off   = fread(fid,1,'uint32');
            extendedHeader.TT.list_off  = fread(fid,1,'uint32');
        case '5854' % mnemo = TX, Text Extension record
            fseek(fid,sizeMnemo,'cof');
        case '0000'
            false
        otherwise
            fseek(fid,sizeMnemo,'cof');
    end
end

if extendedHeader.TT.list_len ~= 0 %isfield(extendedHeader,'TT')
    position = ftell(fid);
    %% Tag Lists
    TAGTable = struct;
    fseek(fid,extendedHeader.TT.list_off,'bof');
    tempData = fread(fid,extendedHeader.TT.list_len/4,'*uint32');
    j = 1;
    for i = 1:length(tempData)
        maskPosition =16777215;
        TAGTable(j).pos = bitand(tempData(j),maskPosition);
        maskClass = hex2dec('FF000000');
        helpClass = bitshift(bitand(maskClass,tempData(j)),-24);
        TAGTable(j).class = helpClass +1;
        
        j = j+1;
    end
    
    positionZ       = find( [TAGTable.class] == 128);
    begSample       = [ 1, positionZ ]';
    endSample       = [ positionZ, size(TAGTable,2)]';
    wholePosition   = [ begSample, endSample ];
    numOfSeg        = size(wholePosition,1);
    
    if (numOfSeg > 1)
        for i = 2 : 1 : numOfSeg
            newvec = [TAGTable(wholePosition(i,1)+1 : wholePosition(i,2)).pos]'+2^24;
            for j = 1 : 1 : size(newvec,1)
                [ TAGTable(wholePosition(i,1)+j).pos ] = newvec(j,1);
            end
        end
    end
    
    extendedHeader.TAG = TAGTable;
    
    %% Tag Definitions
    remPos = extendedHeader.TT.def_off;
    TAGDEF = struct;
    i = 1;
    while(true)
        fseek(fid,remPos,'bof');
        TAGDEF(i).abrv = fread(fid,2,'*char');
        count = fread(fid,1,'*uint16');
        if(bitget(count,16)==1)
            count = count-32768;
            TAGDEF(i).count = count;
            TAGDEF(i).txtlen = fread(fid,1,'uint16');
            TAGDEF(i).txtoff = fread(fid,1,'uint16');
            remPos = remPos + 8;
            fseek(fid,TAGDEF(i).txtoff + extendedHeader.TT.def_off, 'bof');
            TAGDEF(i).text = char(fread(fid,TAGDEF(i).txtlen,'char')');
            break
        else
            TAGDEF(i).count = count;
            TAGDEF(i).txtlen = fread(fid,1,'uint16');
            TAGDEF(i).txtoff = fread(fid,1,'uint16');
            remPos = remPos + 8;
            fseek(fid,TAGDEF(i).txtoff + extendedHeader.TT.def_off, 'bof');
            TAGDEF(i).text = char(fread(fid,TAGDEF(i).txtlen,'char')');
        end
        i = i+1;
    end
    extendedHeader.TAGDEF = TAGDEF;
    fseek(fid,position,'bof');
    
    
end

fclose(fid)
end

