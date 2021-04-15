within Buildings.Templates.BaseClasses.Controls.AHUs;
partial block SingleDuct "Base class for controllers of single duct AHU"
  extends Templates.Interfaces.ControllerAHU;

  outer replaceable Templates.Interfaces.OutdoorReliefReturnSection secOutRel
    "Outdoor/relief/return air section";

  outer replaceable Templates.BaseClasses.Coils.None coiCoo
    "Cooling coil";
  outer replaceable Templates.BaseClasses.Coils.None coiHea
    "Heating coil";
  outer replaceable Templates.BaseClasses.Coils.None coiReh
    "Reheat coil";

  outer replaceable Templates.BaseClasses.Fans.None fanSupDra
    "Supply fan - Draw through";
  outer replaceable Templates.BaseClasses.Fans.None fanSupBlo
    "Supply fan - Blow through";

  final inner parameter Templates.Types.Fan typFanSup=
    if fanSupDra.typ <> Templates.Types.Fan.None then fanSupDra.typ
    elseif fanSupBlo.typ <> Templates.Types.Fan.None then fanSupBlo.typ
    else Templates.Types.Fan.None
    "Type of supply fan"
    annotation (Evaluate=true);
  final inner parameter Templates.Types.Fan typFanRet = secOutRel.secRel.typFan
    "Type of return fan"
    annotation (Evaluate=true);

end SingleDuct;
