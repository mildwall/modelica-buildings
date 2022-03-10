within Buildings.Templates.AirHandlersFans.Validation.UserProject.AirHandlersFans;
model VAVMultiZoneG36Pressure
  extends VAVMultiZoneOpenLoop(
    redeclare replaceable Components.Controls.G36VAVMultiZone
      ctl(typCtlFanRet=Buildings.Templates.AirHandlersFans.Types.ControlFanReturn.BuildingPressure,
      idZon={"Box_1","Box_1"}, namGroZon={"Floor_1","Floor_1"}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end VAVMultiZoneG36Pressure;
