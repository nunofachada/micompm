% Run this script before using micompm.
%
% Copyright (c) 2016-2017 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

% Add paths containing source code
addpath([pwd() filesep '3rdparty']);
addpath([pwd() filesep 'helpers']);
addpath([pwd() filesep 'micompm']);

% Global variables
global micompm_version;

% micompm version
micompm_version = '1.0.0-dev';

% Check if statistics toolbox/package is present
if is_octave()
    check = pkg('list', 'statistics');
    if isempty(check)
        error('micompm requires Octave ''statistics'' package.');
    else
        pkg('load', 'statistics');
    end;
else
    check = license('test', 'Statistics_toolbox');
    if ~check
        error('Micompm requires MATLAB ''Statistics'' toolbox.');
    end;
end;

% If no error, present welcome message
fprintf('\n * Micompm v%s loaded\n\n', micompm_version);

