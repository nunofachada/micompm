function [outputs, groups] = grpoutputs(ccat, varargin)
% GRPOUTPUTS Group outputs from multiple observations of the models to
% be compared.
%
%   [outputs, groups] = GRPOUTPUTS(ccat, folder1, files1, folder2, files2)
%
% Parameters:
%        ccat - If true add an additional output which corresponds to the
%               concatenation of all outputs, properly range scaled.
%    varargin - Pairs of folder and files containing simulation output to
%               open in folder.
%
% Outputs:
%   outputs - Cell array containing grouped outputs. Each cell is
%             associated to one output, and contains a m x n matrix, where
%             m corresponds to the number of iterations and n to the number
%             of observations.
%    groups - Vector indicating to which group individual observations
%             belong to.
%
% Copyright (c) 2016 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

% Number of replications (files) in each set
groups = [];

% Get number of outputs and number of iterations
[n_outputs, n_iters] = get_data_dims(varargin{1}, varargin{2});

% Add an extra concatenated output?
oxtra = ccat > 0;

% Cycle through all file sets
for k = 1:2:numel(varargin)

    % Get file list for current set
    listing = dir([varargin{k} '/' varargin{k + 1}]);

    % How many files in set?
    num_files = size(listing, 1);
    
    % No files? Thrown error then.
    if num_files == 0
        error(['No files found: ' varargin{k} '/' varargin{k + 1}]);
    end;
    
    % Keep number of replications (files)
    groups = [groups ((k + 1) / 2 * ones(1, num_files))];
    
    % Initialize temporary variable for this file set
    set_outputs = cell(n_outputs + oxtra, 1);
    for i = 1:n_outputs
        set_outputs{i} = zeros(n_iters, num_files);
    end;
    
    % Initialize temporary array for extra concatenated output?
    if ccat
        set_outputs{n_outputs + 1} = zeros(n_iters * n_outputs, num_files);
    end;

    % Cycle through files in current folder
    for i = 1:num_files

        % Current file
        file = [varargin{k} '/' listing(i).name];

        % Read file data
        data = dlmread(file);

        % Put each output of current file...
        for j = 1:n_outputs
            
            % ...in a temporary variable for the current folder
            set_outputs{j}(:, i) = data(:, j);
            
            % Optionally also put partial concatenated output in a
            % temporary variable
            if ccat
                idx1 = ((j - 1) * n_iters + 1);
                idx2 = (j * n_iters);
                set_outputs{n_outputs + 1}(idx1:idx2, i) =  ...
                    rangescale(data(:, j));
                
            end;

        end;
       
    end;
    
    % Merge outputs gathered from current folder with global outputs var
    if k == 1
        outputs = set_outputs;
    else
        for i=1:(n_outputs + oxtra)
            outputs{i} = [outputs{i} set_outputs{i}];
        end;
    end;

end;

end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% Helper function to get number of outputs and number of iterations %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
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

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% Helper function to range scale outputs %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
function v_scaled = rangescale(v)

v_scaled = (v - mean(v)) / (max(v) - min(v));

end