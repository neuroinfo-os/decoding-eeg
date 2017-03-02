function MatSigC = cleanAC(MatSig, F_LINE, Fs)
% MatSigC = cleanAC(MatSig, F_LINE, Fs)
% cleanAC  eliminates the AC artifact out of a recorded matrix of signals.
% works better when sampling rate 'Fs' and AC freq. 'F_LINE' are multiples.
% 
% inputs:
%			MatSig: a matrix containing the signal to be filtered
% 			F_LINE: The AC frequency in Hz ej: 50
%			Fs: The sampling frequency in Hz ej: 3012
%
% the output is the filtered matrix of signals
%
%    Ej:  MatSigC =  cleanAC(MatSig, 50, 3012);
%
% Algorithm: (by A.Boidron 1999)
% Computes the 'evoked potential' of the AC signal and substract it from the
% original signal. This means that only the periodic part of the designed 
% frequency 'F_LINE' is eliminated.
%
% E.Rodriguez 2003

% Number of points by AC cycle 			
cycle = fix(Fs/F_LINE); 

flag = 0; %initiating indicator of transposition 
[pts, nsigs]=size(MatSig);

% If MatSig is not correctly oriented (cols being signals), transpose
if nsigs > pts
    MatSig = MatSig';
    [pts, nsigs]=size(MatSig);
    flag = 1;
end

% Maximal number of integer cycles given 'pts' signal points 
nc = floor(pts/cycle);
% Number of points in 'nc' cycles
ptc = nc*cycle;
% Matrix of evoked potential of ONE CYCLE of the cyclic signal
Mat1C=squeeze(sum(reshape(MatSig(1:ptc,:), cycle, nc, nsigs),2))./nc;
% Matrix of AC signal, same size as MatSig  
MatAC = [repmat(Mat1C, nc, 1); Mat1C(1:pts-ptc,:)];
% Substracting AC signal from MatSig.
MatSigC =  MatSig - MatAC;

% If MatSig was transposed. Transpose again to original format
if flag == 1
    MatSigC = MatSigC';
end