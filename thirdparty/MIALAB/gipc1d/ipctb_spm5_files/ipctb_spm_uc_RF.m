function [u] = ipctb_spm_uc_RF(a,df,STAT,R,n)
% corrected critical height threshold at a specified significance level
% FORMAT [u] = spm_uc_RF(a,df,STAT,R,n)
% a     - critical probability - {alpha}
% df    - [df{interest} df{residuals}]
% STAT  - Statisical feild
%		'Z' - Gaussian feild
%		'T' - T - feild
%		'X' - Chi squared feild
%		'F' - F - feild
% R     - RESEL Count {defining search volume}
% n     - number of conjoint SPMs
%
% u     - critical height {corrected}
%
%___________________________________________________________________________
%
% spm_uc returns the corrected critical threshold at a specified significance
% level (a). If n > 1 a conjunction the probability over the n values of the 
% statistic is returned.
%___________________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Karl Friston
% $Id: spm_uc_RF.m 112 2005-05-04 18:20:52Z john $


% find approximate value
%---------------------------------------------------------------------------
u     = ipctb_spm_u((a/sum(R))^(1/n),df,STAT);
du    = 1e-6;

% approximate estimate using E{m}
%---------------------------------------------------------------------------
d     = 1;
while abs(d) > 1e-6
	[P P p] = ipctb_spm_P_RF(1,0,u,df,STAT,R,n);
	[P P q] = ipctb_spm_P_RF(1,0,u + du,df,STAT,R,n);
        d       = (a - p)/((q - p)/du);
        u       = u + d;
end

% refined estimate using 1 - exp(-E{m})
%---------------------------------------------------------------------------
d     = 1;
while abs(d) > 1e-6
        p       = ipctb_spm_P_RF(1,0,u,df,STAT,R,n);
	q       = ipctb_spm_P_RF(1,0,u + du,df,STAT,R,n);
        d       = (a - p)/((q - p)/du);
        u       = u + d;
end
