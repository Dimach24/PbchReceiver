close all;clear all; clc; %#ok<CLALL>
%%

bits=[...
    0,0,0,0,1,0,... % SFN_MSB=32
    0,          ... % scs15or60
    0,1,0,0,    ... % kSsbLsb=4
    1,          ... % dmrs pos3
    1,1,1,1,    ... % sib.RB=15
    0,1,0,1,    ... % sib.searchSpaceZero=5
    0,          ... % cellBarred=True
    1,          ... %intraFreqReselection=False
    0,          ... %reserved
    ];
mib=MibParser.ParseMib(bits);
disp(mib)
disp(mib.sib1cfg)
