class_name AudioPlayer extends AudioStreamPlayer
static var tracks = { 
	"ENCOUNTER" : "res://Battle/SFX/55_Encounter_02.wav",
	"JOURNEY_BEGINS" : "res://Music/And The Journey Begins/xDeviruchi - And The Journey Begins (Loop).wav",
	"BATTLE_END" : "res://Music/Decisive Battle/xDeviruchi - Decisive Battle (End).wav",
	"BATTLE_LOOP" : "res://Music/Decisive Battle/xDeviruchi - Decisive Battle (Loop).wav",
	"OVERWORLD" : "res://Music/Exploring The Unknown/xDeviruchi - Exploring The Unknown (Loop).wav",
	"MINIGAME" : "res://Music/Minigame/xDeviruchi - Minigame (Loop).wav",
	"BATTLE_2_END" : "res://Music/Prepare for Battle!/xDeviruchi - Prepare for Battle! (End).wav",
	"BATTLE_2_INTRO" : "res://Music/Prepare for Battle!/xDeviruchi - Prepare for Battle! (Intro).wav",
	"BATTLE_2_LOOP" : "res://Music/Prepare for Battle!/xDeviruchi - Prepare for Battle! (Loop).wav",
	"TOWN" : "res://Music/Take some rest and eat some food!/xDeviruchi - Take some rest and eat some food! (Loop).wav",
	"ICY_CAVE" : "res://Music/The Icy Cave/xDeviruchi - The Icy Cave (Loop).wav",
	"TITLE" : "res://Music/Title Theme/xDeviruchi - Title Theme (Loop).wav"
}

var previous_track = []

func play_track(track):
	stream = tracks[track]
	play()
	
func fade_to_track(track):
	if tracks[track] == stream.resource_path:
		return
	if playing:
		previous_track.append(tracks.find_key(stream.resource_path))
		#print(previous_track)
		while volume_db > -80:
			volume_db -=1
			await get_tree().process_frame
		stop()
	stream = load(tracks[track])
	play()
	while volume_db < 0:
		volume_db += 1
		await get_tree().process_frame
	
func play_previous_track():
	fade_to_track(previous_track.pop_back())
