%
% Unit tests for micompm
%
% These tests require the MOxUnit framework available at
% https://github.com/MOxUnit/MOxUnit
%
% To run the tests: 
% 1 - Make sure MOxUnit is on the MATLAB/Octave path
% 2 - Make sure micompm is on the MATLAB/Octave path by running
%     startup.m
% 3 - cd into the tests folder
% 4 - Invoke the moxunit_runtests script
%
% Copyright (c) 2017 Nuno Fachada
% Distributed under the MIT License (See accompanying file LICENSE or copy 
% at http://opensource.org/licenses/MIT)
%
function test_suite = tests_all
    try
        % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions();
    catch
        % no problem; early Matlab versions can use initTestSuite fine
    end;
    initTestSuite

% Test function grpoutputs
function test_grpoutputs

    % Test with different output concatenation methods
    cmeth = {0, ...
        'center', 'auto', 'range', 'iqrange', 'vast', 'pareto', 'level'};

    % Folders for grouping with nl_ok
    fldcmp = ...
        {'../data/j_ex_ok', '../data/j_ex_noshuff', '../data/j_ex_diff'};

    % Perform grouping and test return values
    for i = 1:numel(fldcmp)
        for j = 1:numel(cmeth)

            % Number of outputs for this comparison
            nout = 6 + ischar(cmeth{j});

            % Load data with grpoutputs
            [o, g] = grpoutputs(cmeth{j}, ...
                '../data/nl_ok', 'stats400v1*.tsv', ...
                fldcmp{i}, 'stats400v1*.tsv');

            % Test if grpoutputs produces the expected outputs
            assertTrue(iscell(o));
            assertEqual(numel(o), nout);
            assertEqual(g, [ones(1,10) 2 * ones(1, 10)]);

        end;
    end;
    
    % Test grouping with only one output
    [o, g] = grpoutputs(0, ...
                '../data/oneoutput_nl_ok', 'stats400v1*.tsv', ...
                '../data/oneoutput_j_ex_diff', 'stats400v1*.tsv');
            
    assertTrue(iscell(o));
    assertEqual(numel(o), 1);
    assertEqual(g, [ones(1,10) 2 * ones(1, 10)]);
   
% Test function cmpoutput
function test_cmpoutput

    % Sets of folders/files to compare
    fldcmp = { ...
        {'../data/nl_ok', 'stats400v1*.tsv', ...
            '../data/j_ex_ok',  'stats400v1*.tsv'}, ...
        {'../data/nl_ok', 'stats400v1*.tsv', ...
            '../data/j_ex_noshuff', 'stats400v1*.tsv'}, ...
        {'../data/nl_ok', 'stats400v1*.tsv', ...
            '../data/j_ex_diff', 'stats400v1*.tsv'}, ...
        {'../data/oneoutput_nl_ok', 'stats400v1*.tsv', ...
            '../data/oneoutput_j_ex_diff', 'stats400v1*.tsv'}, ...
        {'../data/nl_ok', 'stats400v1*.tsv', ...
            '../data/j_ex_noshuff', 'stats400v1*.tsv', ...
            '../data/j_ex_diff', 'stats400v1*.tsv'}};

    % Perform comparisons
    for i = 1:numel(fldcmp)
        
        % Load data with grpoutputs
        [o, g] = grpoutputs('auto', fldcmp{i}{:});

        % Check for the current number of groups
        assertEqual(numel(unique(g)), numel(fldcmp{i}) / 2);

        % Compare each output individually
        for j = 1:numel(o)
            
            % Test with different percentages of variance to explain
            for k = [0.1 0.5 0.9]
            
                % Compare current output
                [npcs, p_mnv, p_par, p_npar, score, varexp] = ...
                    cmpoutput(k, o{j}, g, 0);
            
                % Check return values
                assertTrue(isnumeric(npcs));
                assertEqual(numel(npcs), 1);
                assertEqual(npcs - round(npcs), 0);

                assertTrue(isnumeric(p_mnv));
                assertEqual(numel(p_mnv), 1);
                
                assertTrue(isnumeric(p_par));
                assertEqual(numel(p_par), size(score, 2));

                assertTrue(isnumeric(p_npar));
                assertEqual(numel(p_npar), size(score, 2));

                assertTrue(isnumeric(score));
                assertEqual(size(score, 1), numel(g));
                
                assertTrue(isnumeric(varexp));
                assertEqual(numel(varexp), size(score, 2));

            end;
        end;
    end;
    
% Test functions micomp, micomp_show and assumptions with micomp
% loading files with outputs
function test_micomp_loadfiles
    
    % Test without and with concatenated output
    ccat = {0, 'vast'};
    
    % Test with different percentages of variance to explain
    ve = [0.05 0.3 0.6 0.8 0.95];
    
    % Test multiple comparisons
    for i = 1:numel(ccat)
        
        for j = 1:numel(ve)
    
            % Perform multiple comparisons
            c = micomp(6 + ischar(ccat{i}), ccat{i}, ve(j), ...
                {'../data/nl_ok', 'stats400v1*.tsv', ...
                    '../data/j_ex_ok',  'stats400v1*.tsv'}, ...
                {'../data/nl_ok', 'stats400v1*.tsv', ...
                    '../data/j_ex_noshuff', 'stats400v1*.tsv'}, ...
                {'../data/nl_ok', 'stats400v1*.tsv', ...
                    '../data/j_ex_diff', 'stats400v1*.tsv'}, ...
                {'../data/nl_ok', 'stats400v1*.tsv', ...
                    '../data/j_ex_noshuff', 'stats400v1*.tsv', ...
                    '../data/j_ex_diff', 'stats400v1*.tsv'});
                
            % Check if micomp_show does not throw errors and returns a
            % string
            tbl = micomp_show(0, c, 6 + ischar(ccat{i}), 4); % LaTeX
            assertTrue(ischar(tbl));
            tbl = micomp_show(1, c, 6 + ischar(ccat{i}), 4); % Plain text
            assertTrue(ischar(tbl));
            
            % Number of PCs for MANOVA and p-values must be numeric
            assertTrue(isnumeric(c.data));
            
            % 4 comparison * 6/7 outputs, 4 stats
            assertEqual(size(c.data), [4 * (6 + ischar(ccat{i})) 4]);
            
            % Check values for each comparison performed
            for k = 1:4
                
                % Check groups
                assertTrue(isnumeric(c.groups{k}));
                assertEqual(numel(c.groups{k}), ...
                    10 * numel(unique(c.groups{k})));
                
                % Check values for each output
                for l = 1:(6 + ischar(ccat{i}))
                    
                    assertTrue(isnumeric(c.scores{l, k}));
                    assertEqual(size(c.scores{l, k}, 1), ...
                        numel(c.groups{k}));
                    
                    assertTrue(isnumeric(c.varexp{l, k}));
                
                    % Test assumptions for current comparison
                    [p_unorm, p_mnorm, p_uvar, p_mvar] = ...
                        cmpassumptions(...
                            c.scores{l, k}, ...
                            c.groups{k}, ...
                            c.data((k - 1) * l + l, 1), ...
                            0);
                    
                    assertTrue(isnumeric(p_unorm));
                    assertTrue(isnumeric(p_mnorm));
                    assertTrue(isnumeric(p_uvar));
                    assertTrue(isnumeric(p_mvar));
                    
                    assertEqual(size(p_unorm), ...
                        [numel(unique(c.groups{k})) ...
                        size(c.scores{l, k}, 2)]);
                    
                    assertEqual(...
                        numel(p_mnorm), numel(unique(c.groups{k})));
                    
                    assertEqual(numel(p_uvar), size(c.scores{l, k}, 2));
                    
                    assertEqual(numel(p_mvar), 1);
                    
                end;
                
            end;

        end;
    end;

% Test functions micomp, micomp_show and assumptions with micomp directly
% using output and group data
function test_micomp_direct
    
    % Test without and with concatenated output
    ccat = {0, 'pareto'};
    
    % Test with different percentages of variance to explain
    ve = [0.07 0.4 0.55 0.7 0.85];
    
    % Test multiple comparisons
    for i = 1:numel(ccat)
        
        for j = 1:numel(ve)
            
            % Load output data with grpoutputs
            [o1, g1] = grpoutputs(ccat{i}, ...
                '../data/nl_ok', 'stats400v1*.tsv', ...
                '../data/j_ex_ok',  'stats400v1*.tsv');
            [o2, g2] = grpoutputs(ccat{i}, ...
                '../data/nl_ok', 'stats400v1*.tsv', ...
                '../data/j_ex_noshuff', 'stats400v1*.tsv');
            [o3, g3] = grpoutputs(ccat{i}, ...
                '../data/nl_ok', 'stats400v1*.tsv', ...
                '../data/j_ex_diff', 'stats400v1*.tsv');
            
            % Perform multiple comparisons using the data directly
            % Note that the concatenation option is ignored in this case
            c = micomp(6 + ischar(ccat{i}), 0, ve(j), ...
                {o1, g1}, {o2, g2}, {o3, g3});
                
            % Check if micomp_show does not throw errors and returns a
            % string
            tbl = micomp_show(0, c, 6 + ischar(ccat{i}), 3); % LaTeX
            assertTrue(ischar(tbl));
            tbl = micomp_show(1, c, 6 + ischar(ccat{i}), 3); % Plain text
            assertTrue(ischar(tbl));
            
            % Number of PCs for MANOVA and p-values must be numeric
            assertTrue(isnumeric(c.data));
            
            % 3 comparison * 6/7 outputs, 4 stats
            assertEqual(size(c.data), [3 * (6 + ischar(ccat{i})) 4]);
            
            % Check values for each comparison performed
            for k = 1:3
                
                % Check groups
                assertTrue(isnumeric(c.groups{k}));
                assertEqual(numel(c.groups{k}), ...
                    10 * numel(unique(c.groups{k})));
                
                % Check values for each output
                for l = 1:(6 + ischar(ccat{i}))
                    
                    assertTrue(isnumeric(c.scores{l, k}));
                    assertEqual(size(c.scores{l, k}, 1), ...
                        numel(c.groups{k}));
                    
                    assertTrue(isnumeric(c.varexp{l, k}));
                
                    % Test assumptions for current comparison
                    [p_unorm, p_mnorm, p_uvar, p_mvar] = ...
                        cmpassumptions(...
                            c.scores{l, k}, ...
                            c.groups{k}, ...
                            c.data((k - 1) * l + l, 1), ...
                            0);
                    
                    assertTrue(isnumeric(p_unorm));
                    assertTrue(isnumeric(p_mnorm));
                    assertTrue(isnumeric(p_uvar));
                    assertTrue(isnumeric(p_mvar));
                    
                    assertEqual(size(p_unorm), ...
                        [numel(unique(c.groups{k})) ...
                        size(c.scores{l, k}, 2)]);
                    
                    assertEqual(...
                        numel(p_mnorm), numel(unique(c.groups{k})));
                    
                    assertEqual(numel(p_uvar), size(c.scores{l, k}, 2));
                    
                    assertEqual(numel(p_mvar), 1);
                    
                end;
                
            end;

        end;
    end;

