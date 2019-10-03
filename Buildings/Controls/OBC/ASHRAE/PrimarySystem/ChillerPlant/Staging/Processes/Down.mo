﻿within Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes;
block Down
  "Sequence for controlling devices when there is a stage-down command"

  parameter Integer nChi "Total number of chillers in the plant";
  parameter Integer totChiSta
    "Total number of stages that do not have waterside economizer being enabled, zero stage should be seem as one stage";
  parameter Integer totSta
    "Total number of stages, including the stages with a WSE, if applicable";
  parameter Boolean haveWSE=true
    "Flag: true=have waterside economizer";
  parameter Boolean havePonyChiller=false
    "Flag: true =have pony chiller";
  parameter Boolean isParallelChiller=true
    "Flag: true=the plant has parallel chillers";
  parameter Boolean isHeadered=true
    "Flag: true=headered condenser water pumps";
  parameter Boolean upOnOffSta[totChiSta] = {false,false,false}
    "Flag of the stage when staging up to it, need to turn off small chiller, the array size should be total numble of non-WSE stage plus 1"
    annotation (Dialog(group="Next chiller", enable=havePonyChiller));
  parameter Boolean dowOnOffSta[totChiSta] = {false,false,false}
    "Flag of the stage when staging down to it, need to turn on small chiller, the array size should be total numble of non-WSE stage plus 1"
    annotation (Dialog(group="Next chiller", enable=havePonyChiller));
  parameter Real chiDemRedFac=0.75
    "Demand reducing factor of current operating chillers"
    annotation (Dialog(group="Disable last chiller", enable=havePonyChiller));
  parameter Modelica.SIunits.Time holChiDemTim=300
    "Maximum time to wait for the actual demand less than percentage of currnet load"
    annotation (Dialog(group="Disable last chiller", enable=havePonyChiller));
  parameter Modelica.SIunits.Time waiTim=30
    "Waiting time after enabling next head pressure control"
    annotation (Dialog(group="Disable last chiller", enable=havePonyChiller));
  parameter Modelica.SIunits.Time proOnTim=300
    "Enabled chiller operation time to indicate if it is proven on"
    annotation (Dialog(group="Disable last chiller", enable=havePonyChiller));
  parameter Modelica.SIunits.Time chaChiWatIsoTim
    "Time to slowly change isolation valve, should be determined in the field"
    annotation (Dialog(group="Disable CHW isolation valve"));
  parameter Real staVec[totSta]
    "Chiller stage vector, element value like x.5 means chiller stage x plus WSE"
    annotation (Dialog(group="Disable condenser water pump"));
  parameter Real desConWatPumSpe[totSta]
    "Design condenser water pump speed setpoints, the size should be doule of total stage numbers"
    annotation (Dialog(group="Disable condenser water pump"));
  parameter Real desConWatPumNum[totSta]
    "Design number of condenser water pumps that should be ON, the size should be doule of total stage numbers"
    annotation (Dialog(group="Disable condenser water pump"));
  parameter Modelica.SIunits.Time byPasSetTim
    "Time to reset minimum by-pass flow"
    annotation (Dialog(group="Reset CHW minimum flow setpoint"));
  parameter Modelica.SIunits.VolumeFlowRate minFloSet[nChi]
    "Minimum chilled water flow through each chiller"
    annotation (Dialog(group="Reset CHW minimum flow setpoint"));
  parameter Modelica.SIunits.VolumeFlowRate maxFloSet[nChi]
    "Maximum chilled water flow through each chiller"
    annotation (Dialog(group="Reset CHW minimum flow setpoint"));
  parameter Modelica.SIunits.Time aftByPasSetTim=60
    "Time to allow loop to stabilize after resetting minimum chilled water flow setpoint"
    annotation (Dialog(group="Reset bypass"));
  parameter Real relSpeDif = 0.05
    "Hysteresis to check if speed setpoint has been achieved, relative error to the setpoint"
    annotation (Dialog(tab="Advanced", group="Disable condenser water pump"));
  parameter Real floEqu=0.95
    "Hysteresis to check if flow achieves setpoint, flow rate relative to its setpoint"
    annotation (Dialog(tab="Advanced", group="Reset bypass"));

  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uStaDow
    "Stage down status: true=stage-down"
    annotation (Placement(transformation(extent={{-320,360},{-280,400}}),
      iconTransformation(extent={{-140,170},{-100,210}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uChiPri[nChi]
    "Chiller enabling priority"
    annotation (Placement(transformation(extent={{-320,320},{-280,360}}),
      iconTransformation(extent={{-140,150},{-100,190}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput minOPLR(
    final min=0,
    final max=1,
    final unit="1")
    "Current stage minimum cycling operative partial load ratio"
    annotation (Placement(transformation(extent={{-320,290},{-280,330}}),
      iconTransformation(extent={{-140,118},{-100,158}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uChiLoa[nChi](
    final quantity=fill("HeatFlowRate", nChi),
    final unit=fill("W", nChi))
    "Current chiller load"
    annotation (Placement(transformation(extent={{-320,240},{-280,280}}),
      iconTransformation(extent={{-140,98},{-100,138}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uChi[nChi]
    "Chiller status: true=ON"
    annotation (Placement(transformation(extent={{-320,210},{-280,250}}),
      iconTransformation(extent={{-140,70},{-100,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput VChiWat_flow(
    final min=0,
    final unit="m3/s",
    final quantity="VolumeFlowRate")
    "Measured chilled water flow rate"
    annotation (Placement(transformation(extent={{-320,180},{-280,220}}),
      iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uChiSta
    "Current chiller stage index, does not include stages like X + WSE"
    annotation (Placement(transformation(extent={{-320,150},{-280,190}}),
      iconTransformation(extent={{-140,10},{-100,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uChiHeaCon[nChi]
    "Chillers head pressure control status"
    annotation (Placement(transformation(extent={{-320,120},{-280,160}}),
      iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uChiWatIsoVal[nChi](
    final min=fill(0, nChi),
    final max=fill(1, nChi),
    final unit=fill("1", nChi))
    "Chilled water isolation valve position"
    annotation (Placement(transformation(extent={{-320,90},{-280,130}}),
      iconTransformation(extent={{-140,-50},{-100,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uChiWatReq[nChi]
    "Chilled water requst status for each chiller"
    annotation (Placement(transformation(extent={{-320,-30},{-280,10}}),
      iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uConWatReq[nChi]
    "Condenser water requst status for each chiller"
    annotation (Placement(transformation(extent={{-320,-150},{-280,-110}}),
      iconTransformation(extent={{-140,-100},{-100,-60}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uChiConIsoVal[nChi]
    "Chiller condenser water isolation valve status"
    annotation (Placement(transformation(extent={{-320,-200},{-280,-160}}),
      iconTransformation(extent={{-140,-130},{-100,-90}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uWSE if haveWSE
    "Water side economizer status: true = ON, false = OFF"
    annotation (Placement(transformation(extent={{-320,-260},{-280,-220}}),
      iconTransformation(extent={{-140,-160},{-100,-120}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uConWatPumSpeSet(
    final min=0,
    final max=1,
    final unit="1")
    "Condenser water pump speed setpoint"
    annotation (Placement(transformation(extent={{-320,-300},{-280,-260}}),
      iconTransformation(extent={{-140,-190},{-100,-150}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uConWatPumSpe(
    final min=0,
    final max=1,
    final unit="1")
    "Current condenser water pump speed"
    annotation (Placement(transformation(extent={{-320,-330},{-280,-290}}),
      iconTransformation(extent={{-140,-210},{-100,-170}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput yStaPro
    "Indicate stage-down status: true=in stage-down process"
    annotation (Placement(transformation(extent={{280,360},{320,400}}),
      iconTransformation(extent={{100,170},{140,210}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yChiDem[nChi](
    final quantity=fill("HeatFlowRate", nChi),
    final unit=fill("W", nChi))
    "Chiller demand setpoint"
    annotation (Placement(transformation(extent={{280,240},{320,280}}),
      iconTransformation(extent={{100,130},{140,170}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput yChi[nChi]
    "Chiller enabling status"
    annotation (Placement(transformation(extent={{280,180},{320,220}}),
      iconTransformation(extent={{100,90},{140,130}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yChiWatIsoVal[nChi](
    final min=fill(0, nChi),
    final max=fill(1, nChi),
    final unit=fill("1", nChi))
    "Chiller chilled water isolation valve position"
    annotation (Placement(transformation(extent={{280,20},{320,60}}),
      iconTransformation(extent={{100,50},{140,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput yTowStaDow
    "Tower stage down status: true=stage down cooling tower"
    annotation (Placement(transformation(extent={{280,-80},{320,-40}}),
      iconTransformation(extent={{100,10},{140,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput yChiHeaCon[nChi]
    "Chiller head pressure control enabling status"
    annotation (Placement(transformation(extent={{280,-130},{320,-90}}),
      iconTransformation(extent={{100,-50},{140,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput yLeaPum
    "Lead pump status"
    annotation (Placement(transformation(extent={{280,-170},{320,-130}}),
      iconTransformation(extent={{100,-90},{140,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yDesConWatPumSpe(
    final min=0,
    final max=1,
    final unit="1")
    "Condenser water pump design speed at current stage"
    annotation (Placement(transformation(extent={{280,-210},{320,-170}}),
      iconTransformation(extent={{100,-130},{140,-90}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yConWatPumNum
    "Number of operating condenser water pumps"
    annotation (Placement(transformation(extent={{280,-250},{320,-210}}),
      iconTransformation(extent={{100,-170},{140,-130}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yChiWatMinFloSet(
    final min=0,
    final unit="m3/s",
    final quantity="VolumeFlowRate")
    "Chilled water minimum flow setpoint"
    annotation (Placement(transformation(extent={{280,-350},{320,-310}}),
      iconTransformation(extent={{100,-208},{140,-168}})));

protected
  Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.NextChiller
    nexChi(
    final nChi=nChi,
    final havePonyChiller=havePonyChiller,
    final totChiSta=totChiSta,
    final upOnOffSta=upOnOffSta,
    final dowOnOffSta=dowOnOffSta) "Identify next enabling chiller"
    annotation (Placement(transformation(extent={{-40,280},{-20,300}})));
  Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.DownStart
    dowSta(
    final nChi=nChi,
    final isParallelChiller=isParallelChiller,
    final chiDemRedFac=chiDemRedFac,
    final holChiDemTim=holChiDemTim,
    final minFloSet=minFloSet,
    final maxFloSet=maxFloSet,
    final aftByPasSetTim=aftByPasSetTim,
    final floEqu=floEqu,
    final byPasSetTim=byPasSetTim,
    final waiTim=waiTim,
    final chaChiWatIsoTim=chaChiWatIsoTim,
    final proOnTim=proOnTim) "Start stage-down process"
    annotation (Placement(transformation(extent={{60,220},{80,240}})));
  Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.CHWIsoVal
    disChiIsoVal(
    final nChi=nChi,
    final chaChiWatIsoTim=chaChiWatIsoTim,
    final iniValPos=1,
    final endValPos=0) "Disable isolation valve of the chiller being disabled"
    annotation (Placement(transformation(extent={{200,50},{220,70}})));
  Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.HeadControl
    disHeaCon(
    final nChi=nChi,
    final thrTimEnb=0,
    final waiTim=0,
    final heaStaCha=false)
    "Disable head pressure control of the chiller being disabled"
    annotation (Placement(transformation(extent={{200,-110},{220,-90}})));
  Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.EnableCWPump
    disNexCWP
    "Identify correct stage number for disabling next condenser water pump"
    annotation (Placement(transformation(extent={{100,-170},{120,-150}})));
  Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Pumps.CondenserWater.Controller
    conWatPumCon(
    final isHeadered=isHeadered,
    final haveWSE=haveWSE,
    final nChi=nChi,
    final totSta=totSta,
    final staVec=staVec,
    final desConWatPumSpe=desConWatPumSpe,
    final desConWatPumNum=desConWatPumNum,
    final relSpeDif=relSpeDif)
    "Enabling next condenser water pump or change pump speed"
    annotation (Placement(transformation(extent={{160,-192},{180,-172}})));
  Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.MinimumFlowBypass.Subsequences.FlowSetpoint
    minChiWatFlo(
    final nChi=nChi,
    final isParallelChiller=isParallelChiller,
    final maxFloSet=maxFloSet,
    final byPasSetTim=byPasSetTim,
    final minFloSet=minFloSet) "Minimum chilled water flow setpoint"
    annotation (Placement(transformation(extent={{180,-340},{200,-320}})));
  Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.ResetMinBypass
    minBypSet(
    final aftByPasSetTim=aftByPasSetTim,
    final floEqu=floEqu)
    "Check if minium bypass has been reset"
    annotation (Placement(transformation(extent={{120,-380},{140,-360}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant con(final k=false)
    "False constant"
    annotation (Placement(transformation(extent={{-160,250},{-140,270}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea1[nChi]
    "Convert boolean input to real output"
    annotation (Placement(transformation(extent={{-240,-20},{-220,0}})));
  Buildings.Controls.OBC.CDL.Routing.RealExtractor curDisChi(final nin=nChi)
    "Current disabling chiller"
    annotation (Placement(transformation(extent={{-80,-20},{-60,0}})));
  Buildings.Controls.OBC.CDL.Continuous.LessEqualThreshold lesEquThr(
    final threshold=0.5)
    "Check if the disabled chiller has chilled water request"
    annotation (Placement(transformation(extent={{-40,-20},{-20,0}})));
  Buildings.Controls.OBC.CDL.Logical.And and4 "Logical and"
    annotation (Placement(transformation(extent={{-40,20},{-20,40}})));
  Buildings.Controls.OBC.CDL.Logical.LogicalSwitch logSwi2 "Logical switch"
    annotation (Placement(transformation(extent={{60,10},{80,30}})));
  Buildings.Controls.OBC.CDL.Logical.And and1 "Logical and"
    annotation (Placement(transformation(extent={{140,10},{160,30}})));
  Buildings.Controls.OBC.CDL.Routing.BooleanReplicator booRep4(final nout=nChi)
    "Replicate boolean input"
    annotation (Placement(transformation(extent={{40,70},{60,90}})));
  Buildings.Controls.OBC.CDL.Logical.Switch swi[nChi]
    "Chilled water isolvation valve position"
    annotation (Placement(transformation(extent={{140,70},{160,90}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea2[nChi]
    "Convert boolean input to real output"
    annotation (Placement(transformation(extent={{-240,-140},{-220,-120}})));
  Buildings.Controls.OBC.CDL.Routing.RealExtractor curDisChi1(final nin=nChi)
    "Current disabling chiller"
    annotation (Placement(transformation(extent={{-80,-140},{-60,-120}})));
  Buildings.Controls.OBC.CDL.Continuous.LessEqualThreshold lesEquThr1(
    final threshold=0.5)
    "Check if the disabled chiller is not requiring condenser water"
    annotation (Placement(transformation(extent={{-40,-140},{-20,-120}})));
  Buildings.Controls.OBC.CDL.Logical.And3 and5 "Logical and"
    annotation (Placement(transformation(extent={{60,-130},{80,-110}})));
  Buildings.Controls.OBC.CDL.Routing.BooleanReplicator booRep1(final nout=nChi)
    "Replicate boolean input"
    annotation (Placement(transformation(extent={{60,-80},{80,-60}})));
  Buildings.Controls.OBC.CDL.Logical.LogicalSwitch logSwi [nChi]
    "Chillers head pressure control status"
    annotation (Placement(transformation(extent={{140,-80},{160,-60}})));
  Buildings.Controls.OBC.CDL.Logical.MultiOr  mulOr(final nu=nChi) "Multiple or"
    annotation (Placement(transformation(extent={{-80,-200},{-60,-180}})));
  Buildings.Controls.OBC.CDL.Logical.MultiOr mulOr1(final nu=nChi) "Multiple or"
    annotation (Placement(transformation(extent={{-80,-230},{-60,-210}})));
  Buildings.Controls.OBC.CDL.Logical.Edge edg
    "Rising edge, output true at the moment when input turns from false to true"
    annotation (Placement(transformation(extent={{-240,370},{-220,390}})));
  Buildings.Controls.OBC.CDL.Logical.Latch lat
    "Logical latch, maintain ON signal until condition changes"
    annotation (Placement(transformation(extent={{-180,370},{-160,390}})));
  Buildings.Controls.OBC.CDL.Logical.And and2 "Logical and"
    annotation (Placement(transformation(extent={{200,-270},{220,-250}})));
  Buildings.Controls.OBC.CDL.Logical.Edge edg1
    "Rising edge, output true at the moment when input turns from false to true"
    annotation (Placement(transformation(extent={{200,-380},{220,-360}})));
  Buildings.Controls.OBC.CDL.Logical.Pre pre
    "Break algebraic loop"
    annotation (Placement(transformation(extent={{160,-380},{180,-360}})));

equation
  connect(nexChi.uChiPri, uChiPri)
    annotation (Line(points={{-42,298},{-200,298},{-200,340},{-300,340}},
      color={255,127,0}));
  connect(uChi, nexChi.uChiEna)
    annotation (Line(points={{-300,230},{-200,230},{-200,294},{-42,294}},
      color={255,0,255}));
  connect(con.y, nexChi.uStaUp)
    annotation (Line(points={{-138,260},{-120,260},{-120,290},{-42,290}},
      color={255,0,255}));
  connect(uChiSta, nexChi.uChiSta)
    annotation (Line(points={{-300,170},{-180,170},{-180,286},{-42,286}},
      color={255,127,0}));
  connect(nexChi.yOnOff,dowSta. uOnOff)
    annotation (Line(points={{-18,290},{0,290},{0,229},{58,229}},
      color={255,0,255}));
  connect(nexChi.yEnaSmaChi,dowSta. nexEnaChi)
    annotation (Line(points={{-18,281},{30,281},{30,227},{58,227}},
      color={255,127,0}));
  connect(dowSta.uChiHeaCon, uChiHeaCon)
    annotation (Line(points={{58,225},{-100,225},{-100,140},{-300,140}},
      color={255,0,255}));
  connect(dowSta.uChiWatIsoVal, uChiWatIsoVal)
    annotation (Line(points={{58,223},{-60,223},{-60,110},{-300,110}},
      color={0,0,127}));
  connect(nexChi.yLasDisChi,dowSta. nexDisChi)
    annotation (Line(points={{-18,286},{20,286},{20,221},{58,221}},
      color={255,127,0}));
  connect(uChiWatReq, booToRea1.u)
    annotation (Line(points={{-300,-10},{-242,-10}}, color={255,0,255}));
  connect(booToRea1.y, curDisChi.u)
    annotation (Line(points={{-218,-10},{-82,-10}}, color={0,0,127}));
  connect(curDisChi.y, lesEquThr.u)
    annotation (Line(points={{-58,-10},{-42,-10}}, color={0,0,127}));
  connect(nexChi.yOnOff, logSwi2.u2)
    annotation (Line(points={{-18,290},{0,290},{0,20},{58,20}},
      color={255,0,255}));
  connect(dowSta.yReaDemLim, and4.u1)
    annotation (Line(points={{82,221},{92,221},{92,100},{-60,100},{-60,30},{-42,30}},
      color={255,0,255}));
  connect(and4.y, logSwi2.u1)
    annotation (Line(points={{-18,30},{40,30},{40,28},{58,28}},
      color={255,0,255}));
  connect(nexChi.yLasDisChi, curDisChi.index)
    annotation (Line(points={{-18,286},{20,286},{20,120},{-140,120},{-140,-30},
      {-70,-30},{-70,-22}}, color={255,127,0}));
  connect(lesEquThr.y, and1.u2)
    annotation (Line(points={{-18,-10},{120,-10},{120,12},{138,12}},
      color={255,0,255}));
  connect(logSwi2.y, and1.u1)
    annotation (Line(points={{82,20},{138,20}}, color={255,0,255}));
  connect(nexChi.yLasDisChi, disChiIsoVal.nexChaChi)
    annotation (Line(points={{-18,286},{20,286},{20,68},{198,68}},
      color={255,127,0}));
  connect(and1.y,disChiIsoVal.uUpsDevSta)
    annotation (Line(points={{162,20},{180,20},{180,55},{198,55}},
      color={255,0,255}));
  connect(nexChi.yOnOff, booRep4.u)
    annotation (Line(points={{-18,290},{0,290},{0,80},{38,80}}, color={255,0,255}));
  connect(booRep4.y, swi.u2)
    annotation (Line(points={{62,80},{138,80}}, color={255,0,255}));
  connect(uChiWatIsoVal, swi.u3)
    annotation (Line(points={{-300,110},{80,110},{80,72},{138,72}},
      color={0,0,127}));
  connect(dowSta.yChiWatIsoVal, swi.u1)
    annotation (Line(points={{82,230},{96,230},{96,88},{138,88}},
      color={0,0,127}));
  connect(swi.y, disChiIsoVal.uChiWatIsoVal)
    annotation (Line(points={{162,80},{180,80},{180,65},{198,65}},
      color={0,0,127}));
  connect(uConWatReq, booToRea2.u)
    annotation (Line(points={{-300,-130},{-242,-130}}, color={255,0,255}));
  connect(booToRea2.y, curDisChi1.u)
    annotation (Line(points={{-218,-130},{-82,-130}},color={0,0,127}));
  connect(curDisChi1.y, lesEquThr1.u)
    annotation (Line(points={{-58,-130},{-42,-130}}, color={0,0,127}));
  connect(logSwi2.y, and5.u1)
    annotation (Line(points={{82,20},{90,20},{90,-20},{10,-20},{10,-112},{58,-112}},
      color={255,0,255}));
  connect(disChiIsoVal.yEnaChiWatIsoVal, and5.u2)
    annotation (Line(points={{222,66},{240,66},{240,-30},{40,-30},{40,-120},{58,
          -120}}, color={255,0,255}));
  connect(lesEquThr1.y, and5.u3)
    annotation (Line(points={{-18,-130},{40,-130},{40,-128},{58,-128}},
      color={255,0,255}));
  connect(uChi,dowSta. uChi)
    annotation (Line(points={{-300,230},{-200,230},{-200,233},{58,233}},
      color={255,0,255}));
  connect(nexChi.yLasDisChi, curDisChi1.index)
    annotation (Line(points={{-18,286},{20,286},{20,120},{-140,120},{-140,-152},
      {-70,-152},{-70,-142}}, color={255,127,0}));
  connect(nexChi.yOnOff, booRep1.u)
    annotation (Line(points={{-18,290},{0,290},{0,-70},{58,-70}},
      color={255,0,255}));
  connect(booRep1.y, logSwi.u2)
    annotation (Line(points={{82,-70},{138,-70}}, color={255,0,255}));
  connect(uChiHeaCon, logSwi.u3)
    annotation (Line(points={{-300,140},{-100,140},{-100,-90},{120,-90},
      {120,-78},{138,-78}}, color={255,0,255}));
  connect(dowSta.yChiHeaCon, logSwi.u1)
    annotation (Line(points={{82,235},{100,235},{100,-62},{138,-62}},
      color={255,0,255}));
  connect(and5.y, disHeaCon.uUpsDevSta)
    annotation (Line(points={{82,-120},{160,-120},{160,-92},{198,-92}},
      color={255,0,255}));
  connect(nexChi.yLasDisChi, disHeaCon.nexChaChi)
    annotation (Line(points={{-18,286},{20,286},{20,-104},{198,-104}},
      color={255,127,0}));
  connect(logSwi.y, disHeaCon.uChiHeaCon)
    annotation (Line(points={{162,-70},{180,-70},{180,-108},{198,-108}},
      color={255,0,255}));
  connect(disHeaCon.yEnaHeaCon,disNexCWP. uUpsDevSta)
    annotation (Line(points={{222,-94},{240,-94},{240,-140},{80,-140},{80,-152},
      {98,-152}}, color={255,0,255}));
  connect(con.y,disNexCWP. uStaUp)
    annotation (Line(points={{-138,260},{-120,260},{-120,-158},{98,-158}},
      color={255,0,255}));
  connect(uChiSta, disNexCWP.uChiSta)
    annotation (Line(points={{-300,170},{-180,170},{-180,-168},{98,-168}},
      color={255,127,0}));
  connect(disNexCWP.yChiSta, conWatPumCon.uChiSta)
    annotation (Line(points={{122,-160},{140,-160},{140,-183},{158,-183}},
      color={255,127,0}));
  connect(mulOr1.y, conWatPumCon.uLeaConWatReq)
    annotation (Line(points={{-58,-220},{126,-220},{126,-180},{158,-180}},
      color={255,0,255}));
  connect(uChi, mulOr.u)
    annotation (Line(points={{-300,230},{-200,230},{-200,-190},{-82,-190}},
      color={255,0,255}));
  connect(uConWatReq, mulOr1.u)
    annotation (Line(points={{-300,-130},{-250,-130},{-250,-220},{-82,-220}},
      color={255,0,255}));
  connect(conWatPumCon.uWSE, uWSE)
    annotation (Line(points={{158,-186},{134,-186},{134,-240},{-300,-240}},
      color={255,0,255}));
  connect(conWatPumCon.uConWatPumSpe, uConWatPumSpe)
    annotation (Line(points={{158,-191},{150,-191},{150,-310},{-300,-310}},
      color={0,0,127}));
  connect(con.y, minChiWatFlo.uStaUp)
    annotation (Line(points={{-138,260},{-120,260},{-120,-321},{178,-321}},
      color={255,0,255}));
  connect(nexChi.yOnOff, minChiWatFlo.uOnOff)
    annotation (Line(points={{-18,290},{0,290},{0,-337},{178,-337}},
      color={255,0,255}));
  connect(dowSta.yChiDem, yChiDem)
    annotation (Line(points={{82,239},{179.5,239},{179.5,260},{300,260}},
      color={0,0,127}));
  connect(dowSta.yChi, yChi)
    annotation (Line(points={{82,225},{180,225},{180,200},{300,200}},
      color={255,0,255}));
  connect(disChiIsoVal.yChiWatIsoVal, yChiWatIsoVal)
    annotation (Line(points={{222,54},{260,54},{260,40},{300,40}},
      color={0,0,127}));
  connect(uStaDow, edg.u)
    annotation (Line(points={{-300,380},{-242,380}}, color={255,0,255}));
  connect(edg.y, lat.u)
    annotation (Line(points={{-218,380},{-182,380}}, color={255,0,255}));
  connect(lat.y, minBypSet.uStaCha)
    annotation (Line(points={{-158,380},{-140,380},{-140,360},{-260,360},
      {-260,-366},{118,-366}}, color={255,0,255}));
  connect(VChiWat_flow, minBypSet.VChiWat_flow)
    annotation (Line(points={{-300,200},{-170,200},{-170,-374},{118,-374}},
      color={0,0,127}));
  connect(VChiWat_flow, dowSta.VChiWat_flow)
    annotation (Line(points={{-300,200},{-170,200},{-170,231},{58,231}},
      color={0,0,127}));
  connect(uChiLoa,dowSta. uChiLoa)
    annotation (Line(points={{-300,260},{-170,260},{-170,235},{58,235}},
      color={0,0,127}));
  connect(lat.y,dowSta. uStaDow)
    annotation (Line(points={{-158,380},{-140,380},{-140,360},{-260,360},
      {-260,239},{58,239}}, color={255,0,255}));
  connect(lat.y, nexChi.uStaDow)
    annotation (Line(points={{-158,380},{-140,380},{-140,360},{-260,360},
      {-260,282},{-42,282}}, color={255,0,255}));
  connect(lat.y, disChiIsoVal.uStaCha)
    annotation (Line(points={{-158,380},{-140,380},{-140,360},{-260,360},
      {-260,52},{198,52}}, color={255,0,255}));
  connect(lat.y, and4.u2)
    annotation (Line(points={{-158,380},{-140,380},{-140,360},{-260,360},
      {-260,22},{-42,22}}, color={255,0,255}));
  connect(lat.y, logSwi2.u3)
    annotation (Line(points={{-158,380},{-140,380},{-140,360},{-260,360},
      {-260,12},{58,12}}, color={255,0,255}));
  connect(lat.y, disHeaCon.uStaCha)
    annotation (Line(points={{-158,380},{-140,380},{-140,360},{-260,360},
      {-260,-96},{198,-96}},color={255,0,255}));
  connect(lat.y, minChiWatFlo.uStaDow)
    annotation (Line(points={{-158,380},{-140,380},{-140,360},{-260,360},
      {-260,-339},{178,-339}}, color={255,0,255}));
  connect(lat.y,disNexCWP. uStaDow)
    annotation (Line(points={{-158,380},{-140,380},{-140,360},{-260,360},
      {-260,-162},{98,-162}}, color={255,0,255}));
  connect(lat.y, yStaPro)
    annotation (Line(points={{-158,380},{300,380}},color={255,0,255}));
  connect(disHeaCon.yEnaHeaCon, and2.u2)
    annotation (Line(points={{222,-94},{240,-94},{240,-140},{80,-140},{80,-268},
      {198,-268}},   color={255,0,255}));
  connect(conWatPumCon.yPumSpeChe, and2.u1)
    annotation (Line(points={{182,-191},{190,-191},{190,-260},{198,-260}},
      color={255,0,255}));
  connect(and2.y, minChiWatFlo.uUpsDevSta)
    annotation (Line(points={{222,-260},{240,-260},{240,-300},{160,-300},
      {160,-323},{178,-323}}, color={255,0,255}));
  connect(and2.y, minBypSet.uUpsDevSta)
    annotation (Line(points={{222,-260},{240,-260},{240,-300},{60,-300},
      {60,-362},{118,-362}}, color={255,0,255}));
  connect(dowSta.minOPLR, minOPLR)
    annotation (Line(points={{58,237},{40,237},{40,310},{-300,310}},
      color={0,0,127}));
  connect(conWatPumCon.uChiConIsoVal, uChiConIsoVal)
    annotation (Line(points={{158,-172},{-140,-172},{-140,-180},{-300,-180}},
      color={255,0,255}));
  connect(mulOr.y, conWatPumCon.uLeaChiEna)
    annotation (Line(points={{-58,-190},{120,-190},{120,-175},{158,-175}},
      color={255,0,255}));
  connect(mulOr.y, conWatPumCon.uLeaChiSta)
    annotation (Line(points={{-58,-190},{120,-190},{120,-177},{158,-177}},
      color={255,0,255}));
  connect(conWatPumCon.yDesConWatPumSpe, yDesConWatPumSpe)
    annotation (Line(points={{182,-179},{240,-179},{240,-190},{300,-190}},
      color={0,0,127}));
  connect(conWatPumCon.uConWatPumSpeSet, uConWatPumSpeSet)
    annotation (Line(points={{158,-189},{142,-189},{142,-280},{-300,-280}},
      color={0,0,127}));
  connect(uChi, minChiWatFlo.uChi)
    annotation (Line(points={{-300,230},{-200,230},{-200,-326},{178,-326}},
      color={255,0,255}));
  connect(nexChi.yLasDisChi, minChiWatFlo.nexDisChi)
    annotation (Line(points={{-18,286},{20,286},{20,-331},{178,-331}},
      color={255,127,0}));
  connect(nexChi.yEnaSmaChi, minChiWatFlo.nexEnaChi)
    annotation (Line(points={{-18,281},{30,281},{30,-329},{178,-329}},
      color={255,127,0}));
  connect(con.y, minChiWatFlo.uSubCha)
    annotation (Line(points={{-138,260},{-120,260},{-120,-334},{178,-334}},
      color={255,0,255}));
  connect(minChiWatFlo.yChiWatMinFloSet, yChiWatMinFloSet)
    annotation (Line(points={{202,-330},{300,-330}}, color={0,0,127}));
  connect(minChiWatFlo.yChiWatMinFloSet, minBypSet.VMinChiWat_setpoint)
    annotation (Line(points={{202,-330},{220,-330},{220,-350},{80,-350},
      {80,-378},{118,-378}}, color={0,0,127}));
  connect(edg1.y, lat.clr)
    annotation (Line(points={{222,-370},{260,-370},{260,-390},{-190,-390},
      {-190,374},{-182,374}}, color={255,0,255}));
  connect(conWatPumCon.yConWatPumNum, yConWatPumNum)
    annotation (Line(points={{182,-185},{220,-185},{220,-230},{300,-230}},
      color={255,127,0}));
  connect(conWatPumCon.yLeaPum, yLeaPum)
    annotation (Line(points={{182,-173},{220,-173},{220,-150},{300,-150}},
      color={255,0,255}));
  connect(disHeaCon.yEnaHeaCon, yTowStaDow)
    annotation (Line(points={{222,-94},{240,-94},{240,-60},{300,-60}},
      color={255,0,255}));
  connect(disHeaCon.yChiHeaCon, yChiHeaCon)
    annotation (Line(points={{222,-106},{260,-106},{260,-110},{300,-110}},
      color={255,0,255}));
  connect(minBypSet.yMinBypRes, pre.u)
    annotation (Line(points={{142,-370},{158,-370}}, color={255,0,255}));
  connect(pre.y, edg1.u)
    annotation (Line(points={{182,-370},{198,-370}}, color={255,0,255}));

annotation (
  defaultComponentName="dowProCon",
  Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-280,-400},{280,400}})),
    Icon(coordinateSystem(extent={{-100,-200},{100,200}}), graphics={
        Rectangle(
        extent={{-100,-200},{100,200}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid,
        borderPattern=BorderPattern.Raised),
        Text(
          extent={{-120,260},{120,200}},
          lineColor={0,0,255},
          textString="%name"),
        Rectangle(
          extent={{-10,140},{10,-120}},
          lineColor={200,200,200},
          fillColor={207,207,207},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{0,-120},{-42,-120},{0,-160},{40,-120},{0,-120}},
          lineColor={200,200,200},
          fillColor={207,207,207},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-100,178},{-58,166}},
          lineColor={255,127,0},
          textString="uChiPri"),
        Text(
          extent={{-98,198},{-58,186}},
          lineColor={255,0,255},
          textString="uStaDow"),
        Text(
          extent={{-96,146},{-52,134}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="minOPLR"),
        Text(
          extent={{-96,126},{-60,114}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="uChiLoa"),
        Text(
          extent={{-100,96},{-70,84}},
          lineColor={255,0,255},
          textString="uChi"),
        Text(
          extent={{-98,68},{-44,54}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="VChiWat_flow"),
        Text(
          extent={{-98,36},{-60,24}},
          lineColor={255,127,0},
          textString="uChiSta"),
        Text(
          extent={{-96,6},{-44,-6}},
          lineColor={255,0,255},
          textString="uChiHeaCon"),
        Text(
          extent={{-98,-22},{-38,-34}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="uChiWatIsoVal"),
        Text(
          extent={{-98,-54},{-48,-66}},
          lineColor={255,0,255},
          textString="uChiWatReq"),
        Text(
          extent={{-98,-72},{-40,-86}},
          lineColor={255,0,255},
          textString="uConWatReq"),
        Text(
          extent={{-98,-102},{-34,-116}},
          lineColor={255,0,255},
          textString="uChiConIsoVal"),
        Text(
          extent={{-102,-134},{-66,-146}},
          lineColor={255,0,255},
          textString="uWSE"),
        Text(
          extent={{-98,-182},{-24,-196}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="uConWatPumSpe"),
        Text(
          extent={{-98,-160},{-14,-178}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="uConWatPumSpeSet"),
        Text(
          extent={{60,198},{100,186}},
          lineColor={255,0,255},
          textString="yStaPro"),
        Text(
          extent={{60,158},{96,146}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="yChiDem"),
        Text(
          extent={{72,118},{96,106}},
          lineColor={255,0,255},
          textString="yChi"),
        Text(
          extent={{36,80},{96,64}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="yChiWatIsoVal"),
        Text(
          extent={{42,38},{96,26}},
          lineColor={255,0,255},
          textString="yTowStaDow"),
        Text(
          extent={{48,-22},{96,-36}},
          lineColor={255,0,255},
          textString="yChiHeaCon"),
        Text(
          extent={{58,-62},{96,-74}},
          lineColor={255,0,255},
          textString="yLeaPum"),
        Text(
          extent={{18,-104},{98,-114}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="yDesConWatPumSpe"),
        Text(
          extent={{34,-142},{96,-156}},
          lineColor={255,127,0},
          textString="yConWatPumNum"),
        Text(
          extent={{28,-180},{98,-194}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="yChiWatMinFloSet")}),
Documentation(info="<html>
<p>
Block that controls devices when there is a stage-down command. This sequence is for
water-cooled primary-only parallel chiller plants with headered chilled water pumps
and headered condenser water pumps, or air-cooled primary-only parallel chiller
plants with headered chilled water pumps.
This development is based on ASHRAE RP-1711 Advanced Sequences of Operation for 
HVAC Systems Phase II – Central Plants and Hydronic Systems (Draft 6 on July 25, 
2019), section 5.2.4.16, which specifies the step-by-step control of
devices during chiller staging down process.
</p>
<ol>
<li>
Identify the chiller(s) that should be enabled (and disabled, if <code>havePonyChiller=true</code>). 
This is implemented in block <code>nexChi</code>. See
<a href=\"modelica://Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.NextChiller\">
Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.NextChiller</a>
for more decriptions.
</li>
<li>
Start the staging down process,
<ul>
<li>
For any stage change during which a smaller chiller is enabled and a larger chller
is disabled:
<ol type=\"i\">
<li>
Command operating chillers to reduce demand to 75% (<code>chiDemRedFac</code>) of 
their current load (<code>uChiLoa</code>) or a percentage equal to current stage 
minimum cycling operative partial load ratio <code>minOPLR</code>, whichever is greater. 
Wait until actual demand &lt; 80% of current load up to a maximum of 5 minutes 
(<code>holChiDemTim</code>) before proceeding.
</li>
<li>
Slowly change the minimum flow bypass setpoint to the one that includes both 
chillers are enabled. After new setpoint is achieved, wait 1 minute 
(<code>aftByPasSetTim</code>) to allow loop stabilize.
</li>
<li>
Enable head pressure control for the chiller being enabled. Wait 30 seconds (<code>waiTim</code>).
</li>
<li>
Slowly (<code>chaChiWatIsoTim</code>) open chilled water isolation valve of the smaller 
chiller being enabled. The valve timing should be determind in the field.
</li>
<li>
Start the smaller chiller after its chilled water isolation valve is fully open.
</li>
<li>
Wait 5 minutes (<code>proOnTim</code>) for the newly enabled chiller to prove that 
it is operating correctly, then shut off the larger chiller and release the 
demand limit.
</li>
</ol>
</li>
<li>
If staging down from any other stage, shut off the last stage chiller.
</li>
</ul>
These are implemented in block <code>dowSta</code>. See
<a href=\"modelica://Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.DownStart\">
Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.DownStart</a>
for more decriptions.
</li>
<li>
When the controller of the chiller being shut off indicates no request for chilled
water flow (<code>uChiWatReq=false</code>), slowly (<code>chaChiWatIsoTim</code>) 
close the chiller's chilled water isolation valve to avoid a sudden change in flow 
through other operating chillers.
This is implemented in block <code>disChiIsoVal</code>. See
<a href=\"modelica://Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.CHWIsoVal\">
Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.CHWIsoVal</a>
for more decriptions.
</li>

<li>
When the controller of the chiller being shut off indicates no request for condenser
water flow (<code>uConWatReq=false</code>), disable the chiller's head pressure control 
loop.
This is implemented in block <code>disHeaCon</code>. See
<a href=\"modelica://Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.HeadControl\">
Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.HeadControl</a>
for more decriptions.
</li>

<li>
When the condenser water head pressure control valve is fully closed, shut off
the last lag condenser water pump or change the pump speed to that required of 
the new stage.
Block <code>disNexCWP</code> identifies chiller stage for the condenser water pump
control
(<a href=\"modelica://Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.EnableCWPump\">
Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.EnableCWPump</a>)
and block <code>conWatPumCon</code> checks if the condenser water pumps have been reset
(<a href=\"modelica://Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Pumps.CondenserWater.Controller\">
Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Pumps.CondenserWater.Controller</a>).
</li>

<li>
Change the chilled water minimum flow setpoint to that appropriate for the new
stage.
The minimum flow setpoint is reset in block <code>minChiWatFlo</code>
(<a href=\"modelica://Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.MinimumFlowBypass.Subsequences.FlowSetpoint\">
Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.MinimumFlowBypass.Subsequences.FlowSetpoint</a>).
Block <code>minBypSet</code> checks if the new setpoint is achieved
(<a href=\"modelica://Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.ResetMinBypass\">
Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Processes.Subsequences.ResetMinBypass</a>).
</li>
</ol>
</html>", revisions="<html>
<ul>
<li>
September 23, 2019, by Jianjun Hu:<br/>
First implementation.
</li>
</ul>
</html>"));
end Down;
