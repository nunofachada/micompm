function lvalue = ltxpv(pvalue, minpv, ulims)
% LTXPV Formats a p-value for LaTeX, using exponents and/or truncating very
% low p-values, and underlining/double-underlining values below user
% specified limits (defaulting to 0.05 for underline and 0.01 for
% double-underline). Requires siunitx and ulem LaTeX packages.
%
%   lvalue = LTXPV(pvalue, minpv, ulims)
%
% Parameters:
%   value - P-value to format.
%   minpv - Minimum displayable value (optional, default = 0.001).
%   ulims - Optional vector of two scalar containing the values below which 
%           the p-values will be underline or double-underline, 
%           respectively. Default value is [0.05 0.01].
%
% Returns:
%  lvalue - A string with the formatted p-value, according to the following
%           rules:
%             * If p-value is NaN, return the character '-'.
%             * If p-value is less than minpv, return "< minpv" (e.g. 
%               "< 0.001" for minpv = 0.001).
%             * If p-value is more than 0.0005, it is formatted with three
%               decimal digits, otherwise it is formatted with scientific
%               notation (the final value will always have five 
%               characters).
%             * If p-value is between ulims(2) and ulims(1) it will be 
%               underlined.
%             * If p-value is less than ulims(2) it will be 
%               double-underlined.
%
% Copyright (c) 2016 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

% Is the p-value a NaN?
if isnan(pvalue)
    % If p-value is NaN, return '-'
    lvalue = '-';
else

    % p-value is not NaN, proceed as usual
    
    % Default minpv
    if nargin < 2
        minpv = 0.001;
    end;
    
    % Default ulims
    if nargin < 3
        ulims = [0.05 0.01];
    end;

    % Determine if p-value will be printed as float or exponent
    if max(pvalue, minpv) > 0.0005
        lvalue = sprintf('%6.3f', max(pvalue, minpv));
    else
        lvalue = sprintf('\\num[output-exponent-marker=\\text{e}]{%5.0e}', ...
            max(pvalue, minpv));
    end;
    
    % Is the p-value truncated?
    if pvalue < minpv
        % If so, add a less than sign
        lvalue = sprintf('< %s', lvalue);
    end;
    
    % Add underline and double-underline.
    if pvalue < ulims(2)
        lvalue = sprintf('\\uuline{%s}', lvalue);
    elseif pvalue < ulims(1)
        lvalue = sprintf('\\uline{%s}', lvalue);
    end;

end;
