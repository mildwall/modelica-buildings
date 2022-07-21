within Buildings.Fluid.Storage.Plant;
model TankBranch
  "Model of the tank branch of a storage plant"
  extends Buildings.Fluid.Storage.Plant.BaseClasses.PartialBranchPorts;

  parameter Boolean tankIsOpen = nom.plaTyp ==
    Buildings.Fluid.Storage.Plant.BaseClasses.Types.Setup.Open "Tank is open";

  Buildings.Fluid.FixedResistances.PressureDrop preDroTanBot(
    redeclare final package Medium = Medium,
    final allowFlowReversal=true,
    final m_flow_nominal=nom.mTan_flow_nominal)
    "Flow resistance on tank branch near tank bottom" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={30,0})));
  Modelica.Blocks.Interfaces.RealOutput mTanBot_flow
    "Mass flow rate measured at the bottom of the tank" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={70,110}), iconTransformation(
        extent={{10,-10},{-10,10}},
        rotation=270,
        origin={80,110})));
  Buildings.Fluid.Storage.Stratified tan(
    redeclare final package Medium = Medium,
    final allowFlowReversal=true,
    hTan=3,
    dIns=0.3,
    VTan=10,
    nSeg=7,
    show_T=true,
    m_flow_nominal=nom.mTan_flow_nominal,
    T_start=nom.T_CHWS_nominal,
    TFlu_start=linspace(
        nom.T_CHWR_nominal,
        nom.T_CHWS_nominal,
        tan.nSeg)) "Tank"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Modelica.Fluid.Sensors.MassFlowRate senFloBot(
    redeclare final package Medium = Medium,
    final allowFlowReversal=true) "Flow rate sensor at tank bottom"
    annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=90,
        origin={50,30})));
  Buildings.Fluid.Sources.Boundary_pT atm(
    redeclare final package Medium = Medium,
    final p(displayUnit="Pa") = 101325,
    final T=nom.T_CHWS_nominal,
    final nPorts=1) if tankIsOpen
                    "Atmosphere pressure" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-10,30})));
  Buildings.Fluid.FixedResistances.PressureDrop preDroTanTop(
    redeclare final package Medium = Medium,
    final allowFlowReversal=true,
    final m_flow_nominal=nom.mTan_flow_nominal)
    "Flow resistance on tank branch near tank top" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-30,0})));
  Modelica.Fluid.Sensors.MassFlowRate senFloTop(
    redeclare final package Medium = Medium,
    final allowFlowReversal=true) "Flow rate sensor at tank top"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-50,-30})));
  Modelica.Blocks.Interfaces.RealOutput mTanTop_flow if tankIsOpen
    "Mass flow rate measured at the top of the tank" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={50,110}), iconTransformation(
        extent={{10,-10},{-10,10}},
        rotation=270,
        origin={40,110})));
  Modelica.Blocks.Interfaces.RealOutput Ql_flow
    "Heat loss of tank (positive if heat flows from tank to ambient)"
    annotation (Placement(transformation(extent={{100,-2},{120,18}}),
        iconTransformation(extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={80,-110})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heaPorTop
    "Heat port tank top (outside insulation)"
    annotation (Placement(transformation(extent={{14,22},{26,34}}),
        iconTransformation(extent={{14,34},{26,46}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heaPorSid
    "Heat port tank side (outside insulation)"
    annotation (Placement(transformation(extent={{34,-36},{46,-24}}),
        iconTransformation(extent={{26,-6},{38,6}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heaPorBot
    "Heat port tank bottom (outside insulation). Leave unconnected for adiabatic condition"
    annotation (Placement(transformation(extent={{14,-56},{26,-44}}),
        iconTransformation(extent={{14,-46},{26,-34}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a[tan.nSeg] heaPorVol
    "Heat port that connects to the control volumes of the tank"
    annotation (Placement(transformation(extent={{-26,-36},{-14,-24}}),
        iconTransformation(extent={{-6,-6},{6,6}})));
equation
  connect(senFloBot.m_flow, mTanBot_flow)
    annotation (Line(points={{61,30},{70,30},{70,110}}, color={0,0,127}));
  connect(port_aFroChi, port_bToNet)
    annotation (Line(points={{-100,60},{100,60}}, color={0,127,255}));
  connect(port_bToChi, port_aFroNet)
    annotation (Line(points={{-100,-60},{100,-60}}, color={0,127,255}));
  connect(atm.ports[1], tan.port_a)
    annotation (Line(points={{-10,20},{-10,10},{-10,10},{-10,0}},
                                                color={0,127,255}));
  connect(preDroTanBot.port_b, senFloBot.port_a)
    annotation (Line(points={{40,0},{50,0},{50,20}}, color={0,127,255}));
  connect(tan.port_b, preDroTanBot.port_a)
    annotation (Line(points={{10,0},{20,0}}, color={0,127,255}));
  connect(preDroTanTop.port_b, tan.port_a)
    annotation (Line(points={{-20,0},{-10,0}}, color={0,127,255}));
  connect(senFloBot.port_b, port_bToNet)
    annotation (Line(points={{50,40},{50,60},{100,60}}, color={0,127,255}));
  connect(preDroTanTop.port_a, senFloTop.port_b)
    annotation (Line(points={{-40,0},{-50,0},{-50,-20}}, color={0,127,255}));
  connect(senFloTop.port_a, port_bToChi) annotation (Line(points={{-50,-40},{-50,
          -60},{-100,-60}}, color={0,127,255}));
  connect(senFloTop.m_flow, mTanTop_flow) annotation (Line(points={{-61,-30},{
          -66,-30},{-66,70},{50,70},{50,110}}, color={0,0,127}));
  connect(tan.Ql_flow, Ql_flow)
    annotation (Line(points={{11,7.2},{11,8},{110,8}}, color={0,0,127}));
  connect(tan.heaPorTop, heaPorTop) annotation (Line(points={{2,7.4},{2,16},{20,
          16},{20,28}}, color={191,0,0}));
  connect(tan.heaPorSid, heaPorSid) annotation (Line(points={{5.6,0},{6,0},{6,
          -30},{40,-30}},   color={191,0,0}));
  connect(tan.heaPorBot, heaPorBot)
    annotation (Line(points={{2,-7.4},{2,-50},{20,-50}}, color={191,0,0}));
  connect(heaPorVol, tan.heaPorVol) annotation (Line(points={{-20,-30},{-8,-30},
          {-8,-4},{0,-4},{0,0}}, color={191,0,0}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
            {100,100}}),       graphics={
        Line(points={{-100,-60},{100,-60}}, color={28,108,200}),
        Line(points={{-100,60},{100,60}}, color={28,108,200}),
        Line(
          points={{40,100},{40,50},{0,50}},
          color={0,0,0},
          pattern=LinePattern.Dash,
          visible=tankIsOpen),
        Line(
          points={{80,100},{80,50},{60,50}},
          color={0,0,0},
          pattern=LinePattern.Dash),
        Line(points={{-42,-60}}, color={28,108,200}),
        Line(points={{-60,-58},{-60,50},{0,50},{0,-52},{60,-52},{60,60}}, color=
             {28,108,200}),
        Rectangle(
          extent={{-28,40},{32,-40}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-50,36},{50,26}},
          lineColor={255,255,255},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          visible=tankIsOpen),
        Line(
          points={{38,0},{80,0},{80,-100}},
          color={127,0,0},
          pattern=LinePattern.Dot),
        Line(
          points={{26,-44},{52,-44},{52,0}},
          color={127,0,0},
          pattern=LinePattern.Dot),
        Line(
          points={{26,44},{52,44},{52,-2}},
          color={127,0,0},
          pattern=LinePattern.Dot)}),                            Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}})),
    defaultComponentName = "tanBra",
    Documentation(info="<html>
<p>
This model is part of a storage plant model. This branch has a stratified tank.
This tank can potentially be charged remotely by a chiller from its district
CHW network other than its own local chiller. To model an open storage tank, set
<code>nom.plaTyp = Buildings.Fluid.Storage.Plant.BaseClasses.Types.Setup.Open</code>.
This enables a volume at atmospheric pressure to be connected to the top of
the tank. Otherwise, the tank is closed and pressurised by other means.
</p>
<p>
Because an open tank exposes the hydraulic loop to the atmospheric pressure,
the mass flow rate of the water through the top port and bottom port of the tank
is not automatically conserved. Flow rate sensors are therefore put on both the top
and bottom sides of the tank to allow the pumps and valves implemented in
<a href=\"Modelica://Buildings.Fluid.Storage.Plant.NetworkConnection\">
Buildings.Fluid.Storage.Plant.NetworkConnection</a>
to balance the flow in order to ensure that that the open tank is not flooded
or drained.
</p>
</html>", revisions="<html>
<ul>
<li>
February 18, 2022 by Hongxiang Fu:<br/>
First implementation. This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2859\">#2859</a>.
</li>
</ul>
</html>"));
end TankBranch;
