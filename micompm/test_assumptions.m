function [p_uv, p_mv, p_hcvm] = test_assumptions(data, groups, npcs)
% TEST_ASSUMPTIONS Get assumptions for the parametric tests performed in
% a comparison.
%
%   [p_uv, p_mv, p_hcvm] = TEST_ASSUMPTIONS(data, groups, npcs)
%
% Parameters:
%    data - PCA scores, i.e. the scores matrix returned by cmpoutput.
%  groups - Groups to which observations (rows of data) belong to.
%    npcs - Number of principal components.
%
% Outputs:
%    p_uv - A ngrps x npcs matrix with the p-values of the Shapiro-Wilk
%           univariate test of normality (ngrp - number of unique groups).
%    p_mv - Vector of size ngrps with the p-values of the Royston test
%           for multivariate normality.
%  p_hcvm - P-value of the Box's M test for the homogeneity of covariance
%           matrices.
%
% Copyright (c) 2016 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

% Unique groups
uniqgrp = unique(groups);
% Number of groups
numgrp = numel(uniqgrp);

% Univariate normality (group-wise)
p_uv = zeros(numgrp, npcs);
% Multivariate normality (group-wise)
p_mv = zeros(numgrp, 1);

% Determine p-values for Shapiro-Wilks normality test
for i = 1:numgrp
    
    % Get data for current group
    datagrp = data(groups == uniqgrp(i), 1:npcs);
    
    % Univariate normality: 
    % Perform test for each variable in current group
    for j = 1:npcs
        [~, p] = swtest(datagrp(:, j), 0.05);
        p_uv(i, j) = p;
    end;
    
    % Multivariate normality:
    % Perform test for first npcs variables in current group
    p_mv(i) = Roystest(datagrp, 0.05);
    
end;

% Homogeneity of Covariance Matrices
if size(groups, 1) < size(groups, 2)
    groups = groups';
end;

mbox = mtest(groups, data, 0.1);
p_hcvm = mbox.pValue;