{smcl}
{* *! version 1.0  25Mar2024}{...}
{cmd:help ge_gravity2} 
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col:{hi: ge_gravity2} {hline 2} Solves a gravity model within the universal gravity class (with a positive supply elasticity).}
{p2colreset}{...}

{title:Syntax}
	
{p 8 15 2}{cmd:ge_gravity2}
{it: exp_id} {it: imp_id} {it: flows} {it: partial}
{ifin}{cmd:,} {opt theta(#)} [{opt psi(#)} {it:{help ge_gravity2##gen_options:gen_options}} {it:{help ge_gravity2##other_options:other_options}}] {p_end}

{synoptset 20 tabbed}{...}

{synopthdr: Required variables}
{synoptline}
{synopt : exp_id} identifies the origin {p_end}
{synopt : imp_id} identifies the destination {p_end}
{synopt : flows} contains bilateral trade flows {p_end}
{synopt : partial} contains the "partial" estimate of the effect {p_end}
{synoptline}

{synoptset 20 tabbed}{...}

{synopthdr: Elasticities}
{synoptline}
{synopt : theta(#)} sets the trade elasticity, which must be strictly positive {p_end}
{synopt : psi(#)} sets the aggregate supply elasticity, which must be nonnegative; optional, default is {cmd:psi(0)} {p_end}
{synoptline}

{synoptset 20 tabbed}{...}
{marker gen_options}
{synopthdr: Generate variables}
{synoptline}

{syntab: {it:Universal gravity}}

{synopt : gen_X(varname)} generates counterfactual trade flows {p_end}
{synopt : gen_rp(varname)} generates the change in real prices (p_hat/P_hat) {p_end}
{synopt : gen_y(varname)} generates the change in income (Y_hat) {p_end}
{synopt : gen_x(varname)} generates the change in trade flows (X_hat) {p_end}
{synopt : gen_p(varname)} generates the change in output prices (p_hat) {p_end}
{synopt : gen_P(varname)} generates the change in price indices (P_hat) {p_end}

{syntab: {it:Prototypical trade model}}

{synopt : gen_w(varname)} generates the change in welfare (W_hat) {p_end}
{synopt : gen_q(varname)} generates the change in real output (Q_hat) {p_end}
{synopt : gen_rw(varname)} generates the change in real wages (w_hat/P_hat) {p_end}
{synopt : gen_nw(varname)} generates the change in nominal wages (w_hat) {p_end}
{synoptline}
{marker other_options}
{synopthdr: Other options}
{synoptline}
{synopt : {opt r:esults}} prints a table with results {p_end}
{synopt : {opt uni:versal}} assumes universal trade deficits {p_end}
{synopt : {opt mult:iplicative}} assumes trade deficits that imply E_hat = Y_hat {p_end}
{synopt : c_hat(matrix)} changes supply shifters {p_end}
{synopt : a_hat(matrix)} changes productivity {p_end}
{synopt : l_hat(matrix)} changes the labor force {p_end}
{synopt : xi_hat(matrix)} changes trade deficits {p_end}
{synopt : tol(#)} sets the tolerance level to verify convergence of the price vector; must be a strictly positive real number; default is {cmd:tol(1e-12)} {p_end}
{synopt : max_iter(#)} sets the maximum number of iterations to solve for the price vector; default is {cmd:max_iter(1000000)} {p_end}
{synoptline}

{opt by} is allowed; see {help prefix}{break}

{title:Description}

{pstd}
{cmd:ge_gravity2} solves and simulates a gravity model with a positive supply elasticity, as decribed in the article by Campos, Reggio, and Timini (2024).
This new command can be used to simulate any model within the universal gravity framework defined by Allen et al (2020).
The {cmd:ge_gravity2} command extends a pre-existing command with the name {cmd:ge_gravity} (Baier et al 2019; Zylkin, 2019).  


{title:Required variables, settings, and options}

{dlgtab: Required variables}

{phang}
{it: exp_id} specifies the variable that identifies the location of origin, for example ISO codes or names of countries. This variable can be a string variable or numeric. This variable cannot contain missing values.

{phang}
{it: imp_id} specifies the variable that identifies the location of destination, for example ISO codes or names of countries. This variable a string variable or numeric. This variable cannot contain missing values.

{phang}
{it: flows} contains bilateral trade flows. This variable contains the flow from the location identified as {it: exp_id} to the location identified as {it: imp_id}. This variable cannot contain missing values, but can contain zeros.

{phang}
{it: partial} contains the "partial" estimate of the effect, typically obtained as a coefficient from a prior gravity estimation. This variable cannot contain missing values.


{dlgtab: Elasticities}

{phang}
{opt theta(#)} sets the trade elasticity, which must be strictly positive.

{phang}
{opt psi(#)} sets the aggregate supply elasticity, which must be nonnegative. If the option {cmd:psi()} is not specified, then the default is {opt psi(0)}.


{dlgtab: New variables (universal gravity)}

{phang}
{opt gen_X(varname)} generates counterfactual trade flows and places the result in a new variable called {it:varname} or overwrites this variable if it already exists.

{phang}
{opt gen_rp(varname)} generates the change in real prices (p_hat/P_hat in the model) and places the result in a new variable called {it:varname} or overwrites this variable if it already exists.

{phang}
{opt gen_y(varname)} generates the change in income (Y_hat in the model) and places the result in a new variable called {it:varname} or overwrites this variable if it already exists.

{phang}
{opt gen_x(varname)} generates the change in trade flows (X_hat in the model) and places the result in a new variable called {it:varname} or overwrites this variable if it already exists.

{phang}
{opt gen_p(varname)} generates the change in output prices (p_hat in the model) and places the result in a new variable called {it:varname} or overwrites this variable if it already exists.

{phang}
{opt gen_P(varname)} generates the change in price indices (P_hat in the model) and places the result in a new variable called {it:varname} or overwrites this variable if it already exists.

{dlgtab: New variables (prototypical model)}

{phang}
{opt gen_w(varname)} generates the change in welfare (W_hat in the model) and places the result in a new variable called {it:varname} or overwrites this variable if it already exists.

{phang}
{opt gen_q(varname)} generates the change in real output (Q_hat in the model) and places the result in a new variable called {it:varname} or overwrites this variable if it already exists.

{phang}
{opt gen_rw(varname)} generates the change in real wages (w_hat/P_hat in the model) and places the result in a new variable called {it:varname} or overwrites this variable if it already exists.

{phang}
{opt gen_nw(varname)} generates the change in nominal wages (w_hat in the model) and places the result in a new variable called {it:varname} or overwrites this variable if it already exists.


{dlgtab: Other options}

{phang}
{opt r:esults} prints a table with percent changes for exports, imports, total trade, domestic trade, real output, and welfare.

{phang}
{opt uni:versal} solves the model with universal trade deficits and allows the user to set the option {opt xi_hat}.

{phang}
{opt mult:iplicative} solves the model for trade deficits that imply E_hat = Y_hat (for backward compatibility with the multiplicative option of the {cmd: ge_gravity} command).

{phang}
{opt c_hat(matrix)} changes supply shifters (c_hat in the model). Welfare will not be calculated if this option is used. This option may not be combined with the options {opt a_hat} or {opt l_hat}.
The default is that all elements of {opt c_hat} are set to one.

{phang}
{opt a_hat(matrix)} changes productivity (A_hat in the prototypical trade model). This option may not be combined with the option {opt c_hat}.
The default is that all elements of {opt a_hat} are set to one.

{phang}
{opt l_hat(matrix)} changes the labor force (L_hat in the prototypical trade model). This option may not be combined with the option {opt c_hat}.
The default is that all elements of {opt l_hat} are set to one.

{phang}
{opt xi_hat(matrix)} changes trade deficits (xi_hat in the model). This option must be used in combination with the {opt universal} option.
If the {opt universal} option is selected and the {opt xi_hat} option is not used, then the command defaults to setting all elements of xi_hat to one.

{phang}
{opt tol(#)} sets the tolerance level to verify convergence of the vector of output price changes. The tolerance level must be a strictly positive real number.
The default is {opt tol(1e-12)}

{phang}
{opt max_iter(#)} sets the maximum number of iterations to solve for the vector of output price changes. The maximum number of iterations must be a positive integer.
The default is {opt max_iter(1000000)}


{title:Remarks}

{p 4 4 2}
The data must be a square database (i.e., the number of exporters must be the same as the numbers importers and their identities must coincide).
The data set must contain a string of numeric variable that identifies exporters and an additional variable of the same kind to identify importers.
Bilateral trade values must be nonnegative.

{pstd}
The command allows the use of the {cmd:by} prefix. If data are not sorted, then it is necessary to use the prefix {cmd:bysort} instead of {cmd:by}. 

{pstd}
{cmd: ge_gravity2} is an e-class ado. To view the list of stored elements issue the command {cmd: ereturn list}.
If {cmd: ge_gravity2} is run with the {cmd:by} prefix, then only the elements {cmd:e(theta)} and {cmd:e(psi)} will be generated and stored. 

{title:Example}

{p 4 8 2}
Load the example data:{p_end}

{p 4 8 2}
{stata "use https://github.com/rolf-campos/ge_gravity2/raw/main/examples/ge_gravity2_example_data.dta, clear"}

{p 4 8 2} 
{stata describe}

{p 4 4 2} 
The variable {it: iso_o} identifies the exporter; the variable {it: iso_d} identifies the importer; the variable {it: trade} identifies trade flows from the exporter to the importer; and the variable {it: year} identifies the year in which a trade flow occurs.{p_end}

{p 4 4 2} 
Assume that a free trade agreement is expected to have a partial equilbrium effect of 0.5. Generate a variable with this value.{p_end}

{p 4 8 2}
{stata gen beta = 0.5}

{p 4 4 2} 
Generate a dummy variable for countries in the North American Free Trade Agreement (NAFTA).{p_end}

{p 4 8 2}
{stata gen nafta = (iso_o == "CAN" & (iso_d == "MEX" | iso_d == "USA")) | (iso_o == "MEX" & (iso_d == "CAN" | iso_d == "USA")) | iso_o == "USA" & (iso_d == "CAN" | iso_d == "MEX")}

{p 4 4 2} 
The partial equilibrium effect of NAFTA can be calculated as follows:{p_end}

{p 4 8 2}
{stata gen partial_effect = beta * nafta }

{p 4 4 2}
Simulate the model with a trade elasticity of 5.03 and supply elasticity of 1.24 using data for the year 1990 and report the general equilibrium effects for all countries.{p_end}

{p 4 8 2} 
{stata ge_gravity2 iso_o iso_d flow partial_effect if year==1990, theta(5.03) psi(1.24) results}

{title:Saved results}

{pstd}
{cmd:ge_gravity2} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(theta)}}trade elasticity {p_end}
{synopt:{cmd:e(psi)}}supply elasticity {p_end}
{synopt:{cmd:e(N)}}number of locations{p_end}
{synopt:{cmd:e(crit)}}convergence criterion achieved {p_end}
{synopt:{cmd:e(n_iter)}}number of iterations performed {p_end}
{synopt:{cmd:e(Xi_hat)}}scalar to ensure that trade deficits sum to zero {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(names)}}identifiers of locations {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(results)}}{it:N} x {it:6} matrix of relative changes for key variables {p_end}
{synopt:{cmd:e(X)}}{it:N} x {it:N} matrix of trade flows (baseline) {p_end}
{synopt:{cmd:e(X_hat)}}{it:N} x {it:N} matrix of X_hat = X_prime / X {p_end}
{synopt:{cmd:e(X_prime)}}{it:N} x {it:N} matrix of trade flows (counterfactual) {p_end}
{synopt:{cmd:e(E)}}{it:N} x {it:1} matrix of expenditure (baseline) {p_end}
{synopt:{cmd:e(Y)}}{it:N} x {it:1} matrix of income (baseline) {p_end}
{synopt:{cmd:e(rp)}}{it:N} x {it:1} matrix of the change in real prices (p_hat / P_hat) {p_end}
{synopt:{cmd:e(p_hat)}}{it:N} x {it:1} matrix of the change in output prices (p_hat) {p_end}
{synopt:{cmd:e(P_hat)}}{it:N} x {it:1} matrix of the change in price indices (P_hat) {p_end}
{synopt:{cmd:e(E_hat)}}{it:N} x {it:1} matrix of the E_hat = E_prime / E {p_end}
{synopt:{cmd:e(Y_hat)}}{it:N} x {it:1} matrix of the Y_hat = Y_prime / Y {p_end}
{synopt:{cmd:e(W_hat)}}{it:N} x {it:1} matrix of the W_hat = W_prime / W {p_end}
{synopt:{cmd:e(Q_hat)}}{it:N} x {it:1} matrix of the Q_hat = Q_prime / Q {p_end}
{synopt:{cmd:e(E_prime)}}{it:N} x {it:1} matrix of expenditure (counterfactual) {p_end}
{synopt:{cmd:e(Y_prime)}}{it:N} x {it:1} matrix of income (counterfactual) {p_end}


{title:Authors}

{pstd}
{browse "mailto:rodolfo.campos@bde.es":Rodolfo G. Campos} & {browse "mailto:iliana.reggio@uam.es":Iliana Reggio} & {browse "mailto:jacopo.timini@bde.es":Jacopo Timini} {break}
Banco de España and Universidad Autónoma de Madrid{break}
Madrid, Spain{break}


{title:References}

{phang}
Allen, T., C. Arkolakis, and Y. Takahashi. 2020. Universal Gravity. {it:Journal of Political Economy} 128(2): 393-433.

{phang}
Campos, R. G., I. Reggio, and J. Timini. 2024. ge_gravity2: a command for solving universal gravity models, {browse "https://arxiv.org/abs/2404.09180":arXiv:2404.09180} [econ.GN].

{phang}
Baier, S. L., Y. V. Yotov, and T. Zylkin. 2019. On the widely differing effects of free trade agreements: Lessons from twenty years of trade integration. {it:Journal of International Economics} 116: 206–226.

{phang}
Zylkin, T. 2019. GE_GRAVITY: Stata module to solve a simple general equilibrium one sector Armington-CES trade model. Statistical Software Components, Boston College Department of Economics. https://ideas.repec.org/c/boc/bocode/s458678.html.

{break}

{phang}Update: April - 2024{p_end}



