********************************************************************************
* F.-Javier Heredia f.javier.heredia(at)upc.edu http://gnom.upc.edu/heredia
* Code under Creative Commons Attribution-NonCommercial-NoDerivs
* 3.0 Unported License http://creativecommons.org/licenses/by-nc-nd/3.0/
********************************************************************************

$title OEMO_MIP

*********************************************************************
* DATA
*********************************************************************

SETS
i     Coefficient for the decision variables /1 * 2/
ic(i) Coeff. for the continuous variables (a subset of "i") /1/
iz(i) Coeff. for the integer variables (a subset of "i")    /2/
j Coefficient for the constraints /1 * 3/;

PARAMETERS
c(i) Linear coef. of the objective function
/ 1  -1
  2  -2 /
b(j) RHS
/
1  9
2 -2
3  4
/;

TABLE
a(j,i) Constraints coefficient matrix
   1    2
1 -4    6
2 -2   -1
3  1    1;

*********************************************************************
* VARIABLES
*********************************************************************
FREE VARIABLES     Z     Objective function;
POSITIVE VARIABLES X(ic) Continous variables;
INTEGER VARIABLES  Y(iz) Integer   variables;

*********************************************************************
* MODEL
*********************************************************************

* Equations of the model: declaration

EQUATIONS
ObjFunc
ConL;

* Equations of the model: definition

ObjFunc.. Z =e= sum(ic,c(ic)*X(ic))+sum(iz,c(iz)*Y(iz));
ConL(j).. sum(ic,a(j,ic)*X(ic))+sum(iz,a(j,iz)*Y(iz)) =l= b(j);

* Creation of the model

MODEL MIP /ALL/;

*********************************************************************
* OPTIMIZATION
*********************************************************************

*SOLVE MIP USING rmip MINIMIZING Z; 

SOLVE MIP USING mip MINIMIZING Z;

display 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', Y.l;

Y.fx(iz) =Y.l(iz);
SOLVE MIP USING rmip MINIMIZING Z;
