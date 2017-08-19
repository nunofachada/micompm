### Summary

_micompm_ is a [MATLAB]/[Octave] port of the original [micompr] [R] package for
comparing multivariate samples associated with different groups. It uses
principal component analysis to convert multivariate observations into a set of
linearly uncorrelated statistical measures, which are then compared using a
number of statistical methods. This technique is independent of the
distributional properties of samples and automatically selects features that
best explain their differences, avoiding manual selection of specific points or
summary statistics. The procedure is appropriate for comparing samples of time
series, images, spectrometric measures or similar multivariate observations.

### List of functions

* [grpoutputs] - Load and group outputs from files containing multiple
observations of the groups to be compared.

* [cmpoutput] - Compares output observations from two or more groups.

* [micomp] - Performs multiple independent comparisons of output observations.

* [micomp_show] - Generate tables and plots of model-independent comparison of
observations.

* [cmp_assumptions] - Verify the assumptions for parametric tests applied to
the comparison of output observations.

_micompm_ uses additional [helper] and [3rd party] functions.

### Theory

* Fachada N, Lopes VV, Martins RC, Rosa AC. (2017)
Model-independent comparison of simulation output. *Simulation Modelling
Practice and Theory*. 72:131–149. http://dx.doi.org/10.1016/j.simpat.2016.12.013
([arXiv preprint](http://arxiv.org/abs/1509.09174))

### Limitations

This port has the following limitations when compared with the original R
[implementation][micompr]:

* It does not support outputs with different lengths.
* It does not directly provide _p_-values adjusted with the weighted Bonferroni
procedure.
* It is unable to directly apply and compare multiple MANOVA tests to each
output/comparison combination for multiple user-specified variances to explain.

### License

[MIT License](LICENSE)

[grpoutputs]: micompm/grpoutputs.m
[cmpoutput]: micompm/cmpoutput.m
[micomp]: micompm/micomp.m
[micomp_show]: micompm/micomp_show.m
[cmp_assumptions]: micompm/cmp_assumptions.m
[helper]: helpers
[3rd party]: 3rdparty
[micompr]: https://github.com/fakenmc/micompr
[R]: https://www.r-project.org/
[Matlab]: http://www.mathworks.com/products/matlab/
[Octave]: https://gnu.org/software/octave/

