function [p_unorm, p_mnorm, p_uvar, p_mvar] = ...
    micomp_assumptions(scores, groups, npcs)
% MICOMP_ASSUMPTIONS Verify the assumptions for parametric tests applied to
% the comparison of output observations.
%
%   [p_unorm, p_mnorm, p_uvar, p_mvar] = MICOMP_ASSUMPTIONS(scores, groups, npcs)
%
% Parameters:
%  scores - PCA scores, i.e. the scores matrix returned by cmpoutput.
%  groups - Groups to which observations (rows of data) belong to.
%    npcs - Number of principal components used in multivariate comparison.
%
% Outputs:
%  p_unorm - A ngrps x tpcs matrix with the p-values of the Shapiro-Wilk
%            univariate test of normality (ngrp is the number of unique
%            groups, tpcs is the total number of principal components).
%  p_mnorm - Vector of size ngrps with the p-values of the Royston test
%            for multivariate normality on npcs.
%   p_uvar - Vector of p-values of the Bartlett's test for equality of
%            variances for each principal components.
%   p_mvar - P-value of the Box's M test for the homogeneity of covariance
%            matrices on npcs.
%
% Copyright (c) 2016-2017 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

% Unique groups
uniqgrp = unique(groups);
% Number of groups
numgrp = numel(uniqgrp);

% Total number of PCs
tpcs = size(scores, 2);

% Univariate normality (group-wise)
p_unorm = nan(numgrp, tpcs);
% Multivariate normality (group-wise)
p_mnorm = nan(numgrp, 1);
% Equality of variances
p_uvar = nan(1, tpcs);
% Homogeneity of Covariance Matrices
p_mvar = nan;

% Determine p-values for Shapiro-Wilks normality test
for i = 1:numgrp
    
    % Get data for current group
    datagrp = scores(groups == uniqgrp(i), 1:tpcs);
    
    % Univariate normality: 
    % Perform test for each variable in current group
    for j = 1:tpcs
        [~, p] = swtest(datagrp(:, j), 0.05);
        p_unorm(i, j) = p;
    end;
    
    % Multivariate normality:
    % Perform test for first npcs variables in current group
    if npcs > 1
        p_mnorm(i) = Roystest(datagrp(:, 1:npcs), 0.05);
    end;
    
end;

% Equality of variances
for i = 1:tpcs
    if is_octave()
        cellscore = cell(1, numgrp);
        for j = 1:numgrp
            idxs = find(groups == uniqgrp(j));
            cellscore{j} = scores(idxs(1):idxs(numel(idxs)), i);
        end;
        % Octave's bartlett_test function does not generate the same
        % p-values as MATLAB and R implementations of the Bartlett test.
        % However, Octave's var_test function does, and as such, it is
        % used in the following line:
        p_uvar(i) = var_test(cellscore{:});
    else
        p_uvar(i) = vartestn(scores(:, i), groups,  'display', 'off');
    end;
end;

% Homogeneity of Covariance Matrices
if npcs > 1
    if size(groups, 1) < size(groups, 2)
        groups = groups';
    end;

    mbox = mtest(groups, scores(:, 1:npcs), 0.1);
    p_mvar = mbox.pValue;
end;