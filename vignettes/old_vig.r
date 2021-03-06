Our example in `help(venus)` has this setup, but with
larger variances:

<!-- ```{r}
  set.seed(12345)
  library(MASS)
  library(venus)
  sigma2.e.x <- 4.7*3*0.01
  sigma2.e <- 7.3/2*0.01
  ## Z are the control variables or nuisance variables
  Z <- mvrnorm(1000, c(0,0,0),
             matrix(c(1,.3,.3,.3,1,.3,.3,.3,1), ncol=3),
             empirical=TRUE)
  ## X is the variable of interest that has a non-linear relationship to
  ## one of the elements in Z 
  X <- Z[,1] + Z[,1]^2 + Z[,2] + rnorm(1000, 0, sqrt(sigma2.e.x))

  df <- data.frame(z1 = Z[,1], z2=Z[,2], z3 = Z[,3], x=scale(X))
  ## make y a linear function of x and the z variables,
  ## so the theoretical coefficient on x is 1
  df$y <- with(df, z1 + z2 + z3 + x) + rnorm(1000, 0, sqrt(sigma2.e))
  ```
  
Mathematically this can be expressed as:
\[
\begin{align}
Z & \sim & MVN\left(\left(\begin{array}{c}0 \\ 0 \\ 0\end{array}\right), 
              \left(\begin{array}{ccc}1 & 0.3 & 0.3 \\
                     0.3 & 1 & 0.3 \\
                     0.3 & 0.3 & 1 \end{array} \right) \right)\\
X & \sim & N(Z_1 + Z_1^2 + Z_2, \sigma^2_{ex}) \\
x & = & \mbox{Scaled, centred X} \\
y & \sim & N(Z_1 + Z_2 + Z_3 + x, \sigma^2_e)
\end{align}
\]

Pairwise plots:

```{r fig.width=6, fig.height=6}
  pairs(df)
```

We partial out the nuisance variables using `venus(y ~ x, nuisance = y ~ .-x, data = df)`.  These are the steps
of that calculation:

First, fit the nuisance model:
```{r}
library(earth)
nuisanceFit <- earth(y ~ .-x, data = df)
yResids <- residuals(nuisanceFit)
```

Now extract the predictors that were chosen, and get residuals
on X:
```{r}
nuisanceModelmatrix <- model.matrix(nuisanceFit)
xResids <- residuals(lm(x ~ nuisanceModelmatrix, data = df))
```

and plot again:

```{r}
plot(yResids ~ xResids)
```

Here's the interesting linear model:

```{r results='asis'}
library(xtable); options(xtable.type = "html")
xtable(lm(yResids ~ xResids - 1))
```

# What happens if $x = z_1^2$?

If $x$ is an error free function of one of the
nuisance variables, we would expect that it adds nothing to
the regression.  However, if it is a nonlinear function, we
might not recognize that.  We try it with our function:

```{r}
  X <- Z[,1]^2
  df <- data.frame(z1 = Z[,1], z2=Z[,2], z3 = Z[,3], x=scale(X))
  ## make y a linear function of x and the z variables,
  ## so the theoretical coefficient on x is 1, but
  ## z1^2 gives the same information
  df$y <- with(df, z1 + z2 + z3 + x) + rnorm(1000, 0, sqrt(sigma2.e))
  ```
 
  Pairwise plots:

```{r fig.width=6, fig.height=6}
  pairs(df)
```

The `venus()` fit:

```{r}
  summary(venus(y ~ x, nuisance = y ~ .-x, data = df))

  # Compare to the pure linear fit

  summary(venus(y ~ x, nuisance = y ~ .-x, method = c("lm", "lm"), data=df))
``` -->
