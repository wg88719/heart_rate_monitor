%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                          %
%           Generated by MATLAB 8.4 and Fixed-Point Designer 4.3           %
%                                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [RpeakPos,Rpeak,ECG_d,ECG_i,ECG_s] = fixed_rivas_wrapper_fixpt(ECG)
    fm = fimath( 'RoundingMethod', 'Floor', 'OverflowAction', 'Wrap', 'ProductMode', 'FullPrecision', 'SumMode', 'FullPrecision' );
    ECG_in = fi( ECG, 0, 12, 0, fm );
    [RpeakPos_out,Rpeak_out,ECG_d_out,ECG_i_out,ECG_s_out] = fixed_rivas_fixpt( ECG_in );
    RpeakPos = double( RpeakPos_out );
    Rpeak = double( Rpeak_out );
    ECG_d = double( ECG_d_out );
    ECG_i = double( ECG_i_out );
    ECG_s = double( ECG_s_out );
end
