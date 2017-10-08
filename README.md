# LauraeCE: Laurae's R package for Parallel Cross-Entropy Optimization

This R pacakge is meant to be used for Cross-Entropy optimization, which is a global optimization method for both continuous and discrete parameters. It tends to outperform Differential Evolution in my local tests.

Installation:

```r
devtools::install_github("Laurae2/LauraeCE")
```

Original source: https://cran.r-project.org/web/packages/CEoptim/index.html

TO-DO:
* add parallelism.
* add hot loading (use previous optimization)
* add interrupt on the fly while saving data
