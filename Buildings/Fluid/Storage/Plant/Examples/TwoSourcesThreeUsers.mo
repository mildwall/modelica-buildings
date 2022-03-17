within Buildings.Fluid.Storage.Plant.Examples;
model TwoSourcesThreeUsers
  "(Draft) District system model with two sources and three users"
  extends Modelica.Icons.Example;

  package MediumCHW = Buildings.Media.Water "Medium model for CHW";
  package MediumCDW1 = Buildings.Media.Water "Medium model for CDW of chi1";

  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal=1
    "Nominal mass flow rate";
  parameter Modelica.Units.SI.PressureDifference dp_nominal=500000
    "Nominal pressure difference";
  parameter Modelica.Units.SI.AbsolutePressure p_Pressurisation=300000
    "Pressurisation point";
  parameter Modelica.Units.SI.Temperature T_CHWR_nominal=12+273.15
    "Nominal temperature of CHW return";
  parameter Modelica.Units.SI.Temperature T_CHWS_nominal=7+273.15
    "Nominal temperature of CHW supply";
  parameter Modelica.Units.SI.Power QCooLoa_flow_nominal=5*4200*0.6
    "Nominal cooling load of one consumer";

// First source: chiller only
  Buildings.Fluid.Chillers.ElectricEIR chi1(
    redeclare final package Medium1 = MediumCDW1,
    redeclare final package Medium2 = MediumCHW,
    m1_flow_nominal=1.2*chi1.m2_flow_nominal,
    m2_flow_nominal=m_flow_nominal,
    final dp1_nominal=0,
    final dp2_nominal=0,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    p2_start=500000,
    T2_start=T_CHWS_nominal,
    final per=perChi1)
    "Water cooled chiller (ports indexed 1 are on condenser side)"
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=90,
        origin={-130,70})));
  parameter Buildings.Fluid.Chillers.Data.ElectricEIR.Generic perChi1(
    QEva_flow_nominal=-1E6,
    COP_nominal=3,
    PLRMax=1,
    PLRMinUnl=0.3,
    PLRMin=0.3,
    etaMotor=1,
    mEva_flow_nominal=0.7*m_flow_nominal,
    mCon_flow_nominal=1.2*perChi1.mEva_flow_nominal,
    TEvaLvg_nominal=280.15,
    capFunT={1,0,0,0,0,0},
    EIRFunT={1,0,0,0,0,0},
    EIRFunPLR={1,0,0},
    TEvaLvgMin=276.15,
    TEvaLvgMax=288.15,
    TConEnt_nominal=310.15,
    TConEntMin=303.15,
    TConEntMax=333.15) "Chiller performance data" annotation (
      choicesAllMatching=true, Placement(transformation(extent={{-180,120},{-160,
            140}})));
 Buildings.Fluid.Movers.SpeedControlled_y pumSup1(
    redeclare package Medium = MediumCHW,
    per(pressure(
          dp=dp_nominal*{2,1.2,0},
          V_flow=(1.5*m_flow_nominal)/1.2*{0,1.2,2})),
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    allowFlowReversal=true,
    addPowerToMedium=false,
    y_start=0,
    T_start=T_CHWR_nominal) "CHW supply pump for chi1"
                                                 annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-70,40})));
  Buildings.Fluid.FixedResistances.CheckValve cheValPumChi1(
    redeclare package Medium = MediumCHW,
    m_flow_nominal=chi1.m2_flow_nominal,
    dpValve_nominal=0.1*dp_nominal,
    dpFixed_nominal=0.1*dp_nominal) "Check valve" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-110,40})));
  Buildings.Controls.Continuous.LimPID conPI_pumChi1(
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    k=1,
    Ti=100,
    reverseActing=true) "PI controller" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={-10,110})));
  Modelica.Blocks.Sources.Constant set_TRet(k=12 + 273.15)
    "CHW return setpoint"
    annotation (Placement(transformation(extent={{20,100},{40,120}})));
  Buildings.Fluid.Sources.Boundary_pT sou_p(
    redeclare final package Medium = MediumCHW,
    final p=p_Pressurisation,
    final T=T_CHWR_nominal,
    nPorts=1) "Pressurisation point" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-170,10})));
  Buildings.Fluid.Sources.MassFlowSource_T souCDW1(
    redeclare package Medium = MediumCDW1,
    m_flow=1.2*chi1.m2_flow_nominal,
    T=305.15,
    nPorts=1) "Source representing CDW supply line" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-170,90})));
  Buildings.Fluid.Sources.Boundary_pT sinCDW1(
    redeclare final package Medium = MediumCDW1,
    final p=300000,
    final T=310.15,
    nPorts=1) "Sink representing CDW return line" annotation (Placement(
        transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={-170,50})));
  Modelica.Blocks.Sources.Constant TEvaLvgSet(k=T_CHWS_nominal)
    "Evaporator leaving temperature setpoint" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-90,130})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant on(k=true)
    "Placeholder, chiller always on"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-130,130})));

