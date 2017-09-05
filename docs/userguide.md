micompm - Multivariate independent comparison of observations
=============================================================

1\.  [Introduction](#introduction)  
1.1\.  [What is micompm?](#whatismicompm?)  
1.2\.  [Basic concepts](#basicconcepts)  
1.3\.  [Available functions](#availablefunctions)  
2\.  [The _micompm_ workflow](#the_micompm_workflow)  
2.1\.  [Getting started](#gettingstarted)  
2.2\.  [Data layout and data file format](#datalayoutanddatafileformat)  
2.3\.  [Compare observations from two or more groups](#compareobservationsfromtwoormoregroups)  
2.4\.  [Verify assumptions for the performed parametric tests](#verifyassumptionsfortheperformedparametrictests)  
2.5\.  [Multiple comparisons and different outputs](#multiplecomparisonsanddifferentoutputs)  
2.6\.  [Visualization and publication quality tables](#visualizationandpublicationqualitytables)  
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

<a name="basicconcepts"></a>

### 1.2\. Basic concepts

Given _n_ observations (_m_-dimensional), PCA can be used to obtain their
representation in the principal components (PCs) space (_r_-dimensional). PCs
are ordered by decreasing variance, with the first PCs explaining most of the
variance in the data. At this stage, PCA-reshaped observations associated with
different groups can be compared using statistical methods. More specifically,
hypothesis tests can be used to check if the sample projections on the PC space
are drawn from populations with the same distribution. There are two possible
lines of action:

1. Apply a [MANOVA] test to the samples, where each observation has
_q_-dimensions, corresponding to the first _q_ PCs (dimensions) such that these
explain a user-defined minimum percentage of variance.
2. Apply a univariate test to observations in individual PCs. Possible tests
include the [_t_-test] and the [Mann-Whitney _U_ test] for comparing two
samples, or [ANOVA] and [Kruskal-Wallis test], which are the respective
parametric and non-parametric versions for comparing more than two samples.

The MANOVA test yields a single _p_-value from the simultaneous comparison of
observations along multiple PCs. An equally succinct answer can be obtained
with a univariate test using the [Bonferroni] correction or a similar method
for handling _p_-values from multiple comparisons.

Conclusions concerning whether samples are statistically similar can be drawn
by analyzing the _p_-values produced by the employed statistical tests, which
should be below the typical 1% or 5% when samples are significantly different.
The scatter plot of the first two PC dimensions can also provide visual,
although subjective feedback on sample similarity.

While the procedure is appropriate for comparing multivariate observations with
highly correlated and similar scale dimensions, assessing the similarity of
“systems” with multiple outputs of different scales is also possible. The
simplest approach would be to apply the proposed method to samples of
individual outputs, and analyze the results in a multiple comparison context.
An alternative approach consists in concatenating, observation-wise, all
outputs, centered and scaled to the same order of magnitude, thus reducing a
“system” with k outputs to a “system” with one output. The proposed method
would then be applied to samples composed of concatenated observations
encompassing the existing outputs. This technique is described in detail in
reference [\[1\]][ref1] in the context of comparing simulation outputs.

<a name="availablefunctions"></a>

### 1.3\. Available functions

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

<a name="the_micompm_workflow"></a>

## 2\. The _micompm_ workflow

<a name="gettingstarted"></a>

### 2.1\. Getting started

Clone or download _micompm_. Then, either: 1) launch [MATLAB]/[Octave] directly
from the `micompm` folder; or, 2) within [MATLAB]/[Octave], `cd` into the
`micompm` folder and execute the [startup] script.

<a name="datalayoutanddatafileformat"></a>

### 2.2\. Data layout and data file format

The basic data layout used in _micompm_ consists of _n_ x _m_ matrices, each
matrix representing an output, where _n_ is the number of observations and _m_
corresponds to the number of variables or dimensions. Individual observations
in these matrices must be associated with a group. This association is
expressed with a _n_-dimensional integer vector, where its _i_ th value
corresponds to the _i_ th observation (row) of the output matrix. For example:

```
data =

    0.5341    0.6815    0.0190    0.5497   46.4804
    0.0900    3.3933    0.0495    8.5071   34.8334
    0.1117    2.4759    0.0148    5.6056   29.1395
    0.6523    0.0037    0.1980    5.6094   19.8188
    0.7032    6.0581    0.1055    1.5949   12.6425
    0.7911    4.2880    0.0959    3.4867   18.5939

groups =

    1     1     1     2     2     2
```

In this example, the `data` matrix contains six five-dimensional
observations. The `groups` vector specifies that the first three observations
(rows) are associated with group 1, while the last three belong to group 2.

The [grpoutputs] function loads and groups outputs from files containing
observations of the groups to be compared. Each individual file represents an
observation, and must be comprised of numerical data with _m_ rows and _g_
columns, where rows correspond to dimensions or variables and columns to
different outputs. The [grpoutputs] function returns two variables: 1) a cell
array containing _g_ output matrices (_n_ x _m_); and, 2) a _n_-dimensional
integer vector defining the group each observation belongs to. In other words,
[grpoutputs] returns data ready to be used in other _micompm_ functions.

<a name="compareobservationsfromtwoormoregroups"></a>

### 2.3\. Compare observations from two or more groups

The [cmpoutput] function compares observations from two or more groups and is
at the core of the _micompm_ toolbox. Its prototype is as follows:

```matlab
[npcs, p_mnv, p_par, p_npar, score, varexp] = cmpoutput(ve, data, groups, summary)
```

The first parameter, `ve`, specifies the percentage of variance which must be
explained by the principal components (PCs) compared in the [MANOVA] test. More
precisely, it determines the number of PCs used in the test. The second
parameter, `data`, is the _n_ x _m_ output matrix containing the data to be
compared, while the third parameter is the _n_-dimensional vector specifying
the `groups` to which the observations in `data` belong to. The last parameter,
`summary`, is optional and can be set to 0 in order to suppress the comparison
summary shown by default. Besides printing this summary, [cmpoutput] returns
the following information:

* `npcs` - Number of principal components which explain `ve` percentage of
variance.
* `p_mnv` - _P_-values for the [MANOVA] test for `npcs` principal components.
* `p_par` - Vector of _p_-values for the parametric test applied to groups
along each principal component ([_t_-test] for 2 groups, [ANOVA] for more than
2 groups).
* `p_npar` - Vector of _p_-values for the non-parametric test applied to groups
along each principal component ([Mann-Whitney _U_ test] for 2 groups,
[Kruskal-Wallis test] for more than 2 groups).
* `score` - _n_ x (_n_ - 1) matrix containing projections of output data in
the principal components space. Rows correspond to observations, columns to
principal components.
* `varexp` - Percentage of variance explained by each principal component.

<a name="verifyassumptionsfortheperformedparametrictests"></a>

### 2.4\. Verify assumptions for the performed parametric tests

The [cmpoutput] function performs several statistical tests, including the
[_t_-test] (on each PC) and [MANOVA] (on the number of PCs that explain `ve`
percentage of variance). These two tests are parametric, which means they
expect samples to be drawn from distributions with particular characteristics,
namely that: 1) they are drawn from a normally distributed population; and, 2)
they are drawn from populations with equal variances. The [cmp_assumptions]
function performs additional tests that verify these assumptions. It is invoked
as follows:

```matlab
[p_unorm, p_mnorm, p_uvar, p_mvar] = cmp_assumptions(scores, groups, npcs)
```

The function accepts as arguments the PCA `scores` returned by [cmpoutput],
the `groups` to which the observations in `scores` belong to, and the number of
PCs (for the multivariate comparison with [MANOVA]). [cmp_assumptions] returns
_p_-values for the assumptions tests, namely:

* `p_unorm` - Matrix _p_-values from the [Shapiro-Wilk] test for univariate
normality, rows correspond to groups, columns to PCs.
* `p_mnorm` - Vector of _p_-values from the [Royston] test of multivariate
normality (on `npcs`), one _p_-value per group.
* `p_uvar` - Vector of _p_-values from the [Bartlett's] test for equality of
variances, one _p_-value per PC.
* `p_mvar` - _P_-value from the [Box's M] test for the homogeneity of
covariance matrices (on `npcs`).

_P_-values less than the typical 0.05 or 0.01 thresholds may be considered
statistically significant, casting doubt on the respective assumption. However,
as discussed in reference [\[1\]][ref1], analysis of these these _p_-values is
often more elaborate.

<a name="multiplecomparisonsanddifferentoutputs"></a>

### 2.5\. Multiple comparisons and different outputs

The [micomp] function performs multiple comparisons of different outputs,
making use the functionality provided by [grpoutputs] and [cmpoutput]. It is
invoked as follows:

```matlab
c = micomp(nout, ccat, ve, varargin)
```

The `nout` parameter specifies the number of outputs to compare, including an
optional concatenated output. The centering and scaling method for the optional
concatenated output is given in the `ccat` parameter (available options are
'center', 'auto', 'range', 'iqrange', 'vast', 'pareto' or 'level'); if `ccat`
is set to 0 or '', the concatenated output is not generated. The `ve` argument
defines the percentage of variance explained by the _q_ principal components
(i.e. number of dimensions) used in the [MANOVA] test. The remaining arguments,
`varargin`, define the data and the comparisons to be performed.

The [micomp] function returns a struct with several fields containing the
results provided by [cmpoutput] for all comparisons and outputs.

<a name="visualizationandpublicationqualitytables"></a>

### 2.6\. Visualization and publication quality tables

Plots and publication quality tables summarizing the performed comparisons can
be generated with the [micomp_show] function.

*TODO*

<a name="tutorial"></a>

## 3\. Tutorial

The tutorial uses the following dataset, which corresponds to the results
presented in reference [\[2\]][ref2]:

* [![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.46848.svg)](http://dx.doi.org/10.5281/zenodo.46848)

Unpack the dataset to any folder and put the complete path to this folder in
variable `datafolder`:

```matlab
datafolder = 'path/to/dataset';
```

The dataset contains output from several implementations or variants of the
[PPHPC] agent-based model. [PPHPC], discussed in reference  [\[2\]][ref2], is a
realization of prototypical predator-prey system with six outputs:

1. Sheep population
2. Wolves population
3. Quantity of available grass
4. Mean sheep energy
5. Mean wolves energy
6. Mean value of the grass countdown parameter

The following implementations or variants of the [PPHPC] model were used to
generate the data [\[3\]][ref3]:

1. [Canonical NetLogo][pphpc_netlogo] implementation.
2. Parallel [Java][pphpc_java] implementation.
3. Parallel [Java][pphpc_java] variant with agent shuffling disabled.
4. Parallel [Java][pphpc_java] variant with a slight difference in one the of
simulation parameters.

The first two implementations strictly follow the [PPHPC] conceptual model
[\[2\]][ref2], and should generate statistically similar outputs. Variants 3
and 4 are purposefully misaligned, and should yield outputs with statistically
significant differences from the first two. The datasets were collected under
five different model sizes (100 _x_ 100, 200 _x_ 200, 400 _x_ 400, 800 _x_ 800
and 1600 _x_ 1600) and two distinct parameterizations (_v1_ and _v2_), as
discussed in reference [\[3\]][ref3].

**TODO** Finish the remaining tutorial...

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

[ref1]: #ref1
[ref2]: #ref2
[ref3]: #ref3
[NetLogo]: https://ccl.northwestern.edu/netlogo/
[PPHPC]: https://github.com/fakenmc/pphpc
[pphpc_netlogo]: https://github.com/fakenmc/pphpc/tree/netlogo
[pphpc_java]: https://github.com/fakenmc/pphpc/tree/java
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
[3rd party]: ``../3rdparty
[micompr]: https://github.com/fakenmc/micompr
[R]: https://www.r-project.org/
[Matlab]: http://www.mathworks.com/products/matlab/
[Octave]: https://gnu.org/software/octave/
[tests]: ../tests
[MOxUnit]: https://github.com/MOxUnit/MOxUnit
[MANOVA]: https://en.wikipedia.org/wiki/Multivariate_analysis_of_variance
[_t_-test]: https://en.wikipedia.org/wiki/Student%27s_t-test
[Mann-Whitney _U_ test]: https://en.wikipedia.org/wiki/Mann%E2%80%93Whitney_U_test
[ANOVA]: https://en.wikipedia.org/wiki/Analysis_of_variance
[Kruskal-Wallis test]: https://en.wikipedia.org/wiki/Kruskal%E2%80%93Wallis_one-way_analysis_of_variance
[Bonferroni]: https://en.wikipedia.org/wiki/Bonferroni_correction
[Shapiro-Wilk]: https://en.wikipedia.org/wiki/Shapiro%E2%80%93Wilk_test
[Royston]: https://www.jstor.org/stable/2347291
[Box's M]:https://en.wikiversity.org/wiki/Box%27s_M
[Bartlett's]: https://en.wikipedia.org/wiki/Bartlett%27s_test
