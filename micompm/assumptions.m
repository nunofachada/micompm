function [p_unorm, p_mnorm, p_uvar, p_mvar] = ...
    assumptions(data, groups, npcs)
% ASSUMPTIONS Verify the assumptions for parametric tests applied to the
% comparison of output observations.
%
%   [p_unorm, p_mnorm, p_uvar, p_mvar] = ASSUMPTIONS(data, groups, npcs)
%
% Parameters:
%    data - PCA scores, i.e. the scores matrix returned by cmpoutput.
%  groups - Groups to which observations (rows of data) belong to.
%    npcs - Number of principal components.
%
% Outputs:
%  p_unorm - A ngrps x npcs matrix with the p-values of the Shapiro-Wilk
%           univariate test of normality (ngrp is the number of unique
%           groups).
%  p_mnorm - Vector of size ngrps with the p-values of the Royston test
%           for multivariate normality.
%  p_uvar - P-value of the Bartlett's test for equality of variances.
%  p_mvar - P-value of the Box's M test for the homogeneity of covariance
%           matrices.
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
tpcs = size(data, 2);

% Univariate normality (group-wise)
p_unorm = zeros(numgrp, npcs);
% Multivariate normality (group-wise)
p_mnorm = zeros(numgrp, 1);
% Equality of variances
p_uvar = zeros(tpcs, 1);

% Determine p-values for Shapiro-Wilks normality test
for i = 1:numgrp
    
    % Get data for current group
    datagrp = data(groups == uniqgrp(i), 1:tpcs);
    
    % Univariate normality: 
    % Perform test for each variable in current group
    for j = 1:tpcs
        [~, p] = swtest(datagrp(:, j), 0.05);
        p_unorm(i, j) = p;
    end;
    
    % Multivariate normality:
    % Perform test for first npcs variables in current group
    p_mnorm(i) = Roystest(datagrp, 0.05);
    
end;

% Equality of variances
for i = 1:tpcs
    if is_octave()
        cellscore = cell(1, numgrp);
        for j = 1:numgrp
            idxs = find(groups == uniqgrp(j));
            cellscore{j} = data(idxs(1):idxs(numel(idxs)), i);
        end;
        % Octave's bartlett_test function does not generate the same
        % p-values as MATLAB and R implementations of the Bartlett test.
        % However, Octave's var_test function does so, and as such, it is
        % used in the following line:
        p_uvar(i) = var_test(cellscore{:});
    else
        p_uvar(i) = vartestn(data(:, i), groups,  'display', 'off');
    end;
end;

% Homogeneity of Covariance Matrices
if size(groups, 1) < size(groups, 2)
    groups = groups';
end;

mbox = mtest(groups, data, 0.1);
p_mvar = mbox.pValue;