// Second source: chiller and tank
  Buildings.Fluid.Storage.Plant.TankBranch tanBra(
    redeclare final package Medium = MediumCHW,
    final m_flow_nominal=1.5*m_flow_nominal,
    final mTan_flow_nominal=0.75*m_flow_nominal,
    final dp_nominal=dp_nominal,
    final T_CHWS_nominal=T_CHWS_nominal,
    final T_CHWR_nominal=T_CHWR_nominal,
    final preDroTan(final dp_nominal=tanBra.dp_nominal*0.1),
    final valCha(final dpValve_nominal=tanBra.dp_nominal*0.1),
    final valDis(final dpValve_nominal=tanBra.dp_nominal*0.1),
    final cheVal(final dpValve_nominal=0.1*tanBra.dp_nominal,
                 final dpFixed_nominal=0.1*tanBra.dp_nominal))
    "Tank branch, tank can be charged remotely" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-70,-60})));
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.ChillerBranch chiBra2(
    redeclare final package Medium = MediumCHW,
    final m_flow_nominal=tanBra.m_flow_nominal - tanBra.mTan_flow_nominal,
    final dp_nominal=dp_nominal,
    final T_a_nominal=T_CHWR_nominal,
    final T_b_nominal=T_CHWS_nominal,
    final cheVal(final dpValve_nominal=0.1*chiBra2.dp_nominal,
                 final dpFixed_nominal=0.1*chiBra2.dp_nominal)) "Chiller branch"
    annotation (Placement(transformation(extent={{-80,-20},{-60,0}})));
  Modelica.Blocks.Sources.BooleanTable uRemCha(table={3600/9*6,3600/9*8},
      startValue=false) "Tank is being charged remotely" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-170,-70})));
  Modelica.Blocks.Sources.BooleanTable uTanDis(table={3600/9*1,3600/9*6,3600/9*
        8}, startValue=false)
    "True = discharging; false = charging (either local or remote)" annotation (
     Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-170,-110})));
  Buildings.Fluid.Storage.Plant.BaseClasses.ReversiblePumpValveControl conPumSecGro
                           "Control block for secondary pump-valve group"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-110,-58})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal mTanSet_flow(
    realTrue=0.75*m_flow_nominal,
    realFalse=-0.75*m_flow_nominal)
    "Set a positive flow rate when tank discharging and negative when charging"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-130,-90})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal mChiBra2Set_flow(
    realTrue=0, realFalse=chiBra2.m_flow_nominal)
    "Set the flow rate to a constant value whenever the tank is not being charged remotely"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-110,-10})));
  Buildings.Controls.OBC.CDL.Logical.Or or2 "Tank charging remotely OR there is load"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-100,-90})));

