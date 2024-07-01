function out_seq = descrambler(mode,in_seq, N_Cell_ID, L_max, block_index)
    %descramble Procedure of revererse scrambling
    %   mode 0: Descrambling after demodulation [7.3.3.1, TS 38.211]
    %   mode 1: Descrambling after CRC detachment [7.1.2, TS 38.212] 
    
    arguments
        mode (1,1)
        in_seq (1,:) % input sequence (boolean matrix)
        N_Cell_ID (1,1)
        L_max (1,1) % maximum number of candidate SS/PBCH blocks in half frame [5, TS 38.213]
        block_index (1,1) % candidate SS/PBCH block index (required only for mode 0)
    end
    
    %init
    A = length(in_seq);
    s = zeros(1,A);
    %
    
    %determinaton of M
    if mode
        M = A-3 - (L_max == 10) - 2*(L_max == 20) - 3*(L_max == 64);
    else
        M = A;
    end
    %

    %determinaton of nu
    if mode
        nu = [in_seq(1+6) in_seq(1+24)]; %3rd & 2nd LSB of SFN are stored in bits 6 & 24 of interleaved sequence
        nu = bin2dec(num2str(nu));
    else
        block_index = fliplr(dec2bin(block_index));
        if L_max == 4
            nu = [block_index(2) block_index(1)];
        else
            nu = [block_index(3) block_index(2) block_index(1)];
        end
        nu = bin2dec(num2str(nu));
    end
    %

    %determination of c
    x1 = zeros(1,2000);
    x2 = zeros(1,2000);
    x1(1) = 1;
    x1(2:31) = 0;
    x2(1:31) = fliplr(dec2bin(N_Cell_ID,31)); %c_init = N_Cell_ID
    for n = 1:2000
        x1(n+31) = mod(x1(n+3)+x1(n),2);
        x2(n+31) = mod(x2(n+3)+x2(n+2)+x2(n+1)+x2(n),2);
        n1 = 1:160;
        c(n1) = mod(x1(n1+1600)+x2(n1+1600),2);
    end
    %

    %determination of s
    i = 0;
    j = 0;
    while i < A
        if ~mode
            s_null_cond = 0;
        else
            s_null_cond = i == 6 || i == 24 || ...
            i == 0 || (i == 31)&&(L_max == 10) || ...
            ((i == 31)||(i == 29))&&(L_max == 20) || ...
            ((i == 31)||(i == 29)||(i == 28))&&(L_max == 64);
        end
        if  ~s_null_cond
            s(1+i) = c(1+j+nu*M);
            j = j+1;
        else
            s(1+i) = 0;
        end
        i = i+1;
    end
    %

    %descrambling
    out_seq = zeros (1,A);
    for i = 1:A
    out_seq(i) = mod(in_seq(i)+ s(i),2);
    end
    %
end