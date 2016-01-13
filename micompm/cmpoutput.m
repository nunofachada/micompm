function [npcs, p_mnv, p_par, p_npar, score, varexp] = ...
    cmpoutput(ve, data, groups, summary)
% CMPOUTPUT Compares one output from several runs of two or more model
% implementations.
%
%    [npcs, p_mnv, p_anv, p_kw, score, varexp] = ...
%       CMPOUTPUT(ve, data, groups, summary)
%
% Parameters:
%        ve - Percentage (between 0 and 1) of variance explained by the q
%             principal components (i.e. number of dimensions) used in
%             MANOVA.
%      data - An n x m matrix, where n is the total number of output
%             observations (runs) and m is the number of variables (i.e.
%             output length).
%    groups - Vector of integers specifying the group to which individual
%             observations are associated with.
%   summary - Optional argument, which if given, will indicate the function
%             to print a comparison summary.
%
% Outputs:
%      npcs - Number of principal components which explain ve percentage of
%             variance.
%     p_mnv - P-values for the MANOVA test for npcs principal components.
%     p_anv - Vector of p-values for the parametric test applied to groups
%             along each principal component (t-test for 2 groups, ANOVA
%             for more than 2 groups).
%      p_kw - Vector of p-values for the non-parametric test applied to
%             groups along each principal component (Mann-Whitney U test
%             for 2 groups, Kruskal-Wallis test for more than 2 groups).
%     score - n x (n - 1) matrix containing projections of simulation
%             output data in the principal components space. Rows
%             correspond to observations, columns to principal components.
%    varexp - Percentage of variance explained by each principal component.
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

% Print summary?
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
%[~, p_mnv] = manova1(score(:, 1:npcs), groups);
[~ , p_mnv] = mancovan(score(:, 1:npcs), groups);

% Allocate arrays for ANOVA and KW
p_par = zeros(npcs, 1);
p_npar = zeros(npcs, 1);

% Perform ANOVA and KW on each PC
if numel(unique(groups)) > 2
    
    for i = 1:npcs
        p_par(i) = anova1(score(:, i), groups, 'off');
        p_npar(i) = kruskalwallis(score(:, i), groups, 'off');
    end;
    
else % Only two samples, use ttest and mann-whitney instead
    
    % Find group change index
    gci = find(groups == 2,1);
    
    for i = 1:npcs
        [~, p_par(i)] = ttest2(score(1:(gci - 1), i), ...
            score(gci:numel(groups), i));
        p_npar(i) = ranksum(score(1:(gci - 1), i), ...
            score(gci:numel(groups), i));
    end;
end;

% Present some summary statistics, if required
if summary
    fprintf('\nNumber of PCs: %d\n', npcs);
    fprintf('MANOVA 1st P-Value: %f\n', p_mnv(1));
    fprintf('ANOVA/t-test P-Value (1st PC): %5.3f\n', p_par(1));
    fprintf('KW/MW P-Value (1st PC): %5.3f\n\n', p_npar(1));
end;


