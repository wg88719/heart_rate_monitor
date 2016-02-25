clc, clear all, close all
load('../../data/mit-bih/101m.mat') %load data
fs=360;
ECG = val(1,:); %get input vector from loaded data

[Rpos R ecgd ecgi ecgs] = fixed_rivas(ECG);

%Rpos = getridofzeros(Rpos);
%R= getridofzeros(R);

figure(1), 
subplot(411), plot(ECG), axis tight
title('original ECG')
subplot(412), plot(ecgd), axis tight
title('Differentiator output')
subplot(413), plot(ecgi), axis tight
title('integrator outout')
subplot(414), plot(ecgs), axis tight
title('Squaring output')
hold on, scatter(Rpos, R)


[Rpos_fpt R_fpt ecgd_fpt ecgi_fpt ecgs_fpt] = fixed_rivas_fixpt(ECG);

Rpos_fpt = getridofzeros(Rpos_fpt);
R_fpt= getridofzeros(R_fpt);

figure(2), 
subplot(411), plot(ECG), axis tight
title('original ECG')
subplot(412), plot(ecgd_fpt), axis tight
title('Differentiator output')
subplot(413), plot(ecgi_fpt.double), axis tight
title('integrator outou')
subplot(414), plot(ecgs_fpt.double), axis tight
title('Squaring output')
hold on, scatter(Rpos_fpt, R_fpt)

E_d = (ecgd - ecgd_fpt)./ecgd;
E_i = (ecgi - ecgi_fpt.double)./ecgi;
E_s = (ecgs - ecgs_fpt.double)./ecgs;
%E_R = (R - double(R_fpt))./R;
%E_Rpos = (Rpos - double(Rpos_fpt))./Rpos;

figure(3),
subplot(311), plot(E_d), axis tight
title('Differentiator output error')
subplot(312), plot(E_i), axis tight
title('integrator outout error')
subplot(313), plot(E_s), axis tight
title('Squaring output error')
%subplot(514), plot(E_R), axis tight
%title('R peak error')
%subplot(515), plot(E_Rpos), axis tight
%title('R peak position error')

