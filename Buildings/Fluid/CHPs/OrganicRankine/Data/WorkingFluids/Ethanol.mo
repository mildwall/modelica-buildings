within Buildings.Fluid.CHPs.OrganicRankine.Data.WorkingFluids;
record Ethanol "Data record for ethanol"
  extends Generic(
    T = {
         263.15,289.99,316.83,343.67,370.51,397.35,424.19,451.03,477.87,
         504.71},
    p = {
         7.689358061e+02,4.849943515e+03,2.156311297e+04,7.357097999e+04,
         2.046081847e+05,4.845344677e+05,1.008761409e+06,1.891911004e+06,
         3.263511383e+06,5.282165193e+06},
    rhoLiq = {
         814.799753232,792.036393251,768.756136609,744.093991385,
         716.886637425,685.51349857 ,647.811686098,601.669643931,
         543.369863156,438.527983321},
    dTRef = 30,
    sSatLiq = {
         -726.973851775,-505.583513991,-286.35608663 , -65.626950104,
          159.007283346, 389.527126652, 627.103332946, 869.931756177,
         1118.157181986,1411.006366334},
    sSatVap = {
         2902.952478464,2699.032398467,2551.227443872,2442.903267896,
         2361.504494341,2297.490986936,2243.294159242,2191.508999328,
         2129.791721023,2005.324094606},
    sRef = {
         3048.947765906,2841.665343912,2692.531793967,2585.157296558,
         2507.385719926,2450.24466807 ,2407.200424972,2373.310666428,
         2343.951307193,2312.828603679},
    hSatLiq = {
         -223584.403049121,-162359.292050491, -95822.158648172,
          -22850.994379185,  57554.398921637, 146473.200208431,
          244865.515469934, 352554.405086509, 470265.911621738,
          618471.162521627},
    hSatVap = {
         731630.710753397,766947.276403163,803209.431320732,
         839255.585640969,873601.64056746 ,904602.640092255,
         930437.502076461,948625.389064672,953695.708791375,
         918429.263157366},
    hRef = {
          772225.371527353, 810437.156029444, 850086.320725499,
          890262.545389702, 929818.501889787, 967557.529390266,
         1002370.800231913,1033259.201313757,1059056.681099724,
         1077479.396060467});
  annotation (
  defaultComponentPrefixes = "parameter",
  defaultComponentName = "pro",
  Documentation(info="<html>
<p>
Record containing properties of ethanol.
Its name in CoolProp is \"Ethanol\".
A figure in the documentation of
<a href=\"Modelica://Buildings.Fluid.CHPs.OrganicRankine.Cycle\">
Buildings.Fluid.CHPs.OrganicRankine.Cycle</a>
shows which lines these arrays represent.
</p>
</html>"));
end Ethanol;