within Buildings.Electrical.AC.ThreePhasesBalanced.MotorDrive.Coupled;
model Chiller "Motor coupled chiller"

    extends Buildings.Fluid.Interfaces.PartialFourPortInterface(
    m1_flow_nominal = QCon_flow_nominal/cp1_default/dTCon_nominal,
    m2_flow_nominal = QEva_flow_nominal/cp2_default/dTEva_nominal);

 extends Buildings.Electrical.Interfaces.PartialOnePort(
    redeclare package PhaseSystem =
        Buildings.Electrical.PhaseSystems.OnePhase,
    redeclare replaceable Interfaces.Terminal_n terminal);

 parameter Modelica.Units.SI.HeatFlowRate QEva_flow_nominal(max=0)= -P_nominal * COP_nominal
    "Nominal cooling heat flow rate (QEva_flow_nominal < 0)"
    annotation (Dialog(group="Nominal condition"));

 parameter Modelica.Units.SI.HeatFlowRate QCon_flow_nominal(min=0)= P_nominal - QEva_flow_nominal
    "Nominal heating flow rate"
    annotation (Dialog(group="Nominal condition"));

  parameter Modelica.Units.SI.TemperatureDifference dTEva_nominal(
    final max=0) = -10 "Temperature difference evaporator outlet-inlet"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.TemperatureDifference dTCon_nominal(
    final min=0) = 10 "Temperature difference condenser outlet-inlet"
    annotation (Dialog(group="Nominal condition"));

  parameter Modelica.Units.SI.Power P_nominal(min=0)
    "Nominal compressor power (at y=1)"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.NonSI.AngularVelocity_rpm Nrpm_nominal=1500
    "Nominal rotational speed for flow characteristic"
    annotation (Dialog(group="Nominal condition"));
 // Efficiency
  parameter Boolean use_eta_Carnot_nominal = true
    "Set to true to use Carnot effectiveness etaCarnot_nominal rather than COP_nominal"
    annotation(Dialog(group="Efficiency"));
  parameter Real etaCarnot_nominal(unit="1") = COP_nominal/
    (TUseAct_nominal/(TCon_nominal+TAppCon_nominal - (TEva_nominal-TAppEva_nominal)))
    "Carnot effectiveness (=COP/COP_Carnot) used if use_eta_Carnot_nominal = true"
    annotation (Dialog(group="Efficiency", enable=use_eta_Carnot_nominal));

  parameter Real COP_nominal(unit="1") = etaCarnot_nominal*TUseAct_nominal/
    (TCon_nominal+TAppCon_nominal - (TEva_nominal-TAppEva_nominal))
    "Coefficient of performance at TEva_nominal and TCon_nominal, used if use_eta_Carnot_nominal = false"
    annotation (Dialog(group="Efficiency", enable=not use_eta_Carnot_nominal));

  parameter Modelica.Units.SI.Temperature TCon_nominal = 303.15
    "Condenser temperature used to compute COP_nominal if use_eta_Carnot_nominal=false"
    annotation (Dialog(group="Efficiency", enable=not use_eta_Carnot_nominal));
  parameter Modelica.Units.SI.Temperature TEva_nominal = 278.15
    "Evaporator temperature used to compute COP_nominal if use_eta_Carnot_nominal=false"
    annotation (Dialog(group="Efficiency", enable=not use_eta_Carnot_nominal));

  parameter Real a[:] = {1}
    "Coefficients for efficiency curve (need p(a=a, yPL=1)=1)"
    annotation (Dialog(group="Efficiency"));

  parameter Modelica.Units.SI.Pressure dp1_nominal(displayUnit="Pa")
    "Pressure difference over condenser"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.Pressure dp2_nominal(displayUnit="Pa")
    "Pressure difference over evaporator"
    annotation (Dialog(group="Nominal condition"));

  parameter Modelica.Units.SI.TemperatureDifference TAppCon_nominal(min=0) = if cp1_default < 1500 then 5 else 2
    "Temperature difference between refrigerant and working fluid outlet in condenser"
    annotation (Dialog(group="Efficiency"));

  parameter Modelica.Units.SI.TemperatureDifference TAppEva_nominal(min=0) = if cp2_default < 1500 then 5 else 2
    "Temperature difference between refrigerant and working fluid outlet in evaporator"
    annotation (Dialog(group="Efficiency"));

  parameter Modelica.Units.SI.Frequency f_base=50 "Frequency of the source";
  parameter Integer pole=2 "Number of pole pairs";
  parameter Integer n=3 "Number of phases";
  parameter Modelica.Units.SI.Inertia JMotor=10 "Moment of inertia";
  parameter Modelica.Units.SI.Resistance R_s=24.5
    "Electric resistance of stator";
  parameter Modelica.Units.SI.Resistance R_r=23 "Electric resistance of rotor";
  parameter Modelica.Units.SI.Reactance X_s=10
    "Complex component of the impedance of stator";
  parameter Modelica.Units.SI.Reactance X_r=40
    "Complex component of the impedance of rotor";
  parameter Modelica.Units.SI.Reactance X_m=25
    "Complex component of the magnetizing reactance";
  parameter Modelica.Units.SI.Inertia JLoad=2 "Moment of inertia";

  ThermoFluid.Chiller mecChi(
    redeclare package Medium1 = Medium1,
    redeclare package Medium2 = Medium2,
    m1_flow_nominal=m1_flow_nominal,
    m2_flow_nominal=m2_flow_nominal,
    dTEva_nominal=dTEva_nominal,
    dTCon_nominal=dTCon_nominal,
    use_eta_Carnot_nominal=use_eta_Carnot_nominal,
    etaCarnot_nominal=etaCarnot_nominal,
    COP_nominal=COP_nominal,
    TCon_nominal=TCon_nominal,
    TEva_nominal=TEva_nominal,
    a=a,
    dp1_nominal=dp1_nominal,
    dp2_nominal=dp2_nominal,
    TAppCon_nominal=TAppCon_nominal,
    TAppEva_nominal=TAppEva_nominal,
    P_nominal=P_nominal,
    QEva_flow_nominal=QEva_flow_nominal,
    QCon_flow_nominal=QCon_flow_nominal,
    Nrpm_nominal=Nrpm_nominal)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));

  Modelica.Blocks.Sources.RealExpression loaTor(y=mecChi.shaft.tau)
    annotation (Placement(transformation(extent={{0,40},{-20,60}})));

  Modelica.Blocks.Interfaces.RealOutput P(quantity="Power", unit="W")
    "Real power"
    annotation (Placement(transformation(extent={{100,20},{120,40}}),  iconTransformation(extent={{100,20},
            {120,40}})));
  Modelica.Blocks.Interfaces.RealOutput Q "Reactive power"
    annotation (Placement(transformation(extent={{100,-40},{120,-20}}),
                                                                      iconTransformation(extent={{100,-40},
            {120,-20}})));
  Modelica.Blocks.Interfaces.RealInput setPoi annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-110,90}), iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-110,90})));
  Modelica.Blocks.Interfaces.RealInput meaPoi annotation (Placement(transformation(extent={{-120,20},{-100,40}}),
        iconTransformation(extent={{-120,20},{-100,40}})));
  InductionMotors.SquirrelCageDrive simMot
    annotation (Placement(transformation(extent={{-40,70},{-20,90}})));
