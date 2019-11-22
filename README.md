MTBF is one of the reliability metrics that is oftenly thrown around.
It is popular because 'mean time between failure' is handy. But it can be misleading.
It doesn't mean what some people think it means.
Some consider it as lifetime of a product, which is not. Other use it to plan their regular maintenance in order to avoid failure, i.e MTBF of 2 years 'means' regular maintenance every 2 years. Which is not a correct approach.
In short MTBF is not a failure free period, this is where people sometimes are mislead.

MTBF is an expression of how often a piece of component will randomly fail, or an inverse of failure rate, if we are talking about component with exponential failure distribution. 


In many cases, when we use MTBF, it is taken from constant failure rate, or from exponential distribution. Looking back at bathtub Curve, constant failure rate is period where the product is in its useful life period after infant mortality. 
If we express 

MTBF -> constant failure -> exponential distribution -> reliability -> 36% -> its meaning on probable failure numbers -> example chart monte carlo MTBF equal mission time -> app
To clarify what MTBF actually is, I created a small app to illustrate the relation between MTBF, reliability, and numbers of probable failures. You can access it at https://manunk.shinyapps.io/monte-carlo-simulation-of-mtbf/. The source code is available at https://github.com/manunggal/Monte-Carlo-Simulation-of-MTBF.
