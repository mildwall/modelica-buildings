within Buildings.Templates.ChilledWaterPlants;
model WaterCooled "Water-cooled chiller plant"
  extends
    Buildings.Templates.ChilledWaterPlants.Interfaces.PartialChilledWaterLoop(
    redeclare replaceable package MediumCon=Buildings.Media.Water,
    final typChi=Buildings.Templates.Components.Types.Chiller.WaterCooled,
    final typCoo=coo.typCoo,
    final typValCooInlIso=coo.typValCooInlIso,
    final typValCooOutIso=coo.typValCooOutIso);

  // Coolers
  replaceable Buildings.Templates.ChilledWaterPlants.Components.CoolerGroups.CoolingTowerOpen
    coo constrainedby
    Buildings.Templates.ChilledWaterPlants.Components.Interfaces.PartialCoolerGroup(
    redeclare final package MediumConWat = MediumCon,
    final have_varCom=true,
    final nCoo=nCoo,
    final dat=dat.coo,
    final energyDynamics=energyDynamics,
    final tau=tau,
    final allowFlowReversal=allowFlowReversal,
    final text_flip=true)
    "Coolers"
    annotation (Dialog(group="Coolers"), Placement(transformation(extent={{-118,34},
            {-282,94}})));

  // CW loop
  Buildings.Templates.Components.Routing.SingleToMultiple inlPumConWat(
    redeclare final package Medium=MediumCon,
    final nPorts=nPumConWat,
    final m_flow_nominal=mCon_flow_nominal,
    final energyDynamics=energyDynamics,
    final tau=tau,
    final allowFlowReversal=allowFlowReversal,
    icon_dy=intChi.icon_dy,
    icon_pipe=Buildings.Templates.Components.Types.IconPipe.Supply)
    "CW pumps inlet manifold"
    annotation (Placement(transformation(extent={{-110,-202},{-90,-182}})));
  Buildings.Templates.Components.Pumps.Multiple pumConWat(
    redeclare final package Medium=MediumCon,
    final nPum=nPumConWat,
    final have_var=have_varPumConWat,
    final have_varCom=have_varComPumConWat,
    final dat=dat.pumConWat,
    final energyDynamics=energyDynamics,
    final allowFlowReversal=allowFlowReversal,
    icon_dy=intChi.icon_dy)
    "CW pumps"
    annotation (Placement(transformation(extent={{-90,-202},{-70,-182}})));
  Fluid.Sources.Boundary_pT bouConWat(
    redeclare final package Medium = MediumCon,
    p=200000,
    nPorts=1)
    "CW pressure boundary condition"
    annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=-90,
        origin={-100,-250})));
  Buildings.Templates.Components.Sensors.Temperature TConWatRet(
    redeclare final package Medium = MediumCon,
    final m_flow_nominal=mCon_flow_nominal,
    final typ=Buildings.Templates.Components.Types.SensorTemperature.InWell,
    icon_pipe=Buildings.Templates.Components.Types.IconPipe.Return)
    "CW return temperature (from chillers to coolers)" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-80,40})));
  Buildings.Templates.Components.Sensors.Temperature TConWatSup(
    redeclare final package Medium = MediumCon,
    final m_flow_nominal=mCon_flow_nominal,
    final typ=Buildings.Templates.Components.Types.SensorTemperature.InWell,
    icon_pipe=Buildings.Templates.Components.Types.IconPipe.Supply)
    "CW supply temperature (from coolers to chillers)"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-160,-192})));

equation
  /* Control point connection - start */
  connect(bus, coo.bus);
  connect(bus.pumConWat, pumConWat.bus);
  connect(TConWatRet.y, bus.TConWatSup);
  connect(TConWatSup.y, bus.TConWatRet);
  /* Control point connection - stop */
  connect(inlPumConWat.ports_b, pumConWat.ports_a)
    annotation (Line(
      points={{-90,-192},{-90,-192}},
      color={0,0,0},
      thickness=0.5));
  connect(busWea, coo.busWea) annotation (Line(
      points={{0,280},{-170,280},{-170,94}},
      color={255,204,51},
      thickness=0.5));
  connect(inlPumConWat.port_a, bouConWat.ports[1])
    annotation (Line(
      points={{-110,-192},{-110,-212},{-100,-212},{-100,-240}},
      color={0,127,255},
      visible=viewDiagramAll));
  connect(pumConWat.ports_b, inlConChi.ports_a)
    annotation (Line(
      points={{-70,-192},{-70,-192}},
      color={0,0,0},
      thickness=0.5));
  connect(outConChi.port_b, TConWatRet.port_b) annotation (Line(
      points={{-60,0},{-60,40},{-70,40}},
      color={0,0,0},
      thickness=0.5,
      pattern=LinePattern.Dash));
  connect(TConWatRet.port_a, coo.port_a) annotation (Line(
      points={{-90,40},{-118,40}},
      color={0,0,0},
      thickness=0.5,
      pattern=LinePattern.Dash));
  connect(coo.port_b,TConWatSup. port_b) annotation (Line(points={{-200,34},{
          -200,-192},{-170,-192}},           color={0,0,0},
      thickness=0.5));
  connect(TConWatSup.port_a, inlPumConWat.port_a)
    annotation (Line(points={{-150,-192},{-110,-192}}, color={0,0,0},
      thickness=0.5));
  annotation (Documentation(info="<html>
<p>
This template represents a chilled water plant with water-cooled compression chillers.
</p>
<p>
The possible equipment configurations are enumerated in the table below where
the first option displayed in bold characters corresponds to the default configuration.
The user may refer to ASHRAE (2021) for further details.
</p>
<table summary=\"summary\" border=\"1\">
<tr><th>Configuration parameter</th><th>Options</th><th>Notes</th></tr>
<tr><td>Chiller arrangement</td>
<td>
<b>Parallel chillers</b><br/>
Series chillers
</td>
<td></td>
</tr>
<tr><td>Chiller head pressure control</td>
<td>
No head pressure control (e.g. magnetic bearing chiller)<br/>
Head pressure control built into chiller’s controller (AO available)<br/>
Head pressure control by BAS
</td>
<td>No default option is provided: the user must select the suitable
option.<br/>
Currently, the template ony supports plant configurations where
all chillers have the same head pressure control.
</td>
</tr>
<tr><td>Chiller CHW isolation valve</td>
<td>
No valve<br/>
Two-way modulating valve<br/>
Two-way two-position valve
</td>
<td>
If the primary CHW pumps are dedicated, the option with no isolation valve
is automatically selected.<br/>
If the primary CHW pumps are headered, the choice between
two-way modulating valves and two-way two-position valves is possible.
A modulating valve is recommended on primary-only variable flow systems
to allow for slow changes in flow during chiller staging.
Sometimes electric valve timing may be sufficiently slow that two-position
valves can provide stable performance.
Two-position valves are acceptable on primary-secondary systems.
</td>
</tr>
<tr><td>Chiller CW isolation valve</td>
<td>
No valve<br/>
Two-way modulating valve<br/>
Two-way modulating valve
</td>
<td>
If the CW pumps are dedicated, the option with no isolation valve
is automatically selected.<br/>
<p style=\"color:#FF0000\">
This raises the question of chiller head pressure control
in case of constant speed CW pumps that are dedicated.<br/>
</p>
CW isolation valves may be two-position for chillers that do not require
head pressure control or for plants with variable speed condenser
pumps but no waterside economizer.
</td>
</tr>
<tr><td>CHW distribution</td>
<td>
<b>Variable primary-only</b><br/>
Constant primary-only<br/>
Constant primary-variable secondary<br/>
Variable primary-variable secondary with centralized secondary pumps<br/>
Variable primary-variable secondary with distributed secondary pumps
</td>
<td>
Constant primary-only systems are typically encountered when
only one or two very large air handlers are served by the plant.<br/>
Variable primary-variable secondary with centralized secondary pumps
refers to configurations with a single group of secondary pumps that
is typically integrated into the plant.<br/>
Variable secondary with distributed secondary pumps refers to configurations
with multiple secondary loops, each loop being served by a dedicated group
of secondary pumps.
</td>
</tr>
<tr><td>Primary CHW pump arrangement</td>
<td>
<b>Headered</b><br/>
Dedicated
</td>
<td>
Headered pumps are required (and automatically selected) for configurations with
<ul>
<li>series chillers, or</li>
<li>waterside economizer.</li>
</ul>
</td>
</tr>
<tr><td>Type of primary CHW pumps for constant flow configurations</td>
<td>
<b>Constant speed pumps</b><br/>
Variable speed pumps operated at a constant speed
</td>
<td>
Variable speed pumps operated at a constant speed most commonly applies
to constant flow primary-only plants, for example, a plant serving
only one or two very large air handlers.
</td>
</tr>
<tr><td>Coolers</td>
<td>
<b>Open-circuit cooling towers in parallel</b>
</td>
<td>
Currently, only open-circuit cooling towers in parallel are supported.
</td>
</tr>
<tr><td>Cooler inlet and outlet isolation valves</td>
<td>
<b>Two-way two-position valve</b><br/>
No valve
</td>
<td>
</td>
</tr>
<tr><td>CW pump arrangement</td>
<td>
<b>Headered</b><br/>
Dedicated
</td>
<td>
Headered pumps are required (and automatically selected) for configurations with
waterside economizer.
</td>
</tr>
<tr>
<td>Type of CW pumps</td>
<td>
<b>Constant speed pumps</b><br/>
Variable speed pumps
</td>
<td>
Variable speed pumps are required (and automatically selected) for configurations with
waterside economizer.
</td>
</tr>
<tr><td>Waterside economizer</td>
<td>
<b>No waterside economizer</b><br/>
Heat exchanger with pump for CHW flow control<br/>
Heat exchanger with bypass valve for CHW flow control
</td>
<td></td>
</tr>
<tr><td>Controller</td>
<td>
<b>ASHRAE Guideline 36 controller</b>
</td>
<td>An open loop controller is also available for validation purposes only.</td>
</tr>
</table>
<h4>References</h4>
<ul>
<li id=\"ASHRAE2021\">
ASHRAE, 2021. Guideline 36-2021, High-Performance Sequences of Operation
for HVAC Systems. Atlanta, GA.
</li>
</ul>
</html>", revisions="<html>
<ul>
<li>
November 18, 2022, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>"));
end WaterCooled;
