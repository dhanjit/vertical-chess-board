# Render every printable part to STL.
#   make            -> build all STLs into ./stl/, using the variant selected
#                      in common.scad (piece_style / pivot_type)
#   make pieces     -> just the chess pieces
#   make clean
#
# Requires OpenSCAD on PATH (https://openscad.org). On Linux:
#   sudo apt install openscad     # or use the AppImage / `flatpak`
#
# High smoothness for final prints:
#   make FN=128
#
# --- Rendering a named VARIANT without editing common.scad -------------
# The design is kept as selectable variants on two independent axes (see the
# top of common.scad). To build one without touching the file:
#
#   make variant STYLE=familiar PIVOT=pin        -> stl/familiar_pin/
#   make variant STYLE=monolith PIVOT=magnet     -> stl/monolith_magnet/
#   make matrix                                  -> all four combinations
#
# Each variant directory gets the six pieces plus whatever the pivot
# architecture actually has printed parts for -- under PIVOT=magnet that is
# the pivot test coupon, because the hub and the cap do not exist there.

OPENSCAD ?= openscad
FN       ?= 96
OUT      ?= stl
PIECES    = pawn knight bishop rook queen king
STYLES    = monolith familiar
PIVOTS    = pin magnet

FLAGS = -D '$$fn=$(FN)'

all: dirs pieces gimbal board board_test mech

dirs:
	@mkdir -p $(OUT)

# --- Pieces: one STL per type (print multiples per the set count) -----
pieces: dirs
	@for p in $(PIECES); do \
		echo "  piece: $$p"; \
		$(OPENSCAD) $(FLAGS) -D "PART=\"$$p\"" -o $(OUT)/piece_$$p.stl pieces.scad; \
	done

# --- Gravity gimbal: hub + cap under "pin", test coupon under "magnet" -
gimbal: dirs
	$(OPENSCAD) $(FLAGS) -o $(OUT)/gimbal_testpair.stl gravity_gimbal.scad

# --- One named variant, into its own directory ------------------------
variant:
	@test -n "$(STYLE)" -a -n "$(PIVOT)" \
		|| { echo "usage: make variant STYLE=<$(STYLES)> PIVOT=<$(PIVOTS)>"; exit 1; }
	@mkdir -p $(OUT)/$(STYLE)_$(PIVOT)
	@echo "variant: $(STYLE) x $(PIVOT)"
	@for p in $(PIECES); do \
		echo "  piece: $$p"; \
		$(OPENSCAD) $(FLAGS) -D 'piece_style="$(STYLE)"' -D 'pivot_type="$(PIVOT)"' \
			-D "PART=\"$$p\"" -o $(OUT)/$(STYLE)_$(PIVOT)/piece_$$p.stl pieces.scad; \
	done
	@$(OPENSCAD) $(FLAGS) -D 'pivot_type="$(PIVOT)"' \
		-o $(OUT)/$(STYLE)_$(PIVOT)/gimbal_$(PIVOT).stl gravity_gimbal.scad

# --- Every combination, for comparing them side by side ---------------
matrix:
	@for s in $(STYLES); do for v in $(PIVOTS); do \
		$(MAKE) --no-print-directory variant STYLE=$$s PIVOT=$$v FN=$(FN) OUT=$(OUT); \
	done; done

# --- Board panel (whole, plus quarters for small beds) ----------------
board: dirs
	$(OPENSCAD) $(FLAGS) -D 'QUARTER="all"' -o $(OUT)/board_panel.stl board_panel.scad
	@for q in bl br tl tr; do \
		$(OPENSCAD) $(FLAGS) -D "QUARTER=\"$$q\"" -o $(OUT)/board_panel_$$q.stl board_panel.scad; \
	done

# --- Phase-0 board test tile (1x2 squares) ----------------------------
board_test: dirs
	$(OPENSCAD) $(FLAGS) -D 'QUARTER="test"' -o $(OUT)/board_test.stl board_panel.scad

# --- Steel sheet cutting outline (for the laser/waterjet shop) --------
sheet: dirs
	$(OPENSCAD) $(FLAGS) -D 'QUARTER="sheet_dxf"' -o $(OUT)/steel_sheet.dxf board_panel.scad

# --- Rotation mechanism + frame ---------------------------------------
mech: dirs
	$(OPENSCAD) $(FLAGS) -D 'PART="wall"'      -o $(OUT)/hub_wall_plate.stl rotation_hub.scad
	$(OPENSCAD) $(FLAGS) -D 'PART="turntable"' -o $(OUT)/hub_turntable.stl  rotation_hub.scad
	$(OPENSCAD) $(FLAGS) -D 'PART="pulley"'    -o $(OUT)/hub_drive_pulley.stl rotation_hub.scad
	$(OPENSCAD) $(FLAGS) -D 'PART="corner"'    -o $(OUT)/frame_corner.stl    frame.scad

clean:
	rm -rf $(OUT)

.PHONY: all dirs pieces gimbal variant matrix board board_test sheet mech clean
