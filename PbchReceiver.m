classdef PbchReceiver
    methods(Static)
        function bitstream=QpskDemodulation(sequence)
            bitstream=zeros(1,length(sequence)*2,"uint8");
            for i=1:length(sequence)
                bitstream(2*i-1)=(1-sign(real(sequence(i))))/2;
                bitstream(2*i)=(1-sign(imag(sequence(i))))/2;
            end
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
        function issb_lsb=PbchDmRsProcessing(dmrs_linearized,NCellId)
            for i=0:7
                dmrs_bank(i+1)=generatePbchDmRs(i,NCellId);
            end
            corr_data=xcorr(dmrs_bank,dmrs_linearized);
            corr_max=max(corr_data);
            [~,issb_lsb]=max(corr_data,[]);
        end
    end

end