extends Panel

@onready var text = $MarginContainer/VBoxContainer/TextLabel

var is_last_logbook = false

var log_books = {
	1: {
		"text": "[b]LOGBOOK 1 – \"INITIAL SURVEY\"[/b]\n\n" +
		"[i]Location: Coral Valley – Inside a sunken survey pod tangled in bioluminescent coral[/i]\n" +
		"[b]Date:[/b] March 5, 2039  \n" +
		"[b]Author:[/b] Dr. Liane Voss\n\n\n" +
		"“Preliminary scans confirm the anomaly is artificial. The architecture… it’s older than anything we’ve found on land. Not Atlantean—something older. These glyphs, they seem to resonate, literally. We picked up vibrations even before the scans.\n" +
		"HQ told us to keep quiet. Full comms blackout. They redirected the research team from Site Omega. We're not alone down here anymore.\n" +
		"The source of the signal appears to originate from a [b]cluster of rock formations northwest of Coral Valley[/b], beyond the thermal vents. But be cautious—our last probe returned damaged… as if something [i]intercepted[/i] it.”\n"
	},
	2: {
		"text": "[b]LOGBOOK 2 – \"PROTOCOL SHIFT\"[/b]\n\n" +
		"[i]Location: The Great Arch – Lodged inside a crushed Blackwave recon sub beneath the archway[/i]\n" +
		"[b]Date:[/b] March 11, 2039  \n" +
		"[b]Author:[/b] Commander Ryker – Blackwave Division\n\n\n" +
		"“Orders updated. We are no longer supporting the research team. New directive: [b]eliminate all unauthorized vessels[/b] in the sector. No warning, no contact. Total blackout.\n" +
		"They say it's for national security, but it’s more than that. The brass doesn't want anyone getting close to the structure. Not because it’s dangerous—because it’s a [i]secret[/i]. One they’re willing to kill for.\n" +
		"If you're reading this, you're already in their crosshairs. [b]Multiple Blackwave patrol subs sweep the area[/b]. Keep your distance. Hide in the thermal shadows if you have to.\n" +
		"I caught a short-range signal before we lost power—looked like a distress beacon. Weak, but heading [b]south[/b], past the kelp ridges. Someone else might still be out there...”\n"
	},
	3: {
		"text": "[b]LOGBOOK 3 – \"SUBMERGED CONTACT\"[/b]\n\n" +
		"[i]Location: The Spiral Garden – Suspended in the center of a formation of rotating alien monoliths[/i]\n" +
		"[b]Date:[/b] March 13, 2039  \n" +
		"[b]Author:[/b] Dr. Emile Carrow – Cognitive Linguistics Division\n\n\n" +
		"“I can barely describe what I’m seeing. The stones here… they [i]float[/i], rotating in perfect harmony. Not mechanically—like they’re responding to some kind of rhythm, a pulse. And it’s not just physical. The audio spectrum is full of patterns, layered tones that echo in your mind.\n" +
		"We ran the glyphs through neural audio filters. It wasn’t language—it was [b]command code[/b]. Primitive, yes. But powerful. One of our techs collapsed just listening to it. Said it spoke to her.\n" +
		"Liane warned us, tried to stop the experiment. Said we didn’t understand what we were waking up. Now she’s gone, and they won’t even say her name.\n" +
		"I copied a fragment of the harmonic code into a beacon. If you’re out there, trace the signal. I launched the beacon [b]north east, into the abyssal trench pass[/b]. Maybe someone smarter, or braver, will find the truth we weren’t meant to hear.”\n"
	},
	4: {
		"text": "[b]LOGBOOK 4 – \"THE SILENCING\"[/b]\n\n" +
		"[i]Location: Blacksite Aegir – Hidden government facility carved into the trench wall, sealed behind biometric locks[/i]\n" +
		"[b]Date:[/b] March 14, 2039  \n" +
		"[b]Author:[/b] Dr. Liane Voss\n\n\n" +
		"“If you're reading this, they haven’t erased me yet. I don’t have long—security is cycling patrols and my clearance was revoked two days ago. They think I’m compliant. I’m not.\n\n" +
		"This place… it’s not just a research outpost. It’s a vault. They’ve known about the structure for decades. Operation Aegir wasn’t about discovery—it was about [b]containment[/b]. And now they’re trying to reverse-engineer what they don’t understand.\n\n" +
		"The pulses from the alien core—it’s not broadcasting, it’s [i]calling[/i]. Responding to something. [b]It wants to be found.[/b] And it’s changing us. I’ve seen the scans. Our minds can’t handle it. Maybe they’re not supposed to.\n\n"
	}
}

func _ready() -> void:
	BiomUtils.logbook_discovered.connect(_show_logbook)

func _show_logbook(logbook_id: int):
	is_last_logbook == logbook_id == 4
	if !log_books.has(logbook_id):
		printerr("Nema ti tog logbooka!")
		return
	
	text.text = log_books[logbook_id]["text"]
	text.visible_ratio = 0.0
	visible = true
	create_tween().tween_property(text, "visible_ratio", 1.0, 10.0)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if (is_last_logbook):
			return
		visible = false
		get_tree().paused = false
