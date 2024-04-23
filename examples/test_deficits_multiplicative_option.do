clear all

********************************************************************************
*               Comparison between ge_gravity2 and ge_gravity                  *
********************************************************************************

** 0. Load data
use GE_gravity2_example_data.dta
keep if year == 2000

** 1. Use a very large partial equilibrium effect of NAFTA
local beta = 2.5

** 2. Generate an indicator of NAFTA
gen nafta = 0
replace nafta = 1 if iso_o == "CAN" & (iso_d == "MEX" | iso_d == "USA")
replace nafta = 1 if iso_o == "MEX" & (iso_d == "CAN" | iso_d == "USA")
replace nafta = 1 if iso_o == "USA" & (iso_d == "CAN" | iso_d == "MEX")

** 3. Generate partial equilibrium effect of dissolving NAFTA (therefore, use negative sign for the NAFTA dummy)
gen partial_effect = `beta' * (-nafta)  // equals -beta for NAFTA pairs, 0 otherwise.

** 3. Obtain general equilibrium effects of dissolving NAFTA
ge_gravity iso_o iso_d flow partial_effect, theta(5.03) gen_X(X1) gen_w(W1) gen_nw(nw1) gen_rw(rw1) gen_P(P1) multiplicative
ge_gravity2 iso_o iso_d flow partial_effect, theta(5.03) psi(0) gen_X(X2) gen_nw(nw2) gen_rw(rw2) gen_P(P2) gen_w(W2) multiplicative
di e(Xi_hat)

** 4. Calculate the absolute log-difference in welfare and report the maximum
gen W_diff = abs(ln(W2) - ln(W1))
mata: max(st_data(., "W_diff"))

** 5. Calculate import shares (pi_{ij} = X_{ij}/E_{j})
egen E1 = sum(X1), by(iso_d)
egen E2 = sum(X2), by(iso_d)
gen pi1 = 100 * X1 / E1
gen pi2 = 100 * X2 / E2

** 6. Calculate the difference in pi and report the maximum absolute difference
gen pi_diff = pi2 - pi1
mata: max(abs(st_data(., "pi_diff")))

** 7. Calculate the absolute log-difference in X and report the maximum
gen X_diff = abs(ln(X2) - ln(X1))
mata: max(st_data(., "X_diff"))

** 8. Calculate the absolute log-difference in E and report the maximum
gen E_diff = abs(ln(E2) - ln(E1))
mata: max(abs(st_data(., "E_diff")))

** 9. Calculate the absolute log-difference in P and report the maximum
gen P_diff = abs(ln(P2) - ln(P1))
mata: max(abs(st_data(., "P_diff")))

** 10. Calculate the absolute log-difference in nw and report the maximum
gen nw_diff = abs(ln(nw2) - ln(nw1))
mata: max(abs(st_data(., "nw_diff")))

** 11. Calculate the absolute log-difference in rw and report the maximum
gen rw_diff = abs(ln(rw2) - ln(rw1))
mata: max(abs(st_data(., "rw_diff")))


** 12. 
ge_gravity2 iso_o iso_d flow partial_effect, theta(5.03) psi(1.24) multiplicative
mata : st_matrix("D", st_matrix("e(E)") - st_matrix("e(Y)"))
mata : st_matrix("D_prime", st_matrix("e(E_prime)") - st_matrix("e(Y_prime)"))

matrix TABLE = (D, D_prime, e(E_hat), e(Y_hat))
matrix rownames TABLE = `e(names)'
matrix colnames TABLE = D D_prime E_hat Y_hat
matlist TABLE

/*
** 10. Run command with positive psi and check that delta_prime - delta = (Xi_hat * xi_hat - 1) * (E/Y)
ge_gravity2 iso_o iso_d flow partial_effect, theta(5.03) psi(1.24) gen_X(X2) gen_P(P2) gen_w(W2)  multiplicative
mata : st_matrix("D", st_matrix("e(E)") - st_matrix("e(Y)"))
mata : st_matrix("D_prime", st_matrix("e(E_prime)") - st_matrix("e(Y_prime)"))
mata: st_matrix("delta", st_matrix("D") :/ st_matrix("e(Y)"))
mata: st_matrix("delta_prime", st_matrix("D_prime") :/ st_matrix("e(Y_prime)"))
mata: st_matrix("delta_diff", st_matrix("delta_prime") - st_matrix("delta"))
mata: st_matrix("delta_diff", st_matrix("delta_prime") - st_matrix("delta"))
mata: st_matrix("E_Y", st_matrix("e(E)") :/ st_matrix("e(Y)"))
matrix delta_diff_theory = (e(Xi_hat) - 1) * E_Y  // simplified formula because xi_hat is all ones in this case
mata: st_matrix("delta_diff", st_matrix("delta_prime") - st_matrix("delta"))
matrix TABLE = (delta_prime, delta, delta_diff, delta_diff_theory)
matrix rownames TABLE = `e(names)'
matrix colnames TABLE = delta_prime delta diff theory
matlist TABLE
*/
