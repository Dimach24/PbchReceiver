classdef PbchReceiver
    methods(Static)
        
        function [MIB, is_data_valid] = receivePbch(bit_sequence, NcellID, Lmax_)
        %receivePbch Procedure of PBCH deconstruction and MIB extraction [7.1, TS 38.212]
            arguments
                bit_sequence (1,:) % demapped and descrambled PBCH bit sequence
                NcellID (1,1) % cell identification number
                Lmax_ (1,1) % maximum number of candidate SS/PBCH blocks in half frame [4.1, TS 38.213]
            end
            
            bit_sequence = PbchReceiver.reverseRateMatching(bit_sequence);
            bit_sequence = PbchReceiver.channelDecoding(bit_sequence);
            [bit_sequence, is_data_valid] = ExtractDataCheckParity(bit_sequence, "crc24c");
            bit_sequence = descrambling(bit_sequence,NcellID,Lmax_);
            MIB = PbchReceiver.payloadReceiving(bit_sequence, Lmax_);

        end

        function out_seq = reverseRateMatching(in_seq)
            in_seq = reverseRateMatching_bitSelection(in_seq);
            out_seq = reverseRateMatching_subBlockDeinterleaving(in_seq);
        end

        function out_seq = channelDecoding(in_seq)
            QN_I_file = matfile("QN_I.mat");
            QN_I = QN_I_file.QN_I;
            in_seq = channelDecoding_polarDecoding(in_seq,QN_I); % does not work properly in the moment
            out_seq = channelDecoding_deinterleaving(in_seq);
        end

        function data = payloadReceiving(in_seq,Lmax_)
            in_seq = payloadReceiving_deinterleaving(in_seq);
            data = MibParser.ParsePbchPayload(in_seq,Lmax_);
        end
    end

end