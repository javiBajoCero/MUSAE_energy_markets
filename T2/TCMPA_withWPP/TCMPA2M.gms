********************************************************************************
* F.-Javier Heredia f.javier.heredia(at)upc.edu http://gnom.upc.edu/heredia
* Code under Creative Commons Attribution-NonCommercial-NoDerivs
* 3.0 Unported License http://creativecommons.org/licenses/by-nc-nd/3.0/
********************************************************************************

file TCMPA_bus /TCMPA_bus.dat/;
file TCMPA_eq  /TCMPA_eq.dat/;
file TCMPA_lbg /TCMPA_lbg.dat/;
file TCMPA_pbg /TCMPA_pbg.dat/;
file TCMPA_PG  /TCMPA_PG.dat/;
file TCMPA_lbd /TCMPA_lbd.dat/;
file TCMPA_pbd /TCMPA_pbd.dat/;
file TCMPA_PD  /TCMPA_PD.dat/;

put TCMPA_bus; loop(bout, put bout.tl);
put TCMPA_eq;
scalar aux;
loop(b$bout(b),
         loop(t,
                 put market_equilibrium(t,b,'energy');
                 put market_equilibrium(t,b,'price');
                 put market_equilibrium(t,b,'nodal SW');
                 put /
         );
);

loop(b$bout(b),
put TCMPA_lbg;
loop(t,
         loop(g$gb(g,b), loop(bg, put  lbg(t,g,bg)));
*        Positive Inflow => generation unit
         loop(b_o$(l(b_o,b) and P.l(t,b_o,b)>0), put NODAL_MARKET.m(t,b_o));
*        Negative Outflow => generation unit
         loop(b_d$(l(b,b_d) and P.l(t,b,b_d)<0), put NODAL_MARKET.m(t,b_d));
         put /);
put TCMPA_pbg;
loop(t,
         loop(g$gb(g,b), loop(bg, put  pbg(t,g,bg)));
*        Positive Inflow => generation unit
         loop(b_o$(l(b_o,b) and P.l(t,b_o,b)>0), put  P.up(t,b_o,b));
*        Negative Outflow => generation unit
         loop(b_d$(l(b,b_d) and P.l(t,b,b_d)<0), aux = -P.lo(t,b,b_d); put aux);
         put /);
put TCMPA_PG;
loop(t,
         loop(g$gb(g,b), loop(bg, put PG.l(t,g,bg)));
*        Positive Inflow => generation unit
         loop(b_o$(l(b_o,b) and P.l(t,b_o,b)>0), put  P.l(t,b_o,b));
*        Negative Outflow => generation unit
         loop(b_d$(l(b,b_d) and P.l(t,b,b_d)<0), aux = -P.l(t,b,b_d); put aux);
         put /);
put TCMPA_lbd;
loop(t,
         loop(d$db(d,b), loop(bd, put  lbd(t,d,bd)));
*        Negative Inflow => demand unit
         loop(b_o$(l(b_o,b) and P.l(t,b_o,b)<0), put NODAL_MARKET.m(t,b_o));
*        Positive Outflow => demand unit
         loop(b_d$(l(b,b_d) and P.l(t,b,b_d)>0), put NODAL_MARKET.m(t,b_d));
         put /);
put TCMPA_pbd;
loop(t,
         loop(d$db(d,b), loop(bd, put  pbd(t,d,bd)));
*        Negative Inflow => demand unit
         loop(b_o$(l(b_o,b) and P.l(t,b_o,b)<0), aux = -P.lo(t,b_o,b); put aux);
*        Positive Outflow => demand unit
         loop(b_d$(l(b,b_d) and P.l(t,b,b_d)>0), put  P.up(t,b,b_d));
         put /);
put TCMPA_PD;
loop(t,
         loop(d$db(d,b), loop(bd, put PD.l(t,d,bd)));
*        Negative Inflow => demand unit
         loop(b_o$(l(b_o,b) and P.l(t,b_o,b)<0), aux = -P.l(t,b_o,b); put aux);
*        Positive Outflow => demand unit
         loop(b_d$(l(b,b_d) and P.l(t,b,b_d)>0), put  P.l(t,b,b_d));
         put /);
);

*file TCMPA_PGT   /TCMPA_PGT.dat/;
*file TCMPA_PGmin /TCMPA_PGmin.dat/;
*file TCMPA_PGmax /TCMPA_PGmax.dat/;
*file TCMPA_PGRU  /TCMPA_PGRU.dat/;
*file TCMPA_PGRD  /TCMPA_PGRD.dat/;

*put TCMPA_PGT;
*loop(g,
*loop(t0, put PGT.l(t0,g)); put/;
*loop(t0, put pg_min(g)) ; put/;
*loop(t0, put pg_max(g)) ; put/;
*loop(t0, put rd(g))     ; put/;
*loop(t0, put ru(g))     ; put/;
*);
