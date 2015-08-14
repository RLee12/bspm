function V = ipctb_spm_write_vol(V,Y)
% Write an image volume to disk, setting scales and offsets as appropriate
% FORMAT V = spm_write_vol(V,Y)
% V (input)  - a structure containing image volume information (see spm_vol)
% Y          - a one, two or three dimensional matrix containing the image voxels
% V (output) - data structure after modification for writing.
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% John Ashburner
% $Id: spm_write_vol.m 800 2007-04-27 07:35:27Z volkmar $

use_offset = false;

if ndims(Y)>3, error('Can only handle a maximum of 3 dimensions.'), end

if ~isfield(V,'pinfo'), V.pinfo = [1,0,0]'; end

dim = [size(Y) 1 1 1];
if ~all(dim(1:3) == V.dim(1:3)) || (size(V.pinfo,2)~=1 && size(V.pinfo,2)~=dim(3)),
	error('Incompatible dimensions.');
end


% Set scalefactors and offsets
%-----------------------------------------------------------------------
dt           = V.dt(1);
s            = find(dt == [2 4 8 256 512 768]);
dmnmx        = [0 -2^15 -2^31 -2^7 0 0 ; 2^8-1 2^15-1 2^31-1 2^7-1 2^16-1 2^32-1];
dmnmx        = dmnmx(:,s);

V.pinfo(1,:) = 1;
V.pinfo(2,:) = 0;
mxs          = zeros(dim(3),1)+NaN;
mns          = zeros(dim(3),1)+NaN;
if ~isempty(s),
	for p=1:dim(3),
		tmp    = double(Y(:,:,p));
		tmp    = tmp(isfinite(tmp));
		if ~isempty(tmp),
			mxs(p) = max(tmp);
			mns(p) = min(tmp);
		end;
	end;

	if size(V.pinfo,2) ~= 1,
		for p=1:dim(3),
			mx = mxs(p);
			mn = mns(p);
			if ~isfinite(mx), mx = 0; end;
			if ~isfinite(mn), mn = 0; end;
			if mx~=mn,
				if use_offset,
					V.pinfo(1,p) = (mx-mn)/(dmnmx(2)-dmnmx(1));
					V.pinfo(2,p) = ...
						(dmnmx(2)*mn-dmnmx(1)*mx)/(dmnmx(2)-dmnmx(1));
				else
					if dmnmx(1)<0,
						V.pinfo(1,p) = max(mx/dmnmx(2),mn/dmnmx(1));
					else
						V.pinfo(1,p) = mx/dmnmx(2);
					end;
					V.pinfo(2,p) = 0;
				end;
			else
				V.pinfo(1,p) = 0;
				V.pinfo(2,p) = mx;
			end;
		end;
	else
		mx = max(mxs(isfinite(mxs)));
		mn = min(mns(isfinite(mns)));
		if isempty(mx), mx = 0; end;
		if isempty(mn), mn = 0; end;
		if mx~=mn,
			if use_offset,
				V.pinfo(1,1) = (mx-mn)/(dmnmx(2)-dmnmx(1));
				V.pinfo(2,1) = (dmnmx(2)*mn-dmnmx(1)*mx)/(dmnmx(2)-dmnmx(1));
			else
				if dmnmx(1)<0,
					V.pinfo(1) = max(mx/dmnmx(2),mn/dmnmx(1));
				else
					V.pinfo(1) = mx/dmnmx(2);
				end;
				V.pinfo(2) = 0;
			end;
		else
			V.pinfo(1,1) = 0;
			V.pinfo(2,1) = mx;
		end;
	end;
end;

%-Create and write image
%-----------------------------------------------------------------------
V = ipctb_spm_create_vol(V);
V = ipctb_spm_write_plane(V,Y,':');
