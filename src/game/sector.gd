class_name Sector
extends RefCounted
## backend/Sector.cs

var SectorId: int
var Name: String
var GalaxyRing: int
var StartsNeutral: bool
var MapX: int
var MapY: int
var MinX: float
var MaxX: float
var MinY: float
var MaxY: float

var Planets: Array[Planet] = []
