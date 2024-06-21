* F.-Javier Heredia f.javier.heredia(at)upc.edu http://gnom.upc.edu/heredia
* Code under Creative Commons Attribution-NonCommercial-NoDerivs
* 3.0 Unported License http://creativecommons.org/licenses/by-nc-nd/3.0/
*
* GAMS code that creates the ASCII files MPA_lbg.dat, MPA_pbg.dat and MPA_PG.dat
* to plot the bid function with Matlab's file MPA_BF.m. Just add the sentence:
*
* $include MPA2M
*
* at the end opf the MPA.gms file.
*

file MPA_eq  /MPA_eq.dat/; put MPA_eq;
loop(t,
put market_equilibrium(t,'energy');
put market_equilibrium(t,'price');
put market_equilibrium(t,'SocWel');
put /);
file MPA_lbg /MPA_lbg.dat/; put MPA_lbg; loop(t, loop(g, loop(bg, put lbg(t,g,bg)));  put /);
file MPA_pbg /MPA_pbg.dat/; put MPA_pbg; loop(t, loop(g, loop(bg, put pbg(t,g,bg)));  put /);
file MPA_PG  /MPA_PG.dat/;  put MPA_PG;  loop(t, loop(g, loop(bg, put PG.l(t,g,bg))); put /);
file MPA_lbd /MPA_lbd.dat/; put MPA_lbd; loop(t, loop(d, loop(bd, put lbd(t,d,bd)));  put /);
file MPA_pbd /MPA_pbd.dat/; put MPA_pbd; loop(t, loop(d, loop(bd, put pbd(t,d,bd)));  put /);
file MPA_PD  /MPA_PD.dat/;  put MPA_PD;  loop(t, loop(d, loop(bd, put PD.l(t,d,bd))); put /);

file MPA_PGT  /MPA_PGT.dat/;
file MPA_PGmin /MPA_PGmin.dat/;
file MPA_PGmax /MPA_PGmax.dat/;
file MPA_PGRU /MPA_PGRU.dat/;
file MPA_PGRD /MPA_PGRD.dat/;

put MPA_PGT;
loop(g,
loop(t0, put PGT.l(t0,g)); put/;
loop(t0, put pg_min(g)) ; put/;
loop(t0, put pg_max(g)) ; put/;
loop(t0, put rd(g))     ; put/;
loop(t0, put ru(g))     ; put/;
);
