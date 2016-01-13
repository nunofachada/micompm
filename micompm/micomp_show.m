function fids = micomp_show(type, c, nout, ncomp, do_plot)
%MICOMP_SHOW Summary of this function goes here
% Parameters:
%     type - Table format, 0 for matlab, 1 for Latex.
%   Detailed explanation goes here
%
% Copyright (c) 2016 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%

t = c.data;
scores = c.scores;
groups = c.groups;
varexp = c.varexp;

% Define output tags
if isnumeric(nout)
    output_tags = cell(nout, 1);
    for i=1:nout
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

if type == 0 % Matlab type
            
    linestyles = {'-bo','-rs','-gd'}; % Improve this

    if do_plot
        
        % Cycle through outputs
        for i=1:nout
    
            fids{i} = zeros(1 + ncomp, 1);
            
            fids{i}(1) = figure();
            hold on;
            grid on;
            title([output_tags{i} ' - Variance explained by PC']);
            
            % Cycle through comparisons
            for j=1:ncomp

                fids{i}(j + 1) = figure();
                gscatter(scores{i, j}(:, 1), scores{i, j}(:, 2), groups{j});
                title([output_tags{i} ' - comp. ' num2str(j)]);
                
                
                figure(fids{i}(1));
                plot(varexp{i, j}(1:10), linestyles{j});
                
            end;
                
            legend(comp_tags);
            
        end;
        

    end;
    
    
    
 
    print_sep(nout);
    fprintf(' Comp.     | Test  |');
    
    for i=1:nout
        fprintf(' % 14s |', output_tags{i});
    end;
    fprintf('\n');
    print_sep(nout);

    for i=1:ncomp % Cycle through comparisons


        fprintf(' % 7s   |', comp_tags{i});

        % Cycle through numPCs+test tags
        for j=1:4

            if j==1
                fprintf(' #PCs  |');
            elseif j==2
                fprintf('           | MNV   |');
            elseif j==3
                fprintf('           | TT    |');
            elseif j==4
                fprintf('           | MW    |');
            end;

            % Cycle through outputs
            for k=1:nout
                row_idx = (i-1)*nout+k;
                if j==1
                    % Number of PCs, no special format
                    fprintf(' % 14d |', t(row_idx, j));
                else
                    % Properly format p-value        
                    fprintf(' % 14.10f |', t(row_idx, j));

                end;                
                 
            end;

            fprintf('\n');
        end;
    print_sep(nout);
    end;    
   
    
    
elseif type == 1 % Latex type
    
    for i=1:ncomp % Cycle through comparisons

        % Print midrule
        fprintf('\\midrule\n');

        % Print comparison tag
        fprintf('\\multirow{5}{*}{% 10s}\n', comp_tags{i});

        % Cycle through numPCs+test tags
        for j=1:5

            if j==1
                fprintf(' & $\\#$PCs ');
            elseif j==2
                fprintf(' & MNV      ');
            elseif j==3
                fprintf(' & $t$-test ');
            elseif j==4
                fprintf(' & MW       ');
            elseif j==5
                fprintf(' & PCS      ');
            end;

            % Cycle through outputs
            for k=1:nout
                row_idx = (i-1)*nout+k;
                if j==1
                    % Number of PCs, no special format
                    fprintf('& %d ', t(row_idx, j));
                elseif j<5
                    % Properly format p-value        
                    fprintf(' & %14s', ltxpv(t(row_idx, j)));
                else
                    % Scatter plot
                    fprintf(' & \\raisebox{-.5\\height}{\\resizebox {1.2cm} {1.2cm} {%s}}', tikscatter(scores{k, i}, groups{i}));
                end;                
            end;
            fprintf('\\\\\n');
        end;
    end;

    
else % Unknown type
    
    error('Unknown type');
    
end;



end


% Helper function for printing plain text tables
function print_sep(nout)

fprintf('--------------------');
for j=1:nout
    fprintf('-----------------');
end;
fprintf('\n');

end