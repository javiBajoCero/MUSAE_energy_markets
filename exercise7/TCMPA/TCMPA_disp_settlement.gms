********************************************************************************
* F.-Javier Heredia f.javier.heredia(at)upc.edu http://gnom.upc.edu/heredia
* Code under Creative Commons Attribution-NonCommercial-NoDerivs
* 3.0 Unported License http://creativecommons.org/licenses/by-nc-nd/3.0/
********************************************************************************

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
                 settlementG('Revenue',g,t) =
                         sum(b$gb(g,b),NODAL_MARKET.m(t,b)*PGT.l(t,g));
                 settlementG('Surplus',g,t) =
                         settlementG('Revenue',g,t) - sum(bg,lbg(t,g,bg)*PG.l(t,g,bg))
         );
         settlementGT('Total rev.',t) = sum(g,settlementG('Revenue',g,t));
         settlementGT('Total sur.',t) = sum(g,settlementG('Surplus',g,t));
         loop(d,
                 settlementD('Payment',d,t) =
                         sum(b$db(d,b),NODAL_MARKET.m(t,b)*PDT.l(t,d));
                 settlementD('Surplus',d,t) =
                         sum(bd,lbd(t,d,bd)*PD.l(t,d,bd))- settlementD('Payment',d,t)
         );
         settlementDT('Total pay.',t) = sum(d,settlementD('Payment',d,t));
         settlementDT('Total sur.',t) = sum(d,settlementD('Surplus',d,t));
);

display settlementG, settlementD, settlementGT, settlementDT;
