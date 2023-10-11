within Buildings.Fluid.HeatExchangers.AirToAirHeatRecovery;
model Wheel "Sensible and latent air-to-air heat recovery wheels"
  extends Buildings.Fluid.Interfaces.PartialFourPortInterface(
        redeclare replaceable package Medium1 =
        Modelica.Media.Interfaces.PartialCondensingGases,
        redeclare replaceable package Medium2 =
        Modelica.Media.Interfaces.PartialCondensingGases);
  extends Buildings.Fluid.Interfaces.FourPortFlowResistanceParameters(
        final computeFlowResistance1=true,
        final computeFlowResistance2=true,
        final from_dp1=false,
        final from_dp2=false);

  parameter
    Buildings.Fluid.HeatExchangers.AirToAirHeatRecovery.Types.RecoveryControl
    controlType=Buildings.Fluid.HeatExchangers.AirToAirHeatRecovery.Types.RecoveryControl.BypassAir
    "Type of controller";
  parameter Real P_nominal(unit="W") = 1000
    "Power at design condition";
  parameter Real k(final min=0) = 1
    "Gain of controller";
  parameter Modelica.Units.SI.Efficiency epsS_cool_nominal(final max=1) = 0.8
    "Nominal sensible heat exchanger effectiveness at the cooling mode";
  parameter Modelica.Units.SI.Efficiency epsL_cool_nominal(final max=1) = 0.8
    "Nominal latent heat exchanger effectiveness at the cooling mode";
  parameter Modelica.Units.SI.Efficiency epsS_cool_partload(final max=1) = 0.75
    "Partial load (75%) sensible heat exchanger effectiveness at the cooling mode";
  parameter Modelica.Units.SI.Efficiency epsL_cool_partload(final max=1) = 0.75
    "Partial load (75%) latent heat exchanger effectiveness at the cooling mode";
  parameter Modelica.Units.SI.Efficiency epsS_heat_nominal(final max=1) = 0.8
    "Nominal sensible heat exchanger effectiveness at the heating mode";
  parameter Modelica.Units.SI.Efficiency epsL_heat_nominal(final max=1) = 0.8
    "Nominal latent heat exchanger effectiveness at the heating mode";
  parameter Modelica.Units.SI.Efficiency epsS_heat_partload(final max=1) = 0.75
    "Partial load (75%) sensible heat exchanger effectiveness at the heating mode";
  parameter Modelica.Units.SI.Efficiency epsL_heat_partload(final max=1) = 0.75
    "Partial load (75%) latent heat exchanger effectiveness at the heating mode";

  Buildings.Fluid.HeatExchangers.AirToAirHeatRecovery.BaseClasses.HeatExchagerWithInputEffectiveness hex(
    redeclare package Medium1 = Medium1,
    redeclare package Medium2 = Medium2,
    final allowFlowReversal1=allowFlowReversal1,
    final allowFlowReversal2=allowFlowReversal2,
    final m1_flow_nominal=m1_flow_nominal,
    final m2_flow_nominal=m2_flow_nominal,
    final show_T = true,
    final dp1_nominal=0,
    final dp2_nominal=dp2_nominal)
    "Heat exchanger"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Buildings.Fluid.HeatExchangers.AirToAirHeatRecovery.BaseClasses.EffectivenessCalculation
    effCal(
    final epsS_cool_nominal=epsS_cool_nominal,
    final epsL_cool_nominal=epsL_cool_nominal,
    final epsS_cool_partload=epsS_cool_partload,
    final epsL_cool_partload=epsL_cool_partload,
    final epsS_heat_nominal=epsS_heat_nominal,
    final epsL_heat_nominal=epsL_heat_nominal,
    final epsS_heat_partload=epsS_heat_partload,
    final epsL_heat_partload=epsL_heat_partload,
    final v_flow_sup_nominal=m1_flow_nominal/1.293)
    "Calculates the effectiveness of heat exhcnages"
    annotation (Placement(transformation(extent={{40,20},{20,40}})));
  Modelica.Blocks.Interfaces.RealInput yWheSpe(unit="1") if not with_BypDam
    "Wheel speed ratio"
    annotation (Placement(transformation(extent={{-140,20},{-100,60}})));
  Modelica.Blocks.Interfaces.RealInput yBypDam(unit="1") if with_BypDam
    "Bypass damper position"
    annotation (Placement(transformation(extent={{-140,-40},{-100,0}})));
  Modelica.Blocks.Interfaces.RealOutput P
    "Electric power consumed by the wheel"
    annotation (Placement(transformation(extent={{100,-10},{120,10}})));
  Modelica.Fluid.Sensors.VolumeFlowRate v_flow_Exh(
    redeclare package Medium = Medium2,
    final allowFlowReversal=allowFlowReversal2)
    "Bypass damper position"
    annotation (Placement(transformation(extent={{34,-14},{20,2}})));
  Modelica.Fluid.Sensors.VolumeFlowRate v_flow_Sup(
    redeclare package Medium = Medium1,
    final allowFlowReversal=allowFlowReversal1)
    "Bypass damper position"
    annotation (Placement(transformation(extent={{-56,-2},{-42,14}})));
  Buildings.Fluid.Actuators.Dampers.Exponential bypDamSup(
    redeclare package Medium = Medium1,
    final allowFlowReversal=allowFlowReversal1,
    final m_flow_nominal=m1_flow_nominal,
    final dpDamper_nominal=dp1_nominal)
    "Bypass damper in the supply air stream"
    annotation (Placement(transformation(extent={{-10,50},{10,70}})));
  Buildings.Fluid.Actuators.Dampers.Exponential damSup(
    redeclare package Medium = Medium1,
    final allowFlowReversal=allowFlowReversal1,
    final m_flow_nominal=m1_flow_nominal,
    final dpDamper_nominal=dp1_nominal)
    "Damper in the supply air stream"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-70,22})));
  Buildings.Fluid.Actuators.Dampers.Exponential damExh(
    redeclare package Medium = Medium2,
    final allowFlowReversal=allowFlowReversal2,
    final m_flow_nominal=m2_flow_nominal,
    final dpDamper_nominal=dp2_nominal)
    "Damper in the exhaust air stream"
    annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=-90,
        origin={66,-38})));
  Buildings.Fluid.Actuators.Dampers.Exponential bypDamExh(
    redeclare package Medium = Medium2,
    final allowFlowReversal=allowFlowReversal2,
    final m_flow_nominal=m2_flow_nominal,
    final dpDamper_nominal=dp2_nominal)
    "Bypass damper in the exhaust air stream"
    annotation (Placement(transformation(extent={{10,-70},{-10,-50}})));
  Modelica.Blocks.Sources.RealExpression TSup(final y=Medium1.temperature(
      Medium1.setState_phX(
        p=port_a1.p,
        h=inStream(port_a1.h_outflow),
        X=inStream(port_a1.Xi_outflow))))
    "Temperature of the supply air"
    annotation (Placement(transformation(extent={{92,30},{72,50}})));
  Modelica.Blocks.Sources.RealExpression TExh(final y=Medium2.temperature(
      Medium2.setState_phX(
        p=port_a2.p,
        h=inStream(port_a2.h_outflow),
        X=inStream(port_a2.Xi_outflow))))
    "Temperature of the exhaust air"
    annotation (Placement(transformation(extent={{92,10},{72,30}})));
  Modelica.Blocks.Sources.Constant zer(final k=0)
    "Zero signal"
    annotation (Placement(transformation(extent={{-78,84},{-64,98}})));
  Modelica.Blocks.Sources.Constant uni(final k=1)
    "Unity signal"
    annotation (Placement(transformation(extent={{-76,-88},{-62,-74}})));
  Modelica.Blocks.Sources.RealExpression PEle(y=P_nominal*effCal.y)
    "Electrical power consumption"
    annotation (Placement(transformation(extent={{70,-10},{90,10}})));
  Modelica.Blocks.Math.Add add(k2=-1)
    "Adder"
    annotation (Placement(transformation(extent={{-64,-46},{-48,-30}})));
