class_name GalaxyFactory
extends RefCounted
## backend/GalaxyFactory.cs - the map, from sectors_data.json and planets_data.json,
## trimmed to the sectors the chosen galaxy size uses.


static func LoadGalaxy(sector_json_path: String, planet_json_path: String, size: int) -> Array[Sector]:
	var out: Array[Sector] = []
	if not FileAccess.file_exists(sector_json_path) or not FileAccess.file_exists(planet_json_path):
		push_error("CRITICAL: Galaxy JSON files are missing!")
		return out

	# STANDARD GALAXY: core + outer rim.
	var sectors := {
		"Corellian": true, "Sesswenna": true, "Sluis": true,
		"Calaron": true, "Churba": true, "Dufilvan": true, "Mayagil": true, "Moddell": true, "Orus": true, "Sumitra": true,
	}
	# LARGE GALAXY (+5)
	if size == Enums.GalaxySize.Large or size == Enums.GalaxySize.Huge:
		for n in ["Farfin", "Glythe", "Jospro", "Kanchen", "Quelli"]:
			sectors[n] = true
	# HUGE GALAXY (+5)
	if size == Enums.GalaxySize.Huge:
		for n in ["Dolomar", "Fakir", "Abrion", "Atrivis", "Xappyh"]:
			sectors[n] = true

	var sector_map: Dictionary = {}   # SectorId -> Sector, insertion order = file order
	for sr in Loaders._list(sector_json_path, CatalogDtos.SectorJsonData.from_dict):
		if not sectors.has(sr.Name):
			continue
		var s := Sector.new()
		s.SectorId = sr.SectorId
		s.Name = sr.Name
		s.GalaxyRing = sr.GalaxyRing
		s.StartsNeutral = sr.StartsNeutral
		s.MapX = sr.MapCenterX
		s.MapY = sr.MapCenterY
		sector_map[sr.SectorId] = s

	for pr in Loaders._list(planet_json_path, CatalogDtos.PlanetJsonData.from_dict):
		if not sector_map.has(pr.SectorId):
			continue
		var p := Planet.new()
		p.Name = pr.Name
		p.StartsInhabited = pr.StartsInhabited
		p.IsInhabited = pr.StartsInhabited
		# BaseEnergy and BaseRawMaterials are set by DayZeroGenerator.
		p.MapX = float(pr.MapX)
		p.MapY = float(pr.MapY)
		# The source does NOT set Planet.SectorId here; mirrored exactly (it is
		# what BombardmentManager.SectorPeers reads, so the omission is behaviour).
		sector_map[pr.SectorId].Planets.append(p)

	for s in sector_map.values():
		out.append(s)
	return out
