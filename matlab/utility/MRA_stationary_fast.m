function RESULTS=MRA_stationary_fast(LFP,wavename,samp_freq)

rand('twister',sum(100*clock));

delta=1/samp_freq;
[Nx,Ny]=size(LFP);

% zero pad

M=log2(Nx);
M=ceil(M);

%LFP_zp=zeros(2^M,Ny);
%LFP_zp(1:Nx,:)=LFP;

Nx_zp=2^M;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DEFINE THE SCALES AND ASSOCIATED FREQUENCIES

% get the maximum scale
maxscale=wmaxlev(Nx,wavename);

% get the scales
a = 2.^(1:maxscale);

% Compute associated pseudo-frequencies.
freqs = scal2frq(a,wavename,delta);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Nx_wc=size(wave_coeff,1);  % number of wavelet coefficients

% wave_coeff is a matrix of wavelet coefficients for each trial

% L is an index vector denoting which coefficients in wave coeff correspond
% to which scale


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DO SELECTIVE RESONSTRUCTION TO GET THE DIFFERENT SCALES

scales=zeros(Nx,Ny,maxscale+1);
%scales_randomized=zeros(Nx,Ny,maxscale+1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make the filters

robscales=zeros(Nx_zp,maxscale+1);
rob=zeros(Nx_zp,1);
offset=round(Nx/2);
rob(offset)=1;
 

% do the stationary decomposition
    
    wavecoef=swt(rob,maxscale,wavename);
    
    [N1,N2]=size(wavecoef);
    
    for s=1:maxscale+1;  % loop over scales
        
        % make coeff for each scale
        
        WC_use=zeros(N1,N2);
        WC_use(s,:)=wavecoef(s,:);
        
        % do the selective reconstruction

        RC_scale=iswt(WC_use,'db4');
        robscales(:,s)=RC_scale;
        
    end;
    
    robscales=robscales(1:Nx,:);
    robscales=flip(robscales,1);

    RESULTS.MRA_filters=robscales;
    
    
  LFPlarge=zeros(Nx+offset,Ny);
  LFPlarge(1:Nx,:)=LFP;
    
  for s=1:maxscale+1;
      
      divterm=2^(maxscale+1-s);
      if divterm==1; divterm=2; end;
    
  
      filtbracket1=offset-round(Nx/divterm)+1;
      filtbracket2=offset+round(Nx/divterm);
         
      robfilt=robscales(filtbracket1:filtbracket2,s);
      
      %LFPfilt=filter(robscales(:,s),1,LFPlarge);
      LFPfilt=filter(robfilt,1,LFPlarge);
     
      offset2=offset-filtbracket1+1;
      
      scales(:,:,s)=LFPfilt(offset2+1:offset2+Nx,:);
    
  end;
  
  
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% Now do the filtering of each trial   
    
%for t=1:Ny;  % loop over trials
            
%for s=1:maxscale+1;  % loop over scales

%    mrafilter=robscales(
    
%        scales(r,t,s)=LFP(:,t)'*robscaleuse(:,s);
     
%    end;

%    end;
    
%end;



scales=flip(scales,3);
%scales_randomized=flipdim(scales_randomized,3);
freqs=flip(freqs',1);


RESULTS.original=LFP;
RESULTS.scales=scales;
RESULTS.freqs=freqs;
%RESULTS.scales_randomized=scales_randomized;
        
        
        
        
        
        
        
        
        
        
        
        