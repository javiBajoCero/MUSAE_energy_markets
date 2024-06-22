********************************************************************************
* F.-Javier Heredia f.javier.heredia(at)upc.edu http://gnom.upc.edu/heredia
* Code under Creative Commons Attribution-NonCommercial-NoDerivs
* 3.0 Unported License http://creativecommons.org/licenses/by-nc-nd/3.0/
********************************************************************************

SET cmat_bus Columns for tables "matched"      /bid_price, bid_power, matched_P/;
SET in /in/;
SET ou /out/;

PARAMETER
matched_generation_bus(b,t,g,bg,cmat_bus)
matched_demand_bus(b,t,d,bd,cmat_bus)
matched_inflow_bus(b,t,b_o,in,cmat_bus)
matched_outflow_bus(b,t,b_o,ou,cmat_bus);
*
* Generation units
*
matched_generation_bus(b,t,g,bg,'bid_price')$gb(g,b) = lbg(t,g,bg);
matched_generation_bus(b,t,g,bg,'bid_power')$gb(g,b) = pbg(t,g,bg);
matched_generation_bus(b,t,g,bg,'matched_P')$gb(g,b) = PG.l(t,g,bg);
* Positive inflow (= generation unit):
matched_inflow_bus(b,t,b_o,in,'bid_price')$(l(b_o,b) and P.l(t,b_o,b)>0) = NODAL_MARKET.m(t,b_o);
matched_inflow_bus(b,t,b_o,in,'bid_power')$(l(b_o,b) and P.l(t,b_o,b)>0) = P.up(t,b_o,b);
matched_inflow_bus(b,t,b_o,in,'matched_P')$(l(b_o,b) and P.l(t,b_o,b)>0) = P.l(t,b_o,b);
* Negative outflow (= positive inflow = generation unit):
matched_inflow_bus(b,t,b_d,in,'bid_price')$(l(b,b_d) and P.l(t,b,b_d)<0) = NODAL_MARKET.m(t,b_d);
matched_inflow_bus(b,t,b_d,in,'bid_power')$(l(b,b_d) and P.l(t,b,b_d)<0) = P.up(t,b,b_d);
matched_inflow_bus(b,t,b_d,in,'matched_P')$(l(b,b_d) and P.l(t,b,b_d)<0) = -P.l(t,b,b_d);
*
* Demand units
*
matched_demand_bus(b,t,d,bd,'bid_price')$db(d,b)     = lbd(t,d,bd);
matched_demand_bus(b,t,d,bd,'bid_power')$db(d,b)     = pbd(t,d,bd);
matched_demand_bus(b,t,d,bd,'matched_P')$db(d,b)     = PD.l(t,d,bd);
* Positive outflow (= demand unit):
matched_outflow_bus(b,t,b_d,ou,'bid_price')$(l(b,b_d) and P.l(t,b,b_d)>0) = NODAL_MARKET.m(t,b_d);
matched_outflow_bus(b,t,b_d,ou,'bid_power')$(l(b,b_d) and P.l(t,b,b_d)>0) = P.up(t,b,b_d);
matched_outflow_bus(b,t,b_d,ou,'matched_P')$(l(b,b_d) and P.l(t,b,b_d)>0) = P.l(t,b,b_d);
* Negative inflow ( = positive outflow = demand unit):
matched_outflow_bus(b,t,b_o,ou,'bid_price')$(l(b_o,b) and P.l(t,b_o,b)<0) = NODAL_MARKET.m(t,b_o);
matched_outflow_bus(b,t,b_o,ou,'bid_power')$(l(b_o,b) and P.l(t,b_o,b)<0) = P.up(t,b_o,b);
matched_outflow_bus(b,t,b_o,ou,'matched_P')$(l(b_o,b) and P.l(t,b_o,b)<0) = -P.l(t,b_o,b);

display
matched_generation_bus, matched_inflow_bus,
matched_demand_bus,     matched_outflow_bus;