// Users
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.DummyUser usr1(
    redeclare package Medium = MediumCHW,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=0.7*dp_nominal,
    T_a_nominal=T_CHWS_nominal,
    T_b_nominal=T_CHWR_nominal) "Dummy user 1" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={60,60})));
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.DummyUser usr2(
    redeclare package Medium = MediumCHW,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=0.7*dp_nominal,
    T_a_nominal=T_CHWS_nominal,
    T_b_nominal=T_CHWR_nominal) "Dummy usr 2" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={60,0})));
  Buildings.Fluid.Storage.Plant.Examples.BaseClasses.DummyUser usr3(
    redeclare package Medium = MediumCHW,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=0.7*dp_nominal,
    T_a_nominal=T_CHWS_nominal,
    T_b_nominal=T_CHWR_nominal) "Dummy user 3" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={60,-60})));
  Buildings.Controls.OBC.CDL.Continuous.MultiMin mulMin_dpUsr(nin=3)
    "Min of pressure head measured from all users"
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=0,
        origin={70,130})));
  Modelica.Blocks.Sources.Constant set_dpUsr(k=1)
    "Normalised consumer differential pressure setpoint"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-50,130})));
  Buildings.Controls.OBC.CDL.Continuous.Hysteresis hysCat(uLow=0.05, uHigh=0.5)
    "Shut off at con.yVal = 0.05 and restarts at 0.5" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={10,-110})));
  Buildings.Controls.OBC.CDL.Continuous.MultiMax mulMax_yVal(nin=3)
    "Max of valve positions"
    annotation (Placement(transformation(extent={{60,-120},{40,-100}})));
  Modelica.Blocks.Sources.TimeTable set_QCooLoa1_flow(table=[0,0; 3600/9*1,0;
        3600/9*1,QCooLoa_flow_nominal; 3600/9*4,QCooLoa_flow_nominal; 3600/9*4,
        0; 3600,0])
    "Cooling load"
    annotation (Placement(transformation(extent={{120,80},{100,100}})));
  Modelica.Blocks.Sources.TimeTable set_QCooLoa2_flow(table=[0,0; 3600/9*2,0;
        3600/9*2,QCooLoa_flow_nominal; 3600/9*5,QCooLoa_flow_nominal; 3600/9*5,
        0; 3600,0])
    "Cooling load"
    annotation (Placement(transformation(extent={{120,20},{100,40}})));
  Modelica.Blocks.Sources.TimeTable set_QCooLoa3_flow(table=[0,0; 3600/9*3,0;
        3600/9*3,QCooLoa_flow_nominal; 3600/9*7,QCooLoa_flow_nominal; 3600/9*7,
        0; 3600,0])                                       "Cooling load"
    annotation (Placement(transformation(extent={{120,-40},{100,-20}})));
  Modelica.Blocks.Math.Gain gaiUsr1(k=1/usr1.dp_nominal)
    "Gain to normalise dp measurement" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={110,60})));
  Modelica.Blocks.Math.Gain gaiUsr2(k=1/usr2.dp_nominal)
    "Gain to normalise dp measurement" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={110,0})));
  Modelica.Blocks.Math.Gain gaiUsr3(k=1/usr3.dp_nominal)
    "Gain to normalise dp measurement" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={110,-60})));

