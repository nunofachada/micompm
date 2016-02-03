function vcs = centerscale(v, type)
% CENTERSCALE Center and scale input vector using the specified method.
% Available methods include 'center', 'auto', 'range', 'iqrange', 'vast',
% 'pareto' and 'level', all of which are described in the reference provided
% below, except for 'iqrange', in which the centered vector is divided by
% the interquartile range.
%
%   vcs = CENTERSCALE(v, type)
%
% Parameters:
%       v - Vector to center and scale.
%    type - Type of scaling: 'center', 'auto', 'range', 'iqrange', 'vast',
%           'pareto' or 'level'.
%
% Outputs:
%     vcs - Center and scaled vector using the specified method.
%
% Reference:
%     R. Berg, H. Hoefsloot, J. Westerhuis, A. Smilde and M. Werf (2006).
%     "Centering, scaling, and transformations: improving the biological
%     information content of metabolomics data". BMC Genomics 7:142
%     DOI: 10.1186/1471-2164-7-142
%
% Copyright (c) 2016 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

switch type
    case 'center'
        vcs = v - mean(v);
    case 'auto'
        vcs = (v - mean(v)) / std(v);
    case 'range'
        vcs = (v - mean(v)) / (max(v) - min(v));
    case 'iqrange'
        vcs = (v - mean(v)) / iqr(v);
    case 'vast'
        vcs = (v - mean(v)) * mean(v) / var(v);
    case 'pareto'
        vcs = (v - mean(v)) / sqrt(std(v));
    case 'level'
        vcs = (v - mean(v)) / mean(v);
    otherwise
        error('Unknown scaling method');
end

