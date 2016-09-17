function migRF = ezfkmig(RF,fs,pitch)
 
%EZFKMIG   f-k migration for plane wave imaging (easy version)
%   MIGRF = EZFKMIG(RFMAT,FS,PITCH) performs a f-k migration of the RF
%   signals stored in the 2-D array RFMAT. MIGRF contains the migrated
%   signals. FS and PITCH represent the sampling frequency (in Hz) and the
%   pitch (in m) that were used to acquire the RF signals.
%
%   The RF signals in RFMAT must have been acquired using a PLANE WAVE
%   configuration with a linear array. Each column corresponds to a single
%   RF signal over time acquired by a single transducer element.
%
%   IMPORTANT NOTE:
%   --------------
%   EZFKMIG is a simplified and non-optimized version of FKMIG. The code
%   has been simplified for academic purposes. It only works with
%   horizontal plane waves generated by a linear array, without delay in
%   reception. The number of options with EZFKMIG is also limited. Use
%   FKMIG for a more general application.
%
%   Reference
%   --------- 
%   Garcia et al., Stolt's f-k migration for plane wave ultrasound imaging.
%   IEEE Trans Ultrason Ferroelectr Freq Control, 2013;60:1853-1867.
%   <a
%   href="matlab:web('http://www.biomecardio.com/pageshtm/publi/ieeeuffc13.pdf')">Paper here</a>
%
%   See also FKMIG
%   
%   -- Damien Garcia -- 2013
%   website: <a
%   href="matlab:web('http://www.biomecardio.com')">www.BiomeCardio.com</a>
 
[nt0,nx0] = size(RF);
 
% Zero-padding
nt = 2^(nextpow2(nt0)+1);
nx = 2*nx0;
 
% Exploding Reflector Model velocity
c = 1540; % propagation velocity (m/s) 
ERMv = c/sqrt(2);
 
% FFT
fftRF = fftshift(fft2(RF,nt,nx));
 
% Linear interpolation
f = (-nt/2:nt/2-1)*fs/nt;
kx = (-nx/2:nx/2-1)/pitch/nx;
[kx,f] = meshgrid(kx,f);
fkz = ERMv*sign(f).*sqrt(kx.^2+f.^2/ERMv^2);
fftRF = interp2(kx,f,fftRF,kx,fkz,'linear',0);
 
% Jacobian (optional)
kz = (-nt/2:nt/2-1)'/ERMv/fs/nt;
fftRF = bsxfun(@times,fftRF,kz)./(fkz+eps);
 
% IFFT & Migrated RF
migRF = ifft2(ifftshift(fftRF),'symmetric');
migRF = migRF(1:nt0,1:nx0);

