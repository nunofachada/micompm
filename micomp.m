function c = micomp(nout, ccat, ve, varargin)
%MICOMP Summary of this function goes here
% do_plot - plot stuff? Can be a cell of output titles
% ccat - provide a concatened output?
% nout - Number of outputs or plot titles (account for concat. output)
%  len - Length of outputs
%   ve - variance explained
% varargin - each variable argument is a cell of sets of folder + files,
% constituting a comparison
% Returns t, the table of comparisons or whatever, and fids, the figure
% ids (if do_plot == 1).
%
% Copyright (c) 2016 Nuno Fachada
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
for i=1:ncomp
    
    [outputs{i}, groups{i}] = grpoutputs(ccat, varargin{i}{:});

end;

% Compare outputs

% Table with statistical results: 'nout' outputs, 4 statistical tests, 
% 'ncomp' comparisons
t = zeros(nout * ncomp, 4);

% Cycle through outputs
for i = 1:nout
    
    
    % Cycle through comparisons
    for j = 1:ncomp

        % Get current output e group
        co = (outputs{j}{i})';
        cg = (groups{j})';

        % Perform model comparison
        [npcs, p_mnv, p_anv, p_kw, scores{i, j}, varexp{i, j}] = ...
            cmpoutput(ve, co, cg, 0);
        
        
        % Put values in table
        o_idx = (j - 1) * nout + i;
        t(o_idx, 1) = npcs;
        t(o_idx, 2) = p_mnv(1);
        t(o_idx, 3) = p_anv(1);
        t(o_idx, 4) = p_kw(1);
        
    end;
    
    
end;


c = struct('data', {t}, 'scores', {scores}, 'groups', {groups}, ...
    'varexp', {varexp});


end

