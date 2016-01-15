function [tbl, fids] = micomp_show(type, c, nout, ncomp)
% MICOMP_SHOW Generate tables and plots of model-independent comparison 
% of simulation output.
%
%   [tbl, fids] = MICOMP_SHOW(type, c, nout, ncomp)
%
% Parameters:
%    type - Table format: 0 for LaTeX table, 1 for plain text table, 2 for
%           plain text table with MATLAB plots summarizing the performed
%           comparisons.
%       c - Output of micomp function.
%    nout - Number of outputs or cell array with output names.
%   ncomp - Number of comparisons or cell array with comparison names.
%
% Outputs:
%     tbl - String containing generated table.
%    fids - Handles of the generated plots, if any.
%
% Copyright (c) 2016 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

t = c.data;
scores = c.scores;
groups = c.groups;
varexp = c.varexp;

% Table string
tbl = '';

% Define output tags
if isnumeric(nout)
    output_tags = cell(nout, 1);
    for i = 1:nout
        output_tags{i} = ['Output ' num2str(i)];
    end;
elseif iscell(nout)
    output_tags = nout;
    nout = numel(nout);
else
    error('"nout" must be an integer or a cell');
end;

% Define comparison tags
if isnumeric(ncomp)
    comp_tags = cell(ncomp, 1);
    for i=1:ncomp
        comp_tags {i} = ['Comp. ' num2str(i)];
    end;
elseif iscell(ncomp)
    comp_tags  = ncomp;
    ncomp = numel(ncomp);
else
    error('"ncomp" must be an integer or a cell');
end;

% Image IDs if plotting enabled
fids = cell(nout, 1);

if type > 0 % Plain text table
            
    linestyles = {'-bo', '-rs', '-gd'}; % Improve this

    if type > 1 % Generate plots
        
        % Cycle through outputs
        for i = 1:nout
    
            fids{i} = zeros(1 + ncomp, 1);
            
            fids{i}(1) = figure();
            hold on;
            grid on;
            title([output_tags{i} ' - Variance explained by PC']);
            
            % Cycle through comparisons
            for j = 1:ncomp

                fids{i}(j + 1) = figure();
                gscatter(scores{i, j}(:, 1), ...
                    scores{i, j}(:, 2), groups{j});
                title([output_tags{i} ' - comp. ' num2str(j)]);
                
                figure(fids{i}(1));
                plot(varexp{i, j}(1:10), linestyles{j});
                
            end;
                
            legend(comp_tags);
            
        end;
        
    end;
    
    tbl = sprintf('%s%s', tbl, print_sep(nout));
    tbl = sprintf('%s| Comp.    | Test  |', tbl);
    
    for i = 1:nout
        tbl = sprintf('%s % 14s |', tbl, output_tags{i});
    end;
    tbl = sprintf('%s\n', tbl);
    tbl = sprintf('%s%s', tbl, print_sep(nout));

    for i = 1:ncomp % Cycle through comparisons

        tbl = sprintf('%s| % 7s  |', tbl, comp_tags{i});

        % Cycle through numPCs + test tags
        for j = 1:4

            if j == 1
                tbl = sprintf('%s #PCs  |', tbl);
            elseif j==2
                tbl = sprintf('%s|          | MNV   |', tbl);
            elseif j==3
                tbl = sprintf('%s|          | TT    |', tbl);
            elseif j==4
                tbl = sprintf('%s|          | MW    |', tbl);
            end;

            % Cycle through outputs
            for k = 1:nout
                
                row_idx = (i - 1) * nout + k;
                
                if j == 1
                    % Number of PCs, no special format
                    tbl = sprintf('%s % 14d |', tbl, t(row_idx, j));
                else
                    % Properly format p-value        
                    tbl = sprintf('%s % 14.10f |', tbl, t(row_idx, j));

                end;                
                 
            end;

            tbl = sprintf('%s\n', tbl);
        end;
    tbl = sprintf('%s%s', tbl, print_sep(nout));
    end;    

elseif type ==  0 % LaTeX table
    
    % Begin LaTeX table
    tbl = sprintf('%s\\begin{tabular}{cl%s}\n', tbl, repmat('r', 1, nout));
    
    % Add toprule
    tbl = sprintf('%s\\toprule\n', tbl);

    % Header
    tbl = sprintf(['%s\\multirow{2}{*}{Comp.} & \\multirow{2}{*}{Test}' ...
        ' & \\multicolumn{%d}{c}{Outputs} \\\\\n'], ...
        tbl, nout);
    
    % cmidrule
    tbl = sprintf('%s\\cmidrule(l){3-%d}\n', tbl, 2 + nout);
    
    % Sub-header
    tbl = sprintf('%s & & %s \\\\\n', tbl, strjoin(output_tags', ' & '));

    % Cycle through comparisons
    for i = 1:ncomp

        % Add midrule
        tbl = sprintf('%s\\midrule\n', tbl);

        % Add comparison tag
        tbl = sprintf('%s\\multirow{5}{*}{% 10s}\n', tbl, comp_tags{i});

        % Cycle through numPCs + test tags
        for j = 1:5

            if j == 1
                tbl = sprintf('%s & $\\#$PCs ', tbl);
            elseif j == 2
                tbl = sprintf('%s & MNV      ', tbl);
            elseif j == 3
                tbl = sprintf('%s & $t$-test ', tbl);
            elseif j == 4
                tbl = sprintf('%s & MW       ', tbl);
            elseif j == 5
                tbl = sprintf('%s & PCS      ', tbl);
            end;

            % Cycle through outputs
            for k = 1:nout
                row_idx = (i - 1) * nout + k;
                if j == 1
                    % Number of PCs, no special format
                    tbl = sprintf('%s& %d ', tbl, t(row_idx, j));
                elseif j < 5
                    % Properly format p-value        
                    tbl = sprintf('%s & %14s', tbl, ltxpv(t(row_idx, j)));
                else
                    % Scatter plot
                    tbl = sprintf(['%s & \\raisebox{-.5\\height}{\\' ...
                        'resizebox {1.2cm} {1.2cm} {%s}}'], ...
                        tbl, tikscatter(scores{k, i}, groups{i}));
                end;                
            end;
            tbl = sprintf('%s\\\\\n', tbl);
        end;
    end;

    % Bottom line
    tbl = sprintf('%s\\bottomrule\n', tbl);
    
    % Close table
    tbl = sprintf('%s\\end{tabular}\n', tbl);
    
else % Unknown type
    
    error('Unknown type');
    
end;

end

% Helper function for printing plain text tables
function tbl = print_sep(nout)

tbl = '--------------------';
for j = 1:nout
    tbl = sprintf('%s-----------------', tbl);
end;
tbl = sprintf('%s\n', tbl);

end