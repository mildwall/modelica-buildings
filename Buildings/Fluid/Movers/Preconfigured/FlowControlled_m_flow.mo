within Buildings.Fluid.Movers.Preconfigured;
model FlowControlled_m_flow "FlowControlled_m_flow with pre-filled parameters"
  extends Buildings.Fluid.Movers.FlowControlled_m_flow(
    final per(
            PowerOrEfficiencyIsHydraulic=true,
            etaHydMet=Buildings.Fluid.Movers.BaseClasses.Types.HydraulicEfficiencyMethod.EulerNumber,
            etaMotMet=Buildings.Fluid.Movers.BaseClasses.Types.MotorEfficiencyMethod.GenericCurve),
    final constantMassFlowRate,
    final massFlowRates,
    final addPowerToMedium=false,
    final nominalValuesDefineDefaultPressureCurve=true,
    final inputType=Buildings.Fluid.Types.InputType.Continuous,
    final energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial);
annotation(Documentation(info="<html>
<p>
This model is the preconfigured version for
<a href=\"Modelica://Buildings.Fluid.Movers.FlowControlled_m_flow\">
Buildings.Fluid.Movers.FlowControlled_m_flow</a>.
It automatically configures a mover model based on
<code>m_flow_nominal</code> and <code>dp_nominal</code>
provided by the user and no other input is allowed.
</p>
</html>", revisions="<html>
<ul>
<li>
August 17, 2022, by Hongxiang Fu:<br/>
First implementation. This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2668\">#2668</a>.
</li>
</ul>
</html>"));
end FlowControlled_m_flow;