// District pipe network
  Buildings.Fluid.FixedResistances.PressureDrop preDroS2U3(
    redeclare package Medium = MediumCHW,
    final allowFlowReversal=true,
    final dp_nominal=0.3*dp_nominal,
    final m_flow_nominal=m_flow_nominal) "Flow resistance source 2 to user 3"
    annotation (Placement(transformation(extent={{-30,-50},{-10,-30}})));
  Buildings.Fluid.FixedResistances.PressureDrop preDroU3S2(
    redeclare package Medium = MediumCHW,
    final allowFlowReversal=true,
    final dp_nominal=0.3*dp_nominal,
    final m_flow_nominal=m_flow_nominal) "Flow resistance user 3 to source 2"
    annotation (Placement(transformation(extent={{30,-90},{10,-70}})));
  Buildings.Fluid.FixedResistances.PressureDrop preDroS2U2(
    redeclare package Medium = MediumCHW,
    final allowFlowReversal=true,
    final dp_nominal=0.3*dp_nominal,
    final m_flow_nominal=m_flow_nominal) "Flow resistance source 2 to user 2"
    annotation (Placement(transformation(extent={{-30,-10},{-10,10}})));
  Buildings.Fluid.FixedResistances.PressureDrop preDroU2S2(
    redeclare package Medium = MediumCHW,
    final allowFlowReversal=true,
    final dp_nominal=0.3*dp_nominal,
    final m_flow_nominal=m_flow_nominal) "Flow resistance user 2 to source 2"
    annotation (Placement(transformation(extent={{30,-30},{10,-10}})));
  Buildings.Fluid.FixedResistances.PressureDrop preDroS1U2(
    redeclare package Medium = MediumCHW,
    final allowFlowReversal=true,
    final dp_nominal=0.3*dp_nominal,
    final m_flow_nominal=m_flow_nominal) "Flow resistance source 1 to user 2"
    annotation (Placement(transformation(extent={{-30,10},{-10,30}})));
  Buildings.Fluid.FixedResistances.PressureDrop preDroU2S1(
    redeclare package Medium = MediumCHW,
    final allowFlowReversal=true,
    final dp_nominal=0.3*dp_nominal,
    final m_flow_nominal=m_flow_nominal) "Flow resistance user 2 to source 1"
    annotation (Placement(transformation(extent={{30,-10},{10,10}})));
  Buildings.Fluid.FixedResistances.PressureDrop preDroS1U1(
    redeclare package Medium = MediumCHW,
    final allowFlowReversal=true,
    final dp_nominal=0.3*dp_nominal,
    final m_flow_nominal=m_flow_nominal) "Flow resistance source 1 to user 3"
    annotation (Placement(transformation(extent={{-30,70},{-10,90}})));
  Buildings.Fluid.FixedResistances.PressureDrop preDroU1S1(
    redeclare package Medium = MediumCHW,
    final allowFlowReversal=true,
    final dp_nominal=0.3*dp_nominal,
    final m_flow_nominal=m_flow_nominal) "Flow resistance user 1 to source 1"
    annotation (Placement(transformation(extent={{30,30},{10,50}})));

