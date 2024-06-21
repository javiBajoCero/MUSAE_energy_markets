*
* File for the Matlab function SPA_AccBidFunc.m to represent the aggregated
* bid functions and the matched energy for each time period.
*
file SPA_eq  /SPA_eq.dat/; put SPA_eq;
put market_equilibrium('energy','SPA');
put market_equilibrium('price','SPA');
put market_equilibrium('SocWel','SPA');

file SPA_lbg /SPA_lbg.dat/; put SPA_lbg; loop(g, loop(bg, put lbg(g,bg)));  put /;
file SPA_pbg /SPA_pbg.dat/; put SPA_pbg; loop(g, loop(bg, put pbg(g,bg)));  put /;
file SPA_PG  /SPA_PG.dat/;  put SPA_PG;  loop(g, loop(bg, put PG.l(g,bg))); put /;
file SPA_lbd /SPA_lbd.dat/; put SPA_lbd; loop(d, loop(bd, put lbd(d,bd)));  put /;
file SPA_pbd /SPA_pbd.dat/; put SPA_pbd; loop(d, loop(bd, put pbd(d,bd)));  put /;
file SPA_PD  /SPA_PD.dat/;  put SPA_PD;  loop(d, loop(bd, put PD.l(d,bd))); put /;

file SPA_PGT  /SPA_PGT.dat/;
file SPA_PGmin /SPA_PGmin.dat/;
file SPA_PGmax /SPA_PGmax.dat/;
file SPA_PGRU /SPA_PGRU.dat/;
file SPA_PGRD /SPA_PGRD.dat/;
