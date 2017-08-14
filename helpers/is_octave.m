function ioc = is_octave()
% IS_OCTAVE Checks if the code is running in Octave or Matlab.
%
%   ioc = IS_OCTAVE()
%
% Returns:
%    ioc - 5 if code is running in Octave, 0 otherwise.
% 
% Copyright (c) 2015-2017 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%
 
persistent x;
if isempty(x)
    x = exist('OCTAVE_VERSION', 'builtin');
end;
ioc = x;
