function [fwhm,VRpv] = ipctb_spm_est_smoothness(varargin)
% Estimation of smoothness based on [residual] images
% FORMAT [fwhm,VRpv] = spm_est_smoothness(VResI,[VM]);
%
% P     - filenames of [residual] images
% PM    - filename of mask image
%
% fwhm  - estimated FWHM in all image directions
% VRpv  - handle of Resels per Voxel image
%_______________________________________________________________________
%  
% spm_est_smoothness returns a spatial smoothness estimator based on the
% variances of the normalized spatial derivatives as described in K.
% Worsley, (1996). Inputs are a mask image and a number of [residual]
% images. Output is a global estimate of the smoothness expressed as the
% FWHM of an equivalent Gaussian point spread function. An estimate of
% resels per voxels (see spm_spm) is written as an image file ('RPV.img')
% to the current directory.
%
% The mask image specifies voxels, used in smoothness estimation, by
% assigning them non-zero values. The dimensions, voxel sizes, orientation 
% of all images must be the same. The dimensions of the images can be of
% dimensions 0, 1, 2 and 3.
% 
% Note that 1-dim images (lines) must exist in the 1st dimension and
% 2-dim images (slices) in the first two dimensions. The estimated fwhm
% for any non-existing dimension is infinity.
%
% 
% Ref:
% 
% K. Worsley (1996). An unbiased estimator for the roughness of a
% multivariate Gaussian random field. Technical Report, Department of
% Mathematics and Statistics, McGill University
%
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Stefan Kiebel
% $Id: spm_est_smoothness.m 112 2005-05-04 18:20:52Z john $


% assign input argumants
%-----------------------------------------------------------------------
if nargin > 0, V  = varargin{1}; end
if nargin > 1, VM = varargin{2}; end
if nargin > 2
	ipctb_spm('alert!', 'ipctb_spm_est_smoothness: Wrong number of arguments');
	return;
end
if nargin < 1
	V   = ipctb_spm_select(inf, '^ResI.*\.img$', 'Select residual images');
end
if nargin < 2
	VM  = ipctb_spm_select(1, 'mask.img', 'Select mask image');
end

% intialise
%-----------------------------------------------------------------------
if ~isstruct(VM)
	V     = ipctb_spm_vol(V);
end
if ~isstruct(VM)
	VM    = ipctb_spm_vol(VM);
end

%-Intialise RESELS per voxel image
%-----------------------------------------------------------------------
VRpv  = struct('fname','RPV.img',...
			'dim',		VM.dim(1:3),...
			'dt',		[ipctb_spm_type('float64') ipctb_spm_platform('bigend')],...
			'mat',		VM.mat,...
			'pinfo',	[1 0 0]',...
			'descrip',	'ipctb_spm_spm: resels per voxel');
VRpv  = ipctb_spm_create_vol(VRpv);


% dimensionality of image
%-----------------------------------------------------------------------
N     = 3 - sum(VM.dim(1:3) == 1);
if N == 0
	fwhm = [Inf Inf Inf];
	return
end

% find voxels within mask
%-----------------------------------------------------------------------
[x,y] = ndgrid(1:VM.dim(1), 1:VM.dim(2));
I     = []; Ix = []; Iy = []; Iz = [];
for i = 1:VM.dim(3)
	z  = i*ones(size(x));
	d  = ipctb_spm_sample_vol(VM, x, y, z, 0);
	I  = find(d);
	Ix = [Ix; x(I)];
	Iy = [Iy; y(I)];
	Iz = [Iz; z(I)];
end

% compute variance of normalized derivatives in all directions
%-----------------------------------------------------------------------
str   = 'Spatial non-sphericity (over scans)';
fprintf('%-40s: %30s',str,'...estimating derivatives')      %-#
ipctb_spm_progress_bar('Init',100,'smoothness estimation','');

v     = zeros(size(Ix,1),N);
ssq   = zeros(size(Ix,1),1);
for i = 1:length(V) % for all residual images
	
	[d, dx, dy, dz] = ipctb_spm_sample_vol(V(i), Ix, Iy, Iz, 1);
	
	if N >= 1. v(:, 1) = v(:, 1) + dx.^2;  end
	if N >= 2. v(:, 2) = v(:, 2) + dy.^2;  end
	if N >= 3, v(:, 3) = v(:, 3) + dz.^2;  end

	ssq  = ssq + d.^2;

	ipctb_spm_progress_bar('Set',100*i/length(V));

end
ipctb_spm_progress_bar('Clear')

% normalise derivatives
%-----------------------------------------------------------------------
for i = 1:N
	v(:,i)     = v(:,i)./ssq;
end

% eliminate zero variance voxels
%-----------------------------------------------------------------------
I      = find(any(isnan(v')));
v(I,:) = []; Ix(I) = []; Iy(I) = []; Iz(I) = [];


% resels per voxel (resel) 
% resels = resels/voxel = 1/prod(FWHM)
% FWHM   = sqrt(4.ln2/|dv/dx|))
% fwhm   = 1/FWHM
%-----------------------------------------------------------------------
fprintf('\r%-40s: %30s\n',str,'...writing resels/voxel image')  %-#

fwhm   = sqrt(v./(4*log(2)));
resel  = prod(fwhm,2);
for  i = 1:VM.dim(3)
	d  = NaN*ones(VM.dim(1:2));
	I  = find(Iz == i);
	if ~isempty(I)
		d(sub2ind(VM.dim(1:2), Ix(I), Iy(I))) = resel(I);
	end
	VRpv = ipctb_spm_write_plane(VRpv, d, i);
end

% global equivalent FWHM {prod(1/FWHM) = (unbiased) RESEL estimator}
%-----------------------------------------------------------------------
fwhm   = mean(fwhm );
RESEL  = mean(resel);
fwhm   = fwhm*((RESEL/prod(fwhm)).^(1/N));
FWHM   = 1./fwhm;
fwhm   = [Inf Inf Inf];
fwhm(1:length(FWHM)) = FWHM;




