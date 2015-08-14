%
% FORMAT spm_defaults
%_______________________________________________________________________
%
% This file is intended to be customised for the site.
% Individual users can make copies which can be stored in their own
% matlab subdirectories. If ~/matlab is ahead of the SnPM directory
% in the MATLABPATH, then the users own personal defaults are used.
%
% Care must be taken when modifying this file
%_______________________________________________________________________
% Copyright (C) 2013 The University of Warwick
% Id: snpm_defaults.m  SnPM13 2013/10/12
% Thomas Nichols

global SnPMdefs

% Spatial extent threshold parameters
%------------------------------------------------------------------------
SnPMdefs.STalpha = 0.01; % T values above this sig are save for ST analysis
SnPMdefs.STprop  = 0.10; % 100*(1-STprop)%ile of observed Psuedo T values saved
SnPMdefs.ST_U    = 2.03; % Default cluster-forming threshold set pre-analysis

% Work in "high memory" mode?
%------------------------------------------------------------------------
SnPMdefs.bVolm = 1; % Default to volumetric if less than this many scans

% When to work volumetrically?
%------------------------------------------------------------------------
SnPMdefs.nMax4DefVol = 16; % Default to volumetric if less than this many scans

% Variance smoothing?
%------------------------------------------------------------------------
SnPMdefs.vFWHM = [0 0 0 ]; 

% Default number of permutations
%------------------------------------------------------------------------
SnPMdefs.nPerm = 5000; % Default to volumetric if less than this many scans

% Statistics
%------------------------------------------------------------------------
SnPMdefs.FWElevel = 0.05;  % Default FWE level
SnPMdefs.FDRlevel = 0.05;  % Default FDR level

% Covariate option
%------------------------------------------------------------------------
SnPMdefs.CovVals = { 
    '1'
    '0'
    };

