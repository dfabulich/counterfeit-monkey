Version 1/260823 of Semantic Mapping (for Glulx only) by Dan Fabulich begins here.

"Builds an ADRIFT-like semantic map from room geometry, renders SVG, and presents it via Glk Mapping. Handles visited fog-of-war, darkness styling, stubs to unseen exits, focus, and room hyperlinks."

Use authorial modesty.

[Semantic map SVG strings for large games can be much longer than Inform's
default ~1024-character text limit.]
Use maximum text length of at least 131072.


Chapter - Geometry

[Abstract map units (not pixels). Rooms with map width 0 are omitted from the map.]

A room has a number called map x. The map x of a room is usually 0.
A room has a number called map y. The map y of a room is usually 0.
A room has a number called map width. The map width of a room is usually 0.
A room has a number called map height. The map height of a room is usually 0.

Semantic map scale is a number that varies. Semantic map scale is 20.

Semantic map enabled is a truth state that varies. Semantic map enabled is initially false.

[If a table of geometry is present, it takes precedence over any per-room
map x/map y/map width/map height declarations.]
Table of Semantic Map Geometry
geo-room (a room)	map-x (a number)	map-y (a number)	map-w (a number)	map-h (a number)
with 1 blank row.

[Find semantic-map geometry values, preferring the Table of Semantic Map Geometry.]
To decide what number is the semantic map geometry x of (R - a room):
	repeat through the Table of Semantic Map Geometry:
		if geo-room entry is R:
			decide on map-x entry;
	decide on the map x of R.

To decide what number is the semantic map geometry y of (R - a room):
	repeat through the Table of Semantic Map Geometry:
		if geo-room entry is R:
			decide on map-y entry;
	decide on the map y of R.

To decide what number is the semantic map geometry width of (R - a room):
	repeat through the Table of Semantic Map Geometry:
		if geo-room entry is R:
			decide on map-w entry;
	decide on the map width of R.

To decide what number is the semantic map geometry height of (R - a room):
	repeat through the Table of Semantic Map Geometry:
		if geo-room entry is R:
			decide on map-h entry;
	decide on the map height of R.

To decide whether (R - a room) is on the semantic map:
	if the semantic map geometry width of R > 0 and the semantic map geometry height of R > 0, yes;
	no.

To decide whether (R - a room) is map-visible:
	if R is on the semantic map:
		if R is visited, yes;
		if R is the location, yes;
	no.

[A room is map-named once the player has seen it in light; until then dark rooms read "Darkness".]
A room can be map-named.

To decide what text is the semantic map label of (R - a room):
	if R is map-named, decide on the printed name of R;
	decide on "Darkness".


Chapter - Paper/ink palette

