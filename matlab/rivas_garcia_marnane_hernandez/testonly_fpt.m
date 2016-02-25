
clc, clear all, close all
load('../../data/mit-bih/101m.mat') %load data
fs=360;
ECG = val(1,:); %get input vector from loaded data
ECG = ECG(1,1:length(ECG)/4);

[Rpos_fpt R_fpt ecgd_fpt ecgi_fpt ecgs_fpt] = fixed_rivas_fixpt(ECG);

Rpos_fpt = getridofzeros(Rpos_fpt);
R_fpt= getridofzeros(R_fpt);

figure(1), 
subplot(411), plot(ECG), axis tight
title('original ECG')
subplot(412), plot(ecgd_fpt), axis tight
title('Fixed Point Differentiator output')
subplot(413), plot(ecgi_fpt), axis tight
title('Fixed Point Integrator outout')
subplot(414), plot(ecgs_fpt), axis tight
title('Fixed Point Squaring output')
hold on, scatter(Rpos_fpt, R_fpt)

