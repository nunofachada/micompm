function [npcs, p_mnv, p_par, p_npar, score, varexp] = ...
    cmpoutput(ve, data, groups, summary)
% CMPOUTPUT Compares output observations from two or more groups.
%
%    [npcs, p_mnv, p_par, p_npar, score, varexp] = ...
%       CMPOUTPUT(ve, data, groups, summary)
%
% Parameters:
%        ve - Percentage (between 0 and 1) of variance explained by the q
%             principal components (i.e. number of dimensions) used in
%             MANOVA.
%      data - An n x m matrix, where n is the total number of output
%             observations and m is the number of variables (i.e. output
%             length).
%    groups - Vector of integers specifying the group to which individual
%             observations are associated with.
%   summary - Set this optional argument to 0 to suppress printing the
%             comparison summary.
%
% Outputs:
%      npcs - Number of principal components which explain ve percentage of
%             variance.
%     p_mnv - P-values for the MANOVA test for npcs principal components.
%     p_par - Vector of p-values for the parametric test applied to groups
%             along each principal component (t-test for 2 groups, ANOVA
%             for more than 2 groups).
%    p_npar - Vector of p-values for the non-parametric test applied to
%             groups along each principal component (Mann-Whitney U test
%             for 2 groups, Kruskal-Wallis test for more than 2 groups).
%     score - n x (n - 1) matrix containing projections of output data in
%             the principal components space. Rows correspond to
%             observations, columns to principal components.
%    varexp - Percentage of variance explained by each principal component.
%
% Note:
%     This function requires the statistics toolbox or package for MATLAB
%     or Octave, respectively. In the latter case, the statistics package
%     can be loaded (if installed) with the following command:
%        "pkg load statistics"
%     
% Copyright (c) 2016-2017 Nuno Fachada
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

% Print summary by default
if nargin < 4
    summary = 1;
end;

% Perform PCA
if is_octave()
    [~, score, latent] = princomp(data, 'econ');
else
    [~, score, latent] = pca(data);
end;

% Variance explain by each PC
varexp = latent ./ sum(latent);

% Total number of PCs
tpcs = size(score, 2);

% How many PCs required to explain user-specified minimum variance
cumvar = cumsum(varexp);
npcs = find(cumvar > ve, 1);

% Perform MANOVA if possible
if npcs > 1
    if is_octave()
        p_mnv = manova_micomp(score(:, 1:npcs), groups);
    else
        [~, p_mnv] = manova1(score(:, 1:npcs), groups);
        p_mnv = p_mnv(1);
    end;
else
    p_mnv = NaN;
end;

% Allocate arrays for ANOVA and KW
p_par = zeros(tpcs, 1);
p_npar = zeros(tpcs, 1);

% Number of unique groups
ugrps = unique(groups);
ngrps = numel(ugrps);

% How many groups?
if ngrps > 2

    % More than two groups, perform ANOVA and KW on each PC
    for i = 1:tpcs
        if is_octave()
            p_par(i) = anova(score(:, i), groups);
            cellscore = cell(1, ngrps);
            for j = 1:ngrps
                idxs = find(groups == ugrps(j));
                cellscore{j} = score(idxs(1):idxs(numel(idxs)), i);
            end;
            p_npar(i) = kruskal_wallis_test(cellscore{:});
        else
            p_par(i) = anova1(score(:, i), groups, 'off');
            p_npar(i) = kruskalwallis(score(:, i), groups, 'off');
        end;
    end;
    
else
    
    % Only two groups, use t-test and Mann-Whitney instead
    
    % Find group change index
    gci = find(groups == 2, 1);
    
    for i = 1:tpcs
        if is_octave()
            p_par(i) = t_test_2(score(1:(gci - 1), i), ...
                score(gci:numel(groups), i));
            p_npar(i) = u_test(score(1:(gci - 1), i), ...
                score(gci:numel(groups), i));
        else
            [~, p_par(i)] = ttest2(score(1:(gci - 1), i), ...
                score(gci:numel(groups), i));
            p_npar(i) = ranksum(score(1:(gci - 1), i), ...
                score(gci:numel(groups), i));
        end;
    end;
end;

% Present some summary statistics, if required
if summary
    fprintf('\nNumber of PCs: %d\n', npcs);
    if npcs > 1
        fprintf('MANOVA 1st P-Value: %f\n', p_mnv(1));
    end;
    fprintf('ANOVA/t-test P-Value (1st PC): %5.3f\n', p_par(1));
    fprintf('KW/MW P-Value (1st PC): %5.3f\n\n', p_npar(1));
end;


