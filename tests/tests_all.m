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

    % Load data with grpoutputs
    [o_ok, g_ok] = grpoutputs(0, ...
        '../data/nl_ok', 'stats400v1*.tsv', ...
        '../data/j_ex_ok', 'stats400v1*.tsv');
    [o_noshuff, g_noshuff] = grpoutputs(0, ...
        '../data/nl_ok', 'stats400v1*.tsv', ...
        '../data/j_ex_noshuff', 'stats400v1*.tsv');
    [o_diff, g_diff] = grpoutputs('range', ...
        '../data/nl_ok', 'stats400v1*.tsv', ...
        '../data/j_ex_diff', 'stats400v1*.tsv');    

    % Test if grpoutputs produces the expected outputs
    assertEqual(iscell(o_ok), true);
    assertEqual(iscell(o_noshuff), true);
    assertEqual(iscell(o_diff), true);

    assertEqual(numel(o_ok), 6);
    assertEqual(numel(o_noshuff), 6);
    assertEqual(numel(o_diff), 7);     % Contains concat. output

    assertEqual(g_ok, [ones(1,10) 2 * ones(1, 10)]);
    assertEqual(g_noshuff, [ones(1,10) 2 * ones(1, 10)]);
    assertEqual(g_diff, [ones(1,10) 2 * ones(1, 10)]);
    
% Test function cmpoutput
function test_cmpoutput

    % Load data with grpoutputs
    [o_noshuff, g_noshuff] = grpoutputs('auto', ...
        '../data/nl_ok', 'stats400v1*.tsv', ...
        '../data/j_ex_noshuff', 'stats400v1*.tsv');
    
    % Compare first output
    [npcs, p_mnv, p_par, p_npar, score, varexp] = ...
        cmpoutput(0.9, o_ok{1,1}, g_ok);
    
    % Check return values
    
    error('Test not implemented');
    
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
