# easys2matlab
Import data in EASYS2 format to MATLAB.

The **easys2matlab toolbox**  is an EASYS2 EEG format implementation in MATLAB interface. Additional the conversion to the FieldTrip and EEGLAB toolboxes was added.

This set of functions was created based on the reference manual to the EASYS2 file format: EASYS2 Reference Manual. 3rd edition. Praha: Neuroscience Technology Research, 2002.

AUTHOR:   Ing. Vaclava Piorecka, Ph.D.

CONTACT:  vaclava.piorecka@nudz.cz, vaclava.piorecka@fbmi.cvut.cz

## List of scripts & functions
readSHeaderEASYS2   - reads the standard header of EASYS2 files

readXHeaderEASYS2   - reads the extended header of EASYS2 files

readDataEASYS2      - reads the raw EEG data of EASYS2 files

easys2fieldtrip     - converts EASYS2 files to [Fieldtrip](http://www.fieldtriptoolbox.org/start) format

easys2eeglab        - converts EASYS2 files to [EEGLAB](https://sccn.ucsd.edu/wiki/EEGLAB) format

example             - example of reading the EASYS2 file

cohort_conversion   - converts multiple EASYS2 files
