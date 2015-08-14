function ipctb_spm_mip(Z,XYZ,M)
% SPM maximum intensity projection
% FORMAT spm_mip(Z,XYZ,M);
% Z       - vector point list of SPM values for MIP
% XYZ     - matrix of coordinates of points (Talairach coordinates)
% M       - voxels - > mm matrix or size of voxels (mm)
%_______________________________________________________________________
%
% If the data are 2 dimensional [DIM(3) = 1] the projection is simply an
% image, otherwise:
%
% spm_mip creates and displays a maximum intensity projection of a point
% list of voxel values (Z) and their location (XYZ) in three orthogonal
% views of the brain.  It is assumed voxel locations conform to the space
% defined in the atlas of Talairach and Tournoux (1988); unless the third
% dimnesion is time.
%
% This routine loads a mip putline from MIP.mat. This is an image with
% contours and grids defining the space of Talairach & Tournoux (1988).
% mip05 corresponds to the Talairach atlas, mip96 to the MNI templates.
% The outline and grid are superimposed at intensity defaults.grid,
% defaulting to 0.4.
%
% A default colormap of 64 levels is assumed. The pointlist image is
% scaled to fit in the interval [0.25,1]*64 for display. Flat images
% are scaled to 1*64.
%
% If M or DIM are not specified, it is assumed the XYZ locations are
% in Talairach mm.
%
%__________________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Karl Friston et al.
% $Id: spm_mip.m 652 2006-10-17 16:51:32Z karl $

%-Get GRID value
%--------------------------------------------------------------------------
global defaults
try, GRID  = defaults.grid;  catch, GRID  = 0.4;              end
try, units = defaults.units; catch, units = {'mm' 'mm' 'mm'}; end

% transpose locations if necessary
%--------------------------------------------------------------------------
if size(XYZ,1) ~= 3, XYZ = XYZ';         end
if size(Z,1)   ~= 1, Z   = Z';           end
if size(M,1)   == 1, M   = speye(4,4)*M; end

%-Scale & offset point list values to fit in [0.25,1]
%==========================================================================
Z   = Z - min(Z);
m   = max(Z);
if isempty(m),
    Z = [];
elseif isfinite(m),
    Z = (1 + 3*Z/m)/4;
else
    Z = ones(1,length(Z));
end

%-Display format
%==========================================================================
load('MIP.mat');

%-Single slice case
%--------------------------------------------------------------------------
if isempty(units{3})

    %-3d case; Load mip and create maximum intensity projection
    %----------------------------------------------------------------------
    mip = 4*grid_trans + mask_trans;
        
elseif units{3} == '%'
    
    %-3d case: Space-time
    %----------------------------------------------------------------------
    mip = 4*grid_time + mask_trans;

else
    %-3d case: Space
    %----------------------------------------------------------------------
    mip = 4*grid_all + mask_all;
end

%-3d case; Load mip and create maximum intensity projection
%----------------------------------------------------------------------
mip  = mip/max(mip(:));
c    = [0 0 0 ;
        0 0 1 ;
        0 1 0 ;
        0 1 1 ;
        1 0 0 ;
        1 0 1 ; 
        1 1 0 ; 
        1 1 1 ] - 0.5;
c    = c*M(1:3,1:3);
dim  = [(max(c) - min(c)) size(mip)];
d    = ipctb_spm_project(Z,round(XYZ),dim);
mip  = max(d,mip);
image(rot90((1 - mip)*64)); axis tight; axis off;

