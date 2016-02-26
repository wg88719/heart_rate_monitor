clc, clear all, close all
load('../../data/mit-bih/101m.mat') %load data
fs=360;
ECG = val(1,:); %get input vector from loaded data
ECG = ECG(1,1:length(ECG)/4);

[Rpos R ecgd ecgi ecgs] = fixed_rivas(ECG);

%Rpos = getridofzeros(Rpos);
%R= getridofzeros(R);

figure(1), 
subplot(421), plot(ECG), axis tight
title('original ECG')
subplot(423), plot(ecgd), axis tight
title('Differentiator output')
subplot(425), plot(ecgi), axis tight
title('integrator output')
subplot(427), plot(ecgs), axis tight
title('Squaring output')
hold on, scatter(Rpos, R)


fm = fimath( 'RoundingMethod', 'Floor', 'OverflowAction', 'Wrap', 'ProductMode', 'FullPrecision', 'SumMode', 'FullPrecision' );
NB=11;
NS=15;

ECG_in = fi( ECG, 0, NB, 0, fm );

[Rpos_fpt R_fpt ecgd_fpt ecgi_fpt ecgs_fpt] = fixed_rivas_fixpt(ECG_in);

%figure(2), 
subplot(422), plot(ECG), axis tight
title('original ECG')
subplot(424), plot(ecgd_fpt), axis tight
title('Fixed Point Differentiator output')
subplot(426), plot(ecgi_fpt), axis tight
title('Fixed Point Integrator output')
subplot(428), plot(ecgs_fpt), axis tight
title('Fixed Point Squaring output')
hold on, scatter(Rpos_fpt, R_fpt)

%E_d=get_error(ecgd,double(ecgd_fpt));
%E_i=get_error(ecgi,double(ecgi_fpt));
%E_s=get_error(ecgs,double(ecgs_fpt));
%E_R=get_error(R,double(R_fpt));
%E_Rpos=get_error(Rpos,double(Rpos_fpt));
%
E_d = (ecgd - double(ecgd_fpt));
E_i = (ecgi - double(ecgi_fpt));
E_s = (ecgs - double(ecgs_fpt));
E_R = (R - double(R_fpt)); %./R;
E_Rpos = (Rpos - double(Rpos_fpt)); %./Rpos;

figure(3),
subplot(511), plot(E_d), axis tight
title('Differentiator output error')
subplot(512), plot(E_i), axis tight
title('integrator outout error')
subplot(513), plot(E_s), axis tight
title('Squaring output error')
subplot(514), plot(E_R), axis tight
title('R peak error')
subplot(515), plot(E_Rpos), axis tight
title('R peak position error')

