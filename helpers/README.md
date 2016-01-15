### micompm

#### List of helper functions

* [is_octave](is_octave.m) - Checks if the code is running in Octave or
MATLAB.

* [ltxpv](ltxpv.m) - Formats a p-value for LaTeX, using exponents and/or 
truncating very low _p_-values, and underlining/double-underlining _p_-values 
below user specified limits (defaulting to 0.05 for underline and 0.01 for
double-underline). Requires [siunitx] and [ulem] LaTeX packages.

* [tikscatter](tikscatter.m) - Creates a simple TikZ 2D scatter plot within a
`tikzpicture` environment.

[siunitx]: https://www.ctan.org/pkg/siunitx
[ulem]: https://www.ctan.org/pkg/ulem