protected
  parameter Boolean with_BypDam = controlType ==Buildings.Fluid.HeatExchangers.AirToAirHeatRecovery.Types.RecoveryControl.BypassAir
    "Boolean flag to enable the bypass control"
    annotation(Evaluate=true, HideResult=true);

equation
  connect(effCal.epsS, hex.epsS) annotation (Line(points={{19,34},{-22,34},{-22,
          4},{-12,4}}, color={0,0,127}));
  connect(effCal.epsL, hex.epsL) annotation (Line(points={{19,26},{-18,26},{-18,
          -4},{-12,-4}}, color={0,0,127}));
  if with_BypDam then
    connect(bypDamExh.y, yBypDam)
      annotation (Line(points={{0,-48},{0,-20},{-120,-20}}, color={0,0,127}));
    connect(bypDamSup.y, yBypDam) annotation (Line(points={{0,72},{0,80},{-80,80},
            {-80,-20},{-120,-20}}, color={0,0,127}));
    connect(uni.y, effCal.y) annotation (Line(points={{-61.3,-81},{56,-81},{56,38},
            {42,38}}, color={0,0,127}));
    connect(add.u2, yBypDam) annotation (Line(points={{-65.6,-42.8},{-92,-42.8},{-92,
          -20},{-120,-20}}, color={0,0,127}));
  else
    connect(effCal.y, yWheSpe) annotation (Line(points={{42,38},{56,38},{56,52},
            {-72,52},{-72,40},{-120,40}}, color={0,0,127}));
    connect(bypDamExh.y, zer.y) annotation (Line(points={{0,-48},{0,-32},{-34,-32},
            {-34,91},{-63.3,91}}, color={0,0,127}));
    connect(add.u2, zer.y) annotation (Line(points={{-65.6,-42.8},{-80,-42.8},{-80,
          -24},{-34,-24},{-34,91},{-63.3,91}}, color={0,0,127}));
    connect(zer.y, bypDamSup.y)
    annotation (Line(points={{-63.3,91},{0,91},{0,72}}, color={0,0,127}));
  end if;
  connect(TSup.y, effCal.TSup) annotation (Line(points={{71,40},{66,40},{66,34},
          {42,34}}, color={0,0,127}));
  connect(TExh.y, effCal.TExh) annotation (Line(points={{71,20},{66,20},{66,30},
          {42,30}}, color={0,0,127}));
  connect(v_flow_Exh.port_b, hex.port_a2)
    annotation (Line(points={{20,-6},{10,-6}}, color={0,127,255}));
  connect(v_flow_Exh.V_flow, effCal.v_flow_Exh) annotation (Line(points={{27,2.8},
          {27,10},{46,10},{46,22},{42,22}},      color={0,0,127}));
  connect(hex.port_a1, v_flow_Sup.port_b)
    annotation (Line(points={{-10,6},{-42,6}}, color={0,127,255}));
  connect(v_flow_Sup.V_flow, effCal.v_flow_Sup) annotation (Line(points={{-49,
          14.8},{-49,18},{50,18},{50,26},{42,26}}, color={0,0,127}));
  connect(bypDamSup.port_a, port_a1)
    annotation (Line(points={{-10,60},{-100,60}}, color={0,127,255}));
  connect(bypDamSup.port_b, port_b1)
    annotation (Line(points={{10,60},{100,60}}, color={0,127,255}));
  connect(bypDamExh.port_a, port_a2)
    annotation (Line(points={{10,-60},{100,-60}}, color={0,127,255}));
  connect(bypDamExh.port_b, port_b2)
    annotation (Line(points={{-10,-60},{-100,-60}}, color={0,127,255}));
  connect(hex.port_b1, port_b1) annotation (Line(points={{10,6},{62,6},{62,60},{
          100,60}}, color={0,127,255}));
  connect(hex.port_b2, port_b2) annotation (Line(points={{-10,-6},{-28,-6},{-28,
          -60},{-100,-60}}, color={0,127,255}));
  connect(PEle.y, P)
  annotation (Line(points={{91,0},{110,0}}, color={0,0,127}));
  connect(v_flow_Sup.port_a, damSup.port_b)
    annotation (Line(points={{-56,6},{-70,6},{-70,12}}, color={0,127,255}));
  connect(damSup.port_a, port_a1)
    annotation (Line(points={{-70,32},{-70,60},{-100,60}}, color={0,127,255}));
  connect(v_flow_Exh.port_a, damExh.port_b)
    annotation (Line(points={{34,-6},{66,-6},{66,-28}}, color={0,127,255}));
  connect(damExh.port_a, port_a2)
    annotation (Line(points={{66,-48},{66,-60},{100,-60}}, color={0,127,255}));
  connect(add.u1, uni.y) annotation (Line(points={{-65.6,-33.2},{-72,-33.2},{-72,
          -68},{-48,-68},{-48,-81},{-61.3,-81}}, color={0,0,127}));
  connect(add.y, damExh.y)
    annotation (Line(points={{-47.2,-38},{54,-38}}, color={0,0,127}));
  connect(damSup.y, add.y) annotation (Line(points={{-58,22},{-38,22},{-38,-38},
          {-47.2,-38}}, color={0,0,127}));
  annotation (
        defaultComponentName="whe",
        Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Rectangle(
          extent={{-92,-55},{-40,-64}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-94,65},{-40,56}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Line(points={{-30,110},{36,110}}, color={28,108,200}),
        Ellipse(extent={{0,100},{36,-100}}, lineColor={28,108,200}),
        Polygon(
          points={{0,100},{0,100}},
          lineColor={28,108,200},
          fillColor={255,255,255},
          fillPattern=FillPattern.None),
        Rectangle(
          extent={{-4,100},{20,-100}},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Ellipse(
          extent={{-44,100},{-8,-100}},
          lineColor={28,108,200},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Line(points={{-24,-100},{20,-100}}, color={28,108,200}),
        Line(points={{-26,100},{18,100}}, color={28,108,200}),
        Rectangle(
          extent={{32,64},{94,56}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{32,-56},{94,-64}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid)}), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    Documentation(info="<html>
Model for a generic, sensible and latent air-to-air heat recovery wheel, that consists of 
a heat exchanger and primary/secondary airflow bypass dampers.

The input requires no geometric data. Performance is defined by specifying sensible and/or latent effectiveness 
at 75% and 100% of the nominal supply air flow rate in both heating and cooling conditions
For details, refer to
<a href=\"modelica://Buildings.Fluid.HeatExchangers.AirToAirHeatRecovery.BaseClasses.EffectivenessCalculation\">
Buildings.Fluid.HeatExchangers.AirToAirHeatRecovery.BaseClasses.EffectivenessCalculation</a>.

The operation of the heat recovery wheel is adjustable through wheel speed modulation or bypassing supply air 
around the heat exchanger.
The parameter, <i>controlType</i>, can be used to specify either wheel speed modulation or bypassing supply air
is used.
See more in  
<a href=\"modelica://Buildings.Fluid.HeatExchangers.AirToAirHeatRecovery.Types.RecoveryControl\">
Buildings.Fluid.HeatExchangers.AirToAirHeatRecovery.Types.RecoveryControlType</a>.

</html>", revisions="<html>
<ul>
<li>
September 29, 2023, by Sen Huang:<br/>
First implementation<br/>
</li>
</ul>
</html>"));
end Wheel;
