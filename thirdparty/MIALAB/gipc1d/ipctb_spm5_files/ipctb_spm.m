function varargout=ipctb_spm(varargin)
% SPM: Statistical Parametric Mapping (startup function)
%_______________________________________________________________________
%  ___  ____  __  __
% / __)(  _ \(  \/  )  
% \__ \ )___/ )    (   Statistical Parametric Mapping
% (___/(__)  (_/\/\_)  SPM - http://www.fil.ion.ucl.ac.uk/spm/
%_______________________________________________________________________
%
% SPM (Statistical Parametric Mapping) is a package for the analysis
% functional brain mapping experiments. It is the in-house package of
% the Wellcome Department of Cognitive Neurology, and is available to
% the scientific community as copyright freeware under the terms of the
% GNU General Public Licence.
% 
% Theoretical, computational and other details of the package are
% available in SPM's "Help" facility. This can be launched from the
% main SPM Menu window using the "Help" button, or directly from the
% command line using the command `spm_help`.
%
% Details of this release are availiable via the "About SPM" help topic
% (file spm.man), accessible from the SPM splash screen.  (Or type
% `spm_help spm.man` in the MatLab command window)
% 
% This spm function initialises the default parameters, and displays a
% splash screen with buttons leading to the PET(SPECT) & fMRI
% modalities Alternatively, `spm('pet')` and `spm('fmri')`
% (equivalently `spm pet` and `spm mri`) lead directly to the respective
% modality interfaces.
%
% Once the modality is chosen, (and it can be toggled mid-session) the
% SPM user interface is displayed. This provides a constant visual
% environment in which data analysis is implemented. The layout has
% been designed to be simple and at the same time show all the
% facilities that are available. The interface consists of three
% windows: A menu window with pushbuttons for the SPM routines (each
% button has a 'CallBack' string which launches the appropriate
% function/script); A blank panel used for interaction with the user;
% And a graphics figure with various editing and print facilities (see
% spm_figure.m). (These windows are 'Tag'ged 'Menu', 'Interactive', and
% 'Graphics' respectively, and should be referred to by their tags
% rather than their figure numbers.)
%
% Further interaction with the user is (mainly) via questioning in the
% 'Interactive' window (managed by spm_input), and file selection
% (managed by ipctb_spm_select). See the help on spm_input.m and ipctb_spm_select.m for
% details on using these functions.
%
% If a "message of the day" file named spm_motd.man exists in the SPM
% directory (alongside spm.m) then it is displayed in the Graphics
% window on startup.
%
% Arguments to this routine (spm.m) lead to various setup facilities,
% mainly of use to SPM power users and programmers. See programmers
% FORMAT & help in the main body of spm.m
%
%_______________________________________________________________________
% SPM is developed by members and collaborators of the
% Wellcome Department of Imaging Neuroscience

%-SVN ID and authorship of this program...
%-----------------------------------------------------------------------
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Andrew Holmes
% $Id: spm.m 816 2007-05-24 19:14:01Z karl $


%=======================================================================
% - FORMAT specifications for embedded CallBack functions
%=======================================================================
%( This is a multi function function, the first argument is an action  )
%( string, specifying the particular action function to take. Recall   )
%( MatLab's command-function duality: `spm Welcome` is equivalent to   )
%( `spm('Welcome')`.                                                   )
%
% FORMAT spm
% Defaults to spm('Welcome')
%
% FORMAT spm('Welcome')
% Clears command window, deletes all figures, prints welcome banner and
% splash screen, sets window defaults.
%
% FORMAT spm('AsciiWelcome')
% Prints ASCII welcome banner in MatLab command window.
%
% FORMAT spm('PET') spm('FMRI')
% Closes all windows and draws new Menu, Interactive, and Graphics
% windows for an SPM session. The buttons in the Menu window launch the
% main analysis routines.
%
% FORMAT Fmenu = spm('CreateMenuWin',Vis)
% Creates SPM menu window, 'Tag'ged 'Menu'
% F   - handle of figure created
% Vis - Visibility, 'on' or 'off'
%
% Finter = FORMAT spm('CreateIntWin',Vis)
% Creates an SPM Interactive window, 'Tag'ged 'Interactive'
% F   - handle of figure created
% Vis - Visibility, 'on' or 'off'
%
% FORMAT spm('ChMod',Modality)
% Changes modality of SPM: Currently SPM supports PET & MRI modalities,
% each of which have a slightly different Menu window and different
% defaults. This function switches to the specified modality, setting
% defaults and displaying the relevant buttons.
%
% FORMAT spm('defaults',Modality)
% Sets default global variables for the specified modality.
%
% FORMAT [Modality,ModNum]=spm('CheckModality',Modality)
% Checks the specified modality against those supported, returns
% upper(Modality) and the Modality number, it's position in the list of
% supported Modalities.
%
% FORMAT WS=spm('WinScale')
% Returns ratios of current display dimensions to that of a 1152 x 900
% Sun display. WS=[Xratio,Yratio,Xratio,Yratio]. Used for scaling other
% GUI elements.
% (Function duplicated in spm_figure.m, repeated to reduce inter-dependencies.)
%
% FORMAT [FS,sf] = spm('FontSize',FS)
% FORMAT [FS,sf] = spm('FontSizes',FS)
% Returns fontsizes FS scaled for the current display.
% FORMAT sf = spm('FontScale')
% Returns font scaling factor
% FS     - (vector of) Font sizes to scale [default [1:36]]
% sf     - font scaling factor (FS(out) = floor(FS(in)*sf)
%
% Rect = spm('WinSize',Win,raw)
% Returns sizes and positions for SPM windows.
% Win  - 'Menu', 'Interactive', 'Graphics', or '0'
%      -  Window whose position is required. Only first character is
%         examined. '0' returns size of root workspace.
% raw  - If specified, then positions are for a 1152 x 900 Sun display.
%        Otherwise the positions are scaled for the current display.
%
% FORMAT SPMdir=spm('Dir',Mfile)
% Returns the directory containing the version of spm in use,
% identified as the first in MATLABPATH containing the Mfile spm (this
% file) (or Mfile if specified).
%
% FORMAT [v,c]=spm('Ver',Mfile,ReDo,Cache,Con)
% Returns the current version (v) & copyright notice, extracted from
% the top line of the Contents.m file in the directory containing the
% currently used file Mfile (defaults on omission or empty to 'spm').
%
%-The version and copyright information are saved in a global
% variable called [upper(ipctb_spm_str_manip(Mfile,'rt')),'_VER'], as a
% structure with fields 'v' and 'c'. This enables repeat use without
% recomputation.
%
%-If Con [default (missing or empty) 1] is false, then the version
% information is extracted from Mfile itself, rather than the
% Contents.m file in the same directory. When using a Contents.m file,
% the first line is read. For other files, the second line (the H1 help
% line) is used. This is for consistency with MatLab's ver and help
% commands respectively. (This functionality enables toolboxes to be
% identified by a function rather than a Contents.m file, allowing
% installation in a directory which already has a Contents.m file.)
%
%-If Cache [default (missing or empty) 1] is true, then the version and
% copyright information cached in the global variable
% [upper(Mfile),'_VER'], as a structure with fields 'v' and 'c'. This
% enables repeat use without recomputation.
%
%-If ReDo [default (missing or empty) 0] is true, then the version and
% copyright information are recomputed (regardless of any stored global
% data).
%
% FORMAT xTB = spm('TBs')
% Identifies installed SPM toolboxes: SPM toolboxes are defined as the
% contents of sub-directories of fullfile(spm('Dir'),'toolbox') - the
% SPM toolbox installation directory. For SPM to pick a toolbox up,
% there must be a single mfile in the directory whose name ends with
% the toolbox directory name. (I.e. A toolbox called "test" would be in
% the "test" subdirectory of spm('Dir'), with a single file named
% *test.m.) This M-file is regarded as the launch file for the
% toolbox.
% xTB      - structure array containing toolbox definitions
% xTB.name - name of toolbox (taken as toolbox directory name)
% xTB.prog - launch program for toolbox
% xTB.dir  - toolbox directory
%
% FORMAT spm('TBlaunch',xTB,i)
% Launch a toolbox, prepending TBdir to path if necessary
% xTB      - toolbox definition structure (i.e. from spm('TBs')
% xTB.name - name of toolbox
% xTB.prog - name of program to launch toolbox
% xTB.dir  - toolbox directory (prepended to path if not on path)
%
% FORMAT [c,cName] = spm('Colour')
% Returns the RGB triple and a description for the current en-vogue SPM
% colour, the background colour for the Menu and Help windows.
%
% FORMAT [v1,v2,...] = spm('GetGlobal',name1,name2,...)
% Returns values of global variables (without declaring them global)
% name1, name2,... - name strings of desired globals
% a1, a2,...       - corresponding values of global variables with given names
%                    ([] is returned as value if global variable doesn't exist)
%
% FORMAT CmdLine = spm('CmdLine',CmdLine)
% Command line SPM usage?
% CmdLine (input)  - CmdLine preference
%                    [defaults (missing or empty) to global defaults.cmdline,]
%                    [if it exists, or 0 (GUI) otherwise.                    ]
% CmdLine (output) - true if global CmdLine if true,
%                    or if on a terminal with no support for graphics windows.
%
% FORMAT v = spm('MLver')
% Returns MatLab version, truncated to major & minor revision numbers
%
% FORMAT spm('SetCmdWinLabel',WinStripe,IconLabel)
% Sets the names on the headers and icons of Sun command tools.
% WinStripe defaults to a summary line identifying the user, host and
% MatLab version; IconLabel to 'MatLab'.
%
% FORMAT spm('PopUpCB',h)
% Callback handler for PopUp UI menus with multiple callbacks as cellstr UserData
%
% FORMAT str = spm('GetUser',fmt)
% Returns current users login name, extracted from the hosting environment
% fmt   - format string: If USER is defined then sprintf(fmt,USER) is returned
%
% FORMAT spm('Beep')
% plays the keyboard beep!
%
% FORMAT spm('time')
% Returns the current time and date as hh:mm dd/mm/yyyy
%
% FORMAT spm('Pointer',Pointer)
% Changes pointer on all SPM (HandleVisible) windows to type Pointer
% Pointer defaults to 'Arrow'. Robust to absence of windows
%
% FORMAT h = spm('alert',Message,Title,CmdLine,wait)
% FORMAT h = spm('alert"',Message,Title,CmdLine,wait)
% FORMAT h = spm('alert*',Message,Title,CmdLine,wait)
% FORMAT h = spm('alert!',Message,Title,CmdLine,wait)
% Displays an alert, either in a GUI msgbox, or as text in the command window.
%  ( 'alert"' uses the 'help' msgbox icon, 'alert*' the )
%  ( 'error' icon, 'alert!' the 'warn' icon             )
% Message - string (or cellstr) containing message to print
% Title   - title string for alert
% CmdLine - CmdLine preference [default spm('CmdLine')]
%         - If CmdLine is complex, then a CmdLine alert is always used,
%           possibly in addition to a msgbox (the latter according
%           to spm('CmdLine').)
% wait    - if true, waits until user dismisses GUI / confirms text alert
%           [default 0] (if doing both GUI & text, waits on GUI alert)
% h       - handle of msgbox created, empty if CmdLine used
%
% FORMAT SPMid = spm('FnBanner', Fn,FnV)
% Prints a function start banner, for version FnV of function Fn, & datestamps
% FORMAT SPMid = spm('SFnBanner',Fn,FnV)
% Prints a sub-function start banner
% FORMAT SPMid = spm('SSFnBanner',Fn,FnV)
% Prints a sub-sub-function start banner
% Fn    - Function name (string)
% FnV   - Function version (string)
% SPMid - ID string: [SPMver: Fn (FnV)] 
%
% FORMAT [Finter,Fgraph,CmdLine] = spm('FnUIsetup',Iname,bGX,CmdLine)
% Robust UIsetup procedure for functions:
%   Returns handles of 'Interactive' and 'Graphics' figures.
%   Creates 'Interactive' figure if ~CmdLine, creates 'Graphics' figure if bGX.
% Iname   - Name for 'Interactive' window
% bGX     - Need a Graphics window? [default 1]
% CmdLine - CommandLine usage? [default spm('CmdLine')]
% Finter  - handle of 'Interactive' figure
% Fgraph  - handle of 'Graphics' figure
% CmdLine - CommandLine usage?
%
% FORMAT F = spm('FigName',Iname,F,CmdLine)
% Set name of figure F to "SPMver (User): Iname" if ~CmdLine
% Robust to absence of figure.
% Iname      - Name for figure
% F (input)  - Handle (or 'Tag') of figure to name [default 'Interactive']
% CmdLine    - CommandLine usage? [default spm('CmdLine')]
% F (output) - Handle of figure named
%
% FORMAT spm('GUI_FileDelete')
% CallBack for GUI for file deletion, using ipctb_spm_select and confirmation dialogs
%
% FORMAT Fs = spm('Show')
% Opens all SPM figure windows (with HandleVisibility) using `figure`.
%   Maintains current figure.
% Fs - vector containing all HandleVisible figures (i.e. get(0,'Children'))
%
% FORMAT spm('Clear',Finter, Fgraph)
% Clears and resets SPM-GUI, clears and timestamps MatLab command window
% Finter  - handle or 'Tag' of 'Interactive' figure [default 'Interactive']
% Fgraph  - handle or 'Tag' of 'Graphics' figure [default 'Graphics']
%
% FORMAT spm('Help',varargin)
% Merely a gateway to spm_help(varargin) - so you can type "spm help"
% 
%_______________________________________________________________________


%-Parameters
%-----------------------------------------------------------------------
Modalities = {'PET','FMRI','EEG'};

%-Format arguments
%-----------------------------------------------------------------------
if nargin == 0, Action='Welcome'; else, Action = varargin{1}; end


%=======================================================================
switch lower(Action), case 'welcome'             %-Welcome splash screen
%=======================================================================

ipctb_spm_defaults;
global defaults
if isfield(defaults,'modality'), ipctb_spm(defaults.modality); return; end;

%-Open startup window, set window defaults
%-----------------------------------------------------------------------
try
    feature('JavaFigures',0);
end
openfig('spm_Welcome');


%=======================================================================
case 'asciiwelcome'                           %-ASCII SPM banner welcome
%=======================================================================
disp( ' ___  ____  __  __                                            ');
disp( '/ __)(  _ \(  \/  )                                           ');
disp( '\__ \ )___/ )    (   Statistical Parametric Mapping           ');
disp(['(___/(__)  (_/\/\_)  ',ipctb_spm('Ver'),' - http://www.fil.ion.ucl.ac.uk/spm/']);
fprintf('\n');


%=======================================================================
case lower(Modalities)            %-Initialise SPM in PET, fMRI modality
%=======================================================================
% spm(Modality)

%-Initialisation and workspace canonicalisation
%-----------------------------------------------------------------------
local_clc, ipctb_spm('SetCmdWinLabel')
ipctb_spm('AsciiWelcome');                    fprintf('\n\nInitialising SPM');
Modality = upper(Action);                                  fprintf('.');
delete(get(0,'Children'));                                 fprintf('.');

%-Draw SPM windows
%-----------------------------------------------------------------------
Fmenu  = ipctb_spm('CreateMenuWin','off');fprintf('.');
Finter = ipctb_spm('CreateIntWin','off');	                       fprintf('.');
Fgraph = spm_figure('Create','Graphics','Graphics','off'); fprintf('.');
   
spm_figure('WaterMark',Finter,ipctb_spm('Ver'),'',45);           fprintf('.');

Fmotd  = fullfile(ipctb_spm('Dir'),'spm_motd.man');
if exist(Fmotd), spm_help('!Disp',Fmotd,'',Fgraph,ipctb_spm('Ver')); end
                                                           fprintf('.');

%-Load startup global defaults
%-----------------------------------------------------------------------
ipctb_spm_defaults;                                              fprintf('.');

%-Setup for current modality
%-----------------------------------------------------------------------
ipctb_spm('ChMod',Modality);                                     fprintf('.');

%-Reveal windows
%-----------------------------------------------------------------------
set([Fmenu,Finter,Fgraph],'Visible','on');          fprintf('done\n\n');

%-Print present working directory
%-----------------------------------------------------------------------
fprintf('SPM present working directory:\n\t%s\n',pwd)


%=======================================================================
case 'createmenuwin'                              %-Draw SPM menu window
%=======================================================================
% Fmenu = ipctb_spm('CreateMenuWin',Vis)

%-Close any existing 'Menu' 'Tag'ged windows
%-----------------------------------------------------------------------
delete(ipctb_spm_figure('FindWin','Menu'))
Fmenu     = openfig('ipctb_spm_Menu');

%-Set spm colour
%-----------------------------------------------------------------------
set(findobj(Fmenu,'Tag', 'frame'),'backgroundColor',ipctb_spm('colour'));

%-Set toolbox
%-----------------------------------------------------------------------
xTB       = ipctb_spm('tbs');
set(findobj(Fmenu,'Tag', 'Toolbox'),'String',{'Toolbox:' xTB.name });
set(findobj(Fmenu,'Tag', 'Toolbox'),'UserData',xTB);
varargout = {Fmenu};
return

%=======================================================================
case 'createintwin'                      %-Create SPM interactive window
%=======================================================================
% Finter = ipctb_spm('CreateIntWin',Vis)
%-----------------------------------------------------------------------
delete(ipctb_spm_figure('FindWin','Interactive'))
Finter    = openfig('ipctb_spm_Interactive');
varargout = {Finter};
return


%=======================================================================
case 'chmod'                            %-Change SPM modality PET<->fMRI
%=======================================================================
% ipctb_spm('ChMod',Modality)
%-----------------------------------------------------------------------

%-Sort out arguments
%-----------------------------------------------------------------------
if nargin<2, Modality = ''; else, Modality = varargin{2}; end
[Modality,ModNum] = ipctb_spm('CheckModality',Modality);

%-Sort out global defaults
%-----------------------------------------------------------------------
ipctb_spm('defaults',Modality);

%-Sort out visability of appropriate controls on Menu window
%-----------------------------------------------------------------------
Fmenu = ipctb_spm_figure('FindWin','Menu');
if isempty(Fmenu), error('SPM Menu window not found'), end

if strcmpi(Modality,'PET')
	set(findobj(Fmenu, 'Tag', 'FMRI'),    'Visible', 'off');
	set(findobj(Fmenu, 'Tag', 'EEG'),     'Visible', 'off');
	set(findobj(Fmenu, 'Tag', 'PETFMRI'), 'Visible', 'on' );
	set(findobj(Fmenu, 'Tag', 'PET'),     'Visible', 'on' );
elseif strcmpi(Modality,'FMRI')
	set(findobj(Fmenu, 'Tag', 'EEG'),     'Visible', 'off');
	set(findobj(Fmenu, 'Tag', 'PET'),     'Visible', 'off');
	set(findobj(Fmenu, 'Tag', 'PETFMRI'), 'Visible', 'on' );
	set(findobj(Fmenu, 'Tag', 'FMRI'),    'Visible', 'on' );
else
	set(findobj(Fmenu, 'Tag', 'PETFMRI'), 'Visible', 'off');
	set(findobj(Fmenu, 'Tag', 'PET'),     'Visible', 'off');
	set(findobj(Fmenu, 'Tag', 'FMRI'),    'Visible', 'off');
	set(findobj(Fmenu, 'Tag', 'EEG'),     'Visible', 'on' );
end
set(findobj(Fmenu,'Tag','Modality'),'Value',ModNum,'UserData',ModNum);
ipctb_spm_jobman('chmod',Modality);

%=======================================================================
case 'defaults'                 %-Set SPM defaults (as global variables)
%=======================================================================
% ipctb_spm('defaults',Modality)
%-----------------------------------------------------------------------
global defaults
if isempty(defaults), ipctb_spm_defaults; end;

%-Sort out arguments
%-----------------------------------------------------------------------
if nargin<2, Modality=''; else, Modality=varargin{2}; end
Modality          = ipctb_spm('CheckModality',Modality);
defaults.modality = Modality;
defaults.SWD      = ipctb_spm('Dir');              % SPM directory
defaults.TWD      = ipctb_spm_platform('tempdir'); % Temp directory
	
%-Set Modality specific default (global variables)
%-----------------------------------------------------------------------
global UFp
if strcmpi(defaults.modality,'pet')
	UFp	= defaults.stats.pet.ufp;		% Upper tail F-prob
elseif strcmpi(defaults.modality,'fmri')
	UFp	= defaults.stats.fmri.ufp;		% Upper tail F-prob
elseif strcmpi(defaults.modality,'eeg')
    ;
elseif strcmpi(defaults.modality,'unknown')
else
	error('Illegal Modality');
end


%=======================================================================
case 'quit'                                      %-Quit SPM and clean up
%=======================================================================
% ipctb_spm('Quit')
%-----------------------------------------------------------------------
delete(get(0,'Children'));
local_clc;
fprintf('Bye for now...\n\n');


%=======================================================================
case 'checkmodality'              %-Check & canonicalise modality string
%=======================================================================
% [Modality,ModNum] = ipctb_spm('CheckModality',Modality)
%-----------------------------------------------------------------------
if nargin<2, Modality=''; else, Modality=upper(varargin{2}); end
if isempty(Modality)
	global defaults
	if isfield(defaults,'modality'), Modality = defaults.modality;
	else, Modality = 'UNKNOWN'; end
end
if ischar(Modality)
	ModNum = find(ismember(Modalities,Modality));
else
	if ~any(Modality == [1:length(Modalities)])
		Modality = 'ERROR';
		ModNum   = [];
	else
		ModNum   = Modality;
		Modality = Modalities{ModNum};
	end
end

if isempty(ModNum), error('Unknown Modality'), end
varargout = {upper(Modality),ModNum};


%=======================================================================
case {'winscale','getwinscale'}  %-Window scale factors (to fit display)
%=======================================================================
% WS = ipctb_spm('WinScale')
%-----------------------------------------------------------------------
if strcmp(lower(Action),'getwinscale')
	warning('ipctb_spm(''GetWinScale'' GrandFathered, use ''WinScale''')
end
% MonitorPosition doesn't work properly for ipctb
% if ipctb_spm_matlab_version_chk('7') >=0
% 	S0 = get(0, 'MonitorPosition');
% 	S0 = S0(1,:);
% else
	S0   = get(0,'ScreenSize');    
% end;
if all(S0==1), error('Can''t open any graphics windows...'), end

tmp = [S0(3)/1152 (S0(4)-50)/900 S0(3)/1152 (S0(4)-50)/900];
varargout = {min(tmp)*[1 1 1 1]};

% Make sure that aspect ratio is about right - for funny shaped screens
% varargout = {[S0(3)/1152 (S0(4)-50)/900 S0(3)/1152 (S0(4)-50)/900]};


%=======================================================================
case {'fontsize','fontsizes','fontscale'}                 %-Font scaling
%=======================================================================
% [FS,sf] = ipctb_spm('FontSize',FS)
% [FS,sf] = ipctb_spm('FontSizes',FS)
% sf = ipctb_spm('FontScale')
%-----------------------------------------------------------------------
if nargin<3, c=0; else, c=1; end
if nargin<2, FS=[1:36]; else, FS=varargin{2}; end

sf  = 1 + 0.85*(min(ipctb_spm('WinScale'))-1);

if strcmp(lower(Action),'fontscale')
	varargout = {sf};
else
	varargout = {ceil(FS*sf),sf};
end


%=======================================================================
case 'winsize'                 %-Standard SPM window locations and sizes
%=======================================================================
% Rect = ipctb_spm('WinSize',Win,raw)
%-----------------------------------------------------------------------
if nargin<3, raw=0; else, raw=1; end
if nargin<2, Win=''; else, Win=varargin{2}; end

Rect = [	[108 466 400 445];...
		[108 045 400 395];...
		[515 015 600 865] ];

WS = ipctb_spm('WinScale');

if isempty(Win)
	WS = ones(3,1)*WS;
elseif upper(Win(1))=='M'
	%-Menu window
	Rect = Rect(1,:);
elseif upper(Win(1))=='I'
	%-Interactive window
	Rect = Rect(2,:);
elseif upper(Win(1))=='G'
	%-Graphics window
	Rect = Rect(3,:);
elseif Win(1)=='0'
	%-Root workspace
if ipctb_spm_matlab_version_chk('7') >=0
		Rect = get(0, 'MonitorPosition');
		Rect = Rect(1,:);
	else
		Rect = get(0,'ScreenSize');
	end;
else
	error('Unknown Win type');
end

if ~raw, Rect = Rect.*WS; end
varargout = {Rect};


%=======================================================================
case 'dir'                           %-Identify specific (SPM) directory
%=======================================================================
% ipctb_spm('Dir',Mfile)
%-----------------------------------------------------------------------
if nargin<2, Mfile='ipctb_spm'; else, Mfile=varargin{2}; end
SPMdir = which(Mfile);
if isempty(SPMdir)			%-Not found or full pathname given
	if exist(Mfile,'file')==2	%-Full pathname
		SPMdir = Mfile;
	else
		error(['Can''t find ',Mfile,' on MATLABPATH']);
	end
end
[SPMdir,junk] = fileparts(SPMdir);

if exist('isdeployed') && isdeployed,
    ind = findstr(SPMdir,'_mcr')-1;
    [SPMdir,junk] = fileparts(SPMdir(1:ind(1)));
end;
varargout = {SPMdir};


%=======================================================================
case 'ver'                                                 %-SPM version
%=======================================================================
% SPMver = ipctb_spm('Ver',Mfile,ReDo,Cache,Con)
%-----------------------------------------------------------------------
if nargin<5, Con=[]; else, Con=varargin{5}; end
if isempty(Con), Con=1; end
if nargin<4, Cache=[]; else, Cache=varargin{4}; end
if isempty(Cache), Cache=1; end
if nargin<3, ReDo=[]; else, ReDo=varargin{3}; end
if isempty(ReDo), ReDo=0; end
if nargin<2, Mfile=''; else, Mfile=varargin{2}; end
if isempty(Mfile), Mfile='ipctb_spm'; end

xVname = [upper(ipctb_spm_str_manip(Mfile,'rt')),'_VER'];

%-See if version info exists in global variable
%-----------------------------------------------------------------------
xV = ipctb_spm('GetGlobal',xVname);
if ~ReDo & ~isempty(xV)
	if isstruct(xV) & isfield(xV,'v') & isfield(xV,'c')
		varargout = {xV.v,xV.c};
		return
	end
end

%-Work version out from file
%-----------------------------------------------------------------------
if Con
	Vfile = fullfile(ipctb_spm('Dir',Mfile),'Contents.m');
	skip = 0;	%-Don't skip first line
else
	Vfile = which(Mfile);
	if isempty(Vfile), error(['Can''t find ',Mfile,' on MATLABPATH']); end
	skip = 1;	%-Skip first line
end
if exist(Vfile)
	fid = fopen(Vfile,'r');
	str = fgets(fid);
	if skip, str=fgets(fid); end
	fclose(fid);
	str(1:max(1,min(find(str~='%' & str~=' '))-1))=[];
	tmp = min(find(str==10|str==32));
	v = str(1:tmp-1);
	if str(tmp)==32
		c = str(tmp+1:tmp+min(find(str(tmp+1:end)==10))-1);
	else
		c = '(c) Copyright reserved';
	end
else
	v = 'SPM';
	c = '(c) Copyright reserved';
end

%-Store version info in global variable
%-----------------------------------------------------------------------
if Cache
	eval(['global ',xVname])
	eval([xVname,' = struct(''v'',v,''c'',c);'])
end

varargout = {v,c};


%=======================================================================
case 'tbs'                                %-Identify installed toolboxes
%=======================================================================
% xTB = ipctb_spm('TBs')
%-----------------------------------------------------------------------

% Toolbox directory
%-----------------------------------------------------------------------
Tdir  = fullfile(ipctb_spm('Dir'),'toolbox');

%-List of potential installed toolboxes directories
%-----------------------------------------------------------------------
if exist(Tdir,'dir')
	d = dir(Tdir); 
	d = {d([d.isdir]).name};
	d = {d{cellfun('isempty',regexp(d,'^\.'))}};
else
	d = {};
end


%-Look for a "main" M-file in each potential directory
%-----------------------------------------------------------------------
xTB = [];
for i = 1:length(d)
    tdir = fullfile(Tdir,d{i});
    fn   = cellstr(ipctb_spm_select('List',tdir,['^.*' d{i} '\.m$']));

    if ~isempty(fn{1}),
        xTB(end+1).name = strrep(d{i},'_','');
        xTB(end).prog   = ipctb_spm_str_manip(fn{1},'r');
        xTB(end).dir    = tdir;
    end;

end

varargout{1} = xTB;


%=======================================================================
case 'tblaunch'                                  %-Launch an SPM toolbox
%=======================================================================
% xTB = ipctb_spm('TBlaunch',xTB,i)
%-----------------------------------------------------------------------
if nargin < 3, i   = 1;          else i   = varargin{3}; end
if nargin < 2, xTB = ipctb_spm('TBs'); else xTB = varargin{2}; end

if i > 0
	%-Addpath (& report)
	%-------------------------------------------------------------------
	if isempty(findstr(xTB(i).dir,path))
		addpath(xTB(i).dir,'-begin');
		ipctb_spm('alert"',{'Toolbox directory prepended to Matlab path:',...
			xTB(i).dir},...
			[xTB(i).name,' toolbox'],1);
	end

	%-Launch
	%-------------------------------------------------------------------
	evalin('base',xTB(i).prog);
end


%=======================================================================
case 'colour'                                     %-SPM interface colour
%=======================================================================
% ipctb_spm('Colour')
%-----------------------------------------------------------------------
%-Pre-developmental livery
% varargout = {[1.0,0.2,0.3],'fightening red'};
%-Developmental livery
% varargout = {[0.7,1.0,0.7],'flourescent green'};
%-Alpha release livery
% varargout = {[0.9,0.9,0.5],'over-ripe banana'};
%-Beta release livery
  varargout = {[0.9 0.8 0.9],'blackcurrant purple'};
%-Distribution livery
% varargout = {[0.8 0.8 1.0],'vile violet'};;

global defaults
if isempty(defaults), ipctb_spm_defaults; end;
if isfield(defaults,'ui') && isfield(defaults.ui,'colour2'),
	varargout{1} = defaults.ui.colour2;
end;

%=======================================================================
case 'getglobal'                           %-Get global variable cleanly
%=======================================================================
% varargout = ipctb_spm('GetGlobal',varargin)
%-----------------------------------------------------------------------
wg = who('global');
for i=1:nargin-1
	if any(strcmp(wg,varargin{i+1}))
		eval(['global ',varargin{i+1},', tmp=',varargin{i+1},';'])
		varargout{i} = tmp;
	else
		varargout{i} = [];
	end
end

%=======================================================================
case {'cmdline','isgcmdline'}                   %-SPM command line mode?
%=======================================================================
% CmdLine = ipctb_spm('CmdLine',CmdLine)
% isGCmdLine usage is Grandfathered
%-----------------------------------------------------------------------
if nargin<2, CmdLine=[]; else, CmdLine = varargin{2}; end
if isempty(CmdLine),
	global defaults
	if ~isempty(defaults) & isfield(defaults,'cmdline'),
		CmdLine = defaults.cmdline;
	else,
		CmdLine = 0;
	end;
end
varargout = {CmdLine * (get(0,'ScreenDepth')>0)};

%=======================================================================
case 'mlver'                       %-MatLab major & point version number
%=======================================================================
% v = ipctb_spm('MLver')
%-----------------------------------------------------------------------
v = version; tmp = find(v=='.');
if length(tmp)>1, varargout={v(1:tmp(2)-1)}; end

%=======================================================================
case 'setcmdwinlabel'      %-Set command window label (Sun OpenWin only)
%=======================================================================
% ipctb_spm('SetCmdWinLabel',WinStripe,IconLabel)
%-----------------------------------------------------------------------

%-Only label Sun command tools
%-----------------------------------------------------------------------
Term        = getenv('TERM');
if ~strcmp(Term,'sun-cmd'), return, end

%-Work out label text
%-----------------------------------------------------------------------
User        = ipctb_spm('GetUser');
[null,Host] = unix('echo `hostname` | sed -e ''s/\..*$//''');
Host        = Host(1:length(Host)-1); 
v           = ipctb_spm('MLver');

if nargin<3, IconLabel = ['MatLab',v(1)]; end
if nargin<2, WinStripe = [User,' - ',Host,' : MatLab ',v]; end

%-Set window stripe
%-----------------------------------------------------------------------
disp([']l' WinStripe '\]L' IconLabel '\'])


%=======================================================================
case 'popupcb'               %-Callback handling utility for PopUp menus
%=======================================================================
% ipctb_spm('PopUpCB',h)
%-----------------------------------------------------------------------
if nargin<2, h=gcbo; else, h=varargin{2}; end
v   = get(h,'Value');
if v==1, return, end
set(h,'Value',1)
CBs = get(h,'UserData');
evalin('base',CBs{v-1})


%=======================================================================
case 'getuser'                                           %-Get user name
%=======================================================================
% str = ipctb_spm('GetUser',fmt)
%-----------------------------------------------------------------------
str = ipctb_spm_platform('user');
if ~isempty(str) & nargin>1, str = sprintf(varargin{2},str); end
varargout = {str};


%=======================================================================
case 'beep'                                %-Emit a keyboard "bell" beep
%=======================================================================
% ipctb_spm('Beep')
fprintf('%c',7)


%=======================================================================
case 'time'                          %-Return formatted date/time string
%=======================================================================
% [timestr, date_vec] = ipctb_spm('Time')
%-----------------------------------------------------------------------
tmp = clock;
varargout = {sprintf('%02d:%02d:%02d - %02d/%02d/%4d',...
			tmp(4),tmp(5),floor(tmp(6)),tmp(3),tmp(2),tmp(1)),...
		tmp};


%=======================================================================
case 'pointer'                 %-Set mouse pointer in all MatLab windows
%=======================================================================
% ipctb_spm('Pointer',Pointer)
%-----------------------------------------------------------------------
if nargin<2, Pointer='Arrow'; else, Pointer=varargin{2}; end
set(get(0,'Children'),'Pointer',Pointer)


%=======================================================================
case {'alert','alert"','alert*','alert!'}                %-Alert dialogs
%=======================================================================
% h = ipctb_spm('alert',Message,Title,CmdLine,wait)
%-----------------------------------------------------------------------

%- Globals 
%-----------------------------------------------------------------------
if nargin<5, wait    = 0;  else, wait    = varargin{5}; end
if nargin<4, CmdLine = []; else, CmdLine = varargin{4}; end
if nargin<3, Title   = ''; else, Title   = varargin{3}; end
if nargin<2, Message = ''; else, Message = varargin{2}; end
Message = cellstr(Message);

if isreal(CmdLine)
	CmdLine  = ipctb_spm('CmdLine',CmdLine);
	CmdLine2 = 0;
else
	CmdLine  = ipctb_spm('CmdLine');
	CmdLine2 = 1;
end
timestr = ipctb_spm('Time');
SPMv    = ipctb_spm('ver');

switch(lower(Action))
case 'alert',	icon = 'none';	str = '--- ';
case 'alert"',	icon = 'help';	str = '~ - ';
case 'alert*',	icon = 'error'; str = '* - ';
case 'alert!',	icon = 'warn';	str = '! - ';
end

if CmdLine | CmdLine2
	Message(strcmp(Message,'')) = {' '};
	tmp = sprintf('%s: %s',SPMv,Title);
	fprintf('\n    %s%s  %s\n\n',str,tmp,repmat('-',1,62-length(tmp)))
	fprintf('        %s\n',Message{:})
	fprintf('\n        %s  %s\n\n',repmat('-',1,62-length(timestr)),timestr)
	h = [];
end

if ~CmdLine
	tmp = max(size(char(Message),2),42) - length(SPMv) - length(timestr);
	str = sprintf('%s  %s  %s',SPMv,repmat(' ',1,tmp-4),timestr);
	h   = msgbox([{''};Message(:);{''};{''};{str}],...
		sprintf('%s%s: %s',SPMv,ipctb_spm('GetUser',' (%s)'),Title),...
		icon,'non-modal');
	drawnow
	set(h,'windowstyle','modal');
end

if wait
	if isempty(h)
		input('        press ENTER to continue...');
	else
		uiwait(h)
		h = [];
	end
end

if nargout, varargout = {h}; end


%=======================================================================
case {'fnbanner','sfnbanner','ssfnbanner'}  %-Text banners for functions
%=======================================================================
% SPMid = ipctb_spm('FnBanner', Fn,FnV)
% SPMid = ipctb_spm('SFnBanner',Fn,FnV)
% SPMid = ipctb_spm('SSFnBanner',Fn,FnV)
%-----------------------------------------------------------------------
time = ipctb_spm('time');
str  = ipctb_spm('ver');
if nargin>=2, str = [str,': ',varargin{2}]; end
if nargin>=3, str = [str,' (v',varargin{3},')']; end

switch lower(Action)
case 'fnbanner'
	tab = '';
	wid = 72;
	lch = '=';
case 'sfnbanner'
	tab = sprintf('\t');
	wid = 72-8;
	lch = '-';
case 'ssfnbanner'
	tab = sprintf('\t\t');
	wid = 72-2*8;
	lch = '-';
end

fprintf('\n%s%s',tab,str)
fprintf('%c',repmat(' ',1,wid-length([str,time])))
fprintf('%s\n%s',time,tab)
fprintf('%c',repmat(lch,1,wid)),fprintf('\n')
varargout = {str};


%=======================================================================
case 'fnuisetup'                %-Robust UI setup for main SPM functions
%=======================================================================
% [Finter,Fgraph,CmdLine] = ipctb_spm('FnUIsetup',Iname,bGX,CmdLine)
%-----------------------------------------------------------------------
if nargin<4, CmdLine=ipctb_spm('CmdLine'); else, CmdLine=varargin{4}; end
if nargin<3, bGX=1; else, bGX=varargin{3}; end
if nargin<2, Iname=''; else, Iname=varargin{2}; end
if CmdLine
	Finter = ipctb_spm_figure('FindWin','Interactive');
	if ~isempty(Finter), ipctb_spm_figure('Clear',Finter), end
	%if ~isempty(Iname), fprintf('%s:\n',Iname), end
else
	Finter = ipctb_spm_figure('GetWin','Interactive');
	ipctb_spm_figure('Clear',Finter)
	if ~isempty(Iname)
		str = sprintf('%s (%s): %s',ipctb_spm('ver'),ipctb_spm('GetUser'),Iname);
	else
		str = '';
	end
	set(Finter,'Name',str)
end

if bGX
	Fgraph = ipctb_spm_figure('GetWin','Graphics');
	ipctb_spm_figure('Clear',Fgraph)
else
	Fgraph = ipctb_spm_figure('FindWin','Graphics');
end
varargout = {Finter,Fgraph,CmdLine};	


%=======================================================================
case 'figname'                                %-Robust SPM figure naming
%=======================================================================
% F = ipctb_spm('FigName',Iname,F,CmdLine)
%-----------------------------------------------------------------------
if nargin<4, CmdLine=ipctb_spm('CmdLine'); else, CmdLine=varargin{4}; end
if nargin<3, F='Interactive'; else, F=varargin{3}; end
if nargin<2, Iname=''; else, Iname=varargin{2}; end

%if ~isempty(Iname), fprintf('\t%s\n',Iname), end
if CmdLine, varargout={[]}; return, end
F = ipctb_spm_figure('FindWin',F);
if ~isempty(F) & ~isempty(Iname)
	set(F,'Name',sprintf('%s (%s): %s',ipctb_spm('ver'),ipctb_spm('GetUser'),Iname))
end
varargout={F};


%=======================================================================
case 'gui_filedelete'                                %-GUI file deletion
%=======================================================================
% ipctb_spm('GUI_FileDelete')
%-----------------------------------------------------------------------
P = cellstr(ipctb_spm_select(Inf,'.*','Select file(s) to delete'));
n = numel(P);
if n==0
	ipctb_spm('alert"','Nothing selected to delete!','file delete',0);
	return
elseif n<4
	str=[{' '};P];
elseif n<11
	str=[{' '};P;{' ';sprintf('(%d files)',n)}];
else
	str=[{' '};P(1:min(n,10));{'...';' ';sprintf('(%d files)',n)}];
end
if ipctb_spm_input(str,-1,'bd','delete|cancel',[1,0],[],'confirm file delete')
	ipctb_spm_unlink(P{:})
	ipctb_spm('alert"',P,'file delete',1);
end


%=======================================================================
case 'show'                   %-Bring visible MatLab windows to the fore
%=======================================================================
% Fs = ipctb_spm('Show')
%-----------------------------------------------------------------------
cF = get(0,'CurrentFigure');
Fs = get(0,'Children');
Fs = findobj(Fs,'flat','Visible','on');
for F=Fs', figure(F), end
set(0,'CurrentFigure',cF)
ipctb_spm('FnBanner','GUI show');
varargout={Fs};


%=======================================================================
case 'clear'                                             %-Clear SPM GUI
%=======================================================================
% ipctb_spm('Clear',Finter, Fgraph)
%-----------------------------------------------------------------------
if nargin<3, Fgraph='Graphics'; else, Fgraph=varargin{3}; end
if nargin<2, Finter='Interactive'; else, Finter=varargin{2}; end
ipctb_spm_figure('Clear',Fgraph)
ipctb_spm_figure('Clear',Finter)
ipctb_spm('Pointer','Arrow')
ipctb_spm_select('clearvfiles');
spm_conman('Initialise','reset');
local_clc, ipctb_spm('FnBanner','GUI cleared');
fprintf('\n');
%evalin('Base','clear')


%=======================================================================
case 'help'                                  %-Pass through for spm_help
%=======================================================================
% ipctb_spm('Help',varargin)
%-----------------------------------------------------------------------
if nargin>1, ipctb_spm_help(varargin{2:end}), else, ipctb_spm_help, end


%=======================================================================
otherwise                                        %-Unknown action string
%=======================================================================
error('Unknown action string')

%=======================================================================
end


%=======================================================================
function realign_unwarp(ob,varargin)
% Choose either realign or unwarp
%=======================================================================
if get(ob,'Value')==1,
	ipctb_spm_jobman('interactive','','jobs.spatial.realign');
else
	ipctb_spm_jobman('interactive','','jobs.spatial.realignunwarp');
end


%=======================================================================
function local_clc
%=======================================================================
if ~(exist('isdeployed') && isdeployed),
    clc
end

