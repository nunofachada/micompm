function [MB, Saprox, v, P] = MBoxtest(X, alpha)
% Multivariate Statistical Testing for the Homogeneity of Covariance Matrices by the Box's M.
%
%   Syntax: function [MBox] = MBoxtest(X,alpha)
%
%     Inputs:
%          X - data matrix (Size of matrix must be n-by-(1+p); sample=column 1, variables=column 2:p).
%      alpha - significance level (default = 0.05).
%     Outputs:
%          MBox - the Box's M statistic.
%          Chi-sqr. or F - the approximation statistic test.
%          df's - degrees' of freedom of the approximation statistic test.
%          P - observed significance level.
%
%    If the groups sample-size is at least 20 (sufficiently large), Box's M test
%    takes a Chi-square approximation; otherwise it takes an F approximation.
%
%    Example: For a two groups (g = 2) with three independent variables (p = 3), we
%             are interested to test the homogeneity of covariances matrices with a
%             significance level = 0.05. The two groups have the same sample-size
%             n1 = n2 = 5.
%                                       Group
%                      ---------------------------------------
%                            1                        2
%                      ---------------------------------------
%                       x1   x2   x3             x1   x2   x3
%                      ---------------------------------------
%                       23   45   15             277  230   63
%                       40   85   18             153   80   29
%                      215  307   60             306  440  105
%                      110  110   50             252  350  175
%                       65  105   24             143  205   42
%                      ---------------------------------------
%
%             Total data matrix must be:
%          X=[1 23 45 15;1 40 85 18;1 215 307 60;1 110 110 50;1 65 105 24;
%          2 277 230 63;2 153 80 29;2 306 440 105;2 252 350 175;2 143 205 42];
%
%             Calling on Matlab the function:
%                MBoxtest(X,0.05)
%
%             Answer is:
%
%  ------------------------------------------------------------
%       MBox         F           df1          df2          P
%  ------------------------------------------------------------
%     27.1622     2.6293          6           463       0.0162
%  ------------------------------------------------------------
%  Covariance matrices are significantly different.
%

%  Created by A. Trujillo-Ortiz and R. Hernandez-Walls
%             Facultad de Ciencias Marinas
%             Universidad Autonoma de Baja California
%             Apdo. Postal 453
%             Ensenada, Baja California
%             Mexico.
%             atrujo@uabc.mx
%             And the special collaboration of the post-graduate students of the 2002:2
%             Multivariate Statistics Course: Karel Castro-Morales, Alejandro Espinoza-Tenorio,
%             Andrea Guia-Ramirez, Raquel Muniz-Salazar, Jose Luis Sanchez-Osorio and
%             Roberto Carmona-Pina.
%  November 2002.
%
% Changes by Nuno Fachada (Copyright 2016-2017), according to the terms of
% the BSD license:
%  * Supress output
%  * Make sure function does not fail when bandera != 1
%  * Make sure function does not fail when test statistic is complex
%  * Other small code style improvements
%
%  To cite this file, this would be an appropriate format:
%  Trujillo-Ortiz, A., R. Hernandez-Walls, K. Castro-Morales, A. Espinoza-Tenorio, A. Guia-Ramirez
%    and R. Carmona-Pina. (2002). MBoxtest: Multivariate Statistical Testing for the Homogeneity of
%    Covariance Matrices by the Box's M. A MATLAB file. [WWW document]. URL http://www.mathworks.com/
%    matlabcentral/fileexchange/loadFile.do?objectId=2733&objectType=FILE
%
%  References:
%
%  Stevens, J. (1992), Applied Multivariate Statistics for Social Sciences. 2nd. ed.
%              New-Jersey:Lawrance Erlbaum Associates Publishers. pp. 260-269.

if nargin < 1,
    error('Requires at least one input arguments.');
end;

if nargin < 2,
    alpha = 0.05; %(default)
end;

if (alpha <= 0 || alpha >= 1)
    error('Significance level must be between 0 and 1\n');
end;

% Number of groups
g = max(X(:, 1));

% Vector of groups-size
n = [];

indice = X(:,1);
for i = 1:g
    Xe = find(indice==i);
    eval(['X' num2str(i) '= X(Xe,2);']);
    eval(['n' num2str(i) '= length(X' num2str(i) ') ;'])
    eval(['xn= n' num2str(i) ';'])
    n = [n,xn];
end;

[f, c] = size(X);
X = X(:, 2:c);

[N, p] = size(X);
r = 1;
r1 = n(1);

bandera=2;
for k = 1:g
    if n(k) >= 20;
        bandera = 1;
    end
end

% Partition of the group covariance matrices.
for k=1:g
    eval(['S' num2str(k) '=cov(X(r:r1,:));';]);
    if k < g
        r = r + n(k);
        r1 = r1 + n(k + 1);
    end
end

deno = sum(n) - g;
suma = zeros(size(S1));

for k = 1:g
    eval(['suma =suma + (n(k)-1)*S' num2str(k) ';']);
end

% Pooled covariance matrix
Sp = suma / deno;
Falta = 0;

for k=1:g
    eval(['Falta =Falta + ((n(k)-1)*log(det(S' num2str(k) ')));']);
end

% Box's M statistic
MB = (sum(n) - g) * log(det(Sp)) - Falta;
suma1 = sum(1 ./ (n(1:g) - 1));
suma2 = sum(1 ./ ((n(1:g) - 1).^2));

% Computing of correction factor
C = (((2 * p^2) + (3 * p) - 1) / (6 * (p + 1) * (g - 1))) * (suma1 - (1/deno));

if bandera == 1
    
    % Chi-square approximation.
    X2 = MB * (1 - C);
    
    % Degrees of freedom
    v = (p * (p + 1) * (g - 1)) / 2;
    
    % Use only real part of statistic
    X2 = real(X2);
    
    % Significance value associated to the observed Chi-square statistic
    P = 1 - chi2cdf(X2, v);
    
    % The approximate statistic is the chi-squared statistic
    Saprox = X2;
    
else

    % To obtain the F approximation we first define Co, which combined to the before C value
    % are used to estimate the denominator degrees of freedom (v2); resulting two possible cases.
    Co=(((p-1)*(p+2))/(6*(g-1)))*(suma2-(1/(deno^2)));
    
    if Co - (C^2) >= 0
        
        % Numerator degrees of freedom
        v1=(p*(p+1)*(g-1))/2;
        
        % Denominator degrees of freedom
        v21=fix((v1+2)/(Co-(C^2)));
        
        % F approximation
        F1=MB*((1-C-(v1/v21))/v1);
        
        % Use only real part of statistic
        F1 = real(F1);

        % Significance value associated to the observed F statistic
        P1 = 1 - fcdf(F1, v1, v21);
    
        % Values to return
        v = [v1 v21];
        Saprox = F1;
        P = P1;
        
    else
        
        % Numerator degrees of freedom
        v1=(p*(p+1)*(g-1))/2;
        
        % Denominator degrees of freedom
        v22=fix((v1+2)/((C^2)-Co));
        b=v22/(1-C-(2/v22));
        
        % F approximation
        F2 = (v22 * MB) / (v1 * (b - MB));
        
        % Use only real part of statistic
        F2 = real(F2);
        
        % Significance value associated to the observed F statistic.
        P2 = 1 - fcdf(F2, v1, v22);

        % Values to return
        v = [v1 v22];
        Saprox = F2;
        P = P2;
        
    end;
end;
