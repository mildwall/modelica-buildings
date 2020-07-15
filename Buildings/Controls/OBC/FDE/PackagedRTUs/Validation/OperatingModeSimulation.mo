within Buildings.Controls.OBC.FDE.PackagedRTUs.Validation;
model OperatingModeSimulation "This model simulates OperatingMode"
  OperatingMode operatingMode
    annotation (Placement(transformation(extent={{60,-20},{86,0}})));
  CDL.Logical.Sources.Pulse                        OccGen(width=0.5, period=
        2880)
    annotation (Placement(transformation(extent={{-82,48},{-62,68}})));
  CDL.Integers.OnCounter                        OccReqGen(y_start=0)
    annotation (Placement(transformation(extent={{-52,20},{-40,32}})));
  CDL.Logical.Sources.Pulse                        booPul(
    width=0.125,
    period=1440,
    startTime=1220)
    annotation (Placement(transformation(extent={{-82,16},{-62,36}})));
  CDL.Logical.Sources.Pulse                        booPul1(
    width=0.0075,
    period=144,
    startTime=260)
    annotation (Placement(transformation(extent={{-82,-18},{-62,2}})));
  CDL.Logical.Sources.Pulse                        booPul2(
    width=0.00275,
    period=144,
    startTime=440)
    annotation (Placement(transformation(extent={{-82,-50},{-62,-30}})));
  CDL.Integers.OnCounter                        SBCreqGen(y_start=0)
    annotation (Placement(transformation(extent={{-52,-14},{-40,-2}})));
  CDL.Integers.OnCounter                        SBHreqGen(y_start=0)
    annotation (Placement(transformation(extent={{-52,-46},{-40,-34}})));
  CDL.Integers.Sources.Constant conInt(k=12)
    "fixed total number of terminal units served by packaged RTU"
    annotation (Placement(transformation(extent={{2,-4},{22,16}})));
equation
  connect(OccReqGen.trigger,booPul. y)
    annotation (Line(points={{-53.2,26},{-60,26}}, color={255,0,255}));
  connect(booPul1.y,SBCreqGen. trigger)
    annotation (Line(points={{-60,-8},{-53.2,-8}}, color={255,0,255}));
  connect(booPul2.y,SBHreqGen. trigger)
    annotation (Line(points={{-60,-40},{-53.2,-40}}, color={255,0,255}));
  connect(OccReqGen.reset,OccGen. y) annotation (Line(points={{-46,18.8},{-34,
          18.8},{-34,58},{-60,58}},      color={255,0,255}));
  connect(SBHreqGen.reset,SBCreqGen. reset) annotation (Line(points={{-46,-47.2},
          {-46,-52},{-34,-52},{-34,-20},{-46,-20},{-46,-15.2}},  color={
          255,0,255}));
  connect(SBHreqGen.reset,OccGen. y) annotation (Line(points={{-46,-47.2},{-46,
          -52},{-34,-52},{-34,58},{-60,58}},      color={255,0,255}));
  connect(OccGen.y, operatingMode.occ) annotation (Line(points={{-60,58},{48,58},
          {48,-1.8},{58,-1.8}}, color={255,0,255}));
  connect(OccReqGen.y, operatingMode.occReq) annotation (Line(points={{-38.8,26},
          {42,26},{42,-4.8},{58,-4.8}}, color={255,127,0}));
  connect(SBCreqGen.y, operatingMode.sbcReq) annotation (Line(points={{-38.8,-8},
          {-8,-8},{-8,-14},{58,-14},{58,-13.6}}, color={255,127,0}));
  connect(SBHreqGen.y, operatingMode.sbhReq) annotation (Line(points={{-38.8,
          -40},{-8,-40},{-8,-17.8},{58,-17.8}}, color={255,127,0}));
  connect(conInt.y, operatingMode.TotalTU) annotation (Line(points={{24,6},{38,
          6},{38,-7.8},{58,-7.8}}, color={255,127,0}));
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Ellipse(lineColor = {75,138,73},
                fillColor={255,255,255},
                fillPattern = FillPattern.Solid,
                extent={{-100,-100},{100,100}}),
        Polygon(lineColor = {0,0,255},
                fillColor = {75,138,73},
                pattern = LinePattern.None,
                fillPattern = FillPattern.Solid,
                points={{-36,60},{64,0},{-36,-60},{-36,60}})}),
    Diagram(coordinateSystem(preserveAspectRatio=false)),
    experiment(StopTime=5760, __Dymola_Algorithm="Dassl"),
    Documentation(info="<html>
<p>
This example simulates
<a href=\"modelica://Buildings.Controls.OBC.FDE.PackagedRTUs.OperatingMode\">
Buildings.Controls.OBC.FDE.PackagedRTUs.OperatingMode</a>.
</p>
</html>"));
end OperatingModeSimulation;
