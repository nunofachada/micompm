function [p_unorm, p_mnorm, p_uvar, p_mvar] = ...
    cmpassumptions(scores, groups, npcs, summary)
% CMPASSUMPTIONS Verify the assumptions for parametric tests applied to
% the comparison of output observations.
%
%   [p_unorm, p_mnorm, p_uvar, p_mvar] = CMPASSUMPTIONS(scores, groups, npcs, summary)
%
% Parameters:
%  scores - PCA scores, i.e. the scores matrix returned by cmpoutput.
%  groups - Groups to which observations (rows of data) belong to.
%    npcs - Number of principal components used in multivariate comparison.
% summary - Optional argument defining the maximum number of PCs to show
%           in the summary (default is 8). Setting this argument to 0
%           suppresses printing assumptions summary.
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

% Print summary by default with 8 PCs
if nargin < 4
    summary = 8;
end;

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
        % Bartlett test with Octave
        cellscore = cell(1, numgrp);
        for j = 1:numgrp
            idxs = find(groups == uniqgrp(j));
            cellscore{j} = scores(idxs(1):idxs(numel(idxs)), i);
        end;
        % Octave's bartlett_test() function does not generate the same
        % p-values as MATLAB and R implementations of the Bartlett test.
        % However, Octave's var_test() function does, and as such, it is
        % used when there are two groups. Unfortunately, var_test() only
        % works with two groups. Thus, if there are more than two groups
        % we are forced to use bartlett_test(), which generates slightly
        % different p-values.
        if numgrp == 2
            p_uvar(i) = var_test(cellscore{:});
        else
            p_uvar(i) = bartlett_test(cellscore{:});
        end;
    else
        % Bartlett test with MATLAB
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

% Present some summary statistics, if required
if summary
    
    % Maximum number of PCs to show the p-values for
    maxpcs = summary;
    
    % Show Shapiro-Wilk test p-values
    str = 'P-values for the Shapiro-Wilk test (univariate normality)';
    fprintf(['\n' str '\n']);
    fprintf([repmat('-', 1, numel(str)) '\n\n']);

    fprintf('           ');
    for j = 1:min(maxpcs, tpcs)
       fprintf(' % 7s%02d', 'PC', j);
    end;
    fprintf('\n');
    for i = 1:numgrp
        fprintf('    Group %d', i);
        for j = 1:min(maxpcs, tpcs)
            fprintf(' % 9.3g', p_unorm(i, j));
        end;
        if tpcs > maxpcs
            fprintf(' ...');
        end;
        fprintf('\n');
    end;
    
    % Show Royston test p-values
    if npcs > 1
        str = sprintf(['P-values for the Royston test ' ...
            '(multivariate normality, %d dimensions)'], npcs);
        fprintf(['\n' str '\n']);
        fprintf([repmat('-', 1, numel(str)) '\n\n']);
        for i = 1:numgrp
            fprintf('    Group %d % 9.3g\n', i, p_mnorm(i));
        end;
    end;
    
    % Show Bartlett's test p-values
    str = 'P-values for Bartlett''s test (equality of variances)';
    fprintf(['\n' str '\n']);
    fprintf([repmat('-', 1, numel(str)) '\n\n']);
    fprintf('           ');
    for j = 1:min(maxpcs, tpcs)
       fprintf(' % 7s%02d', 'PC', j);
    end;
    fprintf('\n           ');
    for j = 1:min(maxpcs, tpcs)
        fprintf(' % 9.3g', p_uvar(j));
    end;
    if tpcs > maxpcs
        fprintf(' ...');
    end;
    fprintf('\n');
    
    % Show Box's M p-value
    if npcs > 1
        str = sprintf(['P-value for Box''s M test (homogeneity of ' ...
            'covariance matrices on %d dimensions)'], npcs);
        fprintf(['\n' str '\n']);
        fprintf([repmat('-', 1, numel(str)) '\n\n']);
        fprintf('            % 9.3g\n', p_mvar);
    end;
    
    fprintf('\n');

end;