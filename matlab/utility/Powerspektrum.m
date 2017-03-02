function [Act_Powerspektrum,f_axis]=Powerspektrum(slope_t,dt,N_DFT_BINS);

% Version 1.0.0 - Gordon Pipa 28/aug/02 - pipa@mpih-frankfurt.mpg.d

%dbstop in Powerspektrum at 6
step=N_DFT_BINS;
step2=step*2;
Y = fft(slope_t,step2);
Pyy = Y.* conj(Y) / step2;
f_axis = (0:step)/(step2*dt);
Act_Powerspektrum=Pyy(1:step+1,:);