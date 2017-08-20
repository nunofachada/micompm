micompm - Multivariate independent comparison of observations
=============================================================

1\.  [Introduction](#introduction)  
1.1\.  [What is micompm?](#whatismicompm?)  
1.2\.  [Available functions](#availablefunctions)  
1.3\.  [Getting started](#gettingstarted)  
2\.  [Basic concepts](#basicconcepts)  
3\.  [Tutorial](#tutorial)  
4\.  [Unit tests](#unittests)  
5\.  [References](#references)  

<a name="introduction"></a>

## 1\. Introduction

<a name="whatismicompm?"></a>

### 1.1\. What is micompm?

_micompm_ is a [MATLAB]/[Octave] port of the original [micompr] [R] package for
comparing multivariate samples associated with different groups. It uses
principal component analysis to convert multivariate observations into a set of
linearly uncorrelated statistical measures, which are then compared using a
number of statistical methods. This technique is independent of the
distributional properties of samples and automatically selects features that
best explain their differences, avoiding manual selection of specific points or
summary statistics. The procedure is appropriate for comparing samples of time
series, images, spectrometric measures or similar multivariate observations.

These utilities are compatible with GNU Octave. However, note that a number of
statistical tests provided by Octave return slightly different _p_-values from
those returned by the equivalent MATLAB functions.

If you use _micompm_, please cite reference [\[1\]][ref1].

<a name="availablefunctions"></a>

### 1.2\. Available functions

The typical _micompm_ workflow is based on the following functions:

* [grpoutputs] - Load and group outputs from files containing multiple
observations of the groups to be compared.
* [cmpoutput] - Compares output observations from two or more groups.
* [micomp] - Performs multiple independent comparisons of output observations.
* [micomp_show] - Generate tables and plots of model-independent comparison of
observations.
* [cmp_assumptions] - Verify the assumptions for parametric tests applied to
the comparison of output observations.

_micompm_ also provides and uses additional [helper] and [3rd party] functions.

<a name="gettingstarted"></a>

### 1.3\. Getting started

Clone or download _micompm_. Then, either: 1) start [MATLAB]/[Octave] directly
in the `micompm` folder; or, 2) within [MATLAB]/[Octave], `cd` into the
`micompm` folder and execute the [startup] script:

```
startup
```

<a name="basicconcepts"></a>

## 2\. Basic concepts

Given _n_ observations (_m_-dimensional), PCA can be used to obtain their
representation in the principal components (PCs) space (_r_-dimensional). PCs
are ordered by decreasing variance, with the first PCs explaining most of the
variance in the data. At this stage, PCA-reshaped observations associated with
different groups can be compared using statistical methods. More specifically,
hypothesis tests can be used to check if the sample projections on the PC space
are drawn from populations with the same distribution. There are two possible
lines of action:

1. Apply a [MANOVA] test to the samples, where each observation has q-dimensions,
corresponding to the first q PCs (dimensions) such that these explain a
user-defined minimum percentage of variance.
2. Apply a univariate test to observations in individual PCs. Possible tests
include the [t-test] and the [Mann-Whitney U test] for comparing two samples,
or [ANOVA] and [Kruskal-Wallis test], which are the respective parametric and
non-parametric versions for comparing more than two samples.

The MANOVA test yields a single p-value from the simultaneous comparison of
observations along multiple PCs. An equally succinct answer can be obtained
with a univariate test using the [Bonferroni] correction or a similar method
for handling _p_-values from multiple comparisons.

Conclusions concerning whether samples are statistically similar can be drawn
by analyzing the _p_-values produced by the employed statistical tests, which
should be below the typical 1% or 5% when samples are significantly different.
The scatter plot of the first two PC dimensions can also provide visual,
although subjective feedback on sample similarity.

While the procedure is most appropriate for comparing multivariate observations
with highly correlated and similar scale dimensions, assessing the similarity
of “systems” with multiple outputs of different scales is also possible. The
simplest approach would be to apply the proposed method to samples of
individual outputs, and analyze the results in a multiple comparison context.
An alternative approach consists in concatenating, observation-wise, all
outputs, centered and scaled to the same order of magnitude, thus reducing a
“system” with k outputs to a “system” with one output. The proposed method
would then be applied to samples composed of concatenated observations
encompassing the existing outputs. This technique is described in detail in
reference [\[1\]][ref1] in the context of comparing simulation outputs.


<a name="tutorial"></a>

## 3\. Tutorial

The examples use the following datasets:

1. [![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.34049.svg)](http://dx.doi.org/10.5281/zenodo.34049)
2. [![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.46848.svg)](http://dx.doi.org/10.5281/zenodo.46848)

These datasets correspond to the results presented in references [\[3\]][ref3]
and [\[4\]][ref4], respectively.

Unpack the datasets to any folder and put the complete path to these folders in
variables `datafolder1` and `datafolder2`, respectively:

```matlab
datafolder1 = 'path/to/dataset1';
datafolder2 = 'path/to/dataset2';
```

The datasets contain output from several implementations of the [PPHPC]
agent-based model. [PPHPC] is a realization of prototypical predator-prey
system with six outputs:

1. Sheep population
2. Wolves population
3. Quantity of available grass
4. Mean sheep energy
5. Mean wolves energy
6. Mean value of the grass countdown parameter

Dataset 1 contains output from the NetLogo implementation and from six variants
of a parallel Java implementation, namely, ST, EQ, EX, ER and OD. These
implementations and variants are *aligned*, i.e., they display the same dynamic
behavior. Dataset 2 contains aligned output from the NetLogo and Java EX
implementations, and also output from two purposefully misaligned versions of
the latter.

The datasets were collected under five different model sizes (100 _x_ 100,
200 _x_ 200, 400 _x_ 400, 800 _x_ 800 and 1600 _x_ 1600) and two distinct
parameterizations (_v1_ and _v2_).

<a name="unittests"></a>

## 4\. Unit tests

The _micompm_ unit tests require the [MOxUnit] framework. Set the appropriate
path to this framework as specified in the respective instructions, `cd` into
the [tests] folder and execute the following instruction:

```
moxunit_runtests
```

The tests can take a few minutes to run.

<a name="references"></a>

## 5\. References

<a name="ref1"></a>

[\[1\]][ref1] Fachada N, Lopes VV, Martins RC, Rosa AC. (2017)
Model-independent comparison of simulation output. *Simulation Modelling
Practice and Theory*. 72:131–149. http://dx.doi.org/10.1016/j.simpat.2016.12.013
([arXiv preprint](http://arxiv.org/abs/1509.09174))

<a name="ref2"></a>

[\[2\]][ref2] Fachada N, Lopes VV, Martins RC, Rosa AC. (2015) Towards a
standard model for research in agent-based modeling and simulation. *PeerJ
Computer Science* 1:e36. https://doi.org/10.7717/peerj-cs.36

<a name="ref3"></a>

[\[3\]][ref3] Fachada N, Lopes VV, Martins RC, Rosa AC. (2017)
Parallelization strategies for spatial agent-based models. *International
Journal of Parallel Programming*. 45(3):449–481.
http://dx.doi.org/10.1007/s10766-015-0399-9
([arXiv preprint](http://arxiv.org/abs/1507.04047))

<a name="ref4"></a>

[\[4\]][ref4] Fachada N, Lopes VV, Martins RC, Rosa AC. (2017)
Model-independent comparison of simulation output. *Simulation Modelling
Practice and Theory*. 72:131–149. http://dx.doi.org/10.1016/j.simpat.2016.12.013
([arXiv preprint](http://arxiv.org/abs/1509.09174))

<a name="ref5"></a>

[\[5\]][ref5] Willink R. (2005) A Confidence Interval and Test for the Mean of
an Asymmetric Distribution. *Communications in Statistics - Theory and Methods*
34 (4): 753–766. https://doi.org/10.1081%2FSTA-200054419

<a name="ref6"></a>

[\[6\]][ref6] Gibbons JD, Chakraborti S. (2010) *Nonparametric statistical
inference*. Chapman and Hall/CRC

<a name="ref7"></a>

[\[7\]][ref7] Montgomery DC, Runger GC. (2014) *Applied statistics and
probability for engineers*. John Wiley \& Sons

<a name="ref8"></a>

[\[8\]][ref8] Kruskal WH, Wallis WA. (1952) Use of Ranks in One-Criterion
Variance Analysis. *Journal of the American Statistical Association* 47 (260):
583–621

[ref1]: #ref1
[ref2]: #ref2
[ref3]: #ref3
[ref4]: #ref4
[ref5]: #ref5
[ref6]: #ref6
[ref7]: #ref7
[ref8]: #ref8
[NetLogo]: https://ccl.northwestern.edu/netlogo/
[PPHPC]: https://github.com/fakenmc/pphpc
[siunitx]: https://www.ctan.org/pkg/siunitx
[ulem]: https://www.ctan.org/pkg/ulem
[multirow]: https://www.ctan.org/pkg/multirow
[booktabs]: https://www.ctan.org/pkg/booktabs
[startup]: ../startup.m
[grpoutputs]: ../micompm/grpoutputs.m
[cmpoutput]: ../micompm/cmpoutput.m
[micomp]: ../micompm/micomp.m
[micomp_show]: ../micompm/micomp_show.m
[cmp_assumptions]: ../micompm/cmp_assumptions.m
[helper]: ../helpers
[3rd party]: ../3rdparty
[micompr]: https://github.com/fakenmc/micompr
[R]: https://www.r-project.org/
[Matlab]: http://www.mathworks.com/products/matlab/
[Octave]: https://gnu.org/software/octave/
[tests]: ../tests
[MOxUnit]: https://github.com/MOxUnit/MOxUnit
[MANOVA]: https://en.wikipedia.org/wiki/Multivariate_analysis_of_variance
[t-test]: https://en.wikipedia.org/wiki/Student%27s_t-test
[Mann-Whitney U test]: https://en.wikipedia.org/wiki/Mann%E2%80%93Whitney_U_test
[ANOVA]: https://en.wikipedia.org/wiki/Analysis_of_variance
[Kruskal-Wallis test]: https://en.wikipedia.org/wiki/Kruskal%E2%80%93Wallis_one-way_analysis_of_variance
[Bonferroni]: https://en.wikipedia.org/wiki/Bonferroni_correction
