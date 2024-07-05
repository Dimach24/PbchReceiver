function [out_seq, J] = reverseRateMatching_subBlockDeinterleaving(in_seq)
%reverseRateMatching_subBlockDeinterleaving Procedure of sub-block
% deinterleaving for reverse rate matching of PBCH receiver 
% [TS 38.212, 5.4.1.1]
% J is the matrix of indexes after sub-block interleaving
    arguments
        in_seq (1,:) % input sequence of bits
    end
    N = 512;
    J = zeros(1,N);
    P = [0 1 2 4 3 5 6 7 8 16 9 17 10 18 11 19 12 20 13 21 14 22 15 ...
          23 24 25 26 28 27 29 30 31]; % interleaving pattern
    i = floor(32*(0:(N-1))/N);
    J(1:N)=P(i+1)*N/32+mod(0:(N-1), N/32);
    out_seq(J(1:N)+1) = in_seq(1:N); %main procedure
end