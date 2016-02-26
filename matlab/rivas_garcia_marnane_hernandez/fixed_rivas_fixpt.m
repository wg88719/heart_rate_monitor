%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                          %
%           Generated by MATLAB 8.4 and Fixed-Point Designer 4.3           %
%                                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%#codegen
function [RpeakPos,Rpeak,ECG_d,ECG_i,ECG_s] = fixed_rivas_fixpt(ECG)
NB=11;
NS=15;

fm = fimath('RoundingMethod', 'Floor', 'OverflowAction', 'Wrap', 'ProductMode', 'FullPrecision', 'SumMode', 'FullPrecision');
%function [RpeakPos Rpeak ] = fixed_rivas(ECG)
%ECG has to be long 21600 = 1 minute of recordings
%initaliazing
len = fi(21600/4, 0, NS, 0, fm);
Nd = fi(7, 0, 3, 0, fm);
ECG_d = fi(zeros( 1, fi_toint(fi_signed(len) - Nd + fi(1, 0, 1, 0, fm)) ), 1, NB+1, 0, fm);
ECG_i = fi(zeros( 1, fi_toint(fi_signed(len) - Nd + fi(1, 0, 1, 0, fm)) ), 1, NB+1, 0, fm);
%ECG_s = fi(zeros( 1, fi_toint(fi_signed(len) - Nd + fi(1, 0, 1, 0, fm)) ), 0, 16, -7, fm);
ECG_s = fi(zeros( 1, fi_toint(fi_signed(len) - Nd + fi(1, 0, 1, 0, fm)) ), 0, 2*(NB+1), 0, fm);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%DIFFERENTIATOR
%difference equation: y(n)= x[n] -x[n-Nd]
%Nd = 7; %round(3*fs/128) -1;
bd = fi([ 1, zeros( 1, fi_toint(fi_signed(Nd) - fi(1, 0, 1, 0, fm)) ), -1 ], 1, 2, 0, fm);
zd = fi(zeros( length( bd ), 1 ), 0, 1, 0, fm);
[fmo_1,fmo_2] = fir_s1( bd, ECG( fi(1, 0, 1, 0, fm):Nd ), zd );
ECG_d1 = fi(fmo_1, 0, NB, 0, fm);
zd1 = fi(fmo_2, 0, NB, 0, fm);
%get initial conditions accounting for delay
ECG_d(:) = fir_s2( bd, ECG( Nd:len ), zd1 );
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%MOVING WINDOW INTEGRATOR
%%% Moving average y[n] =  1/(N-1) \Sigma_{k=0}^{N-1} x[n-k]
N = fi(Nd + fi(1, 0, 1, 0, fm), 0, 4, 0, fm);  %window of the moving average
%b = (1/(N-1))*ones(1,N);; %this is the one on the paper but I think it's wrong
bi = fi((fi_div(fi(1, 0, 1, 0, fm), N))*fi(ones( 1, fi_toint(N) ), 0, 1, 0, fm), 0, 16, 18, fm);
zi = fi(zeros( length( bi ), 1 ), 0, 1, 0, fm);
ECG_i(:) = fir_s2( bi, ECG_d, zi );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%SQUARING
ECG_s(:) = ECG_i .* ECG_i;
%
%%end of preprocessing stage
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PEAK Detection stage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = fi(ECG, 0, NB+1, 0, fm);
y = fi(ECG_s, 0, 2*(NB+1), 0, fm);  %output of the preprocessing stage
%RRmin = 200e-3*fs;
RRmin = fi(72, 0, 7, 0, fm);
QRSint = fi(21.6, 0, 16, 11, fm);  %60e-3*fs;
%Pth= 0.7*fs/128 + 4.7;
K = fi(0.98164, 0, 16, 16, fm);  %6214845220;
i = fi(1, 0, NS, 0, fm);  %signal index
r = fi(1, 0, NS, 0, fm);  %R peaks and positions index
th = fi(0, 0, 2*(NB+1), 0, fm);  %threshold
count = fi(0, 0, NS-5, 0, fm);
%Rpeak = fi(zeros( 1, fi_toint(len) ), 0, 16, 0, fm);
%RpeakPos = fi((len-Nd+1)*ones( 1, fi_toint(len) ), 0, 15, 0, fm);
%peakPos = fi(RpeakPos(1), 0, 15, 0, fm);

