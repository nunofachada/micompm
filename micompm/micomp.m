function c = micomp(nout, ccat, ve, varargin)
% MICOMP Performs multiple independent comparisons of output observations.
%
%    c = MICOMP(nout, ccat, ve, varargin)
%
% Parameters:
%      nout - Number of outputs (including the optional concatenated
%             output).
%      ccat - Centering and scaling method for additional concatenated
%             output. Available methods include 'center', 'auto',
%             'range', 'iqrange', 'vast', 'pareto' or 'level'. If set to
%             0 or '' no additional output is added.
%        ve - Percentage (between 0 and 1) of variance explained by the q
%             principal components (i.e. number of dimensions) used in
%             MANOVA.
%  varargin - Each variable argument is a cell of folder and files pairs
%             defining a comparison.
%
% Outputs:
%         c - A struct with the following fields: 
%             data - 2D matrix with dimension (nout x ncomp) x 4, rows
%                    corresponding to outputs grouped by comparison, and 4
%                    corresponds to number of principal components, p-value
%                    of the MANOVA test, 1st p-value of the parametric test
%                    and 1st p-value of the non-parametric test (see
%                    documentation for cmpoutput for more information on
%                    these tests).
%           scores - nout x ncomp cell matrix, each element corresponding
%                    to a scores matrix returned by cmpoutput for each
%                    combination of output and comparison.
%           groups - Cell array containing, for each comparison, a vector
%                    specifying the groups to which observations belong to.
%           varexp - nout x ncomp cell matrix, each element corresponding
%                    to the percentage of variance explained by individual
%                    principal components for the respective 
%                    output/comparison pair.
%
% See also GRPOUTPUTS, CMPOUTPUT, CENTERSCALE.
%
% Copyright (c) 2016-2017 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

% Determine number of comparisons
ncomp = numel(varargin);

% Create necessary variables
outputs = cell(ncomp, 1);
groups = cell(ncomp, 1);

% Other required variables
scores = cell(nout, ncomp);
varexp = cell(nout, ncomp);

% Group data for comparisons
for i = 1:ncomp
    
    [outputs{i}, groups{i}] = grpoutputs(ccat, varargin{i}{:});

end;

% Compare outputs

% Table with statistical results: 'nout' outputs, 'ncomp' comparisons,
% 4 (1 npcs, 3 statistical tests)
t = zeros(nout * ncomp, 4);

% Cycle through outputs
for i = 1:nout
    
    % Cycle through comparisons
    for j = 1:ncomp

        % Get current output and group
        co = outputs{j}{i};
        cg = groups{j};

        % Perform model comparison
        [npcs, p_mnv, p_par, p_npar, scores{i, j}, varexp{i, j}] = ...
            cmpoutput(ve, co, cg, 0);
        
        % Put values in table
        o_idx = (j - 1) * nout + i;
        t(o_idx, 1) = npcs;
        t(o_idx, 2) = p_mnv(1);
        t(o_idx, 3) = p_par(1);
        t(o_idx, 4) = p_npar(1);
        
    end;
    
end;

% Return output struct
c = struct('data', {t}, 'scores', {scores}, 'groups', {groups}, ...
    'varexp', {varexp});

end

