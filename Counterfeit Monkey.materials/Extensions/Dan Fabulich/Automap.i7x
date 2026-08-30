Version 1/260829 of Automap (for Glulx only) by Dan Fabulich begins here.

"Displays a map of rooms that reveals itself as you play (fog of war)."

Use authorial modesty.

Include Glk Mapping by Dan Fabulich.

Use maximum text length of at least 8192.

Part - Model

Chapter - Geometry and pages

[Abstract map units (not pixels). Unplaced rooms (default x/y) or zero-size rooms are omitted.]

The automap unplaced coordinate is always -9999.

A room has a number called map x. The map x of a room is usually the automap unplaced coordinate.
A room has a number called map y. The map y of a room is usually the automap unplaced coordinate.
A room has a number called map z. The map z of a room is usually 0.
A room has a number called map width. The map width of a room is usually 6.
A room has a number called map height. The map height of a room is usually 4.

[Pages: only rooms on the active page are drawn. Switch pages (and full-rebuild)
when the player enters a room on another page.]
A room has a number called map page id. The map page id of a room is usually 0.

The automap page id is a number that varies. The automap page id is 0.

Automap scale is a number that varies. Automap scale is 20.

Automap enabled is a truth state that varies. Automap enabled is initially true.

Automap opening hint enabled is a truth state that varies. Automap opening hint enabled is initially true.

Automap hyperlinks enabled is a truth state that varies. Automap hyperlinks enabled is initially false.
Automap hyperlinks last painted is a truth state that varies. Automap hyperlinks last painted is initially false.

To decide whether (subject - a room) has automap geometry:
	if the map x of subject is the automap unplaced coordinate, no;
	if the map y of subject is the automap unplaced coordinate, no;
	if the map width of subject > 0 and the map height of subject > 0, yes;
	no.

To decide whether (subject - a room) is on the automap:
	if subject has automap geometry and the map page id of subject is the automap page id, yes;
	no.

To sync the automap page from the location:
	if the location has automap geometry:
		let page be the map page id of the location;
		if page is not the automap page id:
			now the automap page id is page;
			invalidate the automap base geometry;
			mark the automap full rebuild needed because "page-change".

[Rooms whose map z differs from the player's are drawn dimmed. Changing floors
reinstalls room cards whose appearance is stale (dim / here); connectors stay.]
To sync the automap z from previous locations:
	unless the location is a room, stop;
	repeat with prev running through the automap previous locations:
		if prev is a room and the map z of prev is not the map z of the location:
			repeat with subject running through rooms:
				if the automap overlay id of subject > 0:
					if subject has a stale automap appearance:
						discover the automap appearance of subject;
						install the automap room overlay for subject;
						repeat with way running through {up, down, inside, outside}:
							install the automap badge from subject for way;
			stop.

To decide whether (subject - a room) is automap-dimmed:
	if subject is the location, no;
	if the map z of subject is the map z of the location, no;
	yes.

To decide whether (subject - a room) is map-visible:
	if subject is on the automap:
		if subject is visited, yes;
		if subject is the location, yes;
	no.


Chapter - Fog and appearance

[map-named: author/debug helper — room seen in light via going or explicit mark.
 Labels come from the status line ([player's surroundings]), stored separately.]
A room can be map-named.

[Last appearance we pushed to the host for this room.]
A room can be automap-drawn-dark.
A room can be automap-drawn-named.
A room can be automap-drawn-here.
A room can be automap-drawn-dimmed.
A room can be automap-discovered.
A room has a text called automap drawn label.

To decide what text is the automap label of (subject - a room):
	if the automap drawn label of subject is not "", decide on the automap drawn label of subject;
	decide on "".

[Same text the status line uses for [player's surroundings] / SL_Location.]
To capture the automap status label for (subject - a room):
	unless subject is a room, stop;
	unless subject is the location, stop;
	unless subject has automap geometry, stop;
	now the automap drawn label of subject is the substituted form of "[player's surroundings]".

[Freeze what the map has "discovered" for subject from live world state. Capture the
 status-line label when the player is in subject; for other rooms (teleport transit,
 REVEAL) fill an empty label from printed name / Darkness without inventing visits.]
To discover the automap appearance of (subject - a room):
	if subject is the location:
		capture the automap status label for subject;
	otherwise if the automap drawn label of subject is "":
		if subject is map-named or (subject is visited and subject is not dark):
			now the automap drawn label of subject is the printed name of subject;
		otherwise if subject is visited and subject is dark:
			now the automap drawn label of subject is "Darkness";
	if subject is dark:
		now subject is automap-drawn-dark;
	else:
		now subject is not automap-drawn-dark;
	if subject is map-named:
		now subject is automap-drawn-named;
	else:
		now subject is not automap-drawn-named;
	if subject is the location:
		now subject is automap-drawn-here;
	else:
		now subject is not automap-drawn-here;
	if subject is automap-dimmed:
		now subject is automap-drawn-dimmed;
	else:
		now subject is not automap-drawn-dimmed;
	now subject is automap-discovered.

To discover all visible automap rooms:
	repeat with subject running through rooms:
		if subject is map-visible:
			discover the automap appearance of subject.

[Mark a room visited for fog-of-war (like arriving there). Sets map-named only when
 the room is lit. Queues it for the next incremental refresh.]
To reveal (R - a room) on the automap:
	unless R is a room, stop;
	now R is visited;
	if R is not dark:
		now R is map-named;
	note automap previous location R.

[Reveal every room currently on the automap page (has geometry and matching page id).
 Rooms on other pages are unchanged.]
To reveal all rooms on the automap:
	repeat with subject running through rooms:
		if subject is on the automap:
			reveal subject on the automap.

To decide whether (subject - a room) has a stale automap appearance:
	[Compare live discovery to frozen drawn — only meaningful for rooms we
	 intentionally re-check (location / leave-room).]
	if subject is dark and subject is not automap-drawn-dark, yes;
	if subject is not dark and subject is automap-drawn-dark, yes;
	if subject is map-named and subject is not automap-drawn-named, yes;
	if subject is not map-named and subject is automap-drawn-named, yes;
	if subject is the location and subject is not automap-drawn-here, yes;
	if subject is not the location and subject is automap-drawn-here, yes;
	if subject is automap-dimmed and subject is not automap-drawn-dimmed, yes;
	if subject is automap-drawn-dimmed:
		unless subject is automap-dimmed, yes;
	if subject is the location:
		let live label be the substituted form of "[player's surroundings]";
		if live label is not the automap drawn label of subject, yes;
	otherwise if subject is map-named:
		if the automap drawn label of subject is not the printed name of subject, yes;
	no.


Chapter - Directions and bearings

[Connectors are lines between rooms. Compass connectors follow the
eight compass bearings. Up/down/in/out are not compass connectors —
they use badge discs. Nautical directions are defined here and remapped
onto those bearings so fore/aft/port draw like N/S/W. Authors with other
custom direction sets can continue the bearing table.]
The starboard is a direction. The starboard has opposite port.
The port is a direction. The port has opposite starboard.
The fore is a direction. The fore has opposite aft.
The aft is a direction. The aft has opposite fore.
The aft-port is a direction. The aft-port has opposite fore-starboard.
The aft-starboard is a direction. The aft-starboard has opposite fore-port.
The fore-port is a direction. The fore-port has opposite aft-starboard.
The fore-starboard is a direction. The fore-starboard has opposite aft-port.

Table of Automap Bearings
exit-way (a direction)	bearing (a direction)
fore	north
aft	south
port	west
starboard	east
fore-port	northwest
fore-starboard	northeast
aft-port	southwest
aft-starboard	southeast
with 1 blank row.

A direction can be automap-remapped.

A direction has a number called automap way index. The automap way index of a direction is usually 0.

The automap compass ways is a list of directions that varies.
The automap exit ways is a list of directions that varies.

To decide which direction is the map facing of (way - a direction):
	if way is automap-remapped:
		decide on the mapped bearing of way;
	decide on way.

A direction has a direction called mapped bearing.

To decide whether (way - a direction) is a standard compass direction:
	if way is north or way is south or way is east or way is west, yes;
	if way is northeast or way is northwest or way is southeast or way is southwest, yes;
	no.

[True for 90° (axis-aligned) and 45° (equal abs deltas) connectors; those stay
straight lines. All other spans use Bezier curves (or author bends).]
To decide whether (start-x - a number) and (start-y - a number) to (end-x - a number) and (end-y - a number) forms a straight diagonal:
	let delta-x be end-x - start-x;
	let delta-y be end-y - start-y;
	if delta-x < 0, now delta-x is 0 - delta-x;
	if delta-y < 0, now delta-y is 0 - delta-y;
	if delta-x < 1:
		if delta-y < 1, decide no;
		yes;
	if delta-y < 1, yes;
	if delta-x is delta-y, yes;
	no.

To apply the automap bearings table:
	truncate the automap compass ways to 0 entries;
	add north to the automap compass ways;
	add south to the automap compass ways;
	add east to the automap compass ways;
	add west to the automap compass ways;
	add northeast to the automap compass ways;
	add northwest to the automap compass ways;
	add southeast to the automap compass ways;
	add southwest to the automap compass ways;
	repeat through the Table of Automap Bearings:
		if there is an exit-way entry and there is a bearing entry:
			let exit-way be the exit-way entry;
			now the mapped bearing of exit-way is the bearing entry;
			now exit-way is automap-remapped;
			unless exit-way is a standard compass direction:
				add exit-way to the automap compass ways;
	[Way indexes for per-connector overlays: all compass ways, then badges.]
	truncate the automap exit ways to 0 entries;
	let way-index be 0;
	repeat with way running through the automap compass ways:
		now the automap way index of way is way-index;
		add way to the automap exit ways;
		increase way-index by 1;
	repeat with way running through {up, down, inside, outside}:
		now the automap way index of way is way-index;
		add way to the automap exit ways;
		increase way-index by 1.


[Up/down/in/out are badge directions; opposites pair the badge connector ends.]
To decide whether (way - a direction) is a badge direction:
	if way is up or way is down or way is inside or way is outside, yes;
	no.

To decide which direction is the badge opposite of (way - a direction):
	if way is up, decide on down;
	if way is down, decide on up;
	if way is inside, decide on outside;
	if way is outside, decide on inside;
	decide on way.


[Sometimes a room has two exits that go to the same place, one compass direction (south) and one badge direction (down). We call those "compass twins." When we detect a compass twin, we position the badge on that port and omit the badge connector.]
To decide whether (subject - a room) has a compass twin to (destination - a room):
	repeat with way running through the automap compass ways:
		if the room way from subject is destination, yes;
	no.

To decide which direction is the compass twin from (subject - a room) to (destination - a room):
	[Only call after "has a compass twin". Never decide on nothing (P33).
	Returns the map facing used for port geometry.]
	repeat with way running through the automap compass ways:
		if the room way from subject is destination, decide on the map facing of way;
	decide on north.


Part - Overlay state

Chapter - Room ids

A room has a number called automap overlay id. The automap overlay id of a room is usually 0.

To forget all automap overlay ids:
	repeat with subject running through rooms:
		now the automap overlay id of subject is 0.

[In addition to overlay ID numbers, we define dense 1..N IDs, which we can use as array indexes. (Raw Glulx object ids are too large).]
A room has a number called automap dense room id. The automap dense room id of a room is usually 0.
The automap dense room count is a number that varies.

To register (subject - an object) in the automap dense room table at index (n - a number):
	(- AM_room_at_dense-->({n} - 1) = {subject}; -)

To sync automap dense room ids:
	let next-dense-room-id be 0;
	repeat with subject running through rooms:
		if subject is on the automap:
			increase next-dense-room-id by 1;
			now the automap dense room id of subject is next-dense-room-id;
			register subject in the automap dense room table at index next-dense-room-id;
		else:
			now the automap dense room id of subject is 0;
	now the automap dense room count is next-dense-room-id.

To decide which object is the automap room at dense index (n - a number):
	(- AM_room_at_dense-->({n} - 1) -)


Chapter - Connector and badge indexes

Include (-
! It would be nice to have an array of connector objects on each room, where each connector has its own overlay ID, kind, and peer room. Unfortunately, we can't do it that way. Instead, we have a flat array of all connector overlay IDs.
! We assign each way (each direction) an index number, a "way index", with a constant AM_MAX_WAYS_PER_ROOM. To find an overlay ID for a connector, we find its "connector index", by multiplying its room's dense room ID (minus one) by AM_MAX_WAYS_PER_ROOM, and then adding the way index.
! So, if AM_MAX_WAYS_PER_ROOM is 24, and we want to find the east connector index for room ID 7, where "east" has way index 2, we'd compute (7 - 1) * 24 + 2 = 146.
! With the connector index, we can read its overlay ID, its kind (none, stub, compass, badge), and its peer room ID out of the flat arrays. (If it's a badge, the badge itself has its own overlay ID as well.)

! Per-exit connector overlays, keyed by dense room id (1..AM_MAX_ROOMS) × way index.
Constant AM_MAX_ROOMS = 256;
Array AM_room_at_dense --> AM_MAX_ROOMS;
Constant AM_MAX_WAYS_PER_ROOM = 24; ! compass + remapped bearings + badges, with headroom
Array AM_connector_overlay_ids --> 6144; ! 256 * 24
Array AM_connector_kinds --> 6144;
Array AM_connector_peers --> 6144;
! Per-badge-disc overlays (up/down/in/out), same dense-room-id × way index as connectors.
Array AM_badge_overlay_ids --> 6144;
Constant AM_CONNECTOR_KIND_NONE = 0;
Constant AM_CONNECTOR_KIND_STUB = 1;
Constant AM_CONNECTOR_KIND_COMPASS_LINK = 2;
Constant AM_CONNECTOR_KIND_BADGE_LINK = 3;
Constant AM_BADGE_KIND_IN = 0;
Constant AM_BADGE_KIND_OUT = 1;
Constant AM_BADGE_KIND_UP = 2;
Constant AM_BADGE_KIND_DOWN = 3;
[ AM_ConnectorIndex dense_room_id way_index;
  if (dense_room_id < 1 || dense_room_id > AM_MAX_ROOMS) return -1;
  if (way_index < 0 || way_index >= AM_MAX_WAYS_PER_ROOM) return -1;
  return (dense_room_id - 1) * AM_MAX_WAYS_PER_ROOM + way_index;
];
[ AM_GetConnectorOverlayId dense_room_id way_index index;
  index = AM_ConnectorIndex(dense_room_id, way_index);
  if (index < 0) return 0;
  return AM_connector_overlay_ids-->index;
];
[ AM_SetConnectorOverlayId dense_room_id way_index value index;
  index = AM_ConnectorIndex(dense_room_id, way_index);
  if (index < 0) return;
  AM_connector_overlay_ids-->index = value;
];
[ AM_GetConnectorKind dense_room_id way_index index;
  index = AM_ConnectorIndex(dense_room_id, way_index);
  if (index < 0) return 0;
  return AM_connector_kinds-->index;
];
[ AM_SetConnectorKind dense_room_id way_index value index;
  index = AM_ConnectorIndex(dense_room_id, way_index);
  if (index < 0) return;
  AM_connector_kinds-->index = value;
];
[ AM_GetConnectorPeer dense_room_id way_index index;
  index = AM_ConnectorIndex(dense_room_id, way_index);
  if (index < 0) return 0;
  return AM_connector_peers-->index;
];
[ AM_SetConnectorPeer dense_room_id way_index value index;
  index = AM_ConnectorIndex(dense_room_id, way_index);
  if (index < 0) return;
  AM_connector_peers-->index = value;
];
[ AM_ClearConnectorIndex dense_room_id way_index index overlay;
  index = AM_ConnectorIndex(dense_room_id, way_index);
  if (index < 0) return;
  overlay = AM_connector_overlay_ids-->index;
  if (overlay) glk_map_overlay_clear(overlay);
  AM_connector_overlay_ids-->index = 0;
  AM_connector_kinds-->index = AM_CONNECTOR_KIND_NONE;
  AM_connector_peers-->index = 0;
];
[ AM_ForgetAllConnectors index;
  for (index = 0: index < AM_MAX_ROOMS * AM_MAX_WAYS_PER_ROOM: index++) {
    AM_connector_overlay_ids-->index = 0;
    AM_connector_kinds-->index = AM_CONNECTOR_KIND_NONE;
    AM_connector_peers-->index = 0;
  }
];
[ AM_GetBadgeOverlayId dense_room_id way_index index;
  index = AM_ConnectorIndex(dense_room_id, way_index);
  if (index < 0) return 0;
  return AM_badge_overlay_ids-->index;
];
[ AM_SetBadgeOverlayId dense_room_id way_index value index;
  index = AM_ConnectorIndex(dense_room_id, way_index);
  if (index < 0) return;
  AM_badge_overlay_ids-->index = value;
];
[ AM_ClearBadgeIndex dense_room_id way_index index overlay;
  index = AM_ConnectorIndex(dense_room_id, way_index);
  if (index < 0) return;
  overlay = AM_badge_overlay_ids-->index;
  if (overlay) glk_map_overlay_clear(overlay);
  AM_badge_overlay_ids-->index = 0;
];
[ AM_ForgetAllBadges index;
  for (index = 0: index < AM_MAX_ROOMS * AM_MAX_WAYS_PER_ROOM: index++) {
    AM_badge_overlay_ids-->index = 0;
  }
];
-).


[Live connector kind: AM_CONNECTOR_KIND_* — see I6 constants and I7 AM connector kind phrases.]
To decide what number is AM connector kind none: (- AM_CONNECTOR_KIND_NONE -).
To decide what number is AM connector kind stub: (- AM_CONNECTOR_KIND_STUB -).
To decide what number is AM connector kind compass link: (- AM_CONNECTOR_KIND_COMPASS_LINK -).
To decide what number is AM connector kind badge link: (- AM_CONNECTOR_KIND_BADGE_LINK -).

To decide what number is AM badge kind in: (- AM_BADGE_KIND_IN -).
To decide what number is AM badge kind out: (- AM_BADGE_KIND_OUT -).
To decide what number is AM badge kind up: (- AM_BADGE_KIND_UP -).
To decide what number is AM badge kind down: (- AM_BADGE_KIND_DOWN -).

To decide what number is AM connector view pad: (- AM_CONNECTOR_VIEW_PAD -).


To set the automap connector overlay at dense (dense-room-id - a number) way (way-index - a number) to (value - a number):
	(- AM_SetConnectorOverlayId({dense-room-id}, {way-index}, {value}); -).

To decide what number is the automap connector kind at dense (dense-room-id - a number) way (way-index - a number):
	(- AM_GetConnectorKind({dense-room-id}, {way-index}) -).

To set the automap connector kind at dense (dense-room-id - a number) way (way-index - a number) to (value - a number):
	(- AM_SetConnectorKind({dense-room-id}, {way-index}, {value}); -).

To decide what number is the automap connector peer at dense (dense-room-id - a number) way (way-index - a number):
	(- AM_GetConnectorPeer({dense-room-id}, {way-index}) -).

To set the automap connector peer at dense (dense-room-id - a number) way (way-index - a number) to (value - a number):
	(- AM_SetConnectorPeer({dense-room-id}, {way-index}, {value}); -).

To clear the automap connector index at dense (dense-room-id - a number) way (way-index - a number):
	(- AM_ClearConnectorIndex({dense-room-id}, {way-index}); -).

To forget all automap connector overlays:
	(- AM_ForgetAllConnectors(); -).

To set the automap badge overlay at dense (dense-room-id - a number) way (way-index - a number) to (value - a number):
	(- AM_SetBadgeOverlayId({dense-room-id}, {way-index}, {value}); -).

To decide whether the automap badge is drawn at dense (dense-room-id - a number) way (way-index - a number):
	(- (AM_GetBadgeOverlayId({dense-room-id}, {way-index}) ~= 0) -).

To clear the automap badge index at dense (dense-room-id - a number) way (way-index - a number):
	(- AM_ClearBadgeIndex({dense-room-id}, {way-index}); -).

To forget all automap badge overlays:
	(- AM_ForgetAllBadges(); -).


Chapter - Bent connectors

[Optional author waypoints for a connector.
 Stored in map units like map x / map y; ignored when absent.]

Table of Automap Connector Midpoints
link-room (a room)	link-way (a direction)	sequence (a number)	mid-x (a number)	mid-y (a number)
with 32 blank rows.

To clear the automap connector midpoints from (subject - a room) via (way - a direction):
	repeat through the Table of Automap Connector Midpoints:
		if there is a link-room entry:
			if the link-room entry is subject and the link-way entry is way:
				blank out the whole row.

To add an automap connector midpoint (mx - a number) and (my - a number) from (subject - a room) via (way - a direction) at sequence (seq - a number):
	choose a blank row in the Table of Automap Connector Midpoints;
	now link-room entry is subject;
	now link-way entry is way;
	now sequence entry is seq;
	now mid-x entry is mx;
	now mid-y entry is my.

To decide what number is the automap connector midpoint count from (subject - a room) via (way - a direction):
	let tally be 0;
	repeat through the Table of Automap Connector Midpoints:
		if there is a link-room entry:
			if the link-room entry is subject and the link-way entry is way:
				increase tally by 1;
	decide on tally.

To decide what number is the automap connector midpoint x from (subject - a room) via (way - a direction) index (n - a number):
	repeat through the Table of Automap Connector Midpoints:
		if there is a link-room entry:
			if the link-room entry is subject and the link-way entry is way:
				if the sequence entry is n:
					decide on the mid-x entry;
	decide on 0.

To decide what number is the automap connector midpoint y from (subject - a room) via (way - a direction) index (n - a number):
	repeat through the Table of Automap Connector Midpoints:
		if there is a link-room entry:
			if the link-room entry is subject and the link-way entry is way:
				if the sequence entry is n:
					decide on the mid-y entry;
	decide on 0.

To decide what number is the map pixel x of automap midpoint (mx - a number):
	decide on mx * automap scale.

To decide what number is the map pixel y of automap midpoint (my - a number):
	decide on my * automap scale.

To bend the automap connector from (subject - a room) via (way - a direction) through (first-x - a number) and (first-y - a number):
	clear the automap connector midpoints from subject via way;
	add an automap connector midpoint first-x and first-y from subject via way at sequence 1;
	mark the automap full rebuild needed because "bent-connector".

To bend the automap connector from (subject - a room) via (way - a direction) through (first-x - a number) and (first-y - a number) and (second-x - a number) and (second-y - a number):
	clear the automap connector midpoints from subject via way;
	add an automap connector midpoint first-x and first-y from subject via way at sequence 1;
	add an automap connector midpoint second-x and second-y from subject via way at sequence 2;
	mark the automap full rebuild needed because "bent-connector".

To bend the automap connector from (subject - a room) via (way - a direction) through (first-x - a number) and (first-y - a number) and (second-x - a number) and (second-y - a number) and (third-x - a number) and (third-y - a number):
	clear the automap connector midpoints from subject via way;
	add an automap connector midpoint first-x and first-y from subject via way at sequence 1;
	add an automap connector midpoint second-x and second-y from subject via way at sequence 2;
	add an automap connector midpoint third-x and third-y from subject via way at sequence 3;
	mark the automap full rebuild needed because "bent-connector".

To bend the automap connector from (subject - a room) via (way - a direction) through (first-x - a number) and (first-y - a number) and (second-x - a number) and (second-y - a number) and (third-x - a number) and (third-y - a number) and (fourth-x - a number) and (fourth-y - a number):
	clear the automap connector midpoints from subject via way;
	add an automap connector midpoint first-x and first-y from subject via way at sequence 1;
	add an automap connector midpoint second-x and second-y from subject via way at sequence 2;
	add an automap connector midpoint third-x and third-y from subject via way at sequence 3;
	add an automap connector midpoint fourth-x and fourth-y from subject via way at sequence 4;
	mark the automap full rebuild needed because "bent-connector".


To decide whether (subject - a room) has a live automap badge for (way - a direction):
	unless way is a badge direction, no;
	unless subject is map-visible, no;
	let dest be the room way from subject;
	if dest is a room and dest has automap geometry, yes;
	no.


To decide what number is the live automap connector kind from (subject - a room) for (way - a direction):
	unless subject is map-visible, decide on AM connector kind none;
	let dest be the room way from subject;
	unless dest is a room, decide on AM connector kind none;
	unless dest has automap geometry, decide on AM connector kind stub;
	if dest is subject, decide on AM connector kind stub;
	if way is a badge direction:
		unless dest is map-visible, decide on AM connector kind none;
		if subject has a compass twin to dest, decide on AM connector kind none;
		let back be the badge opposite of way;
		if the room back from dest is subject and the object number of subject > the object number of dest, decide on AM connector kind none;
		decide on AM connector kind badge link;
	if dest is map-visible:
		let back be the opposite of way;
		if the room back from dest is subject and the object number of subject > the object number of dest, decide on AM connector kind none;
		decide on AM connector kind compass link;
	decide on AM connector kind stub.

To decide what number is the live automap connector peer from (subject - a room) for (way - a direction):
	let dest be the room way from subject;
	unless dest is a room and dest is on the automap, decide on 0;
	decide on the automap dense room id of dest.


Part - Appearance

Chapter - Paper and ink palette

[The "paper" is the default background normal background color; the "ink" is the foreground color. Most map colors are a mix of "ink" color and "paper" color.]

The automap paper color is a number that varies.
The automap ink color is a number that varies.

[Rooms have a "fill" background color (paper mixed with ink, semi-transparent), a "stroke" color for the border, a "label" color for the text (the room name).]
The automap room fill color is a number that varies.
The automap room stroke color is a number that varies.
The automap room label color is a number that varies.
[For the "you are here" room, we use inverted colors, making the "fill" in ink and the "label" in paper.]
The automap here fill color is a number that varies.
The automap here stroke color is a number that varies.
The automap here label color is a number that varies.
[Connectors and "stub" arrows pointing to empty space have colors, too.]
The automap connector color is a number that varies.
The automap stub color is a number that varies.


Include (-
[ AM_MixRGB start_color end_color mix_percent start_red start_green start_blue end_red end_green end_blue;
  if (mix_percent < 0) mix_percent = 0;
  if (mix_percent > 100) mix_percent = 100;
  start_red = (start_color / 65536) & 255; start_green = (start_color / 256) & 255; start_blue = start_color & 255;
  end_red = (end_color / 65536) & 255; end_green = (end_color / 256) & 255; end_blue = end_color & 255;
  end_red = start_red + ((end_red - start_red) * mix_percent) / 100;
  end_green = start_green + ((end_green - start_green) * mix_percent) / 100;
  end_blue = start_blue + ((end_blue - start_blue) * mix_percent) / 100;
  if (end_red < 0) end_red = 0; if (end_red > 255) end_red = 255;
  if (end_green < 0) end_green = 0; if (end_green > 255) end_green = 255;
  if (end_blue < 0) end_blue = 0; if (end_blue > 255) end_blue = 255;
  return (end_red * 65536) + (end_green * 256) + end_blue;
];

[ AM_LuminanceScore rgb red green blue;
  ! Perceived luminance on a 0..1000 scale, using ITU-R Recommendation BT.709
  ! (Rec. 709) luma coefficients: ~0.2126 red, ~0.7152 green, ~0.0722 blue.
  red = (rgb / 65536) & 255;
  green = (rgb / 256) & 255;
  blue = rgb & 255;
  return (2126 * red + 7152 * green + 722 * blue) / 255;
];

[ AM_RoomLabelColor fill paper ink fill_lum paper_lum ink_lum mid_lum;
  fill_lum = AM_LuminanceScore(fill);
  paper_lum = AM_LuminanceScore(paper);
  ink_lum = AM_LuminanceScore(ink);
  if (ink_lum == paper_lum) return ink;
  mid_lum = (ink_lum + paper_lum) / 2;
  if (fill_lum >= mid_lum) {
    if (ink_lum > paper_lum) return paper;
    return ink;
  }
  if (ink_lum > paper_lum) return ink;
  return paper;
];

[ AM_RebuildPalette paper ink dark room_mix room_fill here_fill room_effective_fill here_effective_fill;
  dark = (AM_LuminanceScore(paper) < 450);
  if (dark) room_mix = 18; else room_mix = 12;
  room_fill = AM_MixRGB(paper, ink, room_mix);
  if (dark)
    here_fill = AM_MixRGB(room_fill, ink, 85);
  else
    here_fill = AM_MixRGB(room_fill, ink, 90);
  room_effective_fill = AM_MixRGB(paper, room_fill, 78); ! matches room fill-opacity 0.78
  here_effective_fill = AM_MixRGB(paper, here_fill, 78);
  (+ automap paper color +) = paper;
  (+ automap ink color +) = ink;
  (+ automap room fill color +) = room_fill;
  (+ automap room stroke color +) = ink;
  (+ automap room label color +) = AM_RoomLabelColor(room_effective_fill, paper, ink);
  (+ automap here fill color +) = here_fill;
  (+ automap here stroke color +) = ink;
  (+ automap here label color +) = AM_RoomLabelColor(here_effective_fill, paper, ink);
  if (dark)
    (+ automap connector color +) = AM_MixRGB(paper, ink, 50);
  else
    (+ automap connector color +) = AM_MixRGB(paper, ink, 60);
  if (dark)
    (+ automap stub color +) = AM_MixRGB(paper, ink, 35);
  else
    (+ automap stub color +) = AM_MixRGB(paper, ink, 40);
];

[ AM_MeasurePalette paper ink;
  paper = 16777215; ! 0xFFFFFF white — fallback if style_measure fails
  ink = 0; ! black
  if (gg_mainwin) {
    if (glk_style_measure(gg_mainwin, style_Normal, stylehint_BackColor, gg_arguments))
      paper = gg_arguments-->0;
    if (glk_style_measure(gg_mainwin, style_Normal, stylehint_TextColor, gg_arguments))
      ink = gg_arguments-->0;
  }
  AM_RebuildPalette(paper, ink);
];
-).

To rebuild the automap palette:
	(- AM_MeasurePalette(); -).


Part - SVG buffer

[This is where we construct SVG strings to send to glk_map_present_svg and glk_map_overlay_svg.]

Chapter - Buffer and escaping

Include (-
Global AM_len = 0;
Constant AM_BUF_MAX = 262143;
[ AM_ClearBuf;
  AM_len = 0;
];
[ AM_AddChar codepoint;
  if (AM_len < AM_BUF_MAX) {
    glk_map_svg_buf->AM_len = codepoint;
    AM_len++;
  }
];
! Decode a Glulx string (E0/E1/E2) via @streamstr into the SVG buffer.
[ AM_EncodeUtf8 codepoint;
  if (codepoint < 128) AM_AddChar(codepoint);
  else if (codepoint < $800) {
    AM_AddChar($C0 + (codepoint / $40));
    AM_AddChar($80 + (codepoint & $3F));
  } else if (codepoint < $10000) {
    AM_AddChar($E0 + (codepoint / $1000));
    AM_AddChar($80 + ((codepoint / $40) & $3F));
    AM_AddChar($80 + (codepoint & $3F));
  } else {
    AM_AddChar($F0 + (codepoint / $40000));
    AM_AddChar($80 + ((codepoint / $1000) & $3F));
    AM_AddChar($80 + ((codepoint / $40) & $3F));
    AM_AddChar($80 + (codepoint & $3F));
  }
];
[ AM_AddLit lit_string iosys_mode iosys_rock;
  @getiosys iosys_mode iosys_rock;
  @setiosys 1 AM_EncodeUtf8;
  @streamstr lit_string;
  @setiosys iosys_mode iosys_rock;
];
Array AM_decimal_digits -> 16;
[ AM_AddNum value digit_count;
  if (value < 0) { AM_AddChar('-'); value = -value; }
  if (value == 0) { AM_AddChar('0'); return; }
  digit_count = 0;
  while (value > 0) {
    AM_decimal_digits->digit_count = value % 10;
    value = value / 10;
    digit_count++;
  }
  while (digit_count > 0) {
    digit_count = digit_count - 1;
    AM_AddChar(48 + AM_decimal_digits->digit_count);
  }
];
[ AM_AddHexDigit digit;
  if (digit < 10) AM_AddChar(48 + digit);
  else AM_AddChar(87 + digit);
];
[ AM_AddHexColor rgb red green blue;
  red = (rgb / 65536) & 255;
  green = (rgb / 256) & 255;
  blue = rgb & 255;
  AM_AddChar('#');
  AM_AddHexDigit((red / 16) & 15);
  AM_AddHexDigit(red & 15);
  AM_AddHexDigit((green / 16) & 15);
  AM_AddHexDigit(green & 15);
  AM_AddHexDigit((blue / 16) & 15);
  AM_AddHexDigit(blue & 15);
];
[ AM_AddCodepoint codepoint;
  ! Write one Unicode code point into the SVG byte buffer without XML escaping.
  ! Non-ASCII becomes a decimal NCR so the buffer stays valid UTF-8 / ASCII.
  if (codepoint < 128) AM_AddChar(codepoint);
  else {
    AM_AddChar('&'); AM_AddChar('#');
    AM_AddNum(codepoint);
    AM_AddChar(';');
  }
];
[ AM_EscCodepoint codepoint;
  if (codepoint == '&') AM_AddLit("&amp;");
  else if (codepoint == '<') AM_AddLit("&lt;");
  else if (codepoint == '>') AM_AddLit("&gt;");
  else if (codepoint == '"') AM_AddLit("&quot;");
  else AM_AddCodepoint(codepoint);
];
[ AM_AddText txt index length codepoint saved_transmute saved_capacity;
  if (txt == 0) return;
  saved_capacity = txt-->0;
  saved_transmute = TEXT_TY_Temporarily_Transmute(txt);
  length = TEXT_TY_CharacterLength(txt);
  for (index = 0: index < length: index++) {
    codepoint = BlkValueRead(txt, index);
    if (codepoint == 0) break;
    AM_AddCodepoint(codepoint);
  }
  TEXT_TY_Untransmute(txt, saved_transmute, saved_capacity);
];
-).


To clear the automap svg buffer:
	(- AM_ClearBuf(); -).


To append svg lit (svg-text - text):
	(- AM_AddText({svg-text}); -).


To append svg number (amount - a number):
	(- AM_AddNum({amount}); -).


To decide what number is the automap svg buffer length:
	(- AM_len -).


Chapter - SVG primitives

Include (-
[ AM_EmitSvgOpen min_x min_y view_width view_height;
  ! ~ is Inform's double-quote character inside string literals.
  AM_AddLit("<svg xmlns=~http://www.w3.org/2000/svg~ viewBox=~");
  AM_AddNum(min_x); AM_AddLit(" "); AM_AddNum(min_y); AM_AddLit(" ");
  AM_AddNum(view_width); AM_AddLit(" "); AM_AddNum(view_height); AM_AddLit("~>");
];
[ AM_EmitCubic start_x start_y control1_x control1_y control2_x control2_y end_x end_y color;
  AM_AddLit("<path d=~M ");
  AM_AddNum(start_x); AM_AddLit(" "); AM_AddNum(start_y);
  AM_AddLit(" C ");
  AM_AddNum(control1_x); AM_AddLit(" "); AM_AddNum(control1_y); AM_AddLit(" ");
  AM_AddNum(control2_x); AM_AddLit(" "); AM_AddNum(control2_y); AM_AddLit(" ");
  AM_AddNum(end_x); AM_AddLit(" "); AM_AddNum(end_y);
  AM_AddLit("~ fill=~none~ stroke=~"); AM_AddHexColor(color);
  AM_AddLit("~ stroke-width=~2~ opacity=~0.86~/>");
];
[ AM_EmitLine start_x start_y end_x end_y color;
  AM_AddLit("<line x1=~"); AM_AddNum(start_x);
  AM_AddLit("~ y1=~"); AM_AddNum(start_y);
  AM_AddLit("~ x2=~"); AM_AddNum(end_x);
  AM_AddLit("~ y2=~"); AM_AddNum(end_y);
  AM_AddLit("~ stroke=~"); AM_AddHexColor(color);
  AM_AddLit("~ stroke-width=~2~ opacity=~0.86~/>");
];
! Arrowhead size matches badge up/down triangles (height 8, half-base 4).
Constant AM_ARROW_DEPTH = 8;
Constant AM_ARROW_HALF = 4;
! Connector overlay pad must fit arrow wings (diagonal extent ~9px from tip).
Constant AM_CONNECTOR_VIEW_PAD = 10;
[ AM_EmitArrow tip_x tip_y way_code color;
  ! way_code: 0=N 1=S 2=E 3=W 4=NE 5=SE 6=SW 7=NW else circle
  ! Large unit vectors keep integer division accurate for diagonals.
  if (way_code == 0) AM_EmitArrowVector(tip_x, tip_y, 0, -100, color);
  else if (way_code == 1) AM_EmitArrowVector(tip_x, tip_y, 0, 100, color);
  else if (way_code == 2) AM_EmitArrowVector(tip_x, tip_y, 100, 0, color);
  else if (way_code == 3) AM_EmitArrowVector(tip_x, tip_y, -100, 0, color);
  else if (way_code == 4) AM_EmitArrowVector(tip_x, tip_y, 100, -100, color);
  else if (way_code == 5) AM_EmitArrowVector(tip_x, tip_y, 100, 100, color);
  else if (way_code == 6) AM_EmitArrowVector(tip_x, tip_y, -100, 100, color);
  else if (way_code == 7) AM_EmitArrowVector(tip_x, tip_y, -100, -100, color);
  else {
    AM_AddLit("<circle cx=~"); AM_AddNum(tip_x);
    AM_AddLit("~ cy=~"); AM_AddNum(tip_y);
    AM_AddLit("~ r=~3~ fill=~"); AM_AddHexColor(color);
    AM_AddLit("~ opacity=~0.86~/>");
  }
];
Global AM_bent_sx = 0; Global AM_bent_sy = 0; Global AM_bent_ex = 0; Global AM_bent_ey = 0;
Global AM_bent_count = 0;
Array AM_bent_mids_x --> 4;
Array AM_bent_mids_y --> 4;
[ AM_EmitStoredBentCubic color count c0x c0y c1x c1y;
  count = AM_bent_count;
  c0x = AM_bent_sx; c0y = AM_bent_sy;
  c1x = AM_bent_ex; c1y = AM_bent_ey;
  if (count >= 1) {
    c0x = AM_bent_mids_x-->0; c0y = AM_bent_mids_y-->0;
    c1x = c0x; c1y = c0y;
  }
  if (count >= 2) {
    c1x = AM_bent_mids_x-->(count - 1);
    c1y = AM_bent_mids_y-->(count - 1);
  }
  AM_EmitCubic(AM_bent_sx, AM_bent_sy, c0x, c0y, c1x, c1y, AM_bent_ex, AM_bent_ey, color);
];
[ AM_SetBentMidpoint seq mx my;
  if (seq < 1 || seq > 4) return;
  AM_bent_mids_x-->(seq - 1) = mx;
  AM_bent_mids_y-->(seq - 1) = my;
];
[ AM_DivRound num den;
  ! Signed divide rounded to nearest (den must be non-zero).
  if (den < 0) { num = -num; den = -den; }
  if (num >= 0) return (num + den / 2) / den;
  return -((-num + den / 2) / den);
];
[ AM_EmitArrowVector tip_x tip_y dx dy color depth half_w len ax ay back_x back_y perp_x perp_y;
  ! Same isosceles triangle in every direction (Euclidean), sized like badge arrows.
  depth = AM_ARROW_DEPTH;
  half_w = AM_ARROW_HALF;
  ax = dx; if (ax < 0) ax = -ax;
  ay = dy; if (ay < 0) ay = -ay;
  if (ax < 1 && ay < 1) {
    AM_AddLit("<circle cx=~"); AM_AddNum(tip_x);
    AM_AddLit("~ cy=~"); AM_AddNum(tip_y);
    AM_AddLit("~ r=~3~ fill=~"); AM_AddHexColor(color);
    AM_AddLit("~ opacity=~0.86~/>");
    return;
  }
  ! Scale tiny vectors so ISqrt/division stay accurate (e.g. dx=dy=1 → len 1).
  if (ax < 64 && ay < 64) {
    dx = dx * 64; dy = dy * 64;
    ax = ax * 64; ay = ay * 64;
  }
  if (ax > 20000) { dx = AM_DivRound(dx * 20000, ax); ax = 20000; }
  if (ay > 20000) { dy = AM_DivRound(dy * 20000, ay); ay = 20000; }
  len = AM_ISqrt(ax * ax + ay * ay);
  if (len < 1) len = 1;
  back_x = tip_x - AM_DivRound(dx * depth, len);
  back_y = tip_y - AM_DivRound(dy * depth, len);
  perp_x = AM_DivRound((-dy) * half_w, len);
  perp_y = AM_DivRound(dx * half_w, len);
  AM_AddLit("<polygon points=~");
  AM_AddNum(tip_x); AM_AddLit(","); AM_AddNum(tip_y); AM_AddLit(" ");
  AM_AddNum(back_x + perp_x); AM_AddLit(","); AM_AddNum(back_y + perp_y); AM_AddLit(" ");
  AM_AddNum(back_x - perp_x); AM_AddLit(","); AM_AddNum(back_y - perp_y);
  AM_AddLit("~ fill=~"); AM_AddHexColor(color); AM_AddLit("~ opacity=~0.86~/>");
];
Constant AM_ROOM_CORNER_RADIUS = 4;
[ AM_CornerPortInset;
  ! Inset from sharp corner to rounded-corner arc along the 45° bisector: r*(1 - 1/sqrt(2)).
  return (AM_ROOM_CORNER_RADIUS * 293 + 500) / 1000;
];
[ AM_EmitRoomRect left top width height fill stroke stroke_tenths;
  AM_AddLit("<rect x=~"); AM_AddNum(left);
  AM_AddLit("~ y=~"); AM_AddNum(top);
  AM_AddLit("~ width=~"); AM_AddNum(width);
  AM_AddLit("~ height=~"); AM_AddNum(height);
  AM_AddLit("~ rx=~"); AM_AddNum(AM_ROOM_CORNER_RADIUS);
  AM_AddLit("~ fill=~"); AM_AddHexColor(fill);
  ! fill-opacity 0.78 — connectors under rooms show through.
  AM_AddLit("~ fill-opacity=~0.78~ stroke=~"); AM_AddHexColor(stroke);
  if (stroke_tenths >= 30) AM_AddLit("~ stroke-width=~3~/>");
  else AM_AddLit("~ stroke-width=~1.5~/>");
];
[ AM_EmitDarkCorner left top width height color leg;
  if (width < height) leg = width / 5; else leg = height / 5;
  if (leg < 6) leg = 6;
  AM_AddLit("<polygon points=~");
  AM_AddNum(left + width); AM_AddLit(","); AM_AddNum(top); AM_AddLit(" ");
  AM_AddNum(left + width - leg); AM_AddLit(","); AM_AddNum(top); AM_AddLit(" ");
  AM_AddNum(left + width); AM_AddLit(","); AM_AddNum(top + leg);
  AM_AddLit("~ fill=~"); AM_AddHexColor(color); AM_AddLit("~/>");
];

Constant AM_LABEL_MAX_CHARS = 128;
Constant AM_LABEL_MAX_LINES = 4;
Constant AM_LABEL_PADDING = 8;
Constant AM_LABEL_CHAR_WIDTH_EM100 = 56;  ! 0.56
Constant AM_LABEL_LINE_HEIGHT_EM100 = 115; ! 1.15
Constant AM_SPACE = 32; ! U+0020 space — wrap / skip whitespace
Array AM_label_codepoints --> AM_LABEL_MAX_CHARS;
Array AM_label_line_starts --> AM_LABEL_MAX_LINES;
Array AM_label_line_lengths --> AM_LABEL_MAX_LINES;
Global AM_label_char_count = 0;
Global AM_label_line_count = 0;
Global AM_label_truncated = 0;
[ AM_LoadLabel txt index length codepoint saved_transmute saved_capacity;
  ! Copy Inform text into the label scratch buffer for word wrapping.
  AM_label_char_count = 0;
  if (txt == 0) return;
  saved_capacity = txt-->0;
  saved_transmute = TEXT_TY_Temporarily_Transmute(txt);
  length = TEXT_TY_CharacterLength(txt);
  for (index = 0: index < length: index++) {
    codepoint = BlkValueRead(txt, index);
    if (codepoint == 0) break;
    if (AM_label_char_count < AM_LABEL_MAX_CHARS) {
      AM_label_codepoints-->AM_label_char_count = codepoint;
      AM_label_char_count++;
    }
  }
  TEXT_TY_Untransmute(txt, saved_transmute, saved_capacity);
];
[ AM_WrapLabel max_chars max_lines scan line_start break_at fitted;
  AM_label_line_count = 0;
  AM_label_truncated = 0;
  if (max_chars < 4) max_chars = 4;
  if (max_lines < 1) max_lines = 1;
  if (max_lines > AM_LABEL_MAX_LINES) max_lines = AM_LABEL_MAX_LINES;
  line_start = 0;
  while (line_start < AM_label_char_count && AM_label_line_count < max_lines) {
    while (line_start < AM_label_char_count && AM_label_codepoints-->line_start == AM_SPACE) line_start++;
    if (line_start >= AM_label_char_count) break;
    break_at = -1;
    fitted = 0;
	! Scan for a space or end of the string
    for (scan = line_start: scan <= AM_label_char_count: scan++) {
      if (scan == AM_label_char_count) {
        break_at = scan;
        break;
      }
      if (fitted + 1 > max_chars) break;
      fitted++;
      if (AM_label_codepoints-->scan == AM_SPACE) break_at = scan;
    }
    if (break_at < 0) {
      break_at = line_start + fitted;
    }
    AM_label_line_starts-->AM_label_line_count = line_start;
    AM_label_line_lengths-->AM_label_line_count = break_at - line_start;
    AM_label_line_count++;
    line_start = break_at;
  }
  if (line_start < AM_label_char_count && AM_label_line_count > 0) {
    AM_label_truncated = 1;
    scan = AM_label_line_count - 1;
    if (AM_label_line_lengths-->scan > 1) AM_label_line_lengths-->scan = AM_label_line_lengths-->scan - 1;
  }
];
[ AM_EmitWrappedLabel center_x center_y box_width box_height fill txt
  font_size max_width max_chars max_lines line_height start_y line_index from length char_index;
  font_size = 13;
  max_width = box_width - AM_LABEL_PADDING;
  if (max_width < 24) max_width = 24;
  max_chars = (max_width * 100) / (font_size * AM_LABEL_CHAR_WIDTH_EM100);
  if (max_chars < 4) max_chars = 4;
  max_lines = ((box_height - AM_LABEL_PADDING) * 100) / (font_size * AM_LABEL_LINE_HEIGHT_EM100);
  if (max_lines < 1) max_lines = 1;
  if (max_lines > AM_LABEL_MAX_LINES) max_lines = AM_LABEL_MAX_LINES;
  AM_LoadLabel(txt);
  if (AM_label_char_count == 0) return;
  AM_WrapLabel(max_chars, max_lines);
  if (AM_label_line_count < 1) return;
  line_height = (font_size * AM_LABEL_LINE_HEIGHT_EM100) / 100;
  start_y = center_y - ((AM_label_line_count - 1) * line_height) / 2;
  for (line_index = 0: line_index < AM_label_line_count: line_index++) {
    from = AM_label_line_starts-->line_index;
    length = AM_label_line_lengths-->line_index;
    AM_AddLit("<text x=~"); AM_AddNum(center_x);
    AM_AddLit("~ y=~"); AM_AddNum(start_y + line_index * line_height);
    AM_AddLit("~ text-anchor=~middle~ dominant-baseline=~middle~ font-family=~sans-serif~ font-size=~");
    AM_AddNum(font_size);
    AM_AddLit("~ fill=~"); AM_AddHexColor(fill); AM_AddLit("~>");
    for (char_index = 0: char_index < length: char_index++)
      AM_EscCodepoint(AM_label_codepoints-->(from + char_index));
    if (AM_label_truncated && line_index == AM_label_line_count - 1) AM_AddLit("&#8230;");
    AM_AddLit("</text>");
  }
];
[ AM_EmitBadgeDisc center_x center_y badge_radius paper ink badge_kind;
  AM_AddLit("<circle cx=~"); AM_AddNum(center_x);
  AM_AddLit("~ cy=~"); AM_AddNum(center_y);
  AM_AddLit("~ r=~"); AM_AddNum(badge_radius);
  AM_AddLit("~ fill=~"); AM_AddHexColor(paper);
  AM_AddLit("~ stroke=~"); AM_AddHexColor(ink);
  AM_AddLit("~ stroke-width=~1.25~/>");
  if (badge_kind == AM_BADGE_KIND_IN) {
	! Letter I
    AM_AddLit("<rect x=~"); AM_AddNum(center_x-1);
    AM_AddLit("~ y=~"); AM_AddNum(center_y-4);
    AM_AddLit("~ width=~2~ height=~8~ fill=~"); AM_AddHexColor(ink);
    AM_AddLit("~/>");
  } else if (badge_kind == AM_BADGE_KIND_OUT) {
	! Letter O
    AM_AddLit("<circle cx=~"); AM_AddNum(center_x);
    AM_AddLit("~ cy=~"); AM_AddNum(center_y);
    AM_AddLit("~ r=~3~ fill=~none~ stroke=~"); AM_AddHexColor(ink);
    AM_AddLit("~ stroke-width=~2~/>");
  } else if (badge_kind == AM_BADGE_KIND_UP) {
	! Up Arrow
    AM_AddLit("<polygon points=~");
    AM_AddNum(center_x); AM_AddLit(","); AM_AddNum(center_y-5); AM_AddLit(" ");
    AM_AddNum(center_x-4); AM_AddLit(","); AM_AddNum(center_y+3); AM_AddLit(" ");
    AM_AddNum(center_x+4); AM_AddLit(","); AM_AddNum(center_y+3);
    AM_AddLit("~ fill=~"); AM_AddHexColor(ink); AM_AddLit("~/>");
  } else {
	! Down Arrow
    AM_AddLit("<polygon points=~");
    AM_AddNum(center_x); AM_AddLit(","); AM_AddNum(center_y+5); AM_AddLit(" ");
    AM_AddNum(center_x-4); AM_AddLit(","); AM_AddNum(center_y-3); AM_AddLit(" ");
    AM_AddNum(center_x+4); AM_AddLit(","); AM_AddNum(center_y-3);
    AM_AddLit("~ fill=~"); AM_AddHexColor(ink); AM_AddLit("~/>");
  }
];
-).


To append svg open viewBox min-x (min-x - a number) min-y (min-y - a number) width (view-width - a number) height (view-height - a number):
	(- AM_EmitSvgOpen({min-x}, {min-y}, {view-width}, {view-height}); -).


To append svg cubic from (start-x - a number) and (start-y - a number) via (control1-x - a number) and (control1-y - a number) and (control2-x - a number) and (control2-y - a number) to (end-x - a number) and (end-y - a number) color (color - a number):
	(- AM_EmitCubic({start-x}, {start-y}, {control1-x}, {control1-y}, {control2-x}, {control2-y}, {end-x}, {end-y}, {color}); -).


To append svg line from (start-x - a number) and (start-y - a number) to (end-x - a number) and (end-y - a number) color (color - a number):
	(- AM_EmitLine({start-x}, {start-y}, {end-x}, {end-y}, {color}); -).


To emit the stored automap bent connector svg color (color - a number):
	(- AM_EmitStoredBentCubic({color}); -).


To stage the stored automap bent connector from (start-x - a number) and (start-y - a number) to (end-x - a number) and (end-y - a number) with (mid-count - a number) mids:
	(- AM_bent_sx = {start-x}; AM_bent_sy = {start-y}; AM_bent_ex = {end-x}; AM_bent_ey = {end-y}; AM_bent_count = {mid-count}; -).

To set automap bent midpoint (seq - a number) to (mx - a number) and (my - a number):
	(- AM_SetBentMidpoint({seq}, {mx}, {my}); -).


To append svg arrow at (tip-x - a number) and (tip-y - a number) for vector (dx - a number) and (dy - a number) color (color - a number):
	(- AM_EmitArrowVector({tip-x}, {tip-y}, {dx}, {dy}, {color}); -).


To append svg arrow at (tip-x - a number) and (tip-y - a number) way-code (way - a number) color (color - a number):
	(- AM_EmitArrow({tip-x}, {tip-y}, {way}, {color}); -).


To append svg room rect at (left - a number) and (top - a number) size (width - a number) by (height - a number) fill (fill - a number) stroke (stroke - a number) width-tenths (stroke-tenths - a number):
	(- AM_EmitRoomRect({left}, {top}, {width}, {height}, {fill}, {stroke}, {stroke-tenths}); -).


To append svg dark corner at (left - a number) and (top - a number) size (width - a number) by (height - a number) color (color - a number):
	(- AM_EmitDarkCorner({left}, {top}, {width}, {height}, {color}); -).


To append svg wrapped label (svg-text - text) at (center-x - a number) and (center-y - a number) size (width - a number) by (height - a number) color (fill - a number):
	(- AM_EmitWrappedLabel({center-x}, {center-y}, {width}, {height}, {fill}, {svg-text}); -).


To append svg badge disc at (center-x - a number) and (center-y - a number) radius (badge-radius - a number) paper (paper - a number) ink (ink - a number) badge kind (badge-kind - a number):
	(- AM_EmitBadgeDisc({center-x}, {center-y}, {badge-radius}, {paper}, {ink}, {badge-kind}); -).


Part - Layout

Chapter - Pixel geometry

To decide what number is the map pixel x of (subject - a room):
	unless subject is on the automap, decide on 0;
	decide on the map x of subject * automap scale.

To decide what number is the map pixel y of (subject - a room):
	unless subject is on the automap, decide on 0;
	decide on the map y of subject * automap scale.

To decide what number is the map pixel width of (subject - a room):
	unless subject is on the automap, decide on 0;
	decide on the map width of subject * automap scale.

To decide what number is the map pixel height of (subject - a room):
	unless subject is on the automap, decide on 0;
	decide on the map height of subject * automap scale.


Chapter - Ports and stubs

[Each room has 16 "ports", including 8 cardinal compass directions and 8 "half-wind" ports (NNE, ENE, ESE, SSE, SSW, WSW, WNW, NNW). We attach connectors to ports, and we also position in/out/up/down badges on ports.]

To decide what number is the automap corner port inset:
	(- AM_CornerPortInset() -).

To decide what number is the port x of (subject - a room) for (way - a direction):
	let pixel-x be the map pixel x of subject;
	let pixel-width be the map pixel width of subject;
	let inset be the automap corner port inset;
	if way is north or way is south, decide on pixel-x + (pixel-width / 2);
	if way is east, decide on pixel-x + pixel-width;
	if way is west, decide on pixel-x;
	if way is northeast or way is southeast, decide on pixel-x + pixel-width - inset;
	if way is northwest or way is southwest, decide on pixel-x + inset;
	decide on pixel-x + (pixel-width / 2).

To decide what number is the port y of (subject - a room) for (way - a direction):
	let pixel-y be the map pixel y of subject;
	let pixel-height be the map pixel height of subject;
	let inset be the automap corner port inset;
	if way is east or way is west, decide on pixel-y + (pixel-height / 2);
	if way is south, decide on pixel-y + pixel-height;
	if way is north, decide on pixel-y;
	if way is northeast or way is northwest, decide on pixel-y + inset;
	if way is southeast or way is southwest, decide on pixel-y + pixel-height - inset;
	decide on pixel-y + (pixel-height / 2).

[Stubs are short arrows pointing into empty space, representing exits into unseen rooms.]

To decide what number is the stub delta x for (way - a direction):
	let scale be automap scale + (automap scale / 2);
	if way is east or way is northeast or way is southeast, decide on scale;
	if way is west or way is northwest or way is southwest, decide on 0 - scale;
	decide on 0.

To decide what number is the stub delta y for (way - a direction):
	let scale be automap scale + (automap scale / 2);
	if way is south or way is southeast or way is southwest, decide on scale;
	if way is north or way is northeast or way is northwest, decide on 0 - scale;
	decide on 0.


Chapter - Bezier Curves

Include (-
[ AM_ISqrt value root bit;
  ! Integer square root (bit method). value must be non-negative.
  if (value <= 0) return 0;
  root = 0;
  bit = $40000000;
  while (bit > value) bit = bit / 4;
  while (bit) {
    if (value >= root + bit) {
      value = value - root - bit;
      root = root / 2 + bit;
    } else root = root / 2;
    bit = bit / 4;
  }
  return root;
];
-).


To decide what number is the integer square root of (amount - a number):
	(- AM_ISqrt({amount}) -).


[GetBezierAssister: control point that bends a compass connector out of the room in `way`.]
To decide what number is the bezier span of (start-x - a number) and (start-y - a number) to (end-x - a number) and (end-y - a number):
	let delta-x be end-x - start-x;
	let delta-y be end-y - start-y;
	if delta-x < 0, now delta-x is 0 - delta-x;
	if delta-y < 0, now delta-y is 0 - delta-y;
	[Avoid overflow on huge separations: clamp before squaring.]
	if delta-x > 20000, now delta-x is 20000;
	if delta-y > 20000, now delta-y is 20000;
	let dist be the integer square root of (delta-x * delta-x + delta-y * delta-y);
	if dist < 1, decide on 1;
	decide on dist.

To decide what number is the bezier offset of (dist - a number) across (extent - a number):
	let scale be automap scale;
	if scale < 1, now scale is 1;
	if extent < 1, now extent is 1;
	let offset be (dist * 40) / scale;
	now offset is offset / extent;
	if offset > 60, decide on 60;
	decide on offset.

To decide what number is the bezier assister x of (subject - a room) for (way - a direction) span (dist - a number):
	let offset-x be the bezier offset of dist across the map width of subject;
	let offset-y be the bezier offset of dist across the map height of subject;
	let pixel-x be the map pixel x of subject;
	let pixel-width be the map pixel width of subject;
	let percent-x be 50;
	if way is north or way is south:
		now percent-x is 50;
	if way is east:
		now percent-x is 100 + offset-x;
	if way is west:
		now percent-x is 0 - offset-x;
	if way is northeast or way is southeast:
		now percent-x is 100 + ((3 * offset-x) / 4);
	if way is northwest or way is southwest:
		now percent-x is 0 - ((3 * offset-x) / 4);
	decide on pixel-x + ((pixel-width * percent-x) / 100).

To decide what number is the bezier assister y of (subject - a room) for (way - a direction) span (dist - a number):
	let offset-x be the bezier offset of dist across the map width of subject;
	let offset-y be the bezier offset of dist across the map height of subject;
	let pixel-y be the map pixel y of subject;
	let pixel-height be the map pixel height of subject;
	let percent-y be 50;
	if way is east or way is west:
		now percent-y is 50;
	if way is south:
		now percent-y is 100 + offset-y;
	if way is north:
		now percent-y is 0 - offset-y;
	if way is southeast or way is southwest:
		now percent-y is 100 + (offset-y / 2);
	if way is northeast or way is northwest:
		now percent-y is 0 - (offset-y / 2);
	decide on pixel-y + ((pixel-height * percent-y) / 100).


Chapter - Badge ports

[Each Up/Down/In/Out badge faces its destination room, on a
 "half-wind" site of that edge. Compass-twin exits position the badge on the twin's port
 and omit the badge-to-badge connector.]

To decide which direction is the map facing edge from (subject - a room) to (destination - a room):
	let room-x be the map x of subject;
	let room-width be the map width of subject;
	let delta-x be the map x of destination;
	let dest-width be the map width of destination;
	let room-y be the map y of subject;
	let delta-y be the map y of destination;
	if delta-x > room-x + room-width, decide on east;
	if delta-x + dest-width < room-x, decide on west;
	if delta-y > room-y, decide on south;
	decide on north.

To decide what number is the in-out badge percent x for (way - a direction) facing (edge - a direction):
	[Opposite half-winds on the facing edge (ptIn/ptOut).]
	if edge is east:
		if way is inside, decide on 100;
		decide on 100;
	if edge is west:
		if way is inside, decide on 0;
		decide on 0;
	if edge is south:
		if way is inside, decide on 75;
		decide on 25;
	if way is inside, decide on 25;
	decide on 75.

To decide what number is the in-out badge percent y for (way - a direction) facing (edge - a direction):
	if edge is east:
		if way is inside, decide on 25;
		decide on 75;
	if edge is west:
		if way is inside, decide on 75;
		decide on 25;
	if edge is south:
		decide on 100;
	decide on 0.

To decide what number is the up-down badge percent x for (way - a direction) facing (edge - a direction):
	if edge is east:
		decide on 100;
	if edge is west:
		decide on 0;
	if edge is south:
		if way is up, decide on 75;
		decide on 25;
	if way is up, decide on 75;
	decide on 25.

To decide what number is the up-down badge percent y for (way - a direction) facing (edge - a direction):
	if edge is east:
		if way is up, decide on 25;
		decide on 75;
	if edge is west:
		if way is up, decide on 25;
		decide on 75;
	if edge is south:
		decide on 100;
	decide on 0.

To decide what number is the alternate badge percent x of (percent-x - a number) and (percent-y - a number):
	[Swap to the adjacent corner half-wind when Up/Down collides with In/Out.]
	if percent-x is 100 and percent-y is 25, decide on 75; [ENE -> NNE]
	if percent-x is 100 and percent-y is 75, decide on 75; [ESE -> SSE]
	if percent-x is 0 and percent-y is 25, decide on 25; [WNW -> NNW]
	if percent-x is 0 and percent-y is 75, decide on 25; [WSW -> SSW]
	if percent-x is 75 and percent-y is 0, decide on 100; [NNE -> ENE]
	if percent-x is 25 and percent-y is 0, decide on 0; [NNW -> WNW]
	if percent-x is 75 and percent-y is 100, decide on 100; [SSE -> ESE]
	if percent-x is 25 and percent-y is 100, decide on 0; [SSW -> WSW]
	decide on percent-x.

To decide what number is the alternate badge percent y of (percent-x - a number) and (percent-y - a number):
	if percent-x is 100 and percent-y is 25, decide on 0;
	if percent-x is 100 and percent-y is 75, decide on 100;
	if percent-x is 0 and percent-y is 25, decide on 0;
	if percent-x is 0 and percent-y is 75, decide on 100;
	if percent-x is 75 and percent-y is 0, decide on 25;
	if percent-x is 25 and percent-y is 0, decide on 25;
	if percent-x is 75 and percent-y is 100, decide on 75;
	if percent-x is 25 and percent-y is 100, decide on 75;
	decide on percent-y.

To decide whether (subject - a room) has an in-out badge at percent (percent-x - a number) and (percent-y - a number):
	repeat with in-out-way running through {inside, outside}:
		let dest be the room in-out-way from subject;
		if dest is a room and dest is on the automap:
			let edge be the map facing edge from subject to dest;
			if the in-out badge percent x for in-out-way facing edge is percent-x and the in-out badge percent y for in-out-way facing edge is percent-y:
				yes;
	no.

To decide what number is the faced badge percent x for (way - a direction) on (subject - a room) facing (destination - a room):
	let edge be the map facing edge from subject to destination;
	if way is inside or way is outside:
		decide on the in-out badge percent x for way facing edge;
	if way is up or way is down:
		let percent-x be the up-down badge percent x for way facing edge;
		let percent-y be the up-down badge percent y for way facing edge;
		if subject has an in-out badge at percent percent-x and percent-y:
			decide on the alternate badge percent x of percent-x and percent-y;
		decide on percent-x;
	decide on 50.

To decide what number is the faced badge percent y for (way - a direction) on (subject - a room) facing (destination - a room):
	let edge be the map facing edge from subject to destination;
	if way is inside or way is outside:
		decide on the in-out badge percent y for way facing edge;
	if way is up or way is down:
		let percent-x be the up-down badge percent x for way facing edge;
		let percent-y be the up-down badge percent y for way facing edge;
		if subject has an in-out badge at percent percent-x and percent-y:
			decide on the alternate badge percent y of percent-x and percent-y;
		decide on percent-y;
	decide on 50.

To decide what number is the badge port percent x of (subject - a room) for (way - a direction):
	let dest be the room way from subject;
	if dest is a room and dest is on the automap:
		decide on the faced badge percent x for way on subject facing dest;
	[A4 fallback when the exit has no map node to face.]
	if way is up, decide on 75;
	if way is down, decide on 25;
	if way is inside, decide on 0;
	if way is outside, decide on 100;
	decide on 50.

To decide what number is the badge port percent y of (subject - a room) for (way - a direction):
	let dest be the room way from subject;
	if dest is a room and dest is on the automap:
		decide on the faced badge percent y for way on subject facing dest;
	if way is up, decide on 0;
	if way is down, decide on 100;
	if way is inside, decide on 25;
	if way is outside, decide on 75;
	decide on 50.

To decide what number is the badge x of (subject - a room) for (way - a direction):
	let dest be the room way from subject;
	if dest is a room and subject has a compass twin to dest:
		let twin be the compass twin from subject to dest;
		decide on the port x of subject for twin;
	let pixel-x be the map pixel x of subject;
	let pixel-width be the map pixel width of subject;
	decide on pixel-x + ((pixel-width * the badge port percent x of subject for way) / 100).

To decide what number is the badge y of (subject - a room) for (way - a direction):
	let dest be the room way from subject;
	if dest is a room and subject has a compass twin to dest:
		let twin be the compass twin from subject to dest;
		decide on the port y of subject for twin;
	let pixel-y be the map pixel y of subject;
	let pixel-height be the map pixel height of subject;
	decide on pixel-y + ((pixel-height * the badge port percent y of subject for way) / 100).

[Arrival end of a badge connector on destination.]
To decide what number is the arrival badge x on (destination - a room) facing (subject - a room) for (arrival - a direction):
	if destination has a compass twin to subject:
		let twin be the compass twin from destination to subject;
		decide on the port x of destination for twin;
	if the room arrival from destination is a room:
		decide on the badge x of destination for arrival;
	let pixel-x be the map pixel x of destination;
	let pixel-width be the map pixel width of destination;
	decide on pixel-x + ((pixel-width * the faced badge percent x for arrival on destination facing subject) / 100).

To decide what number is the arrival badge y on (destination - a room) facing (subject - a room) for (arrival - a direction):
	if destination has a compass twin to subject:
		let twin be the compass twin from destination to subject;
		decide on the port y of destination for twin;
	if the room arrival from destination is a room:
		decide on the badge y of destination for arrival;
	let pixel-y be the map pixel y of destination;
	let pixel-height be the map pixel height of destination;
	decide on pixel-y + ((pixel-height * the faced badge percent y for arrival on destination facing subject) / 100).


Chapter - Scene composers

To append the arrow svg at (tip-x - a number) and (tip-y - a number) for (way - a direction) in (color - a number):
	let way-facing be the map facing of way;
	let way-code be 8;
	if way-facing is north, now way-code is 0;
	if way-facing is south, now way-code is 1;
	if way-facing is east, now way-code is 2;
	if way-facing is west, now way-code is 3;
	if way-facing is northeast, now way-code is 4;
	if way-facing is southeast, now way-code is 5;
	if way-facing is southwest, now way-code is 6;
	if way-facing is northwest, now way-code is 7;
	append svg arrow at tip-x and tip-y way-code way-code color color.

[Paper disc + ink stroke; I/O glyphs and Up/Down triangles (PR #170).]
To append the badge disc at (center-x - a number) and (center-y - a number) for (way - a direction):
	let paper be the automap paper color;
	let ink be the automap ink color;
	let badge-radius be automap badge radius;
	let badge-kind be AM badge kind in;
	if way is outside, now badge-kind is AM badge kind out;
	if way is up, now badge-kind is AM badge kind up;
	if way is down, now badge-kind is AM badge kind down;
	append svg badge disc at center-x and center-y radius badge-radius paper paper ink ink badge kind badge-kind.

[Paint from frozen drawn-* discovery, not live lighting. Here-fill still follows
 the real location so leave/enter updates immediately.]
To append the automap normal room svg for (subject - a room):
	let room-fill be the automap room fill color;
	let room-stroke be the automap room stroke color;
	let room-label be the automap room label color;
	let here-fill be the automap here fill color;
	let here-stroke be the automap here stroke color;
	let here-label be the automap here label color;
	let ink be the automap ink color;
	let pixel-x be the map pixel x of subject;
	let pixel-y be the map pixel y of subject;
	let pixel-width be the map pixel width of subject;
	let pixel-height be the map pixel height of subject;
	let fill-color be room-fill;
	let stroke-color be room-stroke;
	let label-color be room-label;
	let stroke-tenths be 15; [1.5 as tenths]
	if subject is the location:
		now stroke-tenths is 30;
		now fill-color is here-fill;
		now stroke-color is here-stroke;
		now label-color is here-label;
	[Off-level: wrap card + label (+ dark corner) so everything dims together.]
	if subject is automap-dimmed:
		append svg lit "<g opacity='0.35'>";
	append svg room rect at pixel-x and pixel-y size pixel-width by pixel-height fill fill-color stroke stroke-color width-tenths stroke-tenths;
	if subject is automap-drawn-dark:
		append svg dark corner at pixel-x and pixel-y size pixel-width by pixel-height color ink;
	let center-x be pixel-x + (pixel-width / 2);
	let center-y be pixel-y + (pixel-height / 2);
	let label be the automap label of subject;
	append svg wrapped label label at center-x and center-y size pixel-width by pixel-height color label-color;
	if subject is automap-dimmed:
		append svg lit "</g>".


Part - Runtime

Chapter - ViewBox and base present

[SVGs have a "viewBox" attribute, consisting of four numbers separated by spaces: min-x, min-y, width, and height. This declares the total size of the SVG canvas; every element in the SVG must be positioned inside the viewBox in order to be visible.]

[We compute the viewBox by measuring the positions of all of the rooms on the current map page, including rooms that are not (yet) visible. Glk Mapping allows us to focus the map and zoom in on the current room, so having a large canvas that reserves space for other rooms is fine.]

The automap view origin x is a number that varies.
The automap view origin y is a number that varies.
The automap view width is a number that varies.
The automap view height is a number that varies.

To compute the automap viewBox:
	let min-x be 100000;
	let min-y be 100000;
	let max-x be -100000;
	let max-y be -100000;
	let any be false;
	let max-geo-w be 0;
	let max-geo-h be 0;
	repeat with subject running through rooms:
		if subject is on the automap:
			now any is true;
			let geo-w be the map width of subject;
			let geo-h be the map height of subject;
			if geo-w > max-geo-w, now max-geo-w is geo-w;
			if geo-h > max-geo-h, now max-geo-h is geo-h;
			let room-left be the map pixel x of subject;
			let room-top be the map pixel y of subject;
			let room-right be room-left + the map pixel width of subject;
			let room-bottom be room-top + the map pixel height of subject;
			if room-left < min-x, now min-x is room-left;
			if room-top < min-y, now min-y is room-top;
			if room-right > max-x, now max-x is room-right;
			if room-bottom > max-y, now max-y is room-bottom;
	if any is false:
		now the automap view origin x is 0;
		now the automap view origin y is 0;
		now the automap view width is 0;
		now the automap view height is 0;
		stop;
	let scale be automap scale;
	[Conservatively estimate extra padding from connectors.]
	let connector-pad be scale + (scale / 2);
	if automap badge radius > connector-pad:
		now connector-pad is automap badge radius;
	let bezier-x be (60 * max-geo-w * scale) / 100;
	let bezier-y be (60 * max-geo-h * scale) / 100;
	if bezier-x > connector-pad, now connector-pad is bezier-x;
	if bezier-y > connector-pad, now connector-pad is bezier-y;
	let pad be scale + connector-pad;
	now min-x is min-x - pad;
	now min-y is min-y - pad;
	now max-x is max-x + pad;
	now max-y is max-y + pad;
	now the automap view origin x is min-x;
	now the automap view origin y is min-y;
	now the automap view width is max-x - min-x;
	now the automap view height is max-y - min-y.

To ensure the automap view geometry is ready:
	unless automap base geometry ready is true:
		sync automap dense room ids;
		compute the automap viewBox;
		now automap base geometry ready is true.

Automap full rebuild needed is a truth state that varies. Automap full rebuild needed is initially true.
[The base map is ready when we successfully call glk_map_present_svg. (We present a blank map; all of the rooms, connectors, and badges are overlays.)]
Automap base map ready is a truth state that varies. Automap base map ready is initially false.
[The base geometry includes the viewbox and the dense room IDs.]
Automap base geometry ready is a truth state that varies. Automap base geometry ready is initially false.
[Rooms to resync after movement. Usually one prior room; teleports / multi-hop
 turns may queue several (going origin/dest plus any newly visited map rooms).]
The automap previous locations is a list of objects that varies.

To note automap previous location (R - an object):
	if R is a room and R has automap geometry:
		unless R is listed in the automap previous locations:
			add R to the automap previous locations.

To gather newly visited automap previous locations:
	[Silent teleports mark visited without going; pick those up at refresh.]
	repeat with subject running through rooms:
		if subject is map-visible and subject is visited and subject is not automap-discovered:
			note automap previous location subject.

To reset automap previous locations to the current room:
	truncate the automap previous locations to 0 entries;
	note automap previous location the location.

To mark the automap full rebuild needed:
	now automap full rebuild needed is true.

To mark the automap full rebuild needed because (reason - text):
	now automap full rebuild needed is true.

To invalidate the automap base geometry:
	now automap base map ready is false;
	now automap base geometry ready is false.

To clear the automap base:
	now automap base map ready is false.


To decide whether we present the automap blank base focusing on left (focus-left - a number) top (focus-top - a number) width (focus-width - a number) height (focus-height - a number):
	let min-x be the automap view origin x;
	let min-y be the automap view origin y;
	let view-width be the automap view width;
	let view-height be the automap view height;
	clear the automap svg buffer;
	if view-width < 1 or view-height < 1:
		now the automap view origin x is 0;
		now the automap view origin y is 0;
		append svg lit "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 40 40'><text x='8' y='22' font-size='10' fill='#666'>No map</text></svg>";
		present map SVG buffer of length (the automap svg buffer length) background color (the automap paper color) focusing on left 0 top 0 width 0 height 0;
		no;
	append svg open viewBox min-x min-x min-y min-y width view-width height view-height;
	append svg lit "<rect x='";
	append svg number min-x;
	append svg lit "' y='";
	append svg number min-y;
	append svg lit "' width='";
	append svg number view-width;
	append svg lit "' height='";
	append svg number view-height;
	append svg lit "' fill='none'/>";
	append svg lit "</svg>";
	if we successfully present map SVG buffer of length (the automap svg buffer length) background color (the automap paper color) focusing on left focus-left top focus-top width focus-width height focus-height:
		yes;
	no.

To sync the automap base focusing on left (focus-left - a number) top (focus-top - a number) width (focus-width - a number) height (focus-height - a number):
	ensure the automap view geometry is ready;
	if we present the automap blank base focusing on left focus-left top focus-top width focus-width height focus-height:
		now automap base map ready is true;
	else:
		now automap base map ready is false.


Chapter - Install overlays

Automap room overlay pad is a number that varies. Automap room overlay pad is 4.
Automap badge radius is a number that varies. Automap badge radius is 8.

To install the automap badge from (subject - a room) for (way - a direction):
	let dense-room-id be the automap dense room id of subject;
	if dense-room-id < 1, stop;
	let way-index be the automap way index of way;
	clear the automap badge index at dense dense-room-id way way-index;
	unless subject has a live automap badge for way:
		stop;
	let badge-x be the badge x of subject for way;
	let badge-y be the badge y of subject for way;
	let badge-radius be automap badge radius;
	[Stroke is 1.25 wide (extends ~0.63 beyond r). Use an explicit margin:
	 Inform 6M62 compiles "badge-x - badge-radius - pad" as BX-(BR-pad), which undersized the
	 viewBox (margin 6 instead of 10) and clipped disc + triangle tips.]
	let pad be 2;
	let margin be badge-radius + pad;
	let view-left be badge-x - margin;
	let view-top be badge-y - margin;
	let view-width be margin + margin;
	let view-height be margin + margin;
	clear the automap svg buffer;
	append svg open viewBox min-x view-left min-y view-top width view-width height view-height;
	if subject is automap-dimmed:
		append svg lit "<g opacity='0.35'>";
	append the badge disc at badge-x and badge-y for way;
	if subject is automap-dimmed:
		append svg lit "</g>";
	append svg lit "</svg>";
	let draw-left be view-left - the automap view origin x;
	let draw-top be view-top - the automap view origin y;
	let overlay-id be the map svg overlay of length (the automap svg buffer length) at left draw-left top draw-top width view-width height view-height z-index 20;
	set the automap badge overlay at dense dense-room-id way way-index to overlay-id;
	if overlay-id < 1:
		mark the automap full rebuild needed because "overlay-id-0".

To install the automap room overlay for (subject - a room):
	let old be the automap overlay id of subject;
	if old > 0:
		clear map overlay old;
		now the automap overlay id of subject is 0;
	unless subject is map-visible, stop;
	let pixel-x be the map pixel x of subject;
	let pixel-y be the map pixel y of subject;
	let pixel-width be the map pixel width of subject;
	let pixel-height be the map pixel height of subject;
	if pixel-width < 1 or pixel-height < 1, stop;
	let pad be automap room overlay pad;
	let view-left be pixel-x - pad;
	let view-top be pixel-y - pad;
	let view-width be pixel-width + pad + pad;
	let view-height be pixel-height + pad + pad;
	clear the automap svg buffer;
	append svg open viewBox min-x view-left min-y view-top width view-width height view-height;
	append the automap normal room svg for subject;
	append svg lit "</svg>";
	let draw-left be view-left - the automap view origin x;
	let draw-top be view-top - the automap view origin y;
	let linkid be 0;
	if automap hyperlinks enabled is true:
		let dense-id be the automap dense room id of subject;
		if dense-id > 0:
			now linkid is dense-id;
	let overlay-id be the map svg overlay of length (the automap svg buffer length) at left draw-left top draw-top width view-width height view-height z-index 10 link id linkid labeled (the automap label of subject);
	now the automap overlay id of subject is overlay-id;
	if overlay-id < 1:
		mark the automap full rebuild needed because "overlay-id-0".

To decide what number is the am-min of (first-value - a number) and (second-value - a number):
	if first-value < second-value, decide on first-value;
	decide on second-value.

To decide what number is the am-max of (first-value - a number) and (second-value - a number):
	if first-value > second-value, decide on first-value;
	decide on second-value.

To extend automap overlay bounds with bent connector midpoints from (subject - a room) via (way - a direction):
	let mid-count be the automap connector midpoint count from subject via way;
	if mid-count < 1, stop;
	repeat with seq running from 1 to mid-count:
		let mx be the automap connector midpoint x from subject via way index seq;
		let my be the automap connector midpoint y from subject via way index seq;
		extend automap overlay bounds with x (the map pixel x of automap midpoint mx) and y (the map pixel y of automap midpoint my).

To append the bent automap connector from (start-x - a number) and (start-y - a number) to (end-x - a number) and (end-y - a number) from (subject - a room) via (way - a direction) color (color - a number) drawing arrow (draw-arrow - a truth state):
	let mid-count be the automap connector midpoint count from subject via way;
	stage the stored automap bent connector from start-x and start-y to end-x and end-y with mid-count mids;
	repeat with seq running from 1 to mid-count:
		let mx be the automap connector midpoint x from subject via way index seq;
		let my be the automap connector midpoint y from subject via way index seq;
		set automap bent midpoint seq to (the map pixel x of automap midpoint mx) and (the map pixel y of automap midpoint my);
	emit the stored automap bent connector svg color color;
	if draw-arrow is false, stop;
	let prev-x be start-x;
	let prev-y be start-y;
	if mid-count >= 1:
		let last-mx be the automap connector midpoint x from subject via way index mid-count;
		let last-my be the automap connector midpoint y from subject via way index mid-count;
		now prev-x is the map pixel x of automap midpoint last-mx;
		now prev-y is the map pixel y of automap midpoint last-my;
	let arrow-dx be end-x - prev-x;
	let arrow-dy be end-y - prev-y;
	append svg arrow at end-x and end-y for vector arrow-dx and arrow-dy color color.

To append the automap connector primitives from (subject - a room) for (way - a direction) of kind (kind - a number):
	let connector-color be the automap connector color;
	let stub-color be the automap stub color;
	if kind is AM connector kind stub:
		let way-facing be the map facing of way;
		let start-x be the port x of subject for way-facing;
		let start-y be the port y of subject for way-facing;
		let end-x be start-x + the stub delta x for way-facing;
		let end-y be start-y + the stub delta y for way-facing;
		append svg line from start-x and start-y to end-x and end-y color stub-color;
		append the arrow svg at end-x and end-y for way-facing in stub-color;
	else if kind is AM connector kind compass link:
		let way-facing be the map facing of way;
		let dest be the room way from subject;
		let back be the opposite of way;
		let back-facing be the map facing of back;
		let start-x be the port x of subject for way-facing;
		let start-y be the port y of subject for way-facing;
		let end-x be the port x of dest for back-facing;
		let end-y be the port y of dest for back-facing;
		let mid-count be the automap connector midpoint count from subject via way;
		if mid-count > 0:
			let draw-arrow be false;
			unless the room back from dest is subject:
				now draw-arrow is true;
			append the bent automap connector from start-x and start-y to end-x and end-y from subject via way color connector-color drawing arrow draw-arrow;
		else if start-x and start-y to end-x and end-y forms a straight diagonal:
			append svg line from start-x and start-y to end-x and end-y color connector-color;
		else:
			let dist be the bezier span of start-x and start-y to end-x and end-y;
			let control1-x be the bezier assister x of subject for way-facing span dist;
			let control1-y be the bezier assister y of subject for way-facing span dist;
			let control2-x be the bezier assister x of dest for back-facing span dist;
			let control2-y be the bezier assister y of dest for back-facing span dist;
			append svg cubic from start-x and start-y via control1-x and control1-y and control2-x and control2-y to end-x and end-y color connector-color;
		unless the room back from dest is subject:
			if mid-count is 0:
				append the arrow svg at end-x and end-y for way-facing in connector-color;
	else:
		let dest be the room way from subject;
		let back be the badge opposite of way;
		let start-x be the badge x of subject for way;
		let start-y be the badge y of subject for way;
		let end-x be the arrival badge x on dest facing subject for back;
		let end-y be the arrival badge y on dest facing subject for back;
		let mid-count be the automap connector midpoint count from subject via way;
		if mid-count > 0:
			let draw-arrow be false;
			unless the room back from dest is subject:
				now draw-arrow is true;
			append the bent automap connector from start-x and start-y to end-x and end-y from subject via way color connector-color drawing arrow draw-arrow;
		else if start-x and start-y to end-x and end-y forms a straight diagonal:
			append svg line from start-x and start-y to end-x and end-y color connector-color;
		else:
			let edge-out be the map facing edge from subject to dest;
			let edge-in be the map facing edge from dest to subject;
			let dist be the bezier span of start-x and start-y to end-x and end-y;
			let control1-x be the bezier assister x of subject for edge-out span dist;
			let control1-y be the bezier assister y of subject for edge-out span dist;
			let control2-x be the bezier assister x of dest for edge-in span dist;
			let control2-y be the bezier assister y of dest for edge-in span dist;
			append svg cubic from start-x and start-y via control1-x and control1-y and control2-x and control2-y to end-x and end-y color connector-color;
		unless the room back from dest is subject:
			if mid-count is 0:
				let tip be the map facing edge from subject to dest;
				append the arrow svg at end-x and end-y for tip in connector-color.

Include (-
Global AM_ovminx;
Global AM_ovminy;
Global AM_ovmaxx;
Global AM_ovmaxy;

[ AM_OverlayBoundsReset;
  AM_ovminx = 100000; AM_ovminy = 100000;
  AM_ovmaxx = -100000; AM_ovmaxy = -100000;
];

[ AM_OverlayBoundsInclude x y;
  if (x < AM_ovminx) AM_ovminx = x;
  if (x > AM_ovmaxx) AM_ovmaxx = x;
  if (y < AM_ovminy) AM_ovminy = y;
  if (y > AM_ovmaxy) AM_ovmaxy = y;
];
-).

To reset automap overlay bounds:
	(- AM_OverlayBoundsReset(); -).

To extend automap overlay bounds with x (X - a number) and y (Y - a number):
	(- AM_OverlayBoundsInclude({X}, {Y}); -).

To decide what number is the automap overlay min x:
	(- AM_ovminx -).

To decide what number is the automap overlay min y:
	(- AM_ovminy -).

To decide what number is the automap overlay max x:
	(- AM_ovmaxx -).

To decide what number is the automap overlay max y:
	(- AM_ovmaxy -).

To build automap stub connector svg from (subject - a room) for (way - a direction):
	reset automap overlay bounds;
	clear the automap svg buffer;
	let way-facing be the map facing of way;
	let start-x be the port x of subject for way-facing;
	let start-y be the port y of subject for way-facing;
	let end-x be start-x + the stub delta x for way-facing;
	let end-y be start-y + the stub delta y for way-facing;
	extend automap overlay bounds with x start-x and y start-y;
	extend automap overlay bounds with x end-x and y end-y;
	let min-x be the automap overlay min x;
	let min-y be the automap overlay min y;
	let max-x be the automap overlay max x;
	let max-y be the automap overlay max y;
	append svg open viewBox min-x (min-x - AM connector view pad) min-y (min-y - AM connector view pad) width (max-x - min-x + AM connector view pad + AM connector view pad) height (max-y - min-y + AM connector view pad + AM connector view pad);
	append the automap connector primitives from subject for way of kind AM connector kind stub;
	append svg lit "</svg>".

To begin automap compass connector svg from (subject - a room) for (way - a direction):
	reset automap overlay bounds;
	clear the automap svg buffer;
	let way-facing be the map facing of way;
	let dest be the room way from subject;
	let back be the opposite of way;
	let back-facing be the map facing of back;
	let start-x be the port x of subject for way-facing;
	let start-y be the port y of subject for way-facing;
	extend automap overlay bounds with x start-x and y start-y;
	let end-x be the port x of dest for back-facing;
	let end-y be the port y of dest for back-facing;
	extend automap overlay bounds with x end-x and y end-y.

To finish automap compass connector svg from (subject - a room) for (way - a direction):
	let way-facing be the map facing of way;
	let dest be the room way from subject;
	let back be the opposite of way;
	let back-facing be the map facing of back;
	let start-x be the port x of subject for way-facing;
	let start-y be the port y of subject for way-facing;
	let end-x be the port x of dest for back-facing;
	let end-y be the port y of dest for back-facing;
	let mid-count be the automap connector midpoint count from subject via way;
	if mid-count > 0:
		extend automap overlay bounds with bent connector midpoints from subject via way;
	else unless start-x and start-y to end-x and end-y forms a straight diagonal:
		let dist be the bezier span of start-x and start-y to end-x and end-y;
		let control1-x be the bezier assister x of subject for way-facing span dist;
		let control1-y be the bezier assister y of subject for way-facing span dist;
		let control2-x be the bezier assister x of dest for back-facing span dist;
		let control2-y be the bezier assister y of dest for back-facing span dist;
		extend automap overlay bounds with x control1-x and y control1-y;
		extend automap overlay bounds with x control2-x and y control2-y;
	let min-x be the automap overlay min x;
	let min-y be the automap overlay min y;
	let max-x be the automap overlay max x;
	let max-y be the automap overlay max y;
	append svg open viewBox min-x (min-x - AM connector view pad) min-y (min-y - AM connector view pad) width (max-x - min-x + AM connector view pad + AM connector view pad) height (max-y - min-y + AM connector view pad + AM connector view pad);
	append the automap connector primitives from subject for way of kind AM connector kind compass link;
	append svg lit "</svg>".

To build automap compass connector svg from (subject - a room) for (way - a direction):
	begin automap compass connector svg from subject for way;
	finish automap compass connector svg from subject for way.

To build automap badge connector svg from (subject - a room) for (way - a direction):
	reset automap overlay bounds;
	clear the automap svg buffer;
	let dest be the room way from subject;
	let back be the badge opposite of way;
	let start-x be the badge x of subject for way;
	let start-y be the badge y of subject for way;
	let end-x be the arrival badge x on dest facing subject for back;
	let end-y be the arrival badge y on dest facing subject for back;
	extend automap overlay bounds with x start-x and y start-y;
	extend automap overlay bounds with x end-x and y end-y;
	let mid-count be the automap connector midpoint count from subject via way;
	if mid-count > 0:
		extend automap overlay bounds with bent connector midpoints from subject via way;
	else unless start-x and start-y to end-x and end-y forms a straight diagonal:
		let edge-out be the map facing edge from subject to dest;
		let edge-in be the map facing edge from dest to subject;
		let dist be the bezier span of start-x and start-y to end-x and end-y;
		let control1-x be the bezier assister x of subject for edge-out span dist;
		let control1-y be the bezier assister y of subject for edge-out span dist;
		let control2-x be the bezier assister x of dest for edge-in span dist;
		let control2-y be the bezier assister y of dest for edge-in span dist;
		extend automap overlay bounds with x control1-x and y control1-y;
		extend automap overlay bounds with x control2-x and y control2-y;
	let min-x be the automap overlay min x;
	let min-y be the automap overlay min y;
	let max-x be the automap overlay max x;
	let max-y be the automap overlay max y;
	append svg open viewBox min-x (min-x - AM connector view pad) min-y (min-y - AM connector view pad) width (max-x - min-x + AM connector view pad + AM connector view pad) height (max-y - min-y + AM connector view pad + AM connector view pad);
	append the automap connector primitives from subject for way of kind AM connector kind badge link;
	append svg lit "</svg>".

To install automap connector overlay at dense (dense-room-id - a number) way (way-index - a number):
	let min-x be the automap overlay min x;
	let min-y be the automap overlay min y;
	let max-x be the automap overlay max x;
	let max-y be the automap overlay max y;
	let view-left be min-x - AM connector view pad;
	let view-top be min-y - AM connector view pad;
	let view-width be max-x - min-x + AM connector view pad + AM connector view pad;
	let view-height be max-y - min-y + AM connector view pad + AM connector view pad;
	let draw-left be view-left - the automap view origin x;
	let draw-top be view-top - the automap view origin y;
	let overlay-id be the map svg overlay of length (the automap svg buffer length) at left draw-left top draw-top width view-width height view-height z-index 1;
	set the automap connector overlay at dense dense-room-id way way-index to overlay-id;
	if overlay-id < 1:
		mark the automap full rebuild needed because "overlay-id-0".

To install the automap connector from (subject - a room) for (way - a direction):
	let dense-room-id be the automap dense room id of subject;
	if dense-room-id < 1, stop;
	let way-index be the automap way index of way;
	clear the automap connector index at dense dense-room-id way way-index;
	let kind be the live automap connector kind from subject for way;
	let peer be 0;
	if kind is not AM connector kind none:
		now peer is the live automap connector peer from subject for way;
	set the automap connector kind at dense dense-room-id way way-index to kind;
	set the automap connector peer at dense dense-room-id way way-index to peer;
	if kind is AM connector kind none, stop;
	if kind is AM connector kind stub:
		build automap stub connector svg from subject for way;
	else if kind is AM connector kind compass link:
		build automap compass connector svg from subject for way;
	else:
		build automap badge connector svg from subject for way;
	install automap connector overlay at dense dense-room-id way way-index.


Chapter - Refresh

[Patch refresh only looks at the current room (and the previous drawn room so
 the here-fill clears). Remote lighting / exit changes are discovered when the
 player next enters that room — no all-rooms / all-exits scan.]

To sync automap exits for (subject - a room):
	let dense-room-id be the automap dense room id of subject;
	if dense-room-id < 1, stop;
	repeat with way running through the automap exit ways:
		let way-index be the automap way index of way;
		let live-kind be the live automap connector kind from subject for way;
		let live-peer be 0;
		if live-kind is not AM connector kind none:
			now live-peer is the live automap connector peer from subject for way;
		let drawn-kind be the automap connector kind at dense dense-room-id way way-index;
		let drawn-peer be the automap connector peer at dense dense-room-id way way-index;
		if live-kind is not drawn-kind or live-peer is not drawn-peer:
			install the automap connector from subject for way;
	repeat with way running through {up, down, inside, outside}:
		let way-index be the automap way index of way;
		let live-badge be 0;
		if subject has a live automap badge for way:
			now live-badge is 1;
		let drawn-badge be 0;
		if the automap badge is drawn at dense dense-room-id way way-index:
			now drawn-badge is 1;
		if live-badge is not drawn-badge:
			install the automap badge from subject for way;

To refresh the automap incrementally:
	unless glk mapping is supported, stop;
	unless automap enabled is true, stop;
	if automap hyperlinks enabled is not automap hyperlinks last painted:
		mark the automap full rebuild needed because "hyperlinks toggled";
	sync the automap page from the location;
	gather newly visited automap previous locations;
	note automap previous location the location;
	sync the automap z from previous locations;
	update automap named rooms quietly;
	rebuild the automap palette;
	let force-all be false;
	if automap full rebuild needed is true or automap base map ready is false:
		now force-all is true;
	ensure the automap view geometry is ready;
	let focus-left be the map pixel x of the location - the automap view origin x;
	let focus-top be the map pixel y of the location - the automap view origin y;
	let focus-width be the map pixel width of the location;
	let focus-height be the map pixel height of the location;
	if force-all is true:
		sync the automap base focusing on left focus-left top focus-top width focus-width height focus-height;
		unless automap base map ready is true:
			stop;
		forget all automap connector overlays;
		forget all automap badge overlays;
		forget all automap overlay ids;
		[MAP/recover: paint frozen discovery. Discover only the current room
		 unless an author already called discover-all (e.g. REVEAL).]
		discover the automap appearance of the location;
		repeat with subject running through rooms:
			if subject is map-visible:
				if subject is the location:
					discover the automap appearance of subject;
				else if subject is not automap-discovered:
					discover the automap appearance of subject;
				now subject is not automap-drawn-here;
				if subject is the location:
					now subject is automap-drawn-here;
		repeat with subject running through rooms:
			if subject is map-visible:
				install the automap room overlay for subject;
		repeat with subject running through rooms:
			let dense-room-id be the automap dense room id of subject;
			if dense-room-id > 0:
				repeat with way running through the automap exit ways:
					install the automap connector from subject for way;
				repeat with way running through {up, down, inside, outside}:
					install the automap badge from subject for way;
		now automap full rebuild needed is false;
		now automap hyperlinks last painted is automap hyperlinks enabled;
	else:
		[Sync current room first, then other queued previous rooms (multi-hop / teleport).]
		if the location is a room:
			if the location has a stale automap appearance or the automap overlay id of the location < 1:
				discover the automap appearance of the location;
				install the automap room overlay for the location;
			sync automap exits for the location;
		repeat with subject running through the automap previous locations:
			if subject is a room and subject is not the location:
				if subject has a stale automap appearance or the automap overlay id of subject < 1:
					discover the automap appearance of subject;
					install the automap room overlay for subject;
				sync automap exits for subject;
		if focus-width > 0 and focus-height > 0:
			set map focus left focus-left top focus-top width focus-width height focus-height;
	clear map hyperlinks;
	reset automap previous locations to the current room;
	request map events.

To refresh the automap:
	mark the automap full rebuild needed because "author";
	refresh the automap incrementally.


Part - Player surface

Chapter - Hyperlinks

[Room hit-testing uses overlay link_id (dense room id 1..N); clear legacy polygon hyperlinks in refresh.]

The automap room hyperlink rules are a room based rulebook.

To set the automap hyperlink command to look:
	now the glulx replacement command is "look".

To set the automap hyperlink command to go to (target - a room):
	now the glulx replacement command is "go to [target]".

A map hyperlink command rule for a number (called linkid) (this is the automap dense room dispatch rule):
	if linkid >= 1 and linkid <= automap dense room count:
		let target be the automap room at dense index linkid;
		if target is a room:
			follow the automap room hyperlink rules for target;
			rule succeeds.


Chapter - Commands and automatic refresh

Requesting the automap is an action out of world applying to nothing.
Understand "map" as requesting the automap.

Carry out requesting the automap:
	if glk mapping is supported:
		now automap enabled is true;
		refresh the automap;
		show the map at user request;
	else:
		say "This interpreter does not support Glk mapping."

Report requesting the automap when glk mapping is supported:
	say "The map is shown."

A map user hide rule (this is the automap user hide rule):
	now automap enabled is false;
	clear the automap base;
	forget all automap overlay ids;
	forget all automap connector overlays;
	forget all automap badge overlays;
	cancel map events;
	say "[bracket]Map hidden. Type MAP to show it again.[close bracket][paragraph break]".

After looking for the first time (this is the automap opening hint rule):
	if automap opening hint enabled is true and glk mapping is supported and automap enabled is true:
		unless the map is visible:
			say "[bracket]To open the map, type MAP.[close bracket][paragraph break]".

Carry out going when the actor is the player (this is the mark automap rooms visited on going rule):
	[Fog-of-war needs the room we leave as well as the destination. Logs (vis=1
	 after Hub→North) showed the origin vanishing when it was never marked visited.]
	let origin be the room gone from;
	let dest be the room gone to;
	if origin is a room:
		reveal origin on the automap;
	if dest is a room:
		reveal dest on the automap.

[Keep map-named in sync for the current room only (discover-on-visit).]
To update automap named rooms quietly:
	if the location is visited and the location is not dark:
		now the location is map-named.

Every turn (this is the mark lit rooms map-named rule):
	update automap named rooms quietly.

[We refresh the automap when going to ensure that if you enter a room X and then teleport to room Y in the same turn, X will be refreshed as well as Y.]
Report going when the actor is the player (this is the refresh automap after going rule):
	if automap enabled is true and glk mapping is supported:
		refresh the automap incrementally.

Every turn when automap enabled is true and glk mapping is supported (this is the refresh automap every turn rule):
	refresh the automap incrementally.

A first when play begins rule (this is the apply automap bearings table rule):
	apply the automap bearings table;
	if the location has automap geometry:
		now the automap page id is the map page id of the location;
	else:
		now the automap page id is 0;
	invalidate the automap base geometry;
	mark the automap full rebuild needed because "geometry".

When play begins (this is the initial automap rule):
	if glk mapping is supported:
		reveal the location on the automap;
		refresh the automap.

[Glk windows survive undo/restore/restart; game state (dirty, caches, enabled)
does not stay in sync with the host map image. GGRecoverObjects runs after a
successful undo or restore, and also during VM startup (including RESTART).
Re-present when the map is enabled; otherwise close any stale host map.]
A glulx object-updating rule (this is the refresh automap after recovering rule):
	if glk mapping is supported:
		if automap enabled is true:
			clear the automap base;
			refresh the automap;
		else:
			close the map;
			cancel map events.

[Forced arrange after autorestore is our hook to re-present the map.]
A first glulx input handling rule for an arrange-event (this is the resync automap after arrange rule):
	if glk mapping is supported and automap enabled is true:
		unless the map is visible:
			now automap base map ready is false;
			mark the automap full rebuild needed because "arrange";
			refresh the automap incrementally.


Automap ends here.


---- DOCUMENTATION ----

Displays a map of rooms that reveals itself as you play ("fog of war").

We draw lines/curves between visited rooms to represent room exits.
One-way exits are marked with an arrow. Exits to unseen rooms are
represented as a "stub" arrow pointing into empty space.

To represent in/out/up/down, we draw "badges", little discs on the edge
of the room border.

Section: Quick start

	Include Glk Mapping by Dan Fabulich.
	Include Automap by Dan Fabulich.

To show rooms on the map, you must declare map coordinates on each room:

	The map x of Kitchen is 0. The map y of Kitchen is 0.

The units of x and y are abstract grid units, not pixels.

You can also set a width and height. (The default is 6 wide by 4 tall.)

	The map width of Kitchen is 8. The map height of Kitchen is 6.

Optionally assign a map z (default 0). Rooms whose map z differs from the
player's current room are drawn dimmed:

	The map z of Attic is 1.
	The map z of Sky is 1.

Rooms that have no x/y or 0 width/height will not appear on the map.
In that case, when the user enters those rooms, there will be no "you are
here" marker on the map.

Section: Map pages

You may optionally assign rooms a page ID number (the default is page ID 0).

	The map page id of Kitchen is 0.
	The map page id of Living Room is 0.
	The map page id of Basement is 1.
	The map page id of Secret Room is 1.

Automap will only display rooms whose page ID matches the current room's
page ID. In this example, in the Kitchen, you'll see the Kitchen and the
Living Room, but not the Basement or the Secret Room. In the Basement,
you'll see the Basement and the Secret Room, but not the Kitchen or the
Living Room.

Section: Directions and bearings

Automap automatically maps nautical directions (fore, aft, port, starboard)
as compass directions. Add other novel directions to the Table of Automap
Bearings.

Table of Automap Bearings (continued) — for other direction names:

	exit-way (a direction)	bearing (a direction)
	larboard	west

Be sure to Include Automap before any code that connects rooms with
nautical directions or other remapped directions. We can only create
reverse map links when a direction's opposite is already defined; Automap
defines those opposites.

Section: Bent connectors

By default, connectors at 90º or 45º are drawn as straight lines; all
other connectors are drawn as curves.

To author an explicit curved bent connector, use:

	bend the automap connector from the Kitchen via south through 48 and 30 and 48 and 42.

Coordinates are map units, like map x and map y (not pixels). Each pair is one
waypoint in order from the source room toward the destination.

Up to four waypoints per phrase; calling the phrase again replaces any
previous bend on that exit.

Section: Room Hyperlinks

You can enable hyperlinks on rooms by setting "automap hyperlinks enabled".
When that happens, the rooms become clickable on the map, and we invoke
an "automap room hyperlink rule" when the user clicks on a room.

If you use "Approaches" by Emily Short, you can add a "go to ROOM NAME"
command to your game, which is a nice convenience, and then you can
implement an automap room hyperlink rule like this:

	An automap room hyperlink rule for a room (called target):
		if target is the location:
			set the automap hyperlink command to look;
		otherwise:
			set the automap hyperlink command to go to target;
		rule succeeds.

Section: Revealing rooms

Automap shows rooms the player has visited. To show a room without
having the player visit it:

	reveal the Kitchen on the automap.

To reveal every room on the current map page:

	reveal all rooms on the automap.

Only rooms with map geometry on the current map page are affected.

If you move the player through rooms (including silent teleports), Automap
picks those up as previous locations for the turn. You do not need to
manually reveal rooms the player actually enters.

Section: Refreshing the automap

By default, the automap updates incrementally, refreshing the label and
exits for the current room and any previous rooms this turn. (Normally,
there's only one previous room, but there may be more if the player
silently moves through several rooms.)

To refresh the entire automap, use "refresh the automap." (This scans all
rooms, which can be slow.)

You can also "refresh the automap incrementally." Normally, you don't
need to do this, because Automap will do it automatically on every turn,
but if you reveal rooms or move the player with an "out of world" action,
you may need to explicitly "refresh the automap incrementally" to ensure
the incremental refresh happens.

Section: Showing and hiding the automap

The automap is enabled by default, but it may not be visible by default.
Some interpreters don't show the map by default (e.g. on mobile, where the
map displays full screen and would takeover the entire game experience).
Also, if the user closes the map, the interpreter may remember the user's
preference, and may not open the map again, even if the player restarts the
game.

The user can use the "MAP" command to open the map, which will "show the
map at user request," opening the map even if the user intentionally
closed it.

After the first look, if the map is still hidden, Automap prints:

	[To open the map, type MAP.]

To suppress that hint:

	When play begins: now automap opening hint enabled is false.

If you do disable the automap opening hint, it's a good idea to provide
the hint in some other way. Perhaps you could prompt users to type
"HELP", and mention the "MAP" command there.

If the user closes the map, Automap will automatically print a hint,
like this: "[Map hidden. Type MAP to show it again.]"

You can also set automap enabled to false to disable the map entirely.


