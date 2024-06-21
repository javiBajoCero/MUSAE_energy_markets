********************************************************************************
* F.-Javier Heredia f.javier.heredia(at)upc.edu http://gnom.upc.edu/heredia
* Code under Creative Commons Attribution-NonCommercial-NoDerivs
* 3.0 Unported License http://creativecommons.org/licenses/by-nc-nd/3.0/
********************************************************************************
*
* Equilibrium
*
matched_generation(t,g,bg,'matched_P') = PG.l(t,g,bg);
matched_demand(t,d,bd,'matched_P')     = PD.l(t,d,bd);

loop(t,
market_equilibrium(t,'SocWel') =
   sum(d, sum(bd, lbd(t, d, bd)*PD.l(t,d,bd)))
 - sum(g, sum(bg, lbg(t, g, bg)*PG.l(t,g,bg)));
market_equilibrium(t,'energy') = sum(d, PDT.l(t,d));
market_equilibrium(t,'price')  = -MARKET.m(t);
);

* Tables to compare market clearing:
display
matched_generation, PGT.l,
matched_demand    , PDT.l,
market_equilibrium;
*
* Settlement
*
SET rsg  Rows for generation settlement  / Revenue, 'Total rev.', Surplus, 'Total sur.'/;
SET rsd  Rows for demand settlement      / Payment, 'Total pay.', Surplus, 'Total sur.'/;
PARAMETER
settlementG(rsg, g, t),
settlementD(rsd, d, t),
settlementGT(rsg, t),
settlementDT(rsd, t);
loop(t,
         loop(g,
                 settlementG('Revenue',g,t) = -MARKET.m(t)*PGT.l(t,g);
                 settlementG('Surplus',g,t) =
                         settlementG('Revenue',g,t) - sum(bg,lbg(t,g,bg)*PG.l(t,g,bg))
         );
         settlementGT('Total rev.',t) = sum(g,settlementG('Revenue',g,t));
         settlementGT('Total sur.',t) = sum(g,settlementG('Surplus',g,t));
         loop(d,
                 settlementD('Payment',d,t) = -MARKET.m(t)*PDT.l(t,d);
                 settlementD('Surplus',d,t) =
                         sum(bd,lbd(t,d,bd)*PD.l(t,d,bd))- settlementD('Payment',d,t)
         );
         settlementDT('Total pay.',t) = sum(d,settlementD('Payment',d,t));
         settlementDT('Total sur.',t) = sum(d,settlementD('Surplus',d,t));
);

display settlementG, settlementD, settlementGT, settlementDT;
