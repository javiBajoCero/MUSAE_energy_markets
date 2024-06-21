********************************************************************************
* F.-Javier Heredia f.javier.heredia(at)upc.edu http://gnom.upc.edu/heredia
* Code under Creative Commons Attribution-NonCommercial-NoDerivs
* 3.0 Unported License http://creativecommons.org/licenses/by-nc-nd/3.0/
*********************************************************************************
* File for the Matlab function TCMPA_BF.m to represent the aggregated
* bid functions and the matched energy for each time period.
*
file MPA_eq  /TCMPA_eq_T.dat/; put MPA_eq;
scalar aux;
loop(t,
aux = sum(d, sum(bd, lbd(t,d,bd)*PD.l(t,d,bd))) - sum(g, sum(bg, lbg(t,g,bg)*PG.l(t,g,bg)));
put sum(g, sum(bg, PG.l(t,g,bg)));
put sum(b, market_equilibrium(t,b,'price'));
put aux;
put /);

file MPA_lbg /TCMPA_lbg_T.dat/; put MPA_lbg; loop(t, loop(g, loop(bg, put lbg(t,g,bg)));  put /);
file MPA_pbg /TCMPA_pbg_T.dat/; put MPA_pbg; loop(t, loop(g, loop(bg, put pbg(t,g,bg)));  put /);
file MPA_PG  /TCMPA_PG_T.dat/;  put MPA_PG;  loop(t, loop(g, loop(bg, put PG.l(t,g,bg))); put /);
file MPA_lbd /TCMPA_lbd_T.dat/; put MPA_lbd; loop(t, loop(d, loop(bd, put lbd(t,d,bd)));  put /);
file MPA_pbd /TCMPA_pbd_T.dat/; put MPA_pbd; loop(t, loop(d, loop(bd, put pbd(t,d,bd)));  put /);
file MPA_PD  /TCMPA_PD_T.dat/;  put MPA_PD;  loop(t, loop(d, loop(bd, put PD.l(t,d,bd))); put /);

file MPA_PGT  /TCMPA_PGT.dat/;
*file MPA_PGmin /TCMPA_PGmin.dat/;
*file MPA_PGmax /TCMPA_PGmax.dat/;
*file MPA_PGRU /TCMPA_PGRU.dat/;
*file MPA_PGRD /TCMPA_PGRD.dat/;

put MPA_PGT;
loop(g,
loop(t0, put PGT.l(t0,g)); put/;
loop(t0, put pg_min(g)) ; put/;
loop(t0, put pg_max(g)) ; put/;
loop(t0, put rd(g))     ; put/;
loop(t0, put ru(g))     ; put/;
);
