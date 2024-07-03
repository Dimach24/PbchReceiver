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
                data.kSsbMsb=2^5*bits(30);
                data.reserved=[bits(31)];
                data.blockIndexMsb=2^3*bits(32);
            elseif Lmax_==20
                data.kSsbMsb=2^5*bits(30);
                data.blockIndexMsb=2^4*bits(31)+2^3*bits(32);
            elseif Lmax_==64
                data.kSsbMsb=0;
                data.blockIndexMsb=2^5*bits(30)+2^4*bits(31)+2^3*bits(32);
            else
                data.kSsbMsb=2^5*bits(30);
                data.reserved=bits(31:32);
                data.blockIndexMsb=0;
            end
            data.kSsb=data.kSsbMsb+data.mib.kSsbLsb;
        end
        function blockIndexLsb=PbchDmRsProcessing(dmrs_linearized,NCellId)
            for i=0:7
                dmrs_bank(i+1)=generatePbchDmRs(i,NCellId);
            end
            corr_data=xcorr(dmrs_bank,dmrs_linearized);
            corr_max=max(corr_data);
            [~,blockIndexLsb]=max(corr_max,[]);
        end
        function [pbch,dmrs]=PbchExtraction(Rgrid,toffset,foffset,NCellId)
            nu=mod(NCellId,4);
            indexes_fsolid=find(mod(1:1:240,4)==1);
            indexes_fsplitted=indexes_fsolid(indexes_fsolid<46 | indexes_fsolid>192);
            indexes_fsolid=indexes_fsoled + nu +foffset;
            indexes_fsplitted=indexes_fsplitted + nu +foffset;
            dmrs=[...
                reshape(Rgrid(indexes_fsolid,   toffset+1),[],1),...
                reshape(Rgrid(indexes_fsplitted,toffset+2),[],1),...
                reshape(Rgrid(indexes_fsolid,   toffset+3),[],1)...
                ];
            pbch=[...
                reshape(Rgrid(setdiff(1:240+foffset,indexes_fsolid)     ,toffset+1),[],1),...
                reshape(Rgrid(setdiff(1:48+foffset,indexes_fsplitted)   ,toffset+2),[],1),...
                reshape(Rgrid(setdiff(193:240+foffset,indexes_fsplitted),toffset+2),[],1),...
                reshape(Rgrid(setdiff(1:240+foffset,indexes_fsolid)     ,toffset+3),[],1),...
                ];
            pbch=QpskDemodulation(pbch);
        end
        function data=ProcessPbch(Rgrid,toffset,foffset,NCellId,Lmax_)
            [pbch,dmrs]=PbchExtraction(Rgrid,toffset,foffset,NCellId);
            data=ParsePbchPayload(pbch,Lmax_);
            data.blockIndexLsb=PbchDmRsProcessing(dmrs,NCellId);
            data.blockIndex=data.blockIndexMsb+data.blockIndexLsb;
        end
    end
end


