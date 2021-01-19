Advanced: Constructing a custom backbone
================

<!-- github markdown built using 
rmarkdown::render("vignettes/advanced_constructing_backbone.Rmd", output_format = rmarkdown::github_document())
-->

You may want to construct your own custom backbone as opposed to those
predefined in dyngen in order to obtain a desired effect. You can do so
in one of two ways.

## Backbone lego

You can use the `bblego` functions in order to create custom backbones
using so-called ‘backbone lego blocks’. Please note that `bblego` only
allows you to create tree-shaped backbones (so no cycles), but in 90% of
cases will be exactly what you need and in the remaining 10% of cases
these functions will still get you 80% of where you need to be.

Here is an example of a bifurcating trajectory.

``` r
library(dyngen)
library(tidyverse)

backbone <- bblego(
  bblego_start("A", type = "simple", num_modules = 2),
  bblego_linear("A", "B", type = "flipflop", num_modules = 4),
  bblego_branching("B", c("C", "D"), type = "simple"),
  bblego_end("C", type = "doublerep2", num_modules = 4),
  bblego_end("D", type = "doublerep1", num_modules = 7)
)

out <- 
  initialise_model(
    backbone = backbone,
    num_tfs = 40,
    num_targets = 0,
    num_hks = 0,
    verbose = FALSE
  ) %>% 
  generate_dataset(make_plots = TRUE)
```

``` r
print(out$plot)
```

![](advanced_constructing_backbone_files/figure-gfm/bblego-1.png)<!-- -->

Check the following predefined backbones for some examples.

