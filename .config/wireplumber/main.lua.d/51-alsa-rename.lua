table.insert(alsa_monitor.rules, {
	matches = {{{"object.path", "equals", "alsa:pcm:1:front:1:playback"}}},
	apply_properties = {["node.description"] = "Sink"},
})
table.insert(alsa_monitor.rules, {
	matches = {{{"object.path", "equals", "alsa:pcm:1:front:1:capture"}}},
	apply_properties = {["node.description"] = "Source"},
})
