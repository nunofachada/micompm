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

    error('Test not implemented');

% Test function cmpoutput
function test_cmpoutput

    error('Test not implemented');
    
% Test function micomp
function test_micomp

    error('Test not implemented');
    
% Test function micomp_show
function test_micomp_show

    error('Test not implemented');
        
% Test function test_assumptions
function test_test_assumptions

    error('Test not implemented');
