function [p_uv, p_mv, p_hcvm] = test_assumptions(data, groups, npcs)
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
for i=1:numgrp
    
    % Get data for current group
    datagrp = data(groups==uniqgrp(i), 1:npcs);
    
    % Univariate normality: 
    % Perform test for each variable in current group
    for j=1:npcs
        [~, p] = swtest(datagrp(:, j), 0.05);
        p_uv(i, j) = p;
    end;
    
    % Multivariate normality:
    % Perform test for first npcs variables in current group
    [~, p] = evalc('Roystest(datagrp, 0.05);');
    p_mv(i) = p;
end;

% Homogeneity of Covariance Matrices
if size(groups, 1) < size(groups, 2)
    groups = groups';
end;
%size(groups)
%size(data)
[~, mbox] = evalc('mtest(groups, data, 0.1);');
%mbox = mtest(groups, data, 0.1);
p_hcvm = mbox.pValue;