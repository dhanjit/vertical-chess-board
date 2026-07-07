# Render every printable part to STL.
#   make            -> build all STLs into ./stl/
#   make pieces     -> just the chess pieces
#   make clean
#
# Requires OpenSCAD on PATH (https://openscad.org). On Linux:
#   sudo apt install openscad     # or use the AppImage / `flatpak`
#
# High smoothness for final prints:
#   make FN=128

OPENSCAD ?= openscad
FN       ?= 96
OUT      ?= stl
PIECES    = pawn knight bishop rook queen king

FLAGS = -D '$$fn=$(FN)'

all: dirs pieces board mech

dirs:
	@mkdir -p $(OUT)

# --- Pieces: one STL per type (print multiples per the set count) -----
pieces: dirs
	@for p in $(PIECES); do \
		echo "  piece: $$p"; \
		$(OPENSCAD) $(FLAGS) -D "PART=\"$$p\"" -o $(OUT)/piece_$$p.stl pieces.scad; \
	done

# --- Gravity gimbal hub + cap -----------------------------------------
gimbal: dirs
	$(OPENSCAD) $(FLAGS) -o $(OUT)/gimbal_testpair.stl gravity_gimbal.scad

# --- Board panel (whole, plus quarters for small beds) ----------------
board: dirs
	$(OPENSCAD) $(FLAGS) -D 'QUARTER="all"' -o $(OUT)/board_panel.stl board_panel.scad
	@for q in bl br tl tr; do \
		$(OPENSCAD) $(FLAGS) -D "QUARTER=\"$$q\"" -o $(OUT)/board_panel_$$q.stl board_panel.scad; \
	done

# --- Rotation mechanism + frame ---------------------------------------
mech: dirs
	$(OPENSCAD) $(FLAGS) -D 'PART="wall"'      -o $(OUT)/hub_wall_plate.stl rotation_hub.scad
	$(OPENSCAD) $(FLAGS) -D 'PART="turntable"' -o $(OUT)/hub_turntable.stl  rotation_hub.scad
	$(OPENSCAD) $(FLAGS) -D 'PART="pulley"'    -o $(OUT)/hub_drive_pulley.stl rotation_hub.scad
	$(OPENSCAD) $(FLAGS) -D 'PART="corner"'    -o $(OUT)/frame_corner.stl    frame.scad

clean:
	rm -rf $(OUT)

.PHONY: all dirs pieces gimbal board mech clean
