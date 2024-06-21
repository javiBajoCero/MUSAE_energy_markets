********************************************************************************
* F.-Javier Heredia f.javier.heredia(at)upc.edu http://gnom.upc.edu/heredia
* Code under Creative Commons Attribution-NonCommercial-NoDerivs
* 3.0 Unported License http://creativecommons.org/licenses/by-nc-nd/3.0/
********************************************************************************

$title OEMO_TCMPA

*********************************************************************
* DATA
*********************************************************************

* Time periods;

SETS
t0    Extended time periods / t0*t5 /
t(t0) Time periods / t1*t5 /;

* Units:

* Generation units:

SETS
g  Generation units / G1*G5/
bg Blocks           /b1*b2/;

PARAMETERS
pg_max(g) Max. active power generation [MW] /G1 300, G2 275, G3 100, G4 50, G5 200/
pg_min(g) Min. active power generation [MW] /G1 30, G2  28, G3 10, G4 5, G5 20/
ru(g)     Ramp-up limit [MW:h]              /G1 100, G2 30, G3 25, G4 10, G5 50/
rd(g)     Ramp-down limit [MW]              /G1 100, G2 30, G3 20, G4 10, G5 50/
p0(g)     Initial power output [MW]         /G1 150, G2 28, G3 50, G4 25, G5 100/;

TABLE pbg(t,g,bg) Power [MW] of the generation bid function
$ include t2_pbg

TABLE lbg(t,g,bg) Prices [eur:MWh] of the generation bid function
$ include t2_lbg

* Demand units:




SETS
d  Demand units / D1*D3/
bd Blocks       / b1*b4 /;

TABLE pbd(t,d,bd) Power [MW] of the demand bid function
$ include t2_pbd

TABLE lbd(t,d,bd) Prices [�:MWh] of the generation bid function
$ include t2_lbd

* Buses:

SET  b      Buses            / bus1*bus4 /;
SET refb(b) Reference bus    / bus1 /;
alias(b,b_o,b_d);

SET gb(g,b) Generation buses / G1.bus1, G2.bus1, G3.bus2, G4.bus2, G5.bus4 /;
SET db(d,b) Demand buses     / D1.bus1, D2.bus2, D3.bus3 /;

* Lines;

SET l(b_o,b_d) lines / bus1.bus2, bus1.bus3, bus2.bus3, bus2.bus4, bus3.bus4 /;

display gb, db, refb, l;

PARAMETERS pbase basepower [MVAr] / 100 /;
TABLE x(b,b) Line reactance [p.u.]
      bus1 bus2   bus3  bus4
bus1   0.0  0.058 0.04  0.0
bus2   0.0  0.0   0.08  0.08
bus3   0.0  0.0   0.0   0.12
bus4   0.0  0.0   0.0   0.0  ;

TABLE s_max(b,b) Line capacity [MVA]
       bus1 bus2 bus3  bus4
bus1   150  150  150   150
bus2   150  150  150   150
bus3   150  150  150   150
bus4   150  150  150   150  ;

*********************************************************************
* VARIABLES
*********************************************************************

FREE VARIABLE     SW         Social welfare (objective function);
* Generation;
POSITIVE VARIABLE PG(t,g,bg) Matched generation of each block [MW]
                  PGT(t0,g)  Total matched generation [MW]
BINARY VARIABLE   U(t,g)     on-off state of the unit;
* Total generation at t=0:
PGT.fx('t0',g) = p0(g);

* Demand;
POSITIVE VARIABLE PD(t,d,bd) Matched demand of each block [MW]
                  PDT(t,d)   Total matched demand [MW];
* Grid;
VARIABLE P(t,b,b)   Line power [MW]
         Th(t,b)    Voltage phase;

P.fx(t,b_o,b_d)$(not l(b_o,b_d)) = 0.0;
P.lo(t,b_o,b_d)   = -s_max(b_o,b_d);
P.up(t,b_o,b_d)   = s_max(b_o,b_d);

Th.fx(t,refb) = 0.0;

*********************************************************************
* OBJECTIVE FUNCTION AND CONSTRAINTS
*********************************************************************

EQUATIONS
OF            Objective function
MATCHED_G     Matched generation to generation block coupling
MATCHED_D     Matched demand to demand block coupling
TOT_MATCHED_G Total matched generation
TOT_MATCHED_D Total matched demand
NODAL_MARKET  Market equilibrium at bus
LPFE          Line power flow equations
RAMP_D        Ramp down limit constraints
RAMP_U        Ramp up limit constraints
PGMIN         Minimum generation
PGMAX         Maximum generation;

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
NODAL_MARKET(t,b)..
* Total power outflow to the grid:
  sum(b_d$l(b,b_d), P(t,b,b_d))
* Total power inflow  from the grid:
- sum(b_o$l(b_o,b), P(t,b_o,b))
* Net power balance of bus "b":
=e= sum(g$gb(g,b),PGT(t,g))- sum(d$db(d,b),PDT(t,d)) ;

* Line power flow equations:
LPFE(t,b_o,b_d)$l(b_o,b_d).. P(t,b_o,b_d) =e= pbase*(Th(t,b_o)-Th(t,b_d))/x(b_o,b_d);

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

MODEL TCMPA    / ALL /;
option optCR = 0.0;
SOLVE TCMPA USING mip MAXIMIZING SW;
U.fx(t,g) = U.l(t,g);
SOLVE TCMPA USING rmip MAXIMIZING SW;

*********************************************************************
* MARKET CLEARING LOG
*********************************************************************

display NODAL_MARKET.m;
$ include TCMPA_disp_equilibrium
$ include TCMPA_disp_equilibrium_bus
$ include TCMPA_disp_settlement

*********************************************************************
* Matlab INPUT FILES FOR MARKET CLEARING PLOTS...
*********************************************************************
* ... for TCMPA_BF.m
*$ include TCMPA2M_T
* ... for TCMPA_BFNodal.m
SET bout(b) /'bus1','bus2','bus3','bus4'/
$ include TCMPA2M

