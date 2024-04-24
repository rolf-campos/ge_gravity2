program define ge_gravity2, eclass byable(recall)
version 11.2

*! A Stata command for solving universal gravity models, by Rodolfo G. Campos, Iliana Reggio, and Jacopo Timini
*! This version: v3.0, April 2024
*!
*! Suggested citation: 
*! Campos, Rodolfo G., Iliana Reggio, and Jacopo Timini, "ge_gravity2: a command for solving universal gravity models," arXiv:2404.09180 [econ.GN].
*! 
*! This code is inspired and based on Tom Zylkin's program called ge_gravity.
*! Zylkin (2019), "GE_GRAVITY: Stata module to solve a simple general equilibrium one sector Armington-CES trade model,"
*! Statistical Software Components S458678, Boston College Department of Economics, revised 09 Sep 2021.
*!
*! We thank Tom Zylkin for his suggestions on how to improve early versions of this code.


syntax anything [if] [in], ///
    theta(real) [psi(real 0) ///
    gen_X(name) gen_rp(name) gen_y(name) gen_x(name) gen_w(name) gen_q(name) gen_p(name) gen_P(name) gen_rw(name) gen_nw(name) ///
    MULTiplicative UNIversal Results tol(real 1e-12) max_iter(int 1000000) c_hat(string) xi_hat(string) a_hat(string) l_hat(string)]

gettoken exp_id rest  : anything
gettoken imp_id rest  : rest
gettoken X      rest  : rest
gettoken partial   close : rest

qui marksample touse

ereturn clear

// Default option: additive
local additive_flag = 1
local universal_flag = 0
local multiplicative_flag = 0

// Change flags if the program is run with universal option
if "`universal'" != "" {
    local additive_flag = 0
    local universal_flag = 1
}

// Change flags if the program is run with multiplicative option
if "`multiplicative'" != "" {
    local additive_flag = 0
    local multiplicative_flag = 1
}

// Check that options do not clash
if `multiplicative_flag' + `universal_flag' > 1  {
    di in red "Error: the options universal and multiplicative are mutually exclusive."
    exit 184
}

// Check if xi_hat is run with the universal option
if "`xi_hat'" != "" & `universal_flag' == 0  {
    di in red "Error: the option xi_hat can only be chosen with the universal option."
    exit 184
}

// Check if the program is run with the by command and set the by_flag to one in that case
local by_flag = 0
if _by() {
    local by_flag = 1
}

// Check to make sure each obs. is uniquely ID'd by a single origin and destination	
local id_flag = 0
local check_ids = "`exp_id' `imp_id'"							

local are_both_ids_strings = 0
foreach v of varlist `check_ids' {
	cap confirm numeric variable `v'
	if _rc {
		local are_both_ids_strings = `are_both_ids_strings' + 1
		local `v'_is_string = 1
	}
	else{
		local `v'_is_string = 0
	}
}

if `are_both_ids_strings' == 0 {
	mata: id_check("`check_ids'",  "`touse'")
}

if `are_both_ids_strings' == 2 {
	mata: id_check_string("`check_ids'",  "`touse'")
}

if `are_both_ids_strings' == 1 {
	foreach v of varlist `check_ids' {
		tempvar `v'2
		if  ``v'_is_string' == 1 {
			qui egen ``v'2' = group(`v')
		}
		else{
			qui gen ``v'2' = `v'
		}
		
	local check_ids2 = "`check_ids2'" + "``v'2' "
	}
	mata: id_check("`check_ids2'",  "`touse'")
}
				    				
if `id_flag' != 0 {
	di in red "Error: the set of origin and destination IDs do not uniquely describe the data."
	di in red "If this is not a mistake, try collapsing the data first using collapse (sum)." 
	exit 111
}

if "`c_hat'" != "" {
    if "`a_hat'" != "" {
        di in red "Error: the options c_hat and a_hat are mutually exclusive."
        exit 184
    }
    if "`l_hat'" != "" {
        di in red "Error: the options c_hat and l_hat are mutually exclusive."
        exit 184
    }
}  

