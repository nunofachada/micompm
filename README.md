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

Follow _micompm_'s [User Guide] to get started.

### Dependencies

* [MATLAB Statistics toolbox] / [Octave statistics package]

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
* The generated LaTeX tables are not directly configurable using function
arguments.

### License

[MIT License](LICENSE)

[micompr]: https://github.com/fakenmc/micompr
[R]: https://www.r-project.org/
[MATLAB]: http://www.mathworks.com/products/matlab/
[Octave]: https://gnu.org/software/octave/
[User Guide]: docs/userguide.md
[MATLAB Statistics toolbox]: https://www.mathworks.com/products/statistics.html
[Octave statistics package]: https://octave.sourceforge.io/statistics/
