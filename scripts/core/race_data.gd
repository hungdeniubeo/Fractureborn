extends RefCounted
class_name RaceData

enum Race { HUMAN, DRAGON, BEAST, ANGEL, DEMON }

const RACE_IDS: Array[StringName] = [
	&"HUMAN",
	&"DRAGON",
	&"BEAST",
	&"ANGEL",
	&"DEMON",
]


static func is_defined(race_id: StringName) -> bool:
	return RACE_IDS.has(race_id)


static func is_playable(race_id: StringName) -> bool:
	return race_id == &"HUMAN"


static func playable_races() -> Array[StringName]:
	return [&"HUMAN"]
