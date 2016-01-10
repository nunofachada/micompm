function [npcs, p_mnv, p_anv, p_kw, score, varexp] = ...
    cmpoutput(ve, data, groups, summary)
% ve is a value between 0 and 1 which should be the minimum variance
% explained by the PCs, required to compare models.
% data is expected to be m x n with m observations and n variables. 
% groups should indicate to which groups observations belong to.
% 
% npcs - Number of PCs used
% p_mnv - MANOVA p-values (first one is critical)
% p_anv - ANOVA p-values, one for each PC used, first ones more important
% p_kw - Kruskal-Wallis p-values, one for each PC used, first ones more
% important
%
% Copyright (c) 2016 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

% Check ve parameter
if ve < 0 || ve > 1
    error('Parameter "ve" must be a value between 0 and 1.');
end;

% Check data and groups parameters
if numel(groups) ~= size(data, 1)
    error(['Number of elements in groups vector must be the same '...
        'as the number of rows in data']);
end;

% % Set default alpha and summary
% if nargin < 4
%     alpha = 0.05;
% end;
if nargin < 4
    summary = 1;
end;

% Perform PCA
[~, score, latent] = princomp(data, 'econ');

% Variance explain by each PC
varexp = latent ./ sum(latent);

% How many PCs required to explain user-specified minimum variance
cumvar = cumsum(varexp);
npcs = find(cumvar > ve, 1);

% Perform MANOVA
[~, p_mnv] = manova1(score(:, 1:npcs), groups);
%[~ , p_mnv] = mancovan(score(:, 1:npcs), groups);

% Allocate arrays for ANOVA and KW
p_anv = zeros(npcs, 1);
p_kw = zeros(npcs, 1);

% Perform ANOVA and KW on each PC
if numel(unique(groups)) > 2
    for i=1:npcs
        p_anv(i) = anova1(score(:, i), groups, 'off');
        p_kw(i) = kruskalwallis(score(:, i), groups, 'off');
    end;
else % Only two samples, use ttest and mann-whitney instead
    
    % Find group change index
    gci = find(groups==2,1);
    
    for i=1:npcs
        [~, p_anv(i)] = ttest2(score(1:(gci-1), i), score(gci:numel(groups), i));
        p_kw(i) = ranksum(score(1:(gci-1), i), score(gci:numel(groups), i));
    end;
end;

% Present some summary statistics, if required
if summary
    fprintf('\nNumber of PCs: %d\n', npcs);
    fprintf('MANOVA 1st P-Value: %f\n', p_mnv(1));
    fprintf('ANOVA P-Value (1st PC): %5.3f\n', p_anv(1));
    fprintf('KW P-Value (1st PC): %5.3f\n\n', p_kw(1));
end;

% function str = test_str(p, alpha)
% 
% if p > alpha
%     str = 'pass test with si