[Matches Spatterlight scarier MAP_SCHEME_STANDARD shades (PR #171):
 room fill = paper mixed a little toward ink; you-are-here = that card mixed
 further toward ink; links/stubs = ink faded toward paper; labels flip to the
 other side of mid-luminance. Paper/ink come from gg_mainwin Normal styles.]

The semantic map paper colour is a number that varies.
The semantic map ink colour is a number that varies.
The semantic map room fill colour is a number that varies.
The semantic map room stroke colour is a number that varies.
The semantic map room label colour is a number that varies.
The semantic map here fill colour is a number that varies.
The semantic map here stroke colour is a number that varies.
The semantic map here label colour is a number that varies.
The semantic map dark fill colour is a number that varies.
The semantic map dark label colour is a number that varies.
The semantic map link colour is a number that varies.
The semantic map stub colour is a number that varies.

Include (-
[ SM_MixRGB a b t100 ar ag ab br bg bb;
  if (t100 < 0) t100 = 0;
  if (t100 > 100) t100 = 100;
  ar = (a / 65536) & 255; ag = (a / 256) & 255; ab = a & 255;
  br = (b / 65536) & 255; bg = (b / 256) & 255; bb = b & 255;
  ar = ar + ((br - ar) * t100) / 100;
  ag = ag + ((bg - ag) * t100) / 100;
  ab = ab + ((bb - ab) * t100) / 100;
  if (ar < 0) ar = 0; if (ar > 255) ar = 255;
  if (ag < 0) ag = 0; if (ag > 255) ag = 255;
  if (ab < 0) ab = 0; if (ab > 255) ab = 255;
  return (ar * 65536) + (ag * 256) + ab;
];

[ SM_Lum1000 rgb r g b;
  r = (rgb / 65536) & 255;
  g = (rgb / 256) & 255;
  b = rgb & 255;
  return (2126 * r + 7152 * g + 722 * b) / 255;
];

[ SM_PaperInkLabel fill paper ink fill_l paper_l ink_l mid;
  fill_l = SM_Lum1000(fill);
  paper_l = SM_Lum1000(paper);
  ink_l = SM_Lum1000(ink);
  if (ink_l == paper_l) return ink;
  mid = (ink_l + paper_l) / 2;
  if (fill_l >= mid) {
    if (ink_l > paper_l) return paper;
    return ink;
  }
  if (ink_l > paper_l) return ink;
  return paper;
];

[ SM_RebuildPalette paper ink dark room_t room_fill here_fill room_eff here_eff dark_fill;
  dark = (SM_Lum1000(paper) < 450);
  if (dark) room_t = 18; else room_t = 12;
  room_fill = SM_MixRGB(paper, ink, room_t);
  if (dark)
    here_fill = SM_MixRGB(room_fill, ink, 85);
  else
    here_fill = SM_MixRGB(room_fill, ink, 90);
  room_eff = SM_MixRGB(paper, room_fill, 78);
  here_eff = SM_MixRGB(paper, here_fill, 78);
  dark_fill = SM_MixRGB(room_fill, ink, 55);
  (+ semantic map paper colour +) = paper;
  (+ semantic map ink colour +) = ink;
  (+ semantic map room fill colour +) = room_fill;
  (+ semantic map room stroke colour +) = ink;
  (+ semantic map room label colour +) = SM_PaperInkLabel(room_eff, paper, ink);
  (+ semantic map here fill colour +) = here_fill;
  (+ semantic map here stroke colour +) = ink;
  (+ semantic map here label colour +) = SM_PaperInkLabel(here_eff, paper, ink);
  (+ semantic map dark fill colour +) = dark_fill;
  (+ semantic map dark label colour +) = SM_PaperInkLabel(SM_MixRGB(paper, dark_fill, 78), paper, ink);
  if (dark)
    (+ semantic map link colour +) = SM_MixRGB(paper, ink, 50);
  else
    (+ semantic map link colour +) = SM_MixRGB(paper, ink, 60);
  if (dark)
    (+ semantic map stub colour +) = SM_MixRGB(paper, ink, 35);
  else
    (+ semantic map stub colour +) = SM_MixRGB(paper, ink, 40);
];

[ SM_MeasurePalette paper ink;
  paper = 16777215;
  ink = 0;
  if (gg_mainwin) {
    if (glk_style_measure(gg_mainwin, style_Normal, stylehint_BackColor, gg_arguments))
      paper = gg_arguments-->0;
    if (glk_style_measure(gg_mainwin, style_Normal, stylehint_TextColor, gg_arguments))
      ink = gg_arguments-->0;
  }
  SM_RebuildPalette(paper, ink);
];

[ SM_HexPow16 i p;
  p = 1;
  while (i > 0) { p = p * 16; i = i - 1; }
  return p;
];

[ SM_PrintHex6 rgb i n;
  print (char) 35;
  for (i = 5: i >= 0: i = i - 1) {
    n = (rgb / SM_HexPow16(i)) & 15;
    if (n < 10) print (char) (48 + n);
    else print (char) (87 + n);
  }
];
-).

To rebuild the semantic map palette:
	(- SM_MeasurePalette(); -).

To say hex of (N - a number):
	(- SM_PrintHex6({N}); -).


Chapter - Presenting

To decide what number is the semantic map minimum x:
	let minx be 100000;
	let any be false;
	repeat with R running through rooms:
		if R is map-visible:
			now any is true;
			let X0 be the map pixel x of R;
			if X0 < minx, now minx is X0;
			repeat with way running through {north, south, east, west, northeast, northwest, southeast, southwest}:
				let dest be the room way from R;
				if dest is a room and dest is on the semantic map:
					unless dest is map-visible:
						let SX be the port x of R for way + the stub delta x for way;
						if SX < minx, now minx is SX;
	if any is false, decide on 0;
	decide on minx - semantic map scale.

To decide what number is the semantic map minimum y:
	let miny be 100000;
	let any be false;
	repeat with R running through rooms:
		if R is map-visible:
			now any is true;
			let Y0 be the map pixel y of R;
			if Y0 < miny, now miny is Y0;
			repeat with way running through {north, south, east, west, northeast, northwest, southeast, southwest}:
				let dest be the room way from R;
				if dest is a room and dest is on the semantic map:
					unless dest is map-visible:
						let SY be the port y of R for way + the stub delta y for way;
						if SY < miny, now miny is SY;
	if any is false, decide on 0;
	decide on miny - semantic map scale.

To refresh the semantic map with (flaglist - a list of map flags):
	unless glk mapping is supported, stop;
	unless semantic map enabled is true, stop;
	sync map markers from geometry;
	let map-origin-x be the semantic map minimum x;
	let map-origin-y be the semantic map minimum y;
	rebuild the semantic map palette;
	let SVG be the semantic map SVG;
	let fl be the map marker left of the location - map-origin-x;
	let ft be the map marker top of the location - map-origin-y;
	let fw be the map marker width of the location;
	let fh be the map marker height of the location;
	present map SVG SVG with flaglist background color (the semantic map paper colour) focusing on left fl top ft width fw height fh;
	install semantic map hyperlinks;
	request map events.

To refresh the semantic map:
	refresh the semantic map with { map-suggest-show }.

To sync map markers from geometry:
	let S be semantic map scale;
	repeat with R running through rooms:
		if R is on the semantic map:
			now the map marker left of R is the semantic map geometry x of R * S;
			now the map marker top of R is the semantic map geometry y of R * S;
			now the map marker width of R is the semantic map geometry width of R * S;
			now the map marker height of R is the semantic map geometry height of R * S;
		else:
			now the map marker left of R is 0;
			now the map marker top of R is 0;
			now the map marker width of R is 0;
			now the map marker height of R is 0.


Chapter - SVG construction

To decide what number is the map pixel x of (R - a room):
	decide on the semantic map geometry x of R * semantic map scale.

To decide what number is the map pixel y of (R - a room):
	decide on the semantic map geometry y of R * semantic map scale.

To decide what number is the map pixel width of (R - a room):
	decide on the semantic map geometry width of R * semantic map scale.

To decide what number is the map pixel height of (R - a room):
	decide on the semantic map geometry height of R * semantic map scale.

To decide what number is the port x of (R - a room) for (way - a direction):
	let X be the map pixel x of R;
	let W be the map pixel width of R;
	if way is north or way is south, decide on X + (W / 2);
	if way is east or way is northeast or way is southeast, decide on X + W;
	if way is west or way is northwest or way is southwest, decide on X;
	decide on X + (W / 2).

To decide what number is the port y of (R - a room) for (way - a direction):
	let Y be the map pixel y of R;
	let H be the map pixel height of R;
	if way is east or way is west, decide on Y + (H / 2);
	if way is south or way is southeast or way is southwest, decide on Y + H;
	if way is north or way is northeast or way is northwest, decide on Y;
	decide on Y + (H / 2).

To decide what number is the stub delta x for (way - a direction):
	let S be semantic map scale + (semantic map scale / 2);
	if way is east or way is northeast or way is southeast, decide on S;
	if way is west or way is northwest or way is southwest, decide on 0 - S;
	decide on 0.

To decide what number is the stub delta y for (way - a direction):
	let S be semantic map scale + (semantic map scale / 2);
	if way is south or way is southeast or way is southwest, decide on S;
	if way is north or way is northeast or way is northwest, decide on 0 - S;
	decide on 0.

To decide what text is the semantic map SVG:
	let minx be 100000;
	let miny be 100000;
	let maxx be -100000;
	let maxy be -100000;
	let any be false;
	let on-map-count be 0;
	let visible-count be 0;
	repeat with R running through rooms:
		if R is on the semantic map:
			increase on-map-count by 1;
		if R is map-visible:
			increase visible-count by 1;
			now any is true;
			let X0 be the map pixel x of R;
			let Y0 be the map pixel y of R;
			let X1 be X0 + the map pixel width of R;
			let Y1 be Y0 + the map pixel height of R;
			if X0 < minx, now minx is X0;
			if Y0 < miny, now miny is Y0;
			if X1 > maxx, now maxx is X1;
			if Y1 > maxy, now maxy is Y1;
			repeat with way running through {north, south, east, west, northeast, northwest, southeast, southwest}:
				let dest be the room way from R;
				if dest is a room and dest is on the semantic map:
					unless dest is map-visible:
						let SX be the port x of R for way + the stub delta x for way;
						let SY be the port y of R for way + the stub delta y for way;
						if SX < minx, now minx is SX;
						if SY < miny, now miny is SY;
						if SX > maxx, now maxx is SX;
						if SY > maxy, now maxy is SY;
	if any is false:
		decide on "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 40 40'><text x='8' y='22' font-size='10' fill='#666'>No map</text></svg>";
	let pad be semantic map scale;
	now minx is minx - pad;
	now miny is miny - pad;
	now maxx is maxx + pad;
	now maxy is maxy + pad;
	let VW be maxx - minx;
	let VH be maxy - miny;
	let SVG be "<svg xmlns='http://www.w3.org/2000/svg' viewBox='[minx] [miny] [VW] [VH]'>";
	now SVG is "[SVG][semantic map connector svg]";
	now SVG is "[SVG][semantic map room svg]";
	now SVG is "[SVG]</svg>";
	decide on SVG.

To decide what text is the semantic map connector svg:
	let SVG be "";
	let link-hex be "";
	let stub-hex be "";
	now link-hex is "[hex of the semantic map link colour]";
	now stub-hex is "[hex of the semantic map stub colour]";
	repeat with R running through rooms:
		if R is map-visible:
			repeat with way running through {north, south, east, west, northeast, northwest, southeast, southwest}:
				let dest be the room way from R;
				if dest is a room and dest is on the semantic map:
					let X1 be the port x of R for way;
					let Y1 be the port y of R for way;
					if dest is map-visible:
						[Draw each duplex edge once, from the lower object number.]
						if the object number of R <= the object number of dest:
							let back be the opposite of way;
							let X2 be the port x of dest for back;
							let Y2 be the port y of dest for back;
							now SVG is "[SVG]<line x1='[X1]' y1='[Y1]' x2='[X2]' y2='[Y2]' stroke='[link-hex]' stroke-width='2' opacity='0.86'/>";
					else:
						[Stub toward an unseen mapped destination.]
						let X2 be X1 + the stub delta x for way;
						let Y2 be Y1 + the stub delta y for way;
						now SVG is "[SVG]<line x1='[X1]' y1='[Y1]' x2='[X2]' y2='[Y2]' stroke='[stub-hex]' stroke-width='2' opacity='0.86'/>";
						now SVG is "[SVG][stub arrow svg at X2 and Y2 for way]";
	decide on SVG.

To decide what text is the stub arrow svg at (X - a number) and (Y - a number) for (way - a direction):
	let S be 5;
	let stub-hex be "[hex of the semantic map stub colour]";
	if way is north:
		decide on "<polygon points='[X],[Y] [X - S],[Y + S] [X + S],[Y + S]' fill='[stub-hex]' opacity='0.86'/>";
	if way is south:
		decide on "<polygon points='[X],[Y] [X - S],[Y - S] [X + S],[Y - S]' fill='[stub-hex]' opacity='0.86'/>";
	if way is east:
		decide on "<polygon points='[X],[Y] [X - S],[Y - S] [X - S],[Y + S]' fill='[stub-hex]' opacity='0.86'/>";
	if way is west:
		decide on "<polygon points='[X],[Y] [X + S],[Y - S] [X + S],[Y + S]' fill='[stub-hex]' opacity='0.86'/>";
	decide on "<circle cx='[X]' cy='[Y]' r='3' fill='[stub-hex]' opacity='0.86'/>".

To decide what text is the semantic map room svg:
	let SVG be "";
	repeat with R running through rooms:
		if R is map-visible:
			let X be the map pixel x of R;
			let Y be the map pixel y of R;
			let W be the map pixel width of R;
			let H be the map pixel height of R;
			let fill-n be the semantic map room fill colour;
			let stroke-n be the semantic map room stroke colour;
			let label-n be the semantic map room label colour;
			let sw be "1.5";
			if R is dark:
				now fill-n is the semantic map dark fill colour;
				now stroke-n is the semantic map room stroke colour;
				now label-n is the semantic map dark label colour;
			if R is the location:
				now sw is "3";
				now fill-n is the semantic map here fill colour;
				now stroke-n is the semantic map here stroke colour;
				now label-n is the semantic map here label colour;
			now SVG is "[SVG]<rect x='[X]' y='[Y]' width='[W]' height='[H]' rx='4' fill='[hex of fill-n]' stroke='[hex of stroke-n]' stroke-width='[sw]'/>";
			if R is dark:
				let Xa be X + (W / 3);
				let Xb be X + ((W * 2) / 3);
				let Ya be Y + (H / 3);
				let Yb be Y + ((H * 2) / 3);
				let hatch be "[hex of the semantic map stub colour]";
				now SVG is "[SVG]<path d='M[X],[Y] L[X + W],[Y + H]' stroke='[hatch]' stroke-width='1' opacity='0.5'/>";
				now SVG is "[SVG]<path d='M[Xa],[Y] L[X + W],[Yb]' stroke='[hatch]' stroke-width='1' opacity='0.35'/>";
				now SVG is "[SVG]<path d='M[X],[Ya] L[Xb],[Y + H]' stroke='[hatch]' stroke-width='1' opacity='0.35'/>";
			let CX be X + (W / 2);
			let CY be Y + (H / 2);
			let label be the semantic map label of R;
			now SVG is "[SVG]<text x='[CX]' y='[CY]' text-anchor='middle' dominant-baseline='middle' font-family='sans-serif' font-size='11' fill='[hex of label-n]'>[label]</text>";
			if R is the location:
				now SVG is "[SVG]<text x='[CX]' y='[Y + 12]' text-anchor='middle' font-family='sans-serif' font-size='9' font-weight='bold' fill='[hex of stroke-n]'>&#64;</text>";
	decide on SVG.


Chapter - Hyperlinks

To install semantic map hyperlinks:
	begin map hyperlinks;
	repeat with R running through rooms:
		if R is map-visible:
			let X be the map pixel x of R;
			let Y be the map pixel y of R;
			let W be the map pixel width of R;
			let H be the map pixel height of R;
			let X2 be X + W;
			let Y2 be Y + H;
			let pts be a list of numbers;
			add X to pts;
			add Y to pts;
			add X2 to pts;
			add Y to pts;
			add X2 to pts;
			add Y2 to pts;
			add X to pts;
			add Y2 to pts;
			add map hyperlink id (the object number of R) labeled (the semantic map label of R) with points pts;
	commit map hyperlinks.

A map hyperlink command rule for a number (called linkid) (this is the semantic map room hyperlink rule):
	repeat with R running through rooms:
		if the object number of R is linkid:
			if R is the location:
				now the glulx replacement command is "look";
			else:
				let way be the best route from the location to R;
				if way is a direction:
					now the glulx replacement command is "[way]";
				else:
					now the glulx replacement command is "";
			rule succeeds.


Chapter - Commands and automatic refresh

Requesting the semantic map is an action out of world applying to nothing.
Understand "semantic map" as requesting the semantic map.

Carry out requesting the semantic map:
	if glk mapping is supported:
		now semantic map enabled is true;
		refresh the semantic map with { map-user-requested-show };
	else:
		say "This interpreter does not support Glk mapping."

Report requesting the semantic map when glk mapping is supported:
	say "The map is shown."

A map user hide rule (this is the semantic map user hide rule):
	now semantic map enabled is false;
	cancel map events;
	say "[bracket]Map hidden. Type MAP to show it again.[close bracket][paragraph break]".

[Standard looking skips visited in darkness, which makes mapped rooms vanish after
you leave. Mark semantic-map rooms on entry so fog-of-war matches exploration.
Runs in carry out before looking; default lookmode is VERBOSE so descriptions still print.]

Carry out going when the actor is the player (this is the mark semantic map rooms visited on going rule):
	let dest be the room gone to;
	if dest is on the semantic map:
		now dest is visited;
	if dest is not dark:
		now dest is map-named.

Every turn (this is the mark lit rooms map-named rule):
	repeat with R running through rooms:
		if R is visited and R is not dark:
			now R is map-named.

[Refresh after Report so we do not suppress "describe room gone into".]

Report going when the actor is the player (this is the refresh semantic map after going rule):
	if semantic map enabled is true and glk mapping is supported:
		refresh the semantic map with { map-suggest-show }.

Every turn when semantic map enabled is true and glk mapping is supported (this is the refresh semantic map every turn rule):
	refresh the semantic map with { map-suggest-show }.

When play begins (this is the initial semantic map rule):
	if glk mapping is supported:
		now the location is map-named;
		refresh the semantic map with { map-suggest-show }.


Semantic Mapping ends here.

---- DOCUMENTATION ----

This extension sits on top of Glk Mapping. Authors declare abstract room geometry:

	The map x of Kitchen is 0. The map y of Kitchen is 0.
	The map width of Kitchen is 6. The map height of Kitchen is 4.

Only rooms with positive width and height appear. Visited rooms (and the
current location) are drawn; exits toward unvisited mapped rooms become stubs.
Colours follow Spatterlight's paper/ink shade scheme: room cards are paper
mixed slightly toward ink, the current room is mixed further toward ink, and
links are faded ink. Paper and ink come from the main window's Normal
BackColor and TextColor when the runner supports glk_style_measure.
Dark rooms use a darker card and hatch marks; until the player has seen a
room in light its label reads "Darkness". The current room is marked with @
and a thicker stroke.

Type MAP to show the map; the runner's hide control disables it until MAP again.
Clicking a room issues the first step of the best route there.
