function v_scaled = rangescale(v)
%
% Copyright (c) 2016 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

v_scaled = (v - mean(v))/(max(v)-min(v));