function [RpeakPos Rpeak ECG_d ECG_i ECG_s] = fixed_rivas(ECG)
%function [RpeakPos Rpeak ] = fixed_rivas(ECG)
%ECG has to be long 21600 = 1 minute of recordings
%initaliazing
len=21600;
Nd=7;
ECG_d=zeros(1,len-Nd+1);
ECG_i=zeros(1,len-Nd+1);
ECG_s=zeros(1,len-Nd+1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%DIFFERENTIATOR
%difference equation: y(n)= x[n] -x[n-Nd]
%Nd = 7; %round(3*fs/128) -1;
bd = [1 zeros(1,Nd-1) -1];
zd = zeros(length(bd),1);
[ECG_d1 zd1] = fir(bd,ECG(1:Nd),zd); %get initial conditions accounting for delay
ECG_d = fir(bd,ECG(Nd:len),zd1);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%MOVING WINDOW INTEGRATOR
%%% Moving average y[n] =  1/(N-1) \Sigma_{k=0}^{N-1} x[n-k]
N = Nd + 1; %window of the moving average
%b = (1/(N-1))*ones(1,N);; %this is the one on the paper but I think it's wrong
bi = (1/N)*ones(1,N);;
zi = zeros(length(bi),1);
ECG_i = fir(bi,ECG_d,zi);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%SQUARING
ECG_s = ECG_i.*ECG_i;
%
%%end of preprocessing stage
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PEAK Detection stage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x=ECG;
y = ECG_s; %output of the preprocessing stage
%RRmin = 200e-3*fs;
RRmin = 72;
QRSint=21.6; %60e-3*fs;
%Pth= 0.7*fs/128 + 4.7;
K=0.98164; %6214845220;

i = 1; %signal index
r = 1; %R peaks and positions index
th=0; %threshold
count = 0;
%Rpeak = zeros(1,len);
%RpeakPos = Rpeak;
while (i < len-Nd+1)
        %State 1
        count = 0;
        peak = y(i);
        peakPos = i;
        while (count <= RRmin + QRSint)
                if(y(i) > peak)
                        peak = y(i);
                        peakPos = i;
                end
                count = count + 1;
                i = i + 1;
                if(i >= len-Nd+1) %to avoid going out of bounds
                        break;
                end
        end
        Rpeak(r) = peak;
        RpeakPos(r) = peakPos;
        count = i - RpeakPos(r) - 1; %to compensate
        r = r + 1;

        %State 2
        while (count <= RRmin)
                count = count + 1;
        end
        th = mean(Rpeak);

        %State 3
        while(y(i) <= th)
                i = i + 1;
                if(i >= len-Nd+1) %to avoid going out of bounds
                        break;
                end
                th = th * K;
        end
end
end
