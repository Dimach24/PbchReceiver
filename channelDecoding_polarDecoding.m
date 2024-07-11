function out_seq = channelDecoding_polarDecoding(in_seq)
%channelDecoding_polarDecoding Procedure of polar decoding in PBCH Receiver
%module [TS 38.212 clause 7.1.4] -> [TS 38.212 clause 5.3.1.2]
    arguments
        in_seq (1,512) % PolarCode - input coded sequence of bits
    end

    N = 512; % input sequence length
    K = 56; % output sequence length
    
    % Q_I_N definition
    Q_0_Nmax = matfile("ReliabilityAndPolarCodingSeqIndexes.mat").ReliabilityAndPolarSeqIndexes.'; % table 5.3.1.2-1
        j = 1;
        for i = 1:1024
            if Q_0_Nmax(i)<N
                Q_0_N(j) = Q_0_Nmax(i);
                j=j+1;
                if j > N
                    break
                end
            end
        end
    Q_I_N = Q_0_N((end-K+1):end);
    
    % G_N matrix definition
    G_2 = ones(2, 2);
    G_2(1, 2) = 0;
    G_N = G_2;
    Power=log2(N);
    for i=1:Power-1
        G_N = kron(G_2, G_N);
    end
    
    u=mod(in_seq/G_N,2); % u definiton
    
    % main procedure
    out_seq = zeros(1,56); 
    k=0;
    for n = 0:(N-1)
        if ismember(n, Q_I_N)
            out_seq(k+1) = u(n+1);
            k = k + 1;
            if k > K
                break
            end
        end
    end 
end

