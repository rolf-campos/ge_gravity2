// *****************************************************************************
//
// ge_gravity2 examples
//
// This dofile creates the log file for applications in the "Examples" section
//
// The examples require that ge_gravity2 is installed
// *****************************************************************************

// Preliminaries
set more off
capture log close
clear all

// Set local paths to run the examples
global data ""
global output ""

// Place the file "ge_gravity2_example_data.dta" in the data folder
// It is available at the following location:
// https://github.com/rolf-campos/ge_gravity2/raw/main/examples/ge_gravity2_example_data.dta

********************************************************************************
*                                                                              *
*             Example 1: Estimating the ex-ante effect of NAFTA                *
*                                                                              *
********************************************************************************
// This application shows basic usage, such as viewing a results table
// and generating counterfactual trade flows (X_prime)
// and comparative statics for welfare (W_hat)

sjlog using ${output}application1, replace

** 0. Load data
use ge_gravity2_example_data.dta

** 1. Use a partial equilibrium effect of NAFTA
local beta = 0.500

** 2. Generate an indicator of NAFTA
gen nafta = 0
replace nafta = 1 if iso_o == "CAN" & (iso_d == "MEX" | iso_d == "USA")
replace nafta = 1 if iso_o == "MEX" & (iso_d == "CAN" | iso_d == "USA")
replace nafta = 1 if iso_o == "USA" & (iso_d == "CAN" | iso_d == "MEX")

** 3. Generate the partial equilibrium effect of NAFTA
gen partial_effect = `beta' * nafta

** 4. Obtain general equilibrium effects of NAFTA usind data for the year 1990.
//    Report a table with results, and generate variables with counterfactual flows and W_hat.
//    We use a trade elasticity of 5.03 and a supply elasticity of 1.24.

ge_gravity2 iso_o iso_d flow partial_effect if year==1990, theta(5.03) psi(1.24) results gen_X(flow_nafta) gen_w(welfare)

** Comments:
// The table with results is also available as e(results)
// To see the list of all stored elements type: ereturn list

sjlog close, replace

********************************************************************************
*                                                                              *
*      Example 2: The effect of economic policies during the Franco regime     *
*                                                                              *
********************************************************************************
// This application shows how to use the command with the by prefix.

clear all

sjlog using ${output}application2, replace

** 0. Load data
use GE_gravity2_example_data.dta
keep if year <= 1980

** 1. Use the estimates of the partial equilibrium effect of Spain's border thickness
// Source: Campos, R. G., Reggio, I., and Timini, J.,
//         "Autarky in Franco's Spain: The costs of a closed economy",
//         Economic History Review, 76 (2023), pp. 1259–1280.
//         https://doi.org/10.1111/ehr.13243
//         Taken from the replication materials for Figure 5.

gen beta_Spain = .
replace beta_Spain = -1.254 if year == 1950
replace beta_Spain = -0.937 if year == 1960
replace beta_Spain = -0.604 if year == 1970
replace beta_Spain = -0.694 if year == 1980 

gen beta_Synthetic_Spain = .
replace beta_Synthetic_Spain = -0.665 if year == 1950
replace beta_Synthetic_Spain = -0.438 if year == 1960
replace beta_Synthetic_Spain = -0.428 if year == 1970
replace beta_Synthetic_Spain = -0.653 if year == 1980 

** 2. Generate an indicator of Spain's borders
gen border = (iso_o != iso_d)
gen border_Spain = border * (iso_o == "ESP" | iso_d == "ESP")

** 3. Generate the partial equilibrium effect of the difference of Spain's actual border thickness relative to that of Synthetic Spain
gen partial_effect = (beta_Spain - beta_Synthetic_Spain) * border_Spain

** 4. Obtain the general equilibrium effect for different values of the supply elasticity
//    Campos, Reggio, and Timini (2023) use a trade elasticity of 4.
//    They (implicitly) use a supply elasticity of zero.
//    We use the by prefix to calculate welfare for all years.
bys year: ge_gravity2 iso_o iso_d flow partial_effect, theta(4) psi(0) gen_w(W0)
bys year: ge_gravity2 iso_o iso_d flow partial_effect, theta(4) psi(1) gen_w(W1)
bys year: ge_gravity2 iso_o iso_d flow partial_effect, theta(4) psi(2) gen_w(W2)

** 5. Collapse and express in percentage points
collapse (first) W0 W1 W2, by(iso_o year)
replace W0 = 100 * (W0 - 1)
replace W1 = 100 * (W1 - 1)
replace W2 = 100 * (W2 - 1)

** 6. List welfare losses for Spain
list if iso_o == "ESP"

sjlog close, replace

********************************************************************************
*                                                                              *
*               Example 3: The a productivity increase in China                *
*                                                                              *
********************************************************************************
// This example shows how to simulate a productivity shock in a country

clear all
sjlog using ${output}application3, replace

** 0. Load data
use GE_gravity2_example_data.dta

** 1. Perform a dry run to see how in what position China is ordered
gen partial_effect = 0
ge_gravity2 iso_o iso_d flow partial_effect if year == 1990, theta(5.03) psi(1.24)
matrix list e(W_hat)  // China is in position 11

** 2. Generate the matrix with the productivity increase
matrix A_hat = J(`e(N)', 1, 1)  // Matrix of size N x 1 filled with ones
matrix A_hat[11, 1] = 1.1  // China's productivity increases by 10%

** 3. Run the command with the a_hat option
ge_gravity2 iso_o iso_d flow partial_effect if year == 1990, theta(5.03) psi(1.24) a_hat(A_hat) results
display e(Xi_hat)

sjlog close, replace
exit