-   [backbone\_bifurcating](https://github.com/dynverse/dyngen/blob/master/R/2c_backbones.R#L3-L11)
-   [backbone\_branching](https://github.com/dynverse/dyngen/blob/master/R/2c_backbones.R#L195-L273)
-   [backbone\_linear](https://github.com/dynverse/dyngen/blob/master/R/2c_backbones.R#L420-L427)

## Manually constructing backbone data frames

To get the most control over how a dyngen simulation is performed, you
can construct a backbone manually (see `?backbone` for the full spec).
This is the only way to create some of the more specific backbone shapes
such as disconnected, cyclic and converging.

This is an example of what data structures a backbone consists of.

### Module info

A tibble containing meta information on the modules themselves. A module
is a group of genes which, to some extent, shows the same expression
behaviour. Several modules are connected together such that one or more
genes from one module will regulate the expression of another module. By
creating chains of modules, a dynamic behaviour in gene regulation can
be created.

-   module\_id (character): the name of the module
-   basal (numeric): basal expression level of genes in this module,
    must be between \[0, 1\]
-   burn (logical): whether or not outgoing edges of this module will be
    active during the burn in phase
-   independence (numeric): the independence factor between regulators
    of this module, must be between \[0, 1\]

``` r
module_info <- tribble(
  ~module_id, ~basal, ~burn, ~independence,
  "A1", 1, TRUE, 1,
  "A2", 0, TRUE, 1,
  "A3", 1, TRUE, 1,
  "B1", 0, FALSE, 1,
  "B2", 1, TRUE, 1,
  "C1", 0, FALSE, 1,
  "C2", 0, FALSE, 1,
  "C3", 0, FALSE, 1,
  "D1", 0, FALSE, 1,
  "D2", 0, FALSE, 1,
  "D3", 1, TRUE, 1,
  "D4", 0, FALSE, 1,
  "D5", 0, FALSE, 1
)
```

### Module network

A tibble describing which modules regulate which other modules.

-   from (character): the regulating module
-   to (character): the target module
-   effect (integer): 1L if the regulating module upregulates the target
    module, -1L if it downregulates
-   strength (numeric): the strength of the interaction
-   hill (numeric): hill coefficient, larger than 1 for positive
    cooperativity, between 0 and 1 for negative cooperativity

``` r
module_network <- tribble(
  ~from, ~to, ~effect, ~strength, ~hill,
  "A1", "A2", 1L, 10, 2,
  "A2", "A3", -1L, 10, 2,
  "A2", "B1", 1L, 1, 2,
  "B1", "B2", -1L, 10, 2,
  "B1", "C1", 1L, 1, 2,
  "B1", "D1", 1L, 1, 2,
  "C1", "C1", 1L, 10, 2,
  "C1", "D1", -1L, 100, 2,
  "C1", "C2", 1L, 1, 2,
  "C2", "C3", 1L, 1, 2,
  "C2", "A2", -1L, 10, 2,
  "C2", "B1", -1L, 10, 2,
  "C3", "A1", -1L, 10, 2,
  "C3", "C1", -1L, 10, 2,
  "C3", "D1", -1L, 10, 2,
  "D1", "D1", 1L, 10, 2,
  "D1", "C1", -1L, 100, 2,
  "D1", "D2", 1L, 1, 2,
  "D1", "D3", -1L, 10, 2,
  "D2", "D4", 1L, 1, 2,
  "D4", "D5", 1L, 1, 2,
  "D3", "D5", -1L, 10, 2
)
```

### Expression patterns

A tibble describing the expected expression pattern changes when a cell
is simulated by dyngen. Each row represents one transition between two
cell states.

-   from (character): name of a cell state
-   to (character): name of a cell state
-   module\_progression (character): differences in module expression
    between the two states. Example: “+4,-1\|+9\|-4” means the
    expression of module 4 will go up at the same time as module 1 goes
    down; afterwards module 9 expression will go up, and afterwards
    module 4 expression will go down again.
-   start (logical): Whether or not this from cell state is the start of
    the trajectory
-   burn (logical): Whether these cell states are part of the burn in
    phase. Cells will not get sampled from these cell states.
-   time (numeric): The duration of an transition.

``` r
expression_patterns <- tribble(
  ~from, ~to, ~module_progression, ~start, ~burn, ~time,
  "sBurn", "sA", "+A1,+A2,+A3,+B2,+D3", TRUE, TRUE, 60,
  "sA", "sB", "+B1", FALSE, FALSE, 60,
  "sB", "sC", "+C1,+C2|-A2,-B1,+C3|-C1,-D1,-D2", FALSE, FALSE, 80,
  "sB", "sD", "+D1,+D2,+D4,+D5", FALSE, FALSE, 120,
  "sC", "sA", "+A1,+A2", FALSE, FALSE, 60
)
```

### Visualising the backbone

By wrapping these data structures as a backbone object, we can now
visualise the topology of the backbone. Drawing the backbone module
network by hand on a piece of paper can help you understand how the gene
regulatory network works.

``` r
backbone <- backbone(
  module_info = module_info,
  module_network = module_network,
  expression_patterns = expression_patterns
)

model <- initialise_model(
  backbone = backbone,
  num_tfs = nrow(backbone$module_info),
  num_targets = 0,
  num_hks = 0,
  simulation_params = simulation_default(
    experiment_params = simulation_type_wild_type(num_simulations = 100),
    total_time = 600
  ),
  verbose = FALSE
)

plot_backbone_modulenet(model)
```

![](advanced_constructing_backbone_files/figure-gfm/bifurcatingloop_print-1.png)<!-- -->

``` r
plot_backbone_statenet(model)
```

![](advanced_constructing_backbone_files/figure-gfm/bifurcatingloop_print-2.png)<!-- -->

### Simulation

This allows you to simulate the following dataset.

``` r
out <- generate_dataset(model, make_plots = TRUE)
```

``` r
print(out$plot)
```

![](advanced_constructing_backbone_files/figure-gfm/bifurcatingloop_plot-1.png)<!-- -->

### More information

dyngen has a lot of predefined backbones. The following predefined
backbones construct the backbone manually (as opposed to using bblego).

-   [backbone\_bifurcating\_converging](https://github.com/dynverse/dyngen/blob/master/R/2c_backbones.R#L16-L61)
-   [backbone\_bifurcating\_cycle](https://github.com/dynverse/dyngen/blob/master/R/2c_backbones.R#L66-L127)
-   [backbone\_bifurcating\_loop](https://github.com/dynverse/dyngen/blob/master/R/2c_backbones.R#L132-L186)
-   [backbone\_binary\_tree](https://github.com/dynverse/dyngen/blob/master/R/2c_backbones.R#L278-L282)
-   [backbone\_consecutive\_bifurcating](https://github.com/dynverse/dyngen/blob/master/R/2c_backbones.R#L287-L289)
-   [backbone\_converging](https://github.com/dynverse/dyngen/blob/master/R/2c_backbones.R#L299-L349)
-   [backbone\_cycle](https://github.com/dynverse/dyngen/blob/master/R/2c_backbones.R#L353-L384)
-   [backbone\_cycle\_simple](https://github.com/dynverse/dyngen/blob/master/R/2c_backbones.R#L388-L416)
-   [backbone\_disconnected](https://github.com/dynverse/dyngen/blob/master/R/2c_backbones.R#L468-L572)
-   [backbone\_linear\_simple](https://github.com/dynverse/dyngen/blob/master/R/2c_backbones.R#L432-L457)
-   [backbone\_trifurcating](https://github.com/dynverse/dyngen/blob/master/R/2c_backbones.R#L293-L295)

<!--
## Combination of bblego and manual

You can also use parts of the 'bblego' framework to construct a backbone manually.
That's because the bblego functions simply generate the three data frames 
(`module_info`, `module_network` and `expression_patterns`) required to construct
a backbone manually. For example:


```r
part1 <- bblego_start("A", type = "simple", num_modules = 2)
part1
```

```
## $module_info
## # A tibble: 2 x 4
##   module_id basal burn  independence
##   <chr>     <dbl> <lgl>        <dbl>
## 1 Burn1         1 TRUE             1
## 2 Burn2         0 TRUE             1
## 
## $module_network
## # A tibble: 2 x 5
##   from  to    effect strength  hill
##   <chr> <chr>  <int>    <dbl> <dbl>
## 1 Burn1 Burn2      1        1     2
## 2 Burn2 A1         1        1     2
## 
## $expression_patterns
## # A tibble: 1 x 6
##   from  to    module_progression start burn   time
##   <chr> <chr> <chr>              <lgl> <lgl> <dbl>
## 1 sBurn sA    +Burn1,+Burn2      TRUE  TRUE     60
```


```r
part2 <- bblego_linear("A", "B", type = "flipflop", num_modules = 4)
part2
```

```
## $module_info
## # A tibble: 4 x 4
##   module_id basal burn  independence
##   <chr>     <dbl> <lgl>        <dbl>
## 1 A1            0 FALSE            1
## 2 A2            0 FALSE            1
## 3 A3            0 FALSE            1
## 4 A4            0 FALSE            1
## 
## $module_network
## # A tibble: 7 x 5
##   from  to    effect strength  hill
##   <chr> <chr>  <int>    <dbl> <dbl>
## 1 A1    A2         1        1     2
## 2 A2    A3         1        1     2
## 3 A3    A4         1        1     2
## 4 A4    B1         1        1     2
## 5 A4    A1        -1       10     2
## 6 A3    B1        -1      100     2
## 7 A4    A4         1        1     2
## 
## $expression_patterns
## # A tibble: 1 x 6
##   from  to    module_progression start burn   time
##   <chr> <chr> <chr>              <lgl> <lgl> <dbl>
## 1 sA    sB    +A1,+A2,+A3,+A4    FALSE FALSE   240
```


```r
part3 <- bblego_linear("B", "C", type = "simple", num_modules = 2)
part3
```

```
## $module_info
## # A tibble: 2 x 4
##   module_id basal burn  independence
##   <chr>     <dbl> <lgl>        <dbl>
## 1 B1            0 FALSE            1
## 2 B2            0 FALSE            1
## 
## $module_network
## # A tibble: 2 x 5
##   from  to    effect strength  hill
##   <chr> <chr>  <int>    <dbl> <dbl>
## 1 B1    B2         1        1     2
## 2 B2    C1         1        1     2
## 
## $expression_patterns
## # A tibble: 1 x 6
##   from  to    module_progression start burn   time
##   <chr> <chr> <chr>              <lgl> <lgl> <dbl>
## 1 sB    sC    +B1,+B2            FALSE FALSE    60
```

You can create a cyclic dataset by adding a module that represses the A1 module.



```r
part4 <- list(
  module_info = tribble(
    ~module_id, ~basal, ~burn, ~independence,
    "C1", 1, TRUE, 1
  ),
  module_network = tribble(
    ~from, ~to, ~effect, ~strength, ~hill,
    "C1", "A1", -1L, 100, 2
  ),
  expression_patterns = tribble(
    ~from, ~to, ~module_progression, ~start, ~burn, ~time,
    "sC", "sA", "+C1", FALSE, FALSE, 30
  )
)

backbone <- bblego(
  part1,
  part2,
  part3,
  part4
)

model <- initialise_model(
  backbone = backbone,
  num_tfs = 40,
  num_targets = 0,
  num_hks = 0,
  simulation_params = simulation_default(census_interval = 10, ssa_algorithm = ssa_etl(tau = 300 / 3600)),
  verbose = FALSE
)

plot_backbone_modulenet(model)
```

![](advanced_constructing_backbone_files/figure-gfm/cyclic_backbone-1.png)<!-- -->

``` r
plot_backbone_statenet(model)
```

![](advanced_constructing_backbone_files/figure-gfm/cyclic_backbone-2.png)<!-- -->

``` r
out <- generate_dataset(model, make_plots = TRUE)
```

``` r
print(out$plot)
```

![](advanced_constructing_backbone_files/figure-gfm/cyclic_sim-1.png)<!-- -->

Note that, for the gold standard to function correctly, the expression
patterns of part2 and part3 need to be modified, because if the A, B,
and C modules are all on we don’t know in which state the gold standard
simulation will find itself.

–&gt;