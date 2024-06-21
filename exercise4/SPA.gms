********************************************************************************
* F.-Javier Heredia f.javier.heredia(at)upc.edu http://gnom.upc.edu/heredia
* Code under Creative Commons Attribution-NonCommercial-NoDerivs
* 3.0 Unported License http://creativecommons.org/licenses/by-nc-nd/3.0/
********************************************************************************

$title OEMO_SPA

*********************************************************************
* DATA
*********************************************************************

* Generation units:

SETS
g Generation units / G1/
bg Blocks           /1*2/;

PARAMETERS
pg_max(g) Max. active power generation [MW] /G1 30/
pg_min(g) Min. active power generation [MW] /G1  15/
ru(g)     Ramp-up limit [MW:h]              /G1  5/
rd(g)     Ramp-down limit [MW]              /G1  5/
p0(g)     Initial power output [MW]         /G1 30/;

TABLE pbg(g,bg) Power [MW] of the generation bid function
     1  2  
G1   15 15 ;

TABLE lbg(g,bg) Prices [eur:MWh] of the generation bid function
     1  2  
G1   3  6 ;

* Demand units:

SETS
d Generation units / D1, D2 /
bd Blocks          / 1*2 /;

TABLE pbd(d,bd) Power [MW] of the demand bid function
    1   2
D1  10 10
D2  10 10;

TABLE lbd(d,bd) Prices [�:MWh] of the generation bid function
    1  2  
D1  8  1 
D2  7  2 ;

display pbg, lbg, pbd, lbd;

*********************************************************************
* VARIABLES
*********************************************************************

FREE VARIABLE     SW       Social welfare (objective function)
POSITIVE VARIABLE PG(g,bg) Matched generation of each block [MW]
                  PD(d,bd) Matched demand of each block [MW];
BINARY VARIABLE   U(g)    on-off state of the unit;

*********************************************************************
* OBJECTIVE FUNCTION AND CONSTRAINTS
*********************************************************************

EQUATIONS
OF         Objective function
MATCHED_G  Matched generation to generation block coupling
MATCHED_D  Matched demand to demand block coupling
MARKET     Market equilibrium
RAMP_D     Ramp down limit constraints
RAMP_U     Ramp up limit constraints
PGMIN      Minimum generation
PGMAX      Maximum generation;

* Social Welfare:
OF.. SW =e=  sum(d, sum(bd, lbd(d,bd)*PD(d,bd)))
           - sum(g, sum(bg,lbg(g,bg)*PG(g,bg)));

* Matched generation to generation block coupling:
MATCHED_G(g,bg).. PG(g,bg) =l= pbg(g,bg);

* Matched demand to demand block coupling:
MATCHED_D(d,bd).. PD(d,bd) =l= pbd(d,bd);

* Market Equilibrium:
MARKET.. sum(d, sum(bd, PD(d,bd) )) =e=
         sum(g, sum(bg, PG(g,bg) ));

* Ramp down limit:
RAMP_D(g).. sum(bg, PG(g,bg)) - p0(g) =g= - rd(g);

* Ramp up limit:
RAMP_U(g).. sum(bg, PG(g,bg)) - p0(g) =l=   ru(g);

* Generation limits:
PGMIN(g)..  sum(bg, PG(g,bg)) =g= pg_min(g)*U(g);
PGMAX(g)..  sum(bg, PG(g,bg)) =l= pg_max(g)*U(g);

*********************************************************************
* OPTIMIZATION
*********************************************************************

SET sc Columns for tables "_s" /bid_price, bid_power, SPA0 , SPA/;
SET req Rows for market clearing tables / SocWel , price, energy/;
SET mod Columns for market clearing tables / SPA0 , SPA/;
PARAMETER
matched_generation(g,bg,sc), total_matched_generation(g,sc),
matched_demand(d,bd,sc), total_matched_demand(d,sc),
market_equilibrium(req,mod);
* Lagrange multipliers mu;
SET mucolG / 'la^*=', 'la^b', '-mu^0', '-mu^b' /;
SET mucolD / 'la^*=', 'la^b', '+mu^0', '+mu^b' /;
PARAMETERS muG_0(g,bg,mucolG),muD_0(d,bd,mucolD);

matched_generation(g,bg,'bid_price') = lbg(g,bg);
matched_generation(g,bg,'bid_power') = pbg(g,bg);
matched_demand(d,bd,'bid_price')     = lbd(d,bd);
matched_demand(d,bd,'bid_power')     = pbd(d,bd);

muG_0(g,bg,'la^b') = lbg(g,bg);
muD_0(d,bd,'la^b') = lbd(d,bd);

* Simplified model (LP):

MODEL SPA0  / OF, MATCHED_G, MATCHED_D, MARKET/;
SOLVE SPA0 USING lp MAXIMIZING SW;

matched_generation(g,bg,'SPA0')     = PG.l(g,bg);
total_matched_generation(g,'SPA0')  = sum(bg,PG.l(g,bg));
matched_demand(d,bd,'SPA0')         = PD.l(d,bd);
total_matched_demand(d,'SPA0')      = sum(bd,PD.l(d,bd));
market_equilibrium('SocWel','SPA0') = SW.l;
market_equilibrium('price', 'SPA0') = MARKET.m;
market_equilibrium('energy', 'SPA0')= sum(d, sum( bd,PD.l(d,bd)));

muG_0(g,bg,'la^*=')    = MARKET.m;
muD_0(d,bd,'la^*=')    = MARKET.m;
* The signs of the lag. mult. in GAMS are the opposite of those defined in classroom;
muG_0(g,bg,'-mu^0') = PG.m(g,bg);
muG_0(g,bg,'-mu^b') = MATCHED_G.m(g,bg);
muD_0(d,bd,'+mu^0') = -PD.m(d,bd);
muD_0(d,bd,'+mu^b') = -MATCHED_D.m(d,bd);

* Full model (MIP):

MODEL SPA    / ALL /;
SOLVE SPA USING mip MAXIMIZING SW;

matched_generation(g,bg,'SPA')   = PG.l(g,bg);
total_matched_generation(g,'SPA')= sum(bg,PG.l(g,bg));
matched_demand(d,bd,'SPA')       = PD.l(d,bd);
total_matched_demand(d,'SPA')    = sum(bd,PD.l(d,bd));
market_equilibrium('SocWel','SPA') = SW.l;
market_equilibrium('energy', 'SPA')= sum(d, sum( bd,PD.l(d,bd)));

* Continuous problem associated to SPA (CSPA):

* We first set the optimal value of the binary variables;
U.fx(g) = U.l(g);
* And then solve the linear relaxation of SPA;
SOLVE SPA USING rmip MAXIMIZING SW;
market_equilibrium('price', 'SPA') = MARKET.m;

* Output:

display
matched_generation, total_matched_generation,
matched_demand    , total_matched_demand,
market_equilibrium,
muG_0, muD_0;

*********************************************************************
* Matlab FILES FOR MARKET CLEARING PLOTS
*********************************************************************
$include SPA2M