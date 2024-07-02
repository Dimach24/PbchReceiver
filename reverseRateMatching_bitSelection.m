function out_seq = reverseRateMatching_bitSelection(in_seq, N)
%reverseRateMatching_bitSelection Procedure of bit selection for reverse 
% rate matching of PBCH Receiver module [TS 38.212 5.4.1.2]
arguments
    in_seq (1,:); % input sequence
    N (1,1); % length of output sequence
end
    E = 864; % determined [TS 38.212, 7.1.5]
    K = 56; % length of output sequence of further polar decoder
    if E >= N
        out_seq(mod(0:(E-1),N)+1) = in_seq(1:E);
        return
    elseif (K/E) <= (7/16)
        out_seq(1:E+N-E) = in_seq(1:E);
        return
    end
    out_seq(1:E) = in_seq(1:E);
end