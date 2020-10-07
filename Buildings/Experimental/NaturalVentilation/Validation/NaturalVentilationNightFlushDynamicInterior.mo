within Buildings.Experimental.NaturalVentilation.Validation;
model NaturalVentilationNightFlushDynamicInterior "Validation model for night flush with dynamic duration for an interior zone"
  replaceable package MediumA =
      Buildings.Media.Air;
  Fluid.Sensors.TemperatureTwoPort temRoo(
    redeclare package Medium = MediumA,
    m_flow_nominal=0.001,
    transferHeat=false) "HeatingTemperature" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={372,-80})));
  Modelica.Blocks.Sources.CombiTimeTable airCon1(
    table=[0,0.001,293.15; 28800,0.05,293.15; 64800,0.001,293.15; 86400,
        0.001,293.15],
    tableOnFile=false,
    tableName="airCon",
    fileName=Modelica.Utilities.Files.loadResource(
        "modelica://Buildings/Resources/Data/ThermalZones/Detailed/FLEXLAB/Rooms/Examples/X3AWithRadiantFloor.txt"),
    columns=2:3,
    smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    timeScale=1) "Inlet air conditions (y[1] = m_flow, y[4] = T)"
    annotation (Placement(transformation(extent={{256,-54},{276,-34}})));

  Fluid.Sources.MassFlowSource_T           airIn1(
    use_m_flow_in=true,
    use_T_in=true,
    redeclare package Medium = MediumA,
    nPorts=1) "Inlet air conditions (from AHU) for X3A"
    annotation (Placement(transformation(extent={{314,-36},{334,-16}})));
  Modelica.Blocks.Sources.CombiTimeTable intGai1(
    table=[0,1.05729426,1.25089426,0; 3600,1.05729426,1.25089426,0; 7200,
        1.05729426,1.25089426,0; 10800,1.05729426,1.25089426,0; 14400,
        1.05729426,1.25089426,0; 18000,1.05729426,1.25089426,0; 21600,
        1.121827593,1.509027593,0; 25200,1.548281766,1.882174238,
        0.330986667; 28800,1.977743414,2.979420831,0.661973333; 32400,
        5.734675369,8.73970762,3.144373333; 36000,5.734675369,8.73970762,
        3.144373333; 39600,5.734675369,8.73970762,3.144373333; 43200,
        5.734675369,8.73970762,3.144373333; 46800,4.496245967,7.501278218,
        1.654933333; 50400,5.734675369,8.73970762,3.144373333; 54000,
        5.734675369,8.73970762,3.144373333; 57600,5.734675369,8.73970762,
        3.144373333; 61200,5.734675369,8.73970762,3.144373333; 64800,
        2.714734464,4.384196826,0.99296; 68400,1.770876747,2.772554164,
        0.330986667; 72000,1.770876747,2.772554164,0.330986667; 75600,
        1.659579257,2.327364201,0.330986667; 79200,1.659579257,2.327364201,
        0.330986667; 82800,1.444848433,1.778740905,0.165493333; 86400,
        1.389199687,1.556145923,0.165493333],
    tableOnFile=false,
    columns=2:4,
    smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    timeScale=1,
    startTime=0)
    "Internal gain heat flow (Radiant = 1, Convective = 2, Latent = 3)"
    annotation (Placement(transformation(extent={{332,148},{352,168}})));
  Modelica.Thermal.HeatTransfer.Components.ThermalConductor conBel3(G=0.2)
    "Combined convection and radiation resistance below the slab"
    annotation (Placement(transformation(extent={{454,-46},{474,-26}})));
  Airflow.Multizone.DoorDiscretizedOperable doo(
    show_T=true,
    wOpe=2,
    hOpe=2,
    hA=1,
    hB=1,
    dp_turbulent=1000,
    LClo=0.01,
    redeclare package Medium = MediumA,
    CDOpe=0.7,
    mOpe=0.75)                          "Window"
    annotation (Placement(transformation(extent={{198,100},{218,120}})));
  BoundaryConditions.WeatherData.ReaderTMY3 weaDat1(filNam=
        Modelica.Utilities.Files.loadResource("modelica://Buildings/Resources/weatherdata/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.mos"))
    "Weather data reader"
    annotation (Placement(transformation(extent={{24,140},{44,160}})));
  Fluid.Sources.Boundary_pT
    airOut2(redeclare package Medium = MediumA,
    use_T_in=true,                              nPorts=1)
                                                     "Air outlet for X3A"
    annotation (Placement(transformation(extent={{288,-90},{308,-70}})));
  Modelica.Thermal.HeatTransfer.Components.ThermalConductor conBel1(G=0.2)
    "Combined convection and radiation resistance below the slab"
    annotation (Placement(transformation(extent={{416,-84},{436,-64}})));
  Controls.OBC.CDL.Continuous.Sources.Constant TIntSet(k=290)
    "Constant interior room air temperature setpoint"
    annotation (Placement(transformation(extent={{-100,-22},{-56,22}})));
  BoundaryConditions.WeatherData.Bus weaBus2 annotation (Placement(
        transformation(extent={{-98,158},{-58,198}}), iconTransformation(extent=
           {{-168,106},{-148,126}})));
  Controls.OBC.CDL.Continuous.Sources.Constant TAirDum(k=280)
    "Constant outdoor air dry bulb temperature"
    annotation (Placement(transformation(extent={{-98,-86},{-54,-42}})));
  Modelica.Fluid.Sources.FixedBoundary boundary(
    T=281.15,                                             nPorts=2, redeclare
      package Medium =                                                                         MediumA)
    annotation (Placement(transformation(extent={{48,162},{68,182}})));
  ThermalZones.Detailed.FLEXLAB.Rooms.X3A.TestCellRadiantInterior radInt(
    nConExtWin=0,
    nConBou=5,
    surBou={Buildings.ThermalZones.Detailed.BaseClasses.OpaqueSurface(
          A=9*5,
          til=Buildings.Types.Tilt.Ceiling,
          boundaryCondition=Buildings.ThermalZones.Detailed.Types.CFDBoundaryConditions.Temperature)},
    lat=0.72954762733363,
    intConMod=Buildings.HeatTransfer.Types.InteriorConvection.Temperature,
    energyDynamics=Modelica.Fluid.Types.Dynamics.DynamicFreeInitial,
    massDynamics=Modelica.Fluid.Types.Dynamics.DynamicFreeInitial,
    T_start=298.15,
    nPorts=4,
    redeclare package Medium = MediumA)
    annotation (Placement(transformation(extent={{418,96},{458,136}})));

  parameter Real TWetBulDif=0.01
    "Allowable difference between outdoor air wet bulb temperature and room air temperature setpoint: OA WB +  this difference must be less than room air temperature setpoint";
  parameter Real TDryBulCut=273.15
    "Outdoor air temperature below which nat vent is not allowed";
  parameter Real winSpeLim=1000
    "Wind speed above which window must be closed";
  parameter Real locTimRai=1800
    "Time for which natural ventilation is locked out after rain is detected";
  HeatTransfer.Sources.FixedTemperature TFix(T=294.15)
    "Boundary temperature to represent interior conditioned space"
    annotation (Placement(transformation(extent={{510,52},{530,72}})));
  Controls.OBC.CDL.Continuous.Sources.Ramp ram(
    height=20,
    duration=86400,
    offset=250) "Varying wind speed"
    annotation (Placement(transformation(extent={{-34,-6},{-14,14}})));
  Controls.OBC.CDL.Logical.Sources.Pulse booPul(
    width=0.25,
    period=86400,
    startTime=32400) "Varying occupancy signal"
    annotation (Placement(transformation(extent={{-80,60},{-60,80}})));
  NaturalVentilationNightFlushDynamic natVenNitFluDyn(
    TDryBulCut=273.15,
    TWetBulDif=0.001,
    winSpeLim=1000,
    TNitFluCut=273.15)
    annotation (Placement(transformation(extent={{20,-2},{100,78}})));
  Controls.OBC.CDL.Logical.Sources.Constant con(k=false)
    "Constant manual override and rain signal"
    annotation (Placement(transformation(extent={{-80,100},{-60,120}})));
  Controls.OBC.CDL.Continuous.Sources.Ramp ram2(
    height=30,
    duration=864000,
    offset=290) "Outdoor air forecast high dry bulb temperature"
    annotation (Placement(transformation(extent={{-40,-100},{-20,-80}})));
equation
  connect(airCon1.y[1],airIn1. m_flow_in) annotation (Line(points={{277,-44},{300,
          -44},{300,-18},{312,-18}},   color={0,0,127}));
  connect(airCon1.y[2],airIn1. T_in) annotation (Line(points={{277,-44},{300,-44},
          {300,-22},{312,-22}},   color={0,0,127}));
  connect(temRoo.port_b, airOut2.ports[1]) annotation (Line(points={{372,-70},{
          340,-70},{340,-80},{308,-80}}, color={0,127,255}));
  connect(weaDat1.weaBus, weaBus2) annotation (Line(
      points={{44,150},{-8,150},{-8,178},{-78,178}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(boundary.ports[1], doo.port_a1) annotation (Line(points={{68,174},{133,
          174},{133,116},{198,116}}, color={0,127,255}));
  connect(doo.port_b2, boundary.ports[2]) annotation (Line(points={{198,104},{140,
          104},{140,108},{68,108},{68,170}}, color={0,127,255}));
  connect(conBel1.port_b, radInt.surf_surBou[1]) annotation (Line(points={{436,
          -74},{434,-74},{434,102},{434.2,102}}, color={191,0,0}));
  connect(radInt.ports[1], doo.port_a2) annotation (Line(points={{423,103},{320,
          103},{320,104},{218,104}}, color={0,127,255}));
  connect(doo.port_b1, radInt.ports[2]) annotation (Line(points={{218,116},{322,
          116},{322,105},{423,105}}, color={0,127,255}));
  connect(radInt.ports[3], temRoo.port_a) annotation (Line(points={{423,107},{
          398,107},{398,-90},{372,-90}}, color={0,127,255}));
  connect(airIn1.ports[1], radInt.ports[4]) annotation (Line(points={{334,-26},
          {380,-26},{380,109},{423,109}}, color={0,127,255}));
  connect(intGai1.y, radInt.qGai_flow) annotation (Line(points={{353,158},{386,
          158},{386,124},{416.4,124}}, color={0,0,127}));
  connect(conBel3.port_b, radInt.surf_conBou[1]) annotation (Line(points={{474,
          -36},{484,-36},{484,-34},{494,-34},{494,99.2},{444,99.2}}, color={191,
          0,0}));
  connect(temRoo.T, airOut2.T_in) annotation (Line(points={{361,-80},{322,-80},
          {322,-96},{286,-96},{286,-76}}, color={0,0,127}));
  connect(TFix.port, conBel3.port_a) annotation (Line(points={{530,62},{572,62},
          {572,-70},{512,-70},{512,-62},{454,-62},{454,-36}}, color={191,0,0}));
  connect(TFix.port, conBel1.port_b) annotation (Line(points={{530,62},{542,62},
          {542,-92},{436,-92},{436,-74}}, color={191,0,0}));
  connect(natVenNitFluDyn.yWinOpe, doo.y) annotation (Line(points={{108,49.2},{151,
          49.2},{151,110},{197,110}}, color={0,0,127}));
  connect(booPul.y, natVenNitFluDyn.uOcc) annotation (Line(points={{-58,70},{
          -52,70},{-52,58},{12,58}},
                                 color={255,0,255}));
  connect(TIntSet.y, natVenNitFluDyn.uRooSet) annotation (Line(points={{-51.6,0},
          {-40,0},{-40,38.8},{12,38.8}},  color={0,0,127}));
  connect(ram.y, natVenNitFluDyn.uWinSpe)
    annotation (Line(points={{-12,4},{0,4},{0,10},{12,10}}, color={0,0,127}));
  connect(weaBus2.TWetBul, natVenNitFluDyn.uWetBul) annotation (Line(
      points={{-78,178},{-84,178},{-84,142},{-96,142},{-96,46.8},{12,46.8}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(TAirDum.y, natVenNitFluDyn.uDryBul) annotation (Line(points={{-49.6,-64},
          {-50,-64},{-50,-62},{-8,-62},{-8,20},{12,20},{12,18.8}}, color={0,0,127}));
  connect(temRoo.T, natVenNitFluDyn.uRooMeaTem) annotation (Line(points={{361,-80},
          {352,-80},{352,-96},{8,-96},{8,2},{12,2}}, color={0,0,127}));
  connect(con.y, natVenNitFluDyn.uManOveRid) annotation (Line(points={{-58,110},
          {-24,110},{-24,73.2},{12,73.2}}, color={255,0,255}));
  connect(con.y, natVenNitFluDyn.uRai) annotation (Line(points={{-58,110},{-24,
          110},{-24,66},{-6,66},{-6,65.2},{12,65.2}}, color={255,0,255}));
  connect(ram2.y, natVenNitFluDyn.uForHi) annotation (Line(points={{-18,-90},{4,
          -90},{4,26.8},{12,26.8}}, color={0,0,127}));
  annotation (Documentation(info="<html>
<p>
This model validates the natural ventilation module with dynamic duration night flush over a calendar year.
A standard interior room is used.
The zone is 5 meters by 9 meters in floor area and is 3 meters in height.
All walls are exposed to a constant-temperature boundary condition that is set to ~70F to approximate interior conditions. 
<li> The room is modeled with standard office internal gains - 0.6 W/SF lighting (20% radiative, 80% convective), 0.6 W/SF plug loads (50% radiative, 50% convective) , and 2 occupants, with corresponding heat gains
<li> (93 W/person sensible (50% radiative and 50% convective) & 74 W/person latent).
<li> Gains are modeled with ASHRAE standard schedules for lighting, plug loads, and occupancy, respectively. 
<li> During occupied hours, the room receives ventilation air at approximately code minimum rate (~90 cfm). 
<li> During unoccupied hours, the room receives a negligible amount of air.
</html>", revisions="<html>
<ul>
<li>
October 6, 2020, by Fiona Woods:<br/>
Updated description. 
</li>
</html>"),experiment(Tolerance=1e-6, StartTime=0, StopTime=864000), __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Experimental/NaturalVentilation/Validation/NaturalVentilationNightFlushDynamicInterior.mos"
        "Simulate and plot"),Icon(coordinateSystem(extent={{-100,-100},{100,100}}),
                   graphics={
        Ellipse(
          lineColor={75,138,73},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          extent={{-100,-100},{100,100}}),
        Polygon(lineColor = {0,0,255},
                fillColor = {75,138,73},
                pattern = LinePattern.None,
                fillPattern = FillPattern.Solid,
                points={{-36,58},{64,-2},{-36,-62},{-36,58}})}), Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{
            640,200}})));
end NaturalVentilationNightFlushDynamicInterior;
