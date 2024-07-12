classdef PbchReceiver
    methods(Static)
        
        function [MIB, is_data_valid] = receivePbch(bit_sequence, NcellID, Lmax_)
        %receivePbch Procedure of PBCH deconstruction and MIB extraction [7.1, TS 38.212]
            arguments
                bit_sequence (1,:) % demapped and descrambled PBCH bit sequence
                NcellID (1,1) % cell identification number
                Lmax_ (1,1) % maximum number of candidate SS/PBCH blocks in half frame [4.1, TS 38.213]
            end
            
            bit_sequence = PbchReceiver.rateRecovery(bit_sequence);
            bit_sequence = PbchReceiver.channelDecoding(bit_sequence);
            [bit_sequence, is_data_valid] = PbchReceiver.crcDetachment(bit_sequence);
            bit_sequence = PbchReceiver.descrambling(bit_sequence,NcellID,Lmax_);
            MIB = PbchReceiver.payloadReceiving(bit_sequence, Lmax_);

        end

        function out_seq = rateRecovery(in_seq)
            in_seq = rateRecovery_bitSelection(in_seq);
            out_seq = rateRecovery_subBlockDeinterleaving(in_seq);
        end

        function out_seq = channelDecoding(in_seq)
            in_seq = channelDecoding_polarDecoding(in_seq);
            out_seq = channelDecoding_deinterleaving(in_seq);
        end

        function [out_seq, isValid] = crcDetachment(in_seq)
            [out_seq, isValid] = ExtractDataCheckParity(in_seq, "crc24c");
        end
        
        function out_seq = descrambling(in_seq,NCellID,Lmax_)
            out_seq = descrambling(in_seq,NCellID,Lmax_);
        end

        function data = payloadReceiving(in_seq,Lmax_)
            in_seq = payloadReceiving_deinterleaving(in_seq);
            data = MibParser.ParsePbchPayload(in_seq,Lmax_);
        end
    end

end