within Buildings.Occupants.Office.Windows;
model Yun2008WindowsTIn "A model to predict occupants' window behavior with indoor temperature"
  extends Modelica.Blocks.Icons.DiscreteBlock;
  parameter Real AOpen = 0.030 "Slope of the logistic relation for opening the window";
  parameter Real BOpen = -0.629 "Intercept of the logistic relation for opening the window";
  parameter Real AClose = -0.007 "Slope of the logistic relation for closing the window";
  parameter Real BClose = -0.209 "Intercept of the logistic relation for closing the window";
  parameter Integer seed = 30 "Seed for the random number generator";
  parameter Modelica.SIunits.Time samplePeriod = 120 "Sample period";

  Modelica.Blocks.Interfaces.RealInput TIn(
    unit="K",
    displayUnit="degC") "Indoor air temperature" annotation (Placement(transformation(extent={{-140,-80},{-100,-40}}),
      iconTransformation(extent={{-140,-80},{-100,-40}})));
  Modelica.Blocks.Interfaces.BooleanInput occ
    "Indoor occupancy, true for occupied"
    annotation (Placement(transformation(extent={{-140,40},{-100,80}})));
  Modelica.Blocks.Interfaces.BooleanOutput on "State of window, true for open"
    annotation (Placement(transformation(extent={{100,-10},{120,10}})));

  Real pOpen(
    unit="1",
    min=0,
    max=1) "Probability of opening the window";
  Real pClose(
    unit="1",
    min=0,
    max=1) "Probability of closing the window";

protected
  parameter Modelica.SIunits.Time t0(fixed = false) "First sample time instant";
  output Boolean sampleTrigger "True, if sample time instant";
initial equation
  t0 = time;
  on = false;
equation
  sampleTrigger = sample(t0,samplePeriod);
  when sampleTrigger then
    pOpen = Modelica.Math.exp(AOpen*(TIn - 273.15)+BOpen)/(Modelica.Math.exp(AOpen*(TIn - 273.15)+BOpen) + 1);
    pClose = Modelica.Math.exp(AClose*(TIn - 273.15)+BClose)/(Modelica.Math.exp(AClose*(TIn - 273.15)+BClose) + 1);
    if occ then
      if pre(on) == true and TIn < 303.15 then
        on = not Buildings.Occupants.BaseClasses.binaryVariableGeneration(p=pClose, globalSeed=seed);
      elseif pre(on) == false and TIn > 293.15 then
        on = Buildings.Occupants.BaseClasses.binaryVariableGeneration(p=pOpen, globalSeed=seed);
      else
        on = pre(on);
      end if;
    else
      on = false;
    end if;
  end when;

  annotation (graphics={
            Rectangle(extent={{-60,40},{60,-40}}, lineColor={28,108,200}), Text(
            extent={{-40,20},{40,-20}},
            lineColor={28,108,200},
            fillColor={0,0,255},
            fillPattern=FillPattern.Solid,
            textStyle={TextStyle.Bold},
            textString="WindowAll_TIn")},
defaultComponentName="win",
Documentation(info="<html>
<p>
Model predicting the state of the window with the indoor air temperature 
and occupancy through Markov approach.
</p>
<h4>Inputs</h4>
<p>
indoor temperature: should be input with the unit of K.
</p>
<p>
occupancy: a boolean variable, true indicates the space is occupied, 
false indicates the space is unoccupied.
</p>
<h4>Outputs</h4>
<p>The state of window: a boolean variable, true indicates the window 
is open, false indicates the window is closed.
</p>
<h4>Dynamics</h4>
<p>
When the space is unoccupied, the window is always closed. When the 
space is occupied, the Probability of closing or opening the window 
depends on the indoor air temperature.
</p>
<h4>References</h4>
<p>
The model is documented in the paper &quot;Yun, G.Y. and Steemers, K., 
2008. Time-dependent occupant behaviour models of window control in 
summer. Building and Environment, 43(9), pp.1471-1482.&quot;.
</p>
<p>
The model parameters are regressed from the field study in offices without
night ventilation, located in Cambridge, UK in summer time (13 Jun. to 15 
Sep., 2006).
</p>
</html>",
revisions="<html>
<ul>
<li>
July 26, 2018, by Zhe Wang:<br/>
First implementation.
</li>
</ul>
</html>"),
    Icon(graphics={Text(
          extent={{-98,98},{94,-96}},
          lineColor={28,108,200},
          textString="ob.office
Window")}));
end Yun2008WindowsTIn;