%Start FSM
while (i<fi_signed(len) - Nd + fi(1, 0, 1, 0, fm))
    %State 1
    count(:) = 0;
    peak = fi(y( i ), 0, 2*(NB+1), 0, fm);
    peakPos = fi(i, 0, NS, 0, fm);
    while (count<=RRmin + QRSint)
        if (y( i )>peak)
            peak(:) = y( i );
            peakPos(:) = i;
        end
        count(:) = count + fi(1, 0, 1, 0, fm);
        i(:) = i + fi(1, 0, 1, 0, fm);
        if (i>=fi_signed(len) - Nd + fi(1, 0, 1, 0, fm))  %to avoid going out of bounds
            break
        end
    end
    Rpeak( r ) = peak;
    RpeakPos( r ) = peakPos;
    count(:) = i - RpeakPos( r ) - fi(1, 0, 1, 0, fm);  %to compensate
    r(:) = r + fi(1, 0, 1, 0, fm);
    %State 2
    while (count<=RRmin)
        count(:) = count + fi(1, 0, 1, 0, fm);
    end
    th(:) = mean( Rpeak );
    %State 3
    while (y( i )<=th)
        i(:) = i + fi(1, 0, 1, 0, fm);
        if (i>=fi_signed(len) - Nd + fi(1, 0, 1, 0, fm))  %to avoid going out of bounds
            break
        end
        th(:) = th*K;
    end
end
end
function [y,z] = fir_s1(b,x,z_1)
NB=11;
NS=15;

fm = fimath('RoundingMethod', 'Floor', 'OverflowAction', 'Wrap', 'ProductMode', 'FullPrecision', 'SumMode', 'FullPrecision');

z = fi(z_1, 1, NB+1, 0, fm);

y = fi(zeros( size( x ) ), 1, NB+1, 0, fm);
for n = 1:length( x )
    z = fi([ fi(x( n ), 0, NB, 0, fm); z( 1:end - 1 ) ], 1, NB+1, 0, fm);
    y( n ) = b*z;
end
end
function [y,z] = fir_s2(b,x,z_1)
NB=11;
NS=15;

fm = fimath('RoundingMethod', 'Floor', 'OverflowAction', 'Wrap', 'ProductMode', 'FullPrecision', 'SumMode', 'FullPrecision');

z = fi(z_1, 1, NB+1, 0, fm);

y = fi(zeros( size( x ) ), 1, NB+1, 0, fm);
for n = 1:length( x )
    z = fi([ fi(x( n ), 1, NB+1, 0, fm); z( 1:end - 1 ) ], 1, NB+1, 0, fm);
    y( n ) = b*z;
end
end


function c = fi_div(a,b)
coder.inline( 'always' );
if isfi( a ) && isfi( b ) && isscalar( b )
    a1 = fi( a, 'RoundMode', 'fix' );
    b1 = fi( b, 'RoundMode', 'fix' );
    c1 = divide( divideType( a1, b1 ), a1, b1 );
    c = fi( c1, numerictype( c1 ), fimath( a ) );
else
    c = a/b;
end
end


function ntype = divideType(a,b)
coder.inline( 'always' );
nt1 = numerictype( a );
nt2 = numerictype( b );
maxFL = max( [ min( nt1.WordLength, nt1.FractionLength ), min( nt2.WordLength, nt2.FractionLength ) ] );
FL = max( maxFL, 24 );
extraBits = (FL - maxFL);
WL = nt1.WordLength + nt2.WordLength;
WL = min( WL, 124 );
if (WL + extraBits)<64
    ntype = numerictype( nt1.Signed || nt2.Signed, WL + extraBits, FL );
else
    ntype = numerictype( nt1.Signed || nt2.Signed, WL, FL );
end
end


function y = fi_signed(a)
coder.inline( 'always' );
if isfi( a ) && ~(issigned( a ))
    nt = numerictype( a );
    new_nt = numerictype( 1, nt.WordLength + 1, nt.FractionLength );
    y = fi( a, new_nt, fimath( a ) );
else
    y = a;
end
end


function y = fi_toint(u)
coder.inline( 'always' );
if isfi( u )
    nt = numerictype( u );
    s = nt.SignednessBool;
    wl = nt.WordLength;
    y = int32( fi( u, s, wl, 0, hdlfimath ) );
else
    y = int32( u );
end
end