if "`gen_X'" == ""{
	tempname gen_X
}
if "`gen_rp'" == ""{
	tempname gen_rp
}
if "`gen_y'" == ""{
	tempname gen_y
}
if "`gen_x'" == ""{
	tempname gen_x
}
if "`gen_w'" == ""{
	tempname gen_w
}
if "`gen_q'" == ""{
    tempname gen_q
}
if "`gen_p'" == ""{
    tempname gen_p
}
if "`gen_P'" == ""{
    tempname gen_P
}
if "`gen_rw'" == ""{
    tempname gen_rw
}
if "`gen_nw'" == ""{
    tempname gen_nw
}

cap gen `gen_X' = .
cap gen `gen_rp' = .
cap gen `gen_y' = .
cap gen `gen_x' = .
cap gen `gen_w'  = .
cap gen `gen_q' = .
cap gen `gen_p' = .
cap gen `gen_P' = .
cap gen `gen_rw' = .
cap gen `gen_nw' = .

di "sorting..."

sort `exp_id' `imp_id' `_byvars'

di "solving..."

mata: ge_solver2("`X'", "`partial'", `theta', `psi', ///
    "`gen_X'", "`gen_rp'", "`gen_y'", "`gen_x'", "`gen_w'", "`gen_q'", "`gen_p'", "`gen_P'", "`gen_rw'", "`gen_nw'", ///
    "`touse'", `tol', `max_iter', `by_flag', `additive_flag', `multiplicative_flag', "`c_hat'", "`xi_hat'", "`a_hat'", "`l_hat'")

di "solved!"


if `by_flag' == 0 {
    /* Rename rownames and colnames in ereturn matrices created in mata */
    quietly levelsof(`exp_id') if `touse', clean
    ereturn local names "`r(levels)'"
    foreach item in "Y_prime" "E_prime" "Q_hat" "W_hat" "Y_hat" "E_hat" "P_hat" "p_hat" "rp" "Y" "E" {
        matrix A = e(`item')
        cap matrix rownames A = `r(levels)'
        cap matrix colnames A = `item'
        ereturn matrix `item' = A
    }

    foreach item in "X_prime" "X_hat" "X" {
        matrix A = e(`item')
        cap matrix rownames A = `r(levels)'
        cap matrix colnames A = `r(levels)'
        ereturn matrix `item' = A
    }

    /* Construct table with the main results for the prototypical trade model */
    mata : st_matrix("X0", rowsum(st_matrix("e(X)") :* (J(`e(N)', `e(N)', 1) - I(`e(N)'))))
    mata : st_matrix("X1", rowsum(st_matrix("e(X_prime)") :* (J(`e(N)', `e(N)', 1) - I(`e(N)'))))
    mata : st_matrix("X", 100 * ((st_matrix("X1") :/ st_matrix("X0")) :/ st_matrix("e(p_hat)") - J(`e(N)', 1, 1)))
    mata : st_matrix("M0", colsum(st_matrix("e(X)") :* (J(`e(N)', `e(N)', 1) - I(`e(N)')))')
    mata : st_matrix("M1", colsum(st_matrix("e(X_prime)") :* (J(`e(N)', `e(N)', 1) - I(`e(N)')))')
    mata : st_matrix("M", 100 * ((st_matrix("M1") :/ st_matrix("M0")) :/ st_matrix("e(P_hat)") - J(`e(N)', 1, 1)))
    mata : st_matrix("X0r", st_matrix("X0") :* (1 :+ st_matrix("X") / 100))
    mata : st_matrix("M0r", st_matrix("M0") :* (1 :+ st_matrix("M") / 100))
    mata : st_matrix("T", 100 * ((st_matrix("X0r") + st_matrix("M0r")) :/ (st_matrix("X0") + st_matrix("M0")) - J(`e(N)', 1, 1)))
    mata : st_matrix("D", 100 * (diagonal(st_matrix("e(X_hat)")) :/ st_matrix("e(P_hat)") - J(`e(N)', 1, 1)))
    mata : st_matrix("Q", 100 * (st_matrix("e(Q_hat)") - J(`e(N)', 1, 1)))
    mata : st_matrix("W", 100 * (st_matrix("e(W_hat)") - J(`e(N)', 1, 1)))
    matrix res = (X, M, T, D, Q, W)
    matrix rownames res = `r(levels)'
    matrix colnames res = Exports Imports IntlTrade Domestic Output Welfare
    ereturn matrix results = res
    if "`results'" != "" {
        *display "Results for the prototypical trade model (percent changes):"
        matlist e(results), border(all) format(%9.3f) title("Results for the prototypical trade model (percent changes)") tindent(20) 
    }  
}

end

mata: 
void ge_solver2(string scalar trade, string scalar partials, real scalar theta, real scalar psi, string scalar gen1, string scalar gen2, 
               string scalar gen3, string scalar gen4, string scalar gen5, string scalar gen6, string scalar gen7, string scalar gen8,
			   string scalar gen9, string scalar gen10, string scalar ok, real scalar tol, numeric scalar max_iter, numeric scalar by_flag,
               numeric scalar additive_flag, numeric scalar multiplicative_flag, string scalar CC, string scalar XX, string scalar AA, string scalar LL)


{

    /* read data from Stata memory */
    X = st_data(., tokens(trade), ok)
    partial = st_data(., tokens(partials), ok)

    /* ensure data set includes all possible flows for each location */
    N = sqrt(rows(X))
    if (floor(N) != N) {
    displayas("err")
    printf("\nNon-square data set detected. The size of the data should be NxN. Check whether every location has N trade partners, including itself. Exiting.\n \n")
    exit(1)
    }

    /* flash warning if trade matrix has missing values */
    if (missing(X) > 0) {
    displayas("err")
    printf("Flow values missing for at least 1 pair; assumed to be zero.\n")
    X = editmissing(X, 0)
    displayas("text")
    }

    /* check for negative trade values */
    if (min(X) < 0) {
    displayas("err")
    printf("\nNegative flow values detected. Exiting.\n \n")
    exit(1)
    }

    /* Set up X_ij trade matrix: exporters (rows) by importers (columns) */
    X = colshape(X, N)

    /* check that internal trade is included for all countries */
    if(min(diagonal(X)) == 0) {
    displayas("err")
    printf("\nX_ii is missing or zero for at least 1 location. Exiting.\n \n")
    exit(1)
    }

    /* flash warning if any partial values are missing */
    if (missing(partial) > 0) {
    displayas("err")
    printf("partial values missing for at least 1 pair; assumed to be zero.\n")
    partial = editmissing(partial, 0)
    displayas("text")
    }

    /* "B" (= e^partial) is the matrix of partial effects */
    B = colshape(exp(partial), N) 

    /* flash warning if partials on the diagonal are not zero. */
    if (min(diagonal(B):== 1) != 1) {
    displayas("err")
    printf("Non-zero partial values for some X_ii terms detected. These have been set to zero.\n")
    B = B - diag(B) :+ I(N)           // should be all 1's on the diagonal
    displayas("text")
    }

    /* Set up Y and E vectors and Ybar  */
    E = colsum(X)'
    Y = rowsum(X)
    Ybar = sum(X)

    /* Compute trade deficits and deficits as a share of income  */
    D = E :- Y
    delta = D :/ Y

    /* Set up shifter vectors */
    xi_hat = J(N, 1, 1)
    A_hat = J(N, 1, 1)
    L_hat = J(N, 1, 1)

    if (AA != "") {
        printf("Using custom a_hat.\n")
        displayas("text")
        A_hat = st_matrix(AA)
    }
    if (LL != "") {
        printf("Using custom l_hat.\n")
        displayas("text")
        L_hat = st_matrix(LL)
    }

    c_hat = A_hat :* L_hat

    if (CC != "") {
        printf("Using custom c_hat. Welfare is undefined.\n")
        displayas("text")
        c_hat = st_matrix(CC)
    }
    
    if (XX != "") {
        printf("Using custom xi_hat.\n")
        displayas("text")
        xi_hat = st_matrix(XX)
    }

    /* Initialize p_hat = P_hat = Xi_hat = 1 */
    p_hat = J(N, 1, 1)
    P_hat = J(N, 1, 1)
    Xi_hat = 1

    /* Algorithm to compute price vectors */
    crit = 1
    j = 0

    do {  
        p_hat_last_step = p_hat

        if (additive_flag == 1) {
            /* Step 0.5: update xi_hat if deficits are additive */
            Y_hat = c_hat :* p_hat :* ((p_hat :/ P_hat) :^ psi)
            delta_hat = J(N, 1, 1) :/ Y_hat
            xi_hat = (1/Xi_hat) :* (J(N, 1, 1) :+ (delta :/ (J(N, 1, 1) :+ delta)) :* (delta_hat :- J(N, 1, 1)))
        }
        
        /* Step 1: update Xi_hat using properties 5 and 6 */
        if (multiplicative_flag == 0) {
            Xi_hat = Ybar / sum(xi_hat :* c_hat :* p_hat :* (p_hat :/ P_hat):^psi :* E)
        }

        /* Step 2: update p_hat */ 	
        part1 = (P_hat :^ (psi)) :/ c_hat
        part2 = X :/ (Y # J(1, N, 1))
        part3 = B
        part4 = (xi_hat :* c_hat)' # J(N, 1, 1)
        part5 = (P_hat :^ (theta - psi))' # J(N, 1, 1)
        part6 = (p_hat :^ (1 + psi))' # J(N, 1, 1)
        p_hat = (Xi_hat :* part1 :* rowsum(part2 :* part3 :* part4 :* part5 :* part6)) :^ (1/(1+theta+psi))

        /* Step 3: update P_hat */
        Part1 = X :/ (E' # J(N, 1, 1))
        Part2 = B
        Part3 = (p_hat # J(1, N, 1)) :^ (-theta)
        P_hat = colsum(Part1 :* Part2 :* Part3)' :^ (-1/theta)

        if (multiplicative_flag == 1) {
            /* Step 3.5: normalize prices using property 6 if deficits are multiplicative */
            rho = sum(c_hat :* p_hat :* (p_hat :/ P_hat):^psi :* Y) / Ybar
            p_hat = p_hat :/ rho
            P_hat = P_hat :/ rho
        }
        
        /* Step 4: check convergence */
        crit = max(abs(p_hat - p_hat_last_step))

        /* Step 5: if convergence was not achieved, increase counter and repeat */
        j = j + 1

    } while (crit > tol & j < max_iter)

    /* Compute change in income (a vector) */
    Y_hat = c_hat :* p_hat :* ((p_hat :/ P_hat) :^ psi)

    /* Compute change in expenditure (a vector) */
    E_hat = Xi_hat :* xi_hat :* Y_hat

    /* Compute change in bilateral trade flows (a matrix) */
    X_hat = B :* (((p_hat # J(1, N, 1))  :/ (P_hat' # J(N, 1, 1))) :^ (-theta)) :* (E_hat' # J(N, 1, 1))

    /* Compute quantities relevant for all universal gravity models */
    p_P = p_hat :/ (P_hat)
    X_new = X_hat :* X
    X_new_gen = colshape(X_new, 1)
    X_hat_gen = colshape(X_hat, 1)
    real_price = p_P # J(N, 1, 1)
    income_hat_gen = Y_hat # J(N, 1, 1)
    p_hat_gen = p_hat # J(N, 1, 1)
    P_hat_gen = P_hat # J(N, 1, 1)

    /* Compute quantities relevant only for the prototypical trade model */
    output_hat = c_hat :* (p_P :^ (psi))
    welfare_hat = Xi_hat :* xi_hat :* A_hat :* (p_P :^ (1+psi))
    rw_hat = A_hat :* (p_P :^ (1+psi))
    nw_hat = rw_hat :* P_hat

    /* Set welfare and the (real and nominal) wage to missing if the option c_hat was used */
    if (CC != "") {
        welfare_hat = J(rows(welfare_hat), cols(welfare_hat), missingof(welfare_hat))
        rw_hat = J(rows(rw_hat), cols(rw_hat), missingof(rw_hat))
        nw_hat = J(rows(nw_hat), cols(nw_hat), missingof(nw_hat))
    }
    
    welfare_hat_gen = welfare_hat # J(N, 1, 1)
    output_hat_gen = output_hat # J(N, 1, 1)
    rw_hat_gen = rw_hat # J(N, 1, 1)
    nw_hat_gen = nw_hat # J(N, 1, 1)

    /* Post results to Stata */
    st_store(., tokens(gen1), ok, X_new_gen)
    st_store(., tokens(gen2), ok, real_price)
    st_store(., tokens(gen3), ok, income_hat_gen)
    st_store(., tokens(gen4), ok, X_hat_gen)
    st_store(., tokens(gen5), ok, welfare_hat_gen)
    st_store(., tokens(gen6), ok, output_hat_gen)
    st_store(., tokens(gen7), ok, p_hat_gen)
    st_store(., tokens(gen8), ok, P_hat_gen)
    st_store(., tokens(gen9), ok, rw_hat_gen)
    st_store(., tokens(gen10), ok, nw_hat_gen)

    /* Generate stored results (ereturn elements) */
    st_numscalar("e(theta)", theta)
    st_numscalar("e(psi)", psi)

    /* Store the following results only if the command was not issued with the by prefix */
    if (by_flag == 0) {
        st_numscalar("e(N)", N)
        st_numscalar("e(crit)", crit)
        st_numscalar("e(n_iter)", j)
        st_numscalar("e(Xi_hat)", Xi_hat)
        st_matrix("e(X)", X)
        st_matrix("e(E)", E)
        st_matrix("e(Y)", Y)
        st_matrix("e(X_hat)", X_hat)
        st_matrix("e(Y_hat)", Y_hat)
        st_matrix("e(E_hat)", E_hat)
        st_matrix("e(rp)", p_P)
        st_matrix("e(p_hat)", p_hat)
        st_matrix("e(P_hat)", P_hat)
        st_matrix("e(W_hat)", welfare_hat)
        st_matrix("e(Q_hat)", output_hat)
        st_matrix("e(X_prime)", X_new)
        st_matrix("e(E_prime)", E_hat :* E)
        st_matrix("e(Y_prime)", Y_hat :* Y)
    }
}


/*************************************************************/
/* CHECK_ID (checks whether ID vars uniquely describe data)  */
/*************************************************************/

// Sometimes users may make a mistake in providing duplicate observations for the same trade flow.
// This will generate a error letting them know. If this is not done by accident,
// perhaps the data needs to be aggregated by collapsing the data.

mata:
void id_check(string scalar idvars,| string scalar touse)
{
	
	st_view(id_vars, ., tokens(idvars), touse)
	uniq_ids = uniqrows(id_vars)
	if (rows(id_vars) != rows(uniq_ids)) {
		st_local("id_flag", "1")
	}	
}

mata:
void id_check_string(string scalar idvars,| string scalar touse)
{
	st_sview(id_vars, ., tokens(idvars), touse)
	uniq_ids = uniqrows(id_vars)
	if (rows(id_vars) != rows(uniq_ids)) {
		st_local("id_flag", "1")
	}	
}

end
