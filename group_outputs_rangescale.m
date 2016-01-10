% varargin should have folder+files pairs
function [outputs, groups] = group_outputs_rangescale(varargin)
%
% Copyright (c) 2016 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

% Number of experiments (files) in each set
groups = [];

% Output
outputs = [];

% Cycle through all file sets
for k=1:2:nargin

    % Get file list for current set
    listing = dir([varargin{k} '/' varargin{k+1}]);

    % How many files in set?
    numFiles = size(listing, 1);
    
    % No files? Thrown error then.
    if numFiles == 0
        error(['No files found: ' varargin{k} '/' varargin{k+1}]);
    end;
    
    % Keep number of experiments (files)
    groups = [groups (k+1)/2*ones(1, numFiles)];
    
    for i=1:numFiles

        % Current output
        co = [];
        
        % Current file
        file = [varargin{k} '/' listing(i).name];

        % Read file data
        data = dlmread(file);

        % Rangescale and concatenate data
        for j = 1:size(data, 2)
            co = [co ; rangescale(data(:, j))];
        end;
        
        outputs = [outputs co];

    end;
    
end;
