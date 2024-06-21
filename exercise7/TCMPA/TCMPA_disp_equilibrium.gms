********************************************************************************
* F.-Javier Heredia f.javier.heredia(at)upc.edu http://gnom.upc.edu/heredia
* Code under Creative Commons Attribution-NonCommercial-NoDerivs
* 3.0 Unported License http://creativecommons.org/licenses/by-nc-nd/3.0/
********************************************************************************

SET cmat         Columns for tables "matched"      /bid_price, bid_power, matched_P/;
SET ceq          Columns for "equilibrium" table   / 'price', 'energy', 'gen.', 'dem.', 'inflow', 'outflow',  'surp. gen.','surp. dem.', SW, 'surp. inf.', 'surp. out.', 'nodal SW'/;
SET ceqt(ceq)    Columns for "equilibrium_T" table / 'energy', 'gen.', 'dem.', 'inflow', 'outflow',  'surp. gen.','surp. dem.', SW/;
SET cmer         Columns for "merchandizing" table / 'price sell','price buy', 'energy', 'mer. surp.'/;

PARAMETER
matched_generation(t,g,bg,cmat), matched_demand(t,d,bd,cmat),
market_equilibrium(t,b,ceq),
market_equilibrium_T(t,ceqt),
market_merchandizing(t,b,b,cmer);

matched_generation(t,g,bg,'bid_price') = lbg(t,g,bg);
matched_generation(t,g,bg,'bid_power') = pbg(t,g,bg);
matched_demand(t,d,bd,'bid_price')     = lbd(t,d,bd);
matched_demand(t,d,bd,'bid_power')     = pbd(t,d,bd);

matched_generation(t,g,bg,'matched_P') = PG.l(t,g,bg);
matched_demand(t,d,bd,'matched_P')     = PD.l(t,d,bd);

*
* Market equilibrium
*
loop(t,
 loop(b,
*
* Social Welfare
*
  market_equilibrium(t,b,'surp. dem.') =
* Demand and generation surplus:
  sum(d$db(d,b), sum(bd, (lbd(t, d, bd)-NODAL_MARKET.M(t,b))*PD.l(t,d,bd)));
  market_equilibrium(t,b,'surp. gen.') =
* Demand and generation surplus:
 + sum(g$gb(g,b), sum(bg, (NODAL_MARKET.M(t,b)-lbg(t, g, bg))*PG.l(t,g,bg)));
  market_equilibrium(t,b,'SW') =
         market_equilibrium(t,b,'surp. dem.')
       + market_equilibrium(t,b,'surp. gen.');
*
* Nodal Equilibrium
*
  market_equilibrium(t,b,'gen.')    = sum(g$gb(g,b), PGT.l(t,g));
  market_equilibrium(t,b,'dem.')    = sum(d$db(d,b), PDT.l(t,d));
  market_equilibrium(t,b,'inflow')  =
          sum(b_o$(l(b_o,b) and P.l(t,b_o,b)>0),P.l(t,b_o,b))
        - sum(b_d$(l(b,b_d) and P.l(t,b,b_d)<0),P.l(t,b,b_d));
  market_equilibrium(t,b,'surp. inf.')  =
          sum(b_o$(l(b_o,b) and P.l(t,b_o,b)>0), (NODAL_MARKET.M(t,b)-NODAL_MARKET.M(t,b_o))*P.l(t,b_o,b))
        - sum(b_d$(l(b,b_d) and P.l(t,b,b_d)<0), (NODAL_MARKET.M(t,b)-NODAL_MARKET.M(t,b_d))*P.l(t,b,b_d));
  market_equilibrium(t,b,'outflow') =
          sum(b_d$(l(b,b_d) and P.l(t,b,b_d)>0),P.l(t,b,b_d))
        - sum(b_o$(l(b_o,b) and P.l(t,b_o,b)<0),P.l(t,b_o,b));
  market_equilibrium(t,b,'surp. out.') =
          sum(b_d$(l(b,b_d) and P.l(t,b,b_d)>0), (NODAL_MARKET.M(t,b_d)-NODAL_MARKET.M(t,b))*P.l(t,b,b_d))
        - sum(b_o$(l(b_o,b) and P.l(t,b_o,b)<0), (NODAL_MARKET.M(t,b_o)-NODAL_MARKET.M(t,b))*P.l(t,b_o,b));
  market_equilibrium(t,b,'nodal SW') =   market_equilibrium(t,b,'SW')
                                       + market_equilibrium(t,b,'surp. inf.')
                                       + market_equilibrium(t,b,'surp. out.');

  market_equilibrium(t,b,'energy') =
         market_equilibrium(t,b,'gen.')
      +  market_equilibrium(t,b,'inflow');
  market_equilibrium(t,b,'price')  = NODAL_MARKET.m(t,b);
 );
loop(ceqt, market_equilibrium_T(t,ceqt) = sum(b, market_equilibrium(t,b,ceqt)));
);
*
* Merchandising surplus:
*
loop(t,
   loop(b_o,
      loop(b_d$(l(b_o,b_d) and P.l(t,b_o,b_d)>0),
*     Positive outflow:
      market_merchandizing(t,b_o,b_d,'price buy') = NODAL_MARKET.m(t,b_o);
      market_merchandizing(t,b_o,b_d,'price sell')  = NODAL_MARKET.m(t,b_d);
      market_merchandizing(t,b_o,b_d,'energy')       = P.l(t,b_o,b_d);
      market_merchandizing(t,b_o,b_d,'mer. surp.') = (NODAL_MARKET.m(t,b_d)-NODAL_MARKET.m(t,b_o))*P.l(t,b_o,b_d);
      );
      loop(b_d$(l(b_o,b_d) and P.l(t,b_o,b_d)<0),
*     Negative outflow (inflow):
      market_merchandizing(t,b_o,b_d,'price buy')  = NODAL_MARKET.m(t,b_d);
      market_merchandizing(t,b_o,b_d,'price sell') = NODAL_MARKET.m(t,b_o);
      market_merchandizing(t,b_o,b_d,'energy')     = -P.l(t,b_o,b_d);
      market_merchandizing(t,b_o,b_d,'mer. surp.') = (NODAL_MARKET.m(t,b_d)-NODAL_MARKET.m(t,b_o))*P.l(t,b_o,b_d);
      );
   );
);
display
matched_generation, PGT.l,
matched_demand    , PDT.l,
market_equilibrium,
market_equilibrium_T,
market_merchandizing;
