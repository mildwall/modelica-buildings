within Buildings.Applications.DHC.Examples.FifthGenUniSeries.Examples;
record DesignDataDHC "Record with design data for DHC system"
  extends Modelica.Icons.Record;
  parameter Modelica.SIunits.MassFlowRate mDisPip_flow_nominal
    "Distribution pipe flow rate";
  parameter Real RDisPip(unit="Pa/m")
    "Pressure drop per meter at m_flow_nominal";
  final parameter Modelica.SIunits.MassFlowRate mPla_flow_nominal = 11.45
    "Plant mass flow rate";
  parameter Real epsPla
    "Plant efficiency";
  final parameter Modelica.SIunits.MassFlowRate mSto_flow_nominal = 105
    "Storage mass flow rate";
  final parameter Modelica.SIunits.Temperature TLooMin = 273.15 + 6
    "Minimum loop temperature";
  final parameter Modelica.SIunits.Temperature TLooMax = 273.15 + 17
    "Maximum loop temperature";
  annotation (
    defaultComponentPrefix="datDes",
    defaultComponentPrefixes="inner");
end DesignDataDHC;
