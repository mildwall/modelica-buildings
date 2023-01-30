within Buildings.Experimental.DHC.Plants.Combined.Controls.BaseClasses;
block StagingPump "Pump staging"

  parameter Integer nPum(
    final min=1,
    start=1)
    "Number of pumps"
    annotation(Evaluate=true);
  parameter Integer nChi(
    final min=1,
    start=1)
    "Number of chillers served by the pumps"
    annotation(Evaluate=true);
  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal
    "Loop design mass flow rate (all pumps)"
    annotation(Dialog(group="Nominal condition"));
  parameter Boolean have_switchover=false
    "Set to true in case of switchover valve in series with isolation valve"
    annotation(Evaluate=true);

  Buildings.Controls.OBC.CDL.Interfaces.RealInput m_flow(final unit="kg/s")
    "Mass flow rate as measured by the loop flow meter"
    annotation (Placement(
        transformation(extent={{-240,60},{-200,100}}),iconTransformation(extent={{-140,
            -20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput y(final unit="1")
    "Commanded speed"
    annotation (Placement(transformation(extent={{-240,-20},{-200,20}}),
      iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1[nPum]
    "Start signal (VFD Run or motor starter contact)"
    annotation (Placement(
        transformation(extent={{200,-20},{240,20}}), iconTransformation(extent={{100,-20},
            {140,20}})));

  Buildings.Controls.OBC.CDL.Continuous.GreaterThreshold cmp(t=0.99)
    "Compare"
    annotation (Placement(transformation(extent={{-100,-10},{-80,10}})));
  Buildings.Controls.OBC.CDL.Logical.Timer timSpe(t=5*60)
    "True delay"
    annotation (Placement(transformation(extent={{-70,-10},{-50,10}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiplyByParameter ratFlo(
    final k=1/m_flow_nominal)
    "Ratio of current flow rate to design value"
    annotation (Placement(transformation(extent={{-148,70},{-128,90}})));
  Buildings.Controls.OBC.CDL.Continuous.Greater cmp2 "Compare"
    annotation (Placement(transformation(extent={{-100,90},{-80,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput y1Ena
    "Lead pump enable signal (e.g. based on isolation valve opening command)"
    annotation (Placement(transformation(extent={{-240,140},{-200,180}}),
        iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Continuous.AddParameter addOff(p=-0.03)
    "Add offset"
    annotation (Placement(transformation(extent={{-80,130},{-100,150}})));
  Buildings.Controls.OBC.CDL.Logical.Timer timFlo(t=10*60)
    "Check if true for a given time"
    annotation (Placement(transformation(extent={{-72,90},{-52,110}})));
  Buildings.Controls.OBC.CDL.Logical.Or up
    "Check if flow or speed criterion passed for staging up"
    annotation (Placement(transformation(extent={{-30,-10},{-10,10}})));
  Buildings.Controls.OBC.CDL.Continuous.Less    cmp3 "Compare"
    annotation (Placement(transformation(extent={{-100,50},{-80,70}})));
  Buildings.Controls.OBC.CDL.Logical.Timer timFlo1(t=10*60)
    "Check if true for a given time"
    annotation (Placement(transformation(extent={{-72,50},{-52,70}})));
  Buildings.Controls.OBC.CDL.Continuous.LessThreshold  cmp4(t=0.3)
    "Compare"
    annotation (Placement(transformation(extent={{-100,-50},{-80,-30}})));
  Buildings.Controls.OBC.CDL.Logical.Timer timSpe1(t=5*60) "True delay"
    annotation (Placement(transformation(extent={{-70,-50},{-50,-30}})));
  Buildings.Controls.OBC.CDL.Logical.Or  dow
    "Check if flow or speed criterion passed for staging down"
    annotation (Placement(transformation(extent={{-30,-50},{-10,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiplyByParameter ratOpeDsg(
    final k=1/nPum)
    "Ratio of number of operating pumps to number of operating pumps at design conditions"
    annotation (Placement(transformation(extent={{-40,130},{-60,150}})));
  Buildings.Controls.OBC.CDL.Integers.GreaterEqualThreshold cvtBoo[nPum](
    final t={i for i in 1:nPum})
    "Compute pump Start command from number of pumps to be commanded On"
    annotation (Placement(transformation(extent={{160,-10},{180,10}})));
  Buildings.Controls.OBC.CDL.Routing.IntegerScalarReplicator rep(
    final nout=nPum) "Replicate"
    annotation (Placement(transformation(extent={{120,-10},{140,10}})));
  Modelica.Blocks.Continuous.FirstOrder filFlo(
    T=60,
    initType=Modelica.Blocks.Types.Init.InitialOutput)
    "Filter input to avoid algebraic loop"
    annotation (Placement(transformation(extent={{-190,70},{-170,90}})));
  StageIndex staLag(final nSta=max(1, nPum - 1), tSta=30)
    if nPum>1
    "Stage lag pumps (minimum runtime allowing for pump start time)"
    annotation (Placement(transformation(extent={{30,-10},{50,10}})));
  Buildings.Controls.OBC.CDL.Conversions.IntegerToReal cvtInt "Convert"
    annotation (Placement(transformation(extent={{70,130},{50,150}})));
  Buildings.Controls.OBC.CDL.Continuous.AddParameter addOffLowSta(p=-1/nPum)
    "Add offset for lower stage"
    annotation (Placement(transformation(extent={{-140,30},{-120,50}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToInteger leaEna
    "Return 1 if lead pump enabled"
    annotation (Placement(transformation(extent={{30,30},{50,50}})));
  Buildings.Controls.OBC.CDL.Integers.Add num "Number of pumps enabled"
    annotation (Placement(transformation(extent={{80,-10},{100,10}})));
  Buildings.Controls.OBC.CDL.Integers.Add numPre "Number of pumps enabled"
    annotation (Placement(transformation(extent={{80,50},{100,70}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant zer(final k=0)
    if nPum==1
    "Constant"
    annotation (Placement(transformation(extent={{30,-50},{50,-30}})));
equation
  connect(y, cmp.u)
    annotation (Line(points={{-220,0},{-102,0}},     color={0,0,127}));
  connect(cmp.y, timSpe.u)
    annotation (Line(points={{-78,0},{-72,0}},       color={255,0,255}));
  connect(ratFlo.y, cmp2.u1)
    annotation (Line(points={{-126,80},{-120,80},{-120,100},{-102,100}},
                                                 color={0,0,127}));
  connect(addOff.y, cmp2.u2) annotation (Line(points={{-102,140},{-110,140},{
          -110,92},{-102,92}},            color={0,0,127}));
  connect(timFlo.passed, up.u1) annotation (Line(points={{-50,92},{-36,92},{-36,
          0},{-32,0}},     color={255,0,255}));
  connect(ratFlo.y, cmp3.u1) annotation (Line(points={{-126,80},{-120,80},{-120,
          60},{-102,60}}, color={0,0,127}));
  connect(y, cmp4.u) annotation (Line(points={{-220,0},{-160,0},{-160,-40},{-102,
          -40}},       color={0,0,127}));
  connect(cmp4.y, timSpe1.u)
    annotation (Line(points={{-78,-40},{-72,-40}},   color={255,0,255}));
  connect(timFlo1.passed,dow. u1) annotation (Line(points={{-50,52},{-40,52},{
          -40,-40},{-32,-40}},                   color={255,0,255}));
  connect(addOff.u, ratOpeDsg.y)
    annotation (Line(points={{-78,140},{-62,140}}, color={0,0,127}));
  connect(rep.y, cvtBoo.u)
    annotation (Line(points={{142,0},{158,0}}, color={255,127,0}));
  connect(cmp2.y, timFlo.u)
    annotation (Line(points={{-78,100},{-74,100}},
                                                 color={255,0,255}));
  connect(cmp3.y, timFlo1.u)
    annotation (Line(points={{-78,60},{-74,60}}, color={255,0,255}));
  connect(timSpe.passed, up.u2) annotation (Line(points={{-48,-8},{-32,-8}},
                               color={255,0,255}));
  connect(timSpe1.passed,dow. u2) annotation (Line(points={{-48,-48},{-40,-48},
          {-40,-48},{-32,-48}},color={255,0,255}));
  connect(m_flow, filFlo.u)
    annotation (Line(points={{-220,80},{-192,80}}, color={0,0,127}));
  connect(filFlo.y, ratFlo.u)
    annotation (Line(points={{-169,80},{-150,80}}, color={0,0,127}));
  connect(y1Ena, staLag.u1) annotation (Line(points={{-220,160},{0,160},{0,6},{
          28,6}},
               color={255,0,255}));
  connect(cvtInt.y, ratOpeDsg.u)
    annotation (Line(points={{48,140},{-38,140}}, color={0,0,127}));
  connect(cvtBoo.y, y1)
    annotation (Line(points={{182,0},{220,0}}, color={255,0,255}));
  connect(addOff.y, addOffLowSta.u) annotation (Line(points={{-102,140},{-160,
          140},{-160,40},{-142,40}}, color={0,0,127}));
  connect(addOffLowSta.y, cmp3.u2) annotation (Line(points={{-118,40},{-110,40},
          {-110,52},{-102,52}}, color={0,0,127}));
  connect(y1Ena, leaEna.u) annotation (Line(points={{-220,160},{0,160},{0,40},{
          28,40}},
                color={255,0,255}));
  connect(dow.y, staLag.u1Dow) annotation (Line(points={{-8,-40},{0,-40},{0,
          -5.8},{28,-5.8}},
                      color={255,0,255}));
  connect(num.y, rep.u)
    annotation (Line(points={{102,0},{118,0}},
                                             color={255,127,0}));
  connect(staLag.idxSta, num.u2) annotation (Line(points={{52,0},{60,0},{60,-6},
          {78,-6}}, color={255,127,0}));
  connect(leaEna.y, num.u1) annotation (Line(points={{52,40},{60,40},{60,6},{78,
          6}}, color={255,127,0}));
  connect(numPre.y, cvtInt.u) annotation (Line(points={{102,60},{100,60},{100,
          140},{72,140}},
                     color={255,127,0}));
  connect(leaEna.y, numPre.u1) annotation (Line(points={{52,40},{60,40},{60,66},
          {78,66}}, color={255,127,0}));
  connect(staLag.preIdxSta, numPre.u2) annotation (Line(points={{52,-6},{56,-6},
          {56,54},{78,54}}, color={255,127,0}));
  connect(zer.y, num.u2) annotation (Line(points={{52,-40},{60,-40},{60,-6},{78,
          -6}}, color={255,127,0}));
  connect(zer.y, numPre.u2) annotation (Line(points={{52,-40},{64,-40},{64,54},
          {78,54}},color={255,127,0}));
  connect(up.y, staLag.u1Up)
    annotation (Line(points={{-8,0},{28,0}}, color={255,0,255}));
  annotation (
  defaultComponentName="staPum",
  Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Text(
          textColor={0,0,255},
          extent={{-150,110},{150,150}},
          textString="%name"),
        Rectangle(
          extent={{-100,-100},{100,100}},
          lineColor={0,0,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid)}),          Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-200,-200},{200,
            200}})));
end StagingPump;
