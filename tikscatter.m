function figstr = tikscatter(pts, groups, marks)
%TIKSCATTER Summary of this function goes here
%   Detailed explanation goes here
%
% Copyright (c) 2016 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

% Default marks
if nargin == 2
    marks = {...
        'mark=square*,mark options={color=red},mark size=0.8pt', ...
        'mark=*,mark size=0.6pt', ...
        'mark=o,mark size=0.7pt'}; % Improve this
end;

% Normalize 
max_pt = max(max(abs(pts(:, 1:2))));
pts = pts / max_pt;

% Unique groups
ugrps = unique(groups);

% Begin figure
figstr = '\begin{tikzpicture}[scale=6] \path (-1.2,-1.2) (1.2,1.2); ';

figstr = sprintf('%s \\draw[very thin,color=gray] (0,1.1)--(0,-1.1); \\draw[very thin,color=gray] (1.1,0)--(-1.1,0);', figstr);

% Cycle groups
for i=1:numel(ugrps)
    
    % Get points in group
    pts_in_grp = pts(find(groups==i), 1:2);

    % Begin plotting points in current group
    figstr = sprintf('%s \\path plot[%s] coordinates {', figstr, marks{i});

    % Cycle points in group
    for j=1:size(pts_in_grp, 1)
       figstr = sprintf('%s (%5.3f,%5.3f)', figstr, pts_in_grp(j, 1), pts_in_grp(j, 2));
    end;
    
    % End current group
    figstr = sprintf('%s}; ', figstr);

end;

figstr = sprintf('%s \\end{tikzpicture} ', figstr);



end

