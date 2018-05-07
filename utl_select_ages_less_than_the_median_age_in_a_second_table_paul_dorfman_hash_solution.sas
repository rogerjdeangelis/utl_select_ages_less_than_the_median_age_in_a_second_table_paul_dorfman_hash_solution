Select ages less than the median age in a second table Paul Dorfman hash solution

Solution by

Paul Dorfman
sashole@bellsouth.net

WPS seem to yeild an incorrect result. It picked a median of 12 for classfit(not 13)
Pauls logic for 19 obs uses the middle value of sorted age which is observation 10.
Using WPS daatsets instead of SAS datasets did not fix the problem.
Perhaps WPS does not support 'h.num_items' yet?


INPUT
====

  sashelp.class
  sashelp.classfit


WANT
====

  select * from sashelp.class where age < median(=13) age in sashelp.classfit


EXAMPLE OUTPUT
==============

  WORK.WANT total obs=7

    AGE     NAME     SEX    HEIGHT    WEIGHT

     12    James      M      57.3       83.0
     12    Jane       F      59.8       84.5
     12    John       M      59.0       99.5
     11    Joyce      F      51.3       50.5
     12    Louise     F      56.3       77.0
     12    Robert     M      64.8      128.0
     11    Thomas     M      57.5       85.0


PROCESS
=======

data want (drop = _:) ;
  dcl hash h (dataset:"sashelp.classfit (keep=age)", multidata:"y", ordered:"a") ;
  h.definekey ("age") ;
  h.definedone () ;
  dcl hiter i ("h") ;
  do _n_ = 1 to ceil (h.num_items / 2) ;
    i.next() ;
  end ;
  if mod (h.num_items, 2) then _median = age ;
  else do ;
    _age = age ;
    i.next() ;
    _median = mean (age, _age) ;
  end ;
  do until (z) ;
    set sashelp.class end = z ;
    if age < _median then output ;
  end ;
run ;

OUTPUT
======

 WORK.WANT total obs=7

   AGE     NAME     SEX    HEIGHT    WEIGHT

    12    James      M      57.3       83.0
    12    Jane       F      59.8       84.5
    12    John       M      59.0       99.5
    11    Joyce      F      51.3       50.5
    12    Louise     F      56.3       77.0
    12    Robert     M      64.8      128.0
    11    Thomas     M      57.5       85.0


*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

see above for SAS


* PROBLEMATIC WPS CODE;

%utl_submit_wps64('
libname wrk sas7bdat "%sysfunc(pathname(work))";
libname hlp sas7bdat "C:\progra~1\SASHome\SASFoundation\9.4\core\sashelp";
data classfit;
  set hlp.classfit;
run;quit;
data wrk.wantwps (/*drop = _:*/) ;
  dcl hash h (dataset:"classfit (keep=age)", multidata:"y", ordered:"a") ;
  h.definekey ("age") ;
  h.definedone () ;
  dcl hiter i ("h") ;
  do _n_ = 1 to ceil (h.num_items / 2) ;
    i.next() ;
  end ;
  if mod (h.num_items, 2) then _median = age ;
  else do ;
    _age = age ;
    i.next() ;
    _median = mean (age, _age) ;
  end ;
  do until (z) ;
    set hlp.class end = z ;
    if age < _median then output ;
  end ;
run;quit;
');


NOTE: Hashexp of 5 selected based on input data set size of 19
NOTE: 6 keys created in hash table from data set HLP.classfit
NOTE: 13 additional multidata items were created
NOTE: Hashexp of 5 selected based on input data set size of 19
NOTE: 6 keys created in hash table from data set HLP.classfit
NOTE: 13 additional multidata items were created
NOTE: 19 observations were read from "HLP.class"
NOTE: Data set "WRK.wantwps" has 2 observation(s) and 7 variable(s)



