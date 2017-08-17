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
        for j = 1:7 % 6 outputs + 1 concatenated output
            
            % Test with different percentages of variance to explain
            for k = [0.1 0.5 0.9]
            
                % Compare current output
                [npcs, p_mnv, p_par, p_npar, score, varexp] = ...
                    cmpoutput(k, o{j, 1}, g, 0);
            
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
    
% Test function micomp
function test_micomp
    
    c = micomp(6, 0, 0.9, ...
        {'../data/nl_ok', 'stats400v1*.tsv', ...
        '../data/j_ex_ok', 'stats400v1*.tsv'}, ...
        {'../data/nl_ok', 'stats400v1*.tsv', ...
        '../data/j_ex_noshuff', 'stats400v1*.tsv'});

    error('Test not implemented');
    
% Test function micomp_show
function test_micomp_show

    error('Test not implemented');
        
% Test function test_assumptions
function test_test_assumptions

    error('Test not implemented');
