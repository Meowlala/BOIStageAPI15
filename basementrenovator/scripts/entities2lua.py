"""
Converts an entities2.xml to a lua table
"""
from pathlib import Path
import xml.etree.cElementTree as ET
import sys

ATTRIB_MAP = {
    "name": "Name",
    "anm2path": "Anm2",
    "baseHP": "HP",
    "stageHP": "StageHP",
    "boss": "Boss",
    "champion": "Champion",
    "collisionDamage": "CollisionDamage",
    "collisionMass": "CollisionMass",
    "collisionRadius": "CollisionRadius",
    "friction": "Friction",
    "shadowSize": "ShadowSize",
    "numGridCollisionPoints": "NumGridCollisionPoints",
    "id": "Type",
    "variant": "Variant",
    "subtype": "Subtype",
    "tags": "Tags",
    "gridCollision": "GridCollision",
    "hasFloorAlts": "HasFloorAlts",
    "collisionRadiusXMulti": "CollisionRadiusXMulti",
    "collisionRadiusYMulti": "CollisionRadiusYMulti",
    "shutdoors": "ShutDoors",
    "shieldStrength": "ShieldStrength",
    "portrait": "Portrait",
}

ATTRIB_DEFAULTS = {
    "boss": "0",
    "champion": "0",
    "baseHP": "0",
    "stageHP": "0",
    "collisionDamage": "0",
    "collisionMass": "0",
    "collisionRadius": "0",
    "friction": "1",
    "shadowSize": "0",
    "numGridCollisionPoints": "1",
    "variant": "0",
    "subtype": "0",
}

BOOLEAN_ATTRIBS = {
    "boss": True,
    "champion": True,
    "hasFloorAlts": True,
    "shutdoors": True,
}


def main():
    if len(sys.argv) < 2:
        input("Requires entities2.xml file as an argument!")
        return

    path = sys.argv[1]
    if not path:
        input("Must specify entities2.xml!")
        return

    path = Path(path)
    if path.suffix != ".xml":
        input("File must be xml!")
        return

    print(path)

    tree = ET.parse(path)
    root = tree.getroot()

    entitytable = "{"
    nametable = "{"
    idmaptable = "{"

    taken_names = {}

    entities_by_id = {}

    entityTableIndex = 1

    for child in root:
        entitytable += "{"
        for key in ATTRIB_MAP.keys():
            if child.attrib.get(key) != None:
                value = child.attrib.get(key)
                if (
                    ATTRIB_DEFAULTS.get(key) == value
                ):  # Cut down on file size by ignoring default values
                    continue

                tblprop = ""

                if value.isnumeric():
                    if BOOLEAN_ATTRIBS.get(key) == True:
                        tblprop = "true" if value == "1" else "false"
                    else:
                        tblprop = value
                else:
                    value = value.replace("\\", "\\\\")
                    value = value.replace('"', '\\"')
                    tblprop = '"' + value + '"'

                entitytable += ATTRIB_MAP[key] + "=" + tblprop + ","

        entitytable += "},"

        name = child.attrib.get("name")
        if name != None:
            if taken_names.get(name) == None:
                taken_names[name] = True
                nametable += '["' + name + '"]=entities[' + str(entityTableIndex) + "],"

        if child.attrib.get("id") != None:
            typ, var, sub = (
                child.attrib.get("id"),
                child.attrib.get("variant", "0"),
                child.attrib.get("subtype", "0"),
            )
            if entities_by_id.get(typ) == None:
                entities_by_id[typ] = {}

            if entities_by_id[typ].get(var) == None:
                entities_by_id[typ][var] = {}

            entities_by_id[typ][var][sub] = entityTableIndex

        entityTableIndex += 1

    for id in entities_by_id.keys():
        idtable = "[" + id + "]={"
        for var in entities_by_id[id].keys():
            idtable += "[" + var + "]={"
            for sub in entities_by_id[id][var].keys():
                idtable += (
                    "[" + sub + "]=entities[" + str(entities_by_id[id][var][sub]) + "],"
                )

            idtable += "},"

        idmaptable += idtable + "},"

    entitytable += "}"
    nametable += "}"
    idmaptable += "}"

    outfile = f"""---@diagnostic disable
return function(mode)
    local entities = {entitytable}
    if not mode or mode == 1 then
        return entities
    elseif mode == 2 then
        return {nametable}
    elseif mode == 3 then
        return {idmaptable}
    end    
end"""

    with open(path.with_suffix(".lua"), "w") as out:
        out.write(outfile)

    input("Successfully parsed entities2.xml.")


if __name__ == "__main__":
    main()