equation
  connect(set_TRet.y,usr1. TSet) annotation (Line(points={{41,110},{44,110},{44,
          82},{64,82},{64,71}}, color={0,0,127}));
  connect(set_TRet.y,usr2. TSet) annotation (Line(points={{41,110},{44,110},{44,
          22},{64,22},{64,11}}, color={0,0,127}));
  connect(set_TRet.y,usr3. TSet) annotation (Line(points={{41,110},{44,110},{44,
          -38},{64,-38},{64,-49}}, color={0,0,127}));
  connect(usr3.yVal_actual, mulMax_yVal.u[1]) annotation (Line(points={{71,-54},
          {86,-54},{86,-110},{74,-110},{74,-110.667},{62,-110.667}}, color={0,0,
          127}));
  connect(usr2.yVal_actual, mulMax_yVal.u[2]) annotation (Line(points={{71,6},{86,
          6},{86,-110},{62,-110}}, color={0,0,127}));
  connect(mulMax_yVal.y, hysCat.u)
    annotation (Line(points={{38,-110},{22,-110}}, color={0,0,127}));
  connect(set_dpUsr.y,conPI_pumChi1. u_s)
    annotation (Line(points={{-39,130},{-10,130},{-10,122}},
                                                   color={0,0,127}));
  connect(usr1.yVal_actual, mulMax_yVal.u[3]) annotation (Line(points={{71,66},
          {86,66},{86,-110},{62,-110},{62,-109.333}},color={0,0,127}));
  connect(preDroS2U3.port_b,usr3. port_a)
    annotation (Line(points={{-10,-40},{60,-40},{60,-50}}, color={0,127,255}));
  connect(usr3.port_b,preDroU3S2. port_a)
    annotation (Line(points={{60,-70},{60,-80},{30,-80}}, color={0,127,255}));
  connect(preDroS2U2.port_b,usr2. port_a) annotation (Line(points={{-10,0},{-4,
          0},{-4,20},{60,20},{60,10}},
                            color={0,127,255}));
  connect(usr2.port_b,preDroU2S2. port_a)
    annotation (Line(points={{60,-10},{60,-20},{30,-20}}, color={0,127,255}));
  connect(preDroS1U2.port_b,usr2. port_a) annotation (Line(points={{-10,20},{60,
          20},{60,10}},         color={0,127,255}));
  connect(usr2.port_b,preDroU2S1. port_a) annotation (Line(points={{60,-10},{60,
          -20},{34,-20},{34,0},{30,0}}, color={0,127,255}));
  connect(preDroS1U1.port_b,usr1. port_a)
    annotation (Line(points={{-10,80},{60,80},{60,70}}, color={0,127,255}));
  connect(usr1.port_b,preDroU1S1. port_a)
    annotation (Line(points={{60,50},{60,40},{30,40}}, color={0,127,255}));
  connect(set_QCooLoa1_flow.y,usr1. QCooLoa_flow)
    annotation (Line(points={{99,90},{68,90},{68,71}}, color={0,0,127}));
  connect(set_QCooLoa2_flow.y,usr2. QCooLoa_flow)
    annotation (Line(points={{99,30},{68,30},{68,11}}, color={0,0,127}));
  connect(set_QCooLoa3_flow.y,usr3. QCooLoa_flow)
    annotation (Line(points={{99,-30},{68,-30},{68,-49}}, color={0,0,127}));
  connect(usr1.dpUsr, gaiUsr1.u)
    annotation (Line(points={{71,62},{71,60},{98,60}}, color={0,0,127}));
  connect(usr2.dpUsr, gaiUsr2.u) annotation (Line(points={{71,2},{71,1.55431e-15},
          {98,1.55431e-15}}, color={0,0,127}));
  connect(usr3.dpUsr, gaiUsr3.u) annotation (Line(points={{71,-58},{72,-58},{72,
          -60},{98,-60}}, color={0,0,127}));
  connect(gaiUsr1.y,mulMin_dpUsr. u[1]) annotation (Line(points={{121,60},{126,
          60},{126,129.333},{82,129.333}},
                                     color={0,0,127}));
  connect(gaiUsr2.y,mulMin_dpUsr. u[2]) annotation (Line(points={{121,-1.38778e-15},
          {126,-1.38778e-15},{126,130},{82,130}},  color={0,0,127}));
  connect(gaiUsr3.y,mulMin_dpUsr. u[3]) annotation (Line(points={{121,-60},{126,
          -60},{126,130.667},{82,130.667}},
                                          color={0,0,127}));
  connect(mulMin_dpUsr.y,conPI_pumChi1. u_m)
    annotation (Line(points={{58,130},{8,130},{8,110},{2,110}},
                                                             color={0,0,127}));
  connect(preDroU3S2.port_b, tanBra.port_1) annotation (Line(points={{10,-80},{
          -80,-80},{-80,-66}}, color={0,127,255}));
  connect(preDroU2S2.port_b, tanBra.port_1) annotation (Line(points={{10,-20},{
          -4,-20},{-4,-80},{-80,-80},{-80,-66}}, color={0,127,255}));
  connect(tanBra.port_2, preDroS2U3.port_a) annotation (Line(points={{-60,-66},
          {-36,-66},{-36,-40},{-30,-40}}, color={0,127,255}));
  connect(tanBra.port_2, preDroS2U2.port_a) annotation (Line(points={{-60,-66},
          {-36,-66},{-36,0},{-30,0}}, color={0,127,255}));
  connect(conPumSecGro.yValDis, tanBra.yValDis)
    annotation (Line(points={{-99,-50},{-81,-50}}, color={0,0,127}));
  connect(conPumSecGro.yValCha, tanBra.yValCha)
    annotation (Line(points={{-99,-54},{-81,-54}}, color={0,0,127}));
  connect(conPumSecGro.yPumSec, tanBra.yPum)
    annotation (Line(points={{-99,-58},{-81,-58}}, color={0,0,127}));
  connect(uRemCha.y, conPumSecGro.uRemCha) annotation (Line(points={{-159,-70},{
          -118,-70}},                                   color={255,0,255}));
  connect(tanBra.yValDis_actual, conPumSecGro.yValDis_actual) annotation (Line(
        points={{-59,-50},{-56,-50},{-56,-40},{-126,-40},{-126,-50},{-121,-50}},
        color={0,0,127}));
  connect(tanBra.yValCha_actual, conPumSecGro.yValCha_actual) annotation (Line(
        points={{-59,-54},{-52,-54},{-52,-36},{-130,-36},{-130,-54},{-121,-54}},
        color={0,0,127}));
  connect(tanBra.mTan_flow, conPumSecGro.mTan_flow) annotation (Line(points={{-59,
          -58},{-48,-58},{-48,-32},{-134,-32},{-134,-58},{-121,-58}}, color={0,
          0,127}));
  connect(uTanDis.y, mTanSet_flow.u) annotation (Line(points={{-159,-110},{-130,
          -110},{-130,-102}}, color={255,0,255}));
  connect(mTanSet_flow.y, conPumSecGro.mTanSet_flow) annotation (Line(points={{-130,
          -78},{-130,-62},{-121,-62}}, color={0,0,127}));
  connect(mChiBra2Set_flow.u, uRemCha.y) annotation (Line(points={{-122,-10},{-148,
          -10},{-148,-70},{-159,-70}},
                            color={255,0,255}));
  connect(tanBra.port_3, chiBra2.port_a) annotation (Line(points={{-74,-50},{-74,
          -26},{-86,-26},{-86,-10},{-80,-10}}, color={0,127,255}));
  connect(tanBra.port_4, chiBra2.port_b) annotation (Line(points={{-66,-49.8},{
          -66,-26},{-54,-26},{-54,-10},{-60,-10}}, color={0,127,255}));
  connect(chiBra2.mPumSet_flow,mChiBra2Set_flow. y)
    annotation (Line(points={{-81,-6},{-92,-6},{-92,-10},{-98,-10}},
                                                             color={0,0,127}));
  connect(conPI_pumChi1.y,pumSup1. y) annotation (Line(points={{-10,99},{-10,94},
          {-42,94},{-42,58},{-70,58},{-70,52}},
                           color={0,0,127}));
  connect(preDroU1S1.port_b, pumSup1.port_a)
    annotation (Line(points={{10,40},{-60,40}}, color={0,127,255}));
  connect(preDroU2S1.port_b, pumSup1.port_a) annotation (Line(points={{10,0},{4,
          0},{4,40},{-60,40}}, color={0,127,255}));
  connect(pumSup1.port_b, cheValPumChi1.port_a)
    annotation (Line(points={{-80,40},{-100,40}}, color={0,127,255}));
  connect(sou_p.ports[1], pumSup1.port_a) annotation (Line(points={{-160,10},{-54,
          10},{-54,40},{-60,40}}, color={0,127,255}));
  connect(cheValPumChi1.port_b, chi1.port_a2) annotation (Line(points={{-120,40},
          {-124,40},{-124,60}},           color={0,127,255}));
  connect(chi1.port_b2, preDroS1U1.port_a) annotation (Line(points={{-124,80},{
          -30,80}},      color={0,127,255}));
  connect(souCDW1.ports[1], chi1.port_a1) annotation (Line(points={{-160,90},{
          -136,90},{-136,80}},                  color={0,127,255}));
  connect(chi1.port_b1, sinCDW1.ports[1]) annotation (Line(points={{-136,60},{
          -136,50},{-160,50}},      color={0,127,255}));
  connect(TEvaLvgSet.y, chi1.TSet)
    annotation (Line(points={{-90,119},{-90,88},{-127,88},{-127,82}},
                                                           color={0,0,127}));
  connect(on.y, chi1.on) annotation (Line(points={{-130,118},{-133,118},{-133,
          82}},     color={255,0,255}));
  connect(preDroS1U2.port_a, chi1.port_b2) annotation (Line(points={{-30,20},{-36,
          20},{-36,80},{-124,80}}, color={0,127,255}));
  connect(uRemCha.y, or2.u1) annotation (Line(points={{-159,-70},{-118,-70},{-118,
          -110},{-100,-110},{-100,-102}}, color={255,0,255}));
  connect(conPumSecGro.uOnl, or2.y) annotation (Line(points={{-114,-70},{-114,-74},
          {-100,-74},{-100,-78}}, color={255,0,255}));
  connect(hysCat.y, or2.u2) annotation (Line(points={{-2,-110},{-92,-110},{-92,-102}},
        color={255,0,255}));
  annotation (__Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Fluid/Storage/Plant/Examples/TwoSourcesThreeUsers.mos"
        "Simulate and plot"),
        experiment(Tolerance=1e-06, StopTime=3600,__Dymola_Algorithm="Dassl"),
        Diagram(coordinateSystem(extent={{-180,-120},{140,140}})), Icon(
        coordinateSystem(extent={{-100,-100},{100,100}})),
    Documentation(info="<html>
<p>
(Draft)
This is a district system model with two CHW sources and three users
as described in
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2859\">#2859</a>.
</p>
<p>
The first source is a simplified CHW plant with only a chiller,
a single supply pump, and a check valve (with series resistance built in).
This supply pump is controlled to ensure that all users have enough pressure head.
The system is pressurised before this supply pump.
</p>
<p>
The second source has a chiller and a stratified CHW tank. Its piping is arranged
in a way that allows the tank to be charged remotely by the other source.
Its supply pump is controlled to maintain the flow rate setpoint of the tank.
This plant is offline when the most open control valve of all users is less than
5% open and is back online when this value is more than 50%.
</p>
<p>
The timetables give the system the following behaviour:
</p>
<table summary= \"system modes\" border=\"1\" cellspacing=\"0\" cellpadding=\"2\">
<thead>
  <tr>
    <th>Time slots</th>
    <th>1</th>
    <th>2</th>
    <th>3</th>
    <th>4</th>
    <th>5</th>
    <th>6</th>
    <th>7</th>
    <th>8</th>
    <th>9</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td>User 1</td>
    <td>-</td>
    <td>Has load</td>
    <td>Has load</td>
    <td>Has load</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
  </tr>
  <tr>
    <td>User 2</td>
    <td>-</td>
    <td>-</td>
    <td>Has load</td>
    <td>Has load</td>
    <td>Has load</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
  </tr>
  <tr>
    <td>User 3</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>Has load</td>
    <td>Has load</td>
    <td>Has load</td>
    <td>Has load</td>
    <td>-</td>
    <td>-</td>
  </tr>
  <tr>
    <td>Tank <br>(being charged)</td>
    <td>Local</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>Remote</td>
    <td>Remote</td>
    <td>-</td>
  </tr>
</tbody>
</table>
</html>", revisions="<html>
<ul>
<li>
February 18, 2022 by Hongxiang Fu:<br/>
First implementation. This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2859\">#2859</a>.
</li>
</ul>
</html>"));
end TwoSourcesThreeUsers;
