---
title: 'micompm: A MATLAB/Octave toolbox for multivariate independent comparison of observations'
tags:
  - multivariate distributions
  - multivariate statistics
  - gnu octave
  - matlab
  - statistical comparison
  - statistical tests
  - principal component analysis
authors:
 - name: Nuno Fachada
   orcid: 0000-0002-8487-5837
   affiliation: 1,2
 - name: Agostinho C. Rosa
   orcid: 0000-0001-5165-3114
   affiliation: 2
affiliations:
 - name: HEI-LAB - Digital Human-Environment and Interactions Labs, Universidade Lusófona de Humanidades e Tecnologias
   index: 1
 - name: Institute for Systems and Robotics (ISR/IST), LARSyS, Instituto Superior Técnico, Universidade de Lisboa
   index: 2
date: 22 September 2017
bibliography: paper.bib
---

# Summary

_micompm_ is a MATLAB [@matlab2013] / GNU Octave [@eaton1997gnu] port of the
original _micompr_ [@fachada2016micompr] R [@r2017stats] package for comparing
multivariate samples associated with different groups. Its purpose is to
determine if the compared samples are significantly different from a
statistical point of view. This method, described in detail by
@fachada2017model, uses principal component analysis to convert multivariate
observations into a set of linearly uncorrelated statistical measures, which
are then compared using statistical tests and score plots. This technique is
independent of the distributional properties of samples and automatically
selects features that best explain their differences, avoiding manual selection
of specific points or summary statistics. The procedure is appropriate for
comparing samples of time series, images, spectrometric measures or similar
multivariate observations.

# References
