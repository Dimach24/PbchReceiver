close all;clear all; clc; %#ok<CLALL>
%%
mib_bits=[...
    0,0,0,1,1,0,... % SFN_MSB=96
    0,          ... % scs15or60
    0,1,0,0,    ... % kssbLsb=4
    1,          ... % dmrs pos3
    1,1,1,1,    ... % sib.RB=15
    0,1,0,1,    ... % sib.searchSpaceZero=5
    0,          ... % cellBarred=True
    1,          ... %intraFreqReselection=False
    0,          ... %reserved
    ];

choice_bit=1;
SFN_LSB=[0,1,0,1];% 5
HF_bit=1;
Lmax_=20;
kSSB_MSB=1;
block_index_MSB=[1,0]; % 32
bits=[choice_bit, mib_bits, SFN_LSB,HF_bit,kSSB_MSB,block_index_MSB];
data=MibParser.ParsePbchPayload(bits,Lmax_);
disp(data)