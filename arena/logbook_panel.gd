extends Panel

@onready var text = $MarginContainer/VBoxContainer/TextLabel

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
}

func _ready() -> void:
	BiomUtils.logbook_discovered.connect(_show_logbook)

func _show_logbook(logbook_id: int):
	if !log_books.has(logbook_id):
		printerr("Nema ti tog logbooka!")
		return
	
	text.text = log_books[logbook_id]["text"]
	text.visible_ratio = 0.0
	visible = true
	create_tween().tween_property(text, "visible_ratio", 1.0, 10.0)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		visible = false
		get_tree().paused = false