protected
  constant Boolean COP_is_for_cooling = true
    "Set to true if the specified COP is for cooling";
  final parameter Modelica.Units.SI.Temperature TUseAct_nominal=
    if COP_is_for_cooling
      then TEva_nominal - TAppEva_nominal
      else TCon_nominal + TAppCon_nominal
    "Nominal evaporator temperature for chiller or condenser temperature for heat pump, taking into account pinch temperature between fluid and refrigerant";

    final parameter Modelica.Units.SI.SpecificHeatCapacity cp1_default=
    Medium1.specificHeatCapacityCp(Medium1.setState_pTX(
      p = Medium1.p_default,
      T = Medium1.T_default,
      X = Medium1.X_default))
    "Specific heat capacity of medium 1 at default medium state";

  final parameter Modelica.Units.SI.SpecificHeatCapacity cp2_default=
    Medium2.specificHeatCapacityCp(Medium2.setState_pTX(
      p = Medium2.p_default,
      T = Medium2.T_default,
      X = Medium2.X_default))
    "Specific heat capacity of medium 2 at default medium state";

equation
  connect(port_a1, mecChi.port_a1) annotation (Line(points={{-100,60},{-60,60},{
          -60,6},{-10,6}}, color={0,127,255}));
  connect(port_b2, mecChi.port_b2) annotation (Line(points={{-100,-60},{-60,-60},
          {-60,-6},{-10,-6}}, color={0,127,255}));
  connect(mecChi.port_b1, port_b1) annotation (Line(points={{10,6},{60,6},{60,60},
          {100,60}}, color={0,127,255}));
  connect(mecChi.port_a2, port_a2) annotation (Line(points={{10,-6},{60,-6},{60,
          -60},{100,-60}}, color={0,127,255}));
  connect(simMot.shaft, mecChi.shaft) annotation (Line(points={{-20,80},{40,80},
          {40,30},{0,30},{0,10}}, color={0,0,0}));
  connect(setPoi, simMot.setPoi) annotation (Line(points={{-110,90},{-80,90},{-80,
          88},{-42,88}},     color={0,0,127}));
  connect(meaPoi, simMot.mea) annotation (Line(points={{-110,30},{-80,30},{-80,84},
          {-42,84}},     color={0,0,127}));
  connect(loaTor.y, simMot.tau_m) annotation (Line(points={{-21,50},{-70,50},{-70,
          72},{-42,72}}, color={0,0,127}));
  connect(simMot.P, P) annotation (Line(points={{-18,88},{80,88},{80,30},{110,
          30}}, color={0,0,127}));
  connect(simMot.Q, Q) annotation (Line(points={{-18,84},{80,84},{80,-30},{110,
          -30}}, color={0,0,127}));
  connect(simMot.terminal, terminal) annotation (Line(points={{-30,90},{-30,100},
          {0,100}},          color={0,120,120}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false,extent={{-100,-100},
            {100,100}}),       graphics={
        Rectangle(
          extent={{-70,80},{70,-80}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-56,68},{58,50}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-56,-52},{58,-70}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-103,64},{98,54}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-2,54},{98,64}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-101,-56},{100,-66}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-100,-66},{0,-56}},
          lineColor={0,0,127},
          pattern=LinePattern.None,
          fillColor={0,0,127},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-42,0},{-52,-12},{-32,-12},{-42,0}},
          lineColor={0,0,0},
          smooth=Smooth.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-42,0},{-52,10},{-32,10},{-42,0}},
          lineColor={0,0,0},
          smooth=Smooth.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-44,50},{-40,10}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-44,-12},{-40,-52}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{38,50},{42,-52}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{18,22},{62,-20}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{40,22},{22,-10},{58,-10},{40,22}},
          lineColor={0,0,0},
          smooth=Smooth.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(points={{62,0},{80,0}},                  color={0,0,255}),
        Line(points={{80,30},{100,30}},               color={0,0,255}),
        Line(points={{80,0},{80,30}},                 color={0,0,255}),
        Line(points={{80,-30},{100,-30}},             color={0,0,255}),
        Line(points={{80,-30},{80,0}},                color={0,0,255})}),
        defaultComponentName="chi",
    Documentation(info="<html>
<p>This is a model of a squirrel cage induction motor coupled chiller with ideal speed control.</p>
</html>",
      revisions="<html>
<ul>
<li>October 15, 2021,
    by Mingzhe Liu:<br/>
    First implementation.</li>
</ul>
</html>"));
end Chiller;
