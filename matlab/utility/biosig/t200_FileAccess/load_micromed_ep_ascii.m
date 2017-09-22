function HDR = load_Micromed_EP_ascii(filename)
%	load_Micromed_EP_ascii_export loads 
%
% HDR = load_Micromed_EP_ascii_export(filename)
%

%	$Id: sopen.m,v 1.241 2009/01/20 14:36:18 schloegl Exp $
%	(C) 2009 by Alois Schloegl <a.schloegl@ieee.org>	
%    	This is part of the BIOSIG-toolbox http://biosig.sf.net/
%
%    BioSig is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    BioSig is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with BioSig.  If not, see <http://www.gnu.org/licenses/>.

d = [];
fid = fopen(filename,'r');
K = 0; 
while (~feof(fid))
	K = K+1;
	line  = fgetl(fid);
	line  = [line,repmat(' ',1,mod(25-length(line),25))];
	for L = 1:ceil(length(line)/25),
		dat{K,L}=line(L*25+[-24:0]);
	end; 
	
end;
 
fclose(fid);
[p,f,e]=fileparts(filename);
if (length(f)>7)
	HDR.Patient.ID = f(7:8);
end;	
HDR.ID.Recording = f(4:6);
HDR.Patient.Condition = lower(dat{3,2});
HDR.Patient.Name = [dat{1,2},' ',dat{1,1}];
HDR.Patient.Birthday = 	datevec(datenum(dat{1,3},'dd.mm.yyyy'));
HDR.dat = dat;
HDR.Label = cellstr(num2str([1:8]'));
HDR.EP = [];

SW = 0;
ep = repmat(NaN,4,2);
for k = 1:K,
	if (k>size(dat,1)) || isempty(dat{k,1}),
		SW = k; 
	end; 
	if ((SW==0) && (k>2))
		for k1 = 3:4;
			t = dat{k,k1};
			if ((t(1)=='N') && ~isempty(strfind(t,'ms')))
				t(t==',')='.';
				f1  = deblank(t(1:3));
				ix1 = strfind(t,' - ');
				ix2 = strfind(t,'ms -');
				ix3 = strfind(t,'V');

				f2 = t(ix1(1)+3:ix2(1)-1);			
				f3 = t(ix1(2)+3:ix3(end)-2);
				if     strcmpi(f1,'N20') k2 = 1; 
				elseif strcmpi(f1,'N20') k2 = 1; 
				elseif strcmpi(f1,'N13') k2 = 2; 
				elseif strcmpi(f1,'N11') k2 = 3; 
				elseif strcmpi(f1,'N7')  k2 = 4; 
				elseif strcmpi(f1,'P25') k2 = 5; 
				end; 
				ep(k2,1) = str2double(f2);
				ep(k2,2) = str2double(f3);
				HDR.EP   = setfield(HDR.EP,[f1,lower(dat{3,2}(1:2))],ep(k2,:));
			end;
		end;
	elseif 1
		;
	elseif (SW && (k>SW) && (k<size(dat,1))) 	
		for L = 1:8;
			tmp = dat{k,L};
			tmp(tmp==',')='.';
			[s,v,t]=str2double(tmp);
			d(k-SW,L)=s;
		end; 	
	end; 
end;
HDR.data = d; 
HDR.EP = setfield(HDR.EP,lower(dat{3,2}(1:2)),ep);
HDR.EP.f = ep(:)';

