close all;clear all; clc; %#ok<CLALL>
%%
test_array=1/2^.5*[1+1j,-1+1j,-1-1j,1-1j];
scatter(real(test_array),imag(test_array))
xlim([-2,2])
ylim([-2,2])
figure 
stairs(PbchReceiver.QpskDemodulation(test_array))
ylim([0,1.5])
xlim([0,9])