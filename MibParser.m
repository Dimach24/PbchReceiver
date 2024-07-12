classdef MibParser
    methods(Static)
        function mib=ParseMib(bits)
            arguments
                bits (1,23) {mustBeMember(bits,[0,1])}
            end
            persistent ScsType DmrsTypeAPositions;
            if isempty(ScsType) || isempty(DmrsTypeAPositions)
                DmrsTypeAPositions=["pos2","pos3"];
                ScsType=["15or60","30or120"];
            end
            mib.SfnMsb=sum(2.^(9:-1:4).*bits(1:6));
            mib.ScsType=ScsType(bits(7)+1);
            mib.kSsbLsb=sum(2.^(3:-1:0).*bits(8:11));
            mib.DMRStypeAPos=DmrsTypeAPositions(bits(12)+1);
            sib1cfg.controlResourceSetZero=sum(2.^(3:-1:0).*bits(13:16));
            sib1cfg.searchSpaceZero=sum(2.^(3:-1:0).*bits(17:20));
            mib.sib1cfg=sib1cfg;
            mib.cellBarred=bits(21)==0; %zero -- True
            mib.intraFreqReselection=bits(22)==0; %zero -- True
            mib.reserved=bits(23);
        end
        function data=ParsePbchPayload(bits,Lmax_)
            arguments
                bits (1,32) {mustBeMember(bits,[0,1])}
                Lmax_ (1,1) {mustBeInteger}
            end
            data.choiceBit=bits(1);
            data.mib=MibParser.ParseMib(bits(2:24));
            data.SfnLsb=sum(2.^(3:-1:0).*bits(25:28));
            data.SFN=data.mib.SfnMsb+data.SfnLsb;
            data.halfFrame=bits(29);
            if Lmax_==10
                data.kSsbMsb=2^4*bits(30);
                data.reserved=[bits(31)];
                data.blockIndexMsb=2^3*bits(32);
            elseif Lmax_==20
                data.kSsbMsb=2^4*bits(30);
                data.blockIndexMsb=2^4*bits(31)+2^3*bits(32);
            elseif Lmax_==64
                data.kSsbMsb=0;
                data.blockIndexMsb=2^5*bits(30)+2^4*bits(31)+2^3*bits(32);
            else
                data.kSsbMsb=2^4*bits(30);
                data.reserved=bits(31:32);
                data.blockIndexMsb=0;
            end
            data.kSsb=data.kSsbMsb+data.mib.kSsbLsb;
        end
    end
end


