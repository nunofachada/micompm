### Summary

_micompm_ is a MATLAB/Octave package for comparing simulation output, ported
from [micompr], the original [R] package.

### List of functions

* [grpoutputs] - Group outputs from multiple observations of the models to be
compared.

* [cmpoutput] - Compares one output from several runs of two or more model
implementations.

* [micomp] - Perform multiple model-independent comparisons of simulation
outputs.

* [micomp_show] - Generate tables and plots of model-independent comparison of
simulation output.

* [test_assumptions] - Get assumptions for the parametric tests performed in
a comparison.

_micompm_ uses additional [helper] and [3rd party] functions.

### Theory

[Model-independent comparison of simulation output](http://arxiv.org/abs/1509.09174),
arXiv preprint.

### Limitations

This port has the following limitations when compared with the original [R]
[implementation][micompr]:

* It does not support outputs with different lengths.
* It does not directly provide _p_-values adjusted with the weighted Bonferroni
procedure.

### License

[MIT License](LICENSE)

[grpoutputs]: micompm/grpoutputs.m
[cmpoutput]: micompm/cmpoutput.m
[micomp]: micompm/micomp.m
[micomp_show]: micompm/micomp_show.m
[test_assumptions]: micompm/test_assumptions.m
[helper]: helpers
[3rd party]: 3rdparty
[micompr]: https://github.com/fakenmc/micompr
[R]: https://www.r-project.org/
