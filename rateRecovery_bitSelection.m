function out_seq = rateRecovery_bitSelection(in_seq)
%rateRecovery_bitSelection Procedure of bit selection for reverse 
% rate matching of PBCH Receiver module [TS 38.212 5.4.1.2]
arguments
    in_seq (1,:); % input sequence
end
    E = 864; % determined [TS 38.212, 7.1.5]
    N = 512; % length of output sequence
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