within Buildings.HeatTransfer.Conduction.BaseClasses.Examples;
model EnthalpyTemperaturePCM
  "Approximation of enthalpy-temperature curve with cubic hermite cubic spline"
  extends Modelica.Icons.Example;
  // Phase-change properties
  parameter Buildings.HeatTransfer.Data.SolidsPCM.Generic
      materialMonotone(
               TSol=273.15+30.9,
               TLiq=273.15+40.0,
               LHea=1000000,
               c=920,
               ensureMonotonicity=true,
               d=1000,
               k=1,
               x=0.2) "Phase change material with monotone u-T relation";
  parameter Buildings.HeatTransfer.Data.SolidsPCM.Generic
      materialNonMonotone(TSol=273.15+30.9,
               TLiq=273.15+40.0,
               LHea=1000000,
               c=920,
               ensureMonotonicity=false,
               d=1000,
               k=1,
               x=0.2) "Phase change material with non-monotone u-T relation";
  parameter Modelica.SIunits.SpecificInternalEnergy ud[materialMonotone.nSupPCM](each fixed=false)
    "Support points";
  parameter Modelica.SIunits.Temperature Td[materialMonotone.nSupPCM](each fixed=false)
    "Support points";
  parameter Real scale=0.999
    "Scale used to position the points 1,3,4 and 6 while T2=TSol and T5=TLiq";
  parameter Real dT_du[materialMonotone.nSupPCM](fixed=false, unit="kg.K2/J")
    "Derivatives at the support points - non-monotone, default in Modelica PCM";
  parameter Real[materialMonotone.nSupPCM] dT_duMonotone(fixed=false, unit="kg.K2/J")
    "Derivatives at the support points for monotone increasing cubic splines";
  Modelica.SIunits.SpecificInternalEnergy u "Specific internal energy";
  Modelica.SIunits.Temperature T
    "Temperature for given u without monotone interpolation";
  Modelica.SIunits.Temperature TMonotone
    "Temperature for given u with monotone interpolation";
  Modelica.SIunits.Temperature TExa "Exact value of temperature";
  Real errMonotone
    "Relative temperature error between calculated value with monotone interpolation and exact temperature";
  Real errNonMonotone
    "Relative temperature error between calculated value with non-monotone interpolation and exact temperature";

 parameter Modelica.SIunits.TemperatureDifference dTCha = materialMonotone.TSol+materialMonotone.TLiq
    "Characteristic temperature difference of the problem";
protected
  function relativeError "Relative error"
    input Modelica.SIunits.Temperature T "Approximated temperature";
    input Modelica.SIunits.Temperature TExa "Exact temperature";
    input Modelica.SIunits.TemperatureDifference dTCha
      "Characteristic temperature difference";
    output Real relErr "Relative error";
  algorithm
    relErr :=(T - TExa)/dTCha;
  end relativeError;

  constant Real conFac(unit="1/s") = 1
    "Conversion factor to satisfy unit check";
initial algorithm
  // Calculate derivatives at support points (non-monotone)
  (ud, Td, dT_du) :=
    Buildings.HeatTransfer.Conduction.BaseClasses.der_temperature_u(
    materialNonMonotone);
  // Calculate derivatives at support points (monotone);
 (ud, Td, dT_duMonotone) :=
    Buildings.HeatTransfer.Conduction.BaseClasses.der_temperature_u(
    materialMonotone);
equation
  // Current value of specific internal energy for which the temperature will be computed.
algorithm
  u :=  time*(materialMonotone.c*(materialMonotone.TSol+materialMonotone.TLiq)+materialMonotone.LHea)*conFac;

  // Calculate T based on non-monotone interpolation
  T := Buildings.HeatTransfer.Conduction.BaseClasses.temperature_u(
       ud=ud,
       Td=Td,
       dT_du=dT_du,
       u=u);
  // Calculate T based on monotone interpolation
  TMonotone := Buildings.HeatTransfer.Conduction.BaseClasses.temperature_u(
       ud=ud,
       Td=Td,
       dT_du=dT_duMonotone,
       u=u);
  //Relative errors of obtained temperatures by using monotone and non-monotone
  //interpolation against exact values of tempratures taken from the u-T curve
  if time>=1.e-05 then
    if u <= materialMonotone.c*materialMonotone.TSol then
      // Solid region
      TExa           := u/materialMonotone.c;
    elseif u >= materialMonotone.c*materialMonotone.TLiq+materialMonotone.LHea then
      // Liquid region
      TExa           := (u-materialMonotone.LHea)/materialMonotone.c;
   else
      // Region of phase transition
      TExa:=((u + materialMonotone.LHea*materialMonotone.TSol/(materialMonotone.TLiq
         - materialMonotone.TSol))/(materialMonotone.c + materialMonotone.LHea/(
        materialMonotone.TLiq - materialMonotone.TSol)));
    end if;
  else
    TExa :=T;
  end if;
  errNonMonotone := relativeError(T=T,         TExa=TExa, dTCha=  dTCha);
  errMonotone    := relativeError(T=TMonotone, TExa=TExa, dTCha=  dTCha);

  annotation (
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{
            100,100}}), graphics),
    __Dymola_Commands(file=
          "modelica://Buildings/Resources/Scripts/Dymola/HeatTransfer/Conduction/BaseClasses/Examples/EnthalpyTemperaturePCM.mos"
        "Simulate and plot"),
    Documentation(info="<html>
<p>
This example tests and demonstrates the implementation of the specific internal 
energy-temperature (u-T) relationship for phase-change problems. 
Cubic hermite interpolation and linear extrapolation is used to approximate 
the u-T relationship. 
A piece-wise linear u-T relationship is assumed in all three chracteristic regions (solid, mushy and liquid).
The example uses the the functions
<a href=\"modelica://Buildings.HeatTransfer.Conduction.BaseClasses.der_temperature_u\">
Buildings.HeatTransfer.Conduction.BaseClasses.der_temperature_u</a> 
and the
<a href=\"modelica://Buildings.HeatTransfer.Conduction.BaseClasses.temeprature_u\">
Buildings.HeatTransfer.Conduction.BaseClasses.temeprature_u</a>.
The first function is used for calculation 
of derivatives at prescribed points,
and the second function returns the temperature 
for a given specific internal energy. 
</p>
<p>
The example demonstrates also the use of the cubic hermite spline interpolation with 
two different settings: One produces an approximation of u-T that is monotone, 
whereas the other does not enforce monotonicity. 
The latter one is used as default in the <code>Buildings</code> library, 
since it produces a higher accuracy in the mushy
region, especially for materials in which phase-change transformation occurs in a wide
temperature interval (see the figure below). 
The curves <code>errNonMonotone</code> and 
<code>errMonotone</code>
represent the relative error between approximated and exact temperatures 
obtained for different enthalpy values (right hand side figure).
</p>
<p align=\"center\"><img src=\"modelica://Buildings/Resources/Images/HeatTransfer/Conduction/BaseClasses/Examples/EnthalpyTemperaturePCM.png\"/>
</p>
</html>", revisions="<html>
<ul>
<li>
March 9, 2013, by Michael Wetter:<br>
Revised implementation to use new data record.
</li>
<li>
January 22, 2013, by Armin Teskeredzic:<br>
First implementations.
</li>
</ul>
</html>"));
end EnthalpyTemperaturePCM;
