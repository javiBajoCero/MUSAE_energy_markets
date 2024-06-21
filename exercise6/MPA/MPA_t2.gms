********************************************************************************
* F.-Javier Heredia f.javier.heredia(at)upc.edu http://gnom.upc.edu/heredia
* Code under Creative Commons Attribution-NonCommercial-NoDerivs
* 3.0 Unported License http://creativecommons.org/licenses/by-nc-nd/3.0/
********************************************************************************

$title OEMO_MPA

*********************************************************************
* DATA
*********************************************************************

* Time periods;

SETS t0    Extended time periods / t0*t2 /
SETS t(t0) Time periods / t1*t2 /

* Generation units:

SETS
g Generation units / G1*G3/
bg Blocks           /b1*b3/;

PARAMETERS
pg_max(g) Max. active power generation [MW] /G1 30, G2 25, G3 25/
pg_min(g) Min. active power generation [MW] /G1  5, G2  8, G3 10/
ru(g)     Ramp-up limit [MW:h]              /G1  5, G2 10, G3 10/
rd(g)     Ramp-down limit [MW]              /G1  5, G2 10, G3 10/
p0(g)     Initial power output [MW]         /G1 10, G2 15, G3 10/;

TABLE pbg(t,g,bg) Power [MW] of the generation bid function
$ include t2_pbg

TABLE lbg(t,g,bg) Prices [eur:MWh] of the generation bid function
$ include t2_lbg

* Demand units:

SETS
d Generation units / D1, D2 /
bd Blocks          / b1*b4 /;

TABLE pbd(t,d,bd) Power [MW] of the demand bid function
$ include t2_pbd

TABLE lbd(t,d,bd) Prices [�:MWh] of the generation bid function
$ include t2_lbd

*********************************************************************
* VARIABLES
*********************************************************************

FREE VARIABLE     SW         Social welfare (objective function)
POSITIVE VARIABLE PG(t,g,bg) Matched generation of each block [MW]
                  PD(t,d,bd) Matched demand of each block [MW]
                  PGT(t0,g)  Total matched generation [MW]
                  PDT(t,d)   Total matched demand [MW];
BINARY VARIABLE   U(t,g)       on-off state of the unit;

* Total generation at t=0:
PGT.fx('t0',g) = p0(g);

*********************************************************************
* OBJECTIVE FUNCTION AND CONSTRAINTS
*********************************************************************

EQUATIONS
OF            Objective function
MATCHED_G     Matched generation to generation block coupling
MATCHED_D     Matched demand to demand block coupling
TOT_MATCHED_G Total matched generation
TOT_MATCHED_D Total matched demand
MARKET      Market equilibrium
RAMP_D      Ramp down limit constraints
RAMP_U      Ramp up limit constraints
PGMIN       Minimum generation
PGMAX       Maximum generation;

* Social Welfare:
OF.. SW =e=
sum(t,
      sum(d, sum(bd, lbd(t,d,bd)*PD(t,d,bd)))
    - sum(g, sum(bg, lbg(t,g,bg)*PG(t,g,bg)))
   );

* Matched generation to generation block coupling:
MATCHED_G(t,g,bg).. PG(t,g,bg) =l= pbg(t,g,bg);

* Matched demand to demand block coupling:
MATCHED_D(t,d,bd).. PD(t,d,bd) =l= pbd(t,d,bd);

* Total matched generation:
TOT_MATCHED_G(t,g).. PGT(t,g) =e= sum(bg, PG(t,g,bg));

* Total matched demand:
TOT_MATCHED_D(t,d).. PDT(t,d) =e= sum(bd, PD(t,d,bd));

* Market Equilibrium:
MARKET(t).. sum(g, PGT(t,g)) - sum(d, PDT(t,d)) =e= 0;

* Ramp down limit:
RAMP_D(t0,g)$(ord(t0) gt 1).. PGT(t0,g) - PGT(t0-1,g) =g= -rd(g);

* Ramp up limit:
RAMP_U(t0,g)$(ord(t0) gt 1).. PGT(t0,g) - PGT(t0-1,g) =l= ru(g);

* Generation limits:
PGMIN(t,g)..  PGT(t,g) =g= pg_min(g)*U(t,g);
PGMAX(t,g)..  PGT(t,g) =l= pg_max(g)*U(t,g);

*********************************************************************
* OPTIMIZATION
*********************************************************************

SET cmat Columns for tables "matched" /bid_price, bid_power, matched_P/;
SET ceq  Rows for market clearing tables    / SocWel , price, energy/;

PARAMETER
matched_generation(t,g,bg,cmat), matched_demand(t,d,bd,cmat),
market_equilibrium(t,ceq);

matched_generation(t,g,bg,'bid_price') = lbg(t,g,bg);
matched_generation(t,g,bg,'bid_power') = pbg(t,g,bg);
matched_demand(t,d,bd,'bid_price')     = lbd(t,d,bd);
matched_demand(t,d,bd,'bid_power')     = pbd(t,d,bd);

MODEL MPA    / ALL /;
SOLVE MPA USING mip MAXIMIZING SW;

* Linear relaxation of the full model to catch up the market clearing price:

* We first fix the optimal value of the binary variables;
U.fx(t,g) = U.l(t,g);
*PGT.fx('t2','G1') = 16;

* And then solve the linear relaxation pf SPA;
SOLVE MPA USING rmip MAXIMIZING SW;

$include MPA_disp

$ include MPA2M
