% varargin should have folder+files pairs
function [outputs, groups] = group_outputs(varargin)
%
% Copyright (c) 2016 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

% Number of experiments (files) in each set
groups = [];

% Get number of outputs and number of iterations
[n_outputs, n_iters] = get_data_dims(varargin{1}, varargin{2});

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
    
    % Initialize temporary variable for this file set
    setOutputs = cell(n_outputs, 1);
    for i = 1:n_outputs
        setOutputs{i} = zeros(n_iters, numFiles);
    end;

    for i=1:numFiles

        % Current file
        file = [varargin{k} '/' listing(i).name];

        % Read file data
        data = dlmread(file);

        % Organize data
        for j = 1:n_outputs
            setOutputs{j}(:,i) = data(:, j);
        end;

    end;
    
    % Merge with global outputs var
    if k==1
        outputs = setOutputs;
    else
        for i=1:n_outputs
            outputs{i} = [outputs{i} setOutputs{i}];
        end;
    end;

end;

end

% Get number of outputs and number of iterations
function [n_outputs, n_iters] = get_data_dims(folder, files)

    % Get file list
    listing = dir([folder '/' files]);
    
    % No files? Thrown error then.
    if size(listing, 1) == 0
        error(['No files found: ' folder '/' files]);
    end;

    % Open first file
    data = dlmread([folder '/' listing(1).name]);

    % Determine number of outputs and iterations
    [n_iters, n_outputs] = size(data);
    
end
