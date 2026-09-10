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
# `all` is every printable PART: pieces, gimbal, board, board_test, mech. It
# does NOT include `sheet` -- that one is a DXF cutting outline for a laser
# shop, not something anybody prints -- so ask for `sheet` by name.
#
# --- Rendering a named VARIANT without editing common.scad -------------
# The design is kept as selectable variants on two independent axes (see the
# top of common.scad). To build one without touching the file:
#
#   make variant STYLE=familiar PIVOT=pin        -> stl/familiar_pin/
#   make variant STYLE=monolith PIVOT=magnet     -> stl/monolith_magnet/
#   make matrix                                  -> all six combinations
#
# Each variant directory gets the six pieces plus whatever the pivot
# architecture actually has printed parts for -- under PIVOT=magnet that is
# the pivot test coupon, because the hub and the cap do not exist there;
# under PIVOT=bearing it is the same hub + cap pair as "pin" (the bearing
# itself is bought).

OPENSCAD ?= openscad
FN       ?= 96
OUT      ?= stl
PIECES    = pawn knight bishop rook queen king
# STYLES/PIVOTS mirror the enums in the SCAD sources. ADDING A STYLE OR A
# PIVOT TOUCHES FOUR PLACES: the SCAD file itself; "THE ENUM" in pieces.scad
# (a style) or the render dispatch in gravity_gimbal.scad (a pivot); these two
# lines; and $STYLES/$PIVOTS in ./build.ps1, the Windows entry point. Only
# `matrix` and `variant`'s name check read them here -- every other target
# passes the name straight through to OpenSCAD, whose asserts are the real gate.
STYLES    = monolith familiar
PIVOTS    = pin magnet bearing

FLAGS = -D '$$fn=$(FN)'

all: dirs pieces gimbal board board_test mech

dirs:
	@mkdir -p $(OUT)

# --- Pieces: one STL per type (print multiples per the set count) -----
# `|| exit 1` sits INSIDE the loop body, not after `done`: a shell for-loop
# reports only its LAST iteration's status, so without it a failed pawn hides
# behind a successful king and make exits 0 with an STL missing.
pieces: dirs
	@for p in $(PIECES); do \
		echo "  piece: $$p"; \
		$(OPENSCAD) $(FLAGS) -D "PART=\"$$p\"" -o $(OUT)/piece_$$p.stl pieces.scad || exit 1; \
	done

# --- Gravity gimbal: hub + cap under "pin", test coupon under "magnet" -
gimbal: dirs
	$(OPENSCAD) $(FLAGS) -o $(OUT)/gimbal_testpair.stl gravity_gimbal.scad

# --- One named variant, into its own directory ------------------------
# STYLE and PIVOT are checked for MEMBERSHIP, not merely for being non-empty:
# a typo would otherwise create stl/<typo>_pin/ and burn six failing renders
# before anything said so.
# GIMBAL_FROM is an internal knob used by `matrix` below; leave it unset.
variant:
	@case " $(STYLES) " in *" $(STYLE) "*) ;; *) echo "usage: make variant STYLE=<$(STYLES)> PIVOT=<$(PIVOTS)>   (got STYLE='$(STYLE)')"; exit 1;; esac
	@case " $(PIVOTS) " in *" $(PIVOT) "*) ;; *) echo "usage: make variant STYLE=<$(STYLES)> PIVOT=<$(PIVOTS)>   (got PIVOT='$(PIVOT)')"; exit 1;; esac
	@mkdir -p $(OUT)/$(STYLE)_$(PIVOT)
	@echo "variant: $(STYLE) x $(PIVOT)"
	@for p in $(PIECES); do \
		echo "  piece: $$p"; \
		$(OPENSCAD) $(FLAGS) -D 'piece_style="$(STYLE)"' -D 'pivot_type="$(PIVOT)"' \
			-D "PART=\"$$p\"" -o $(OUT)/$(STYLE)_$(PIVOT)/piece_$$p.stl pieces.scad || exit 1; \
	done
	@if [ -n "$(GIMBAL_FROM)" ] && [ -f "$(GIMBAL_FROM)" ]; then \
		echo "  gimbal: copied from $(GIMBAL_FROM)"; \
		cp "$(GIMBAL_FROM)" $(OUT)/$(STYLE)_$(PIVOT)/gimbal_$(PIVOT).stl || exit 1; \
	else \
		$(OPENSCAD) $(FLAGS) -D 'pivot_type="$(PIVOT)"' \
			-o $(OUT)/$(STYLE)_$(PIVOT)/gimbal_$(PIVOT).stl gravity_gimbal.scad || exit 1; \
	fi

# --- Every combination, for comparing them side by side ---------------
# Pivot-major on purpose: gravity_gimbal.scad never reads piece_style, so the
# two styles at one pivot render the IDENTICAL gimbal mesh. Render it once per
# pivot and hand the file to the second style via GIMBAL_FROM, which copies it
# -- three gimbal renders per matrix run instead of six.
matrix:
	@for v in $(PIVOTS); do \
		first=""; \
		for s in $(STYLES); do \
			$(MAKE) --no-print-directory variant STYLE=$$s PIVOT=$$v FN=$(FN) OUT=$(OUT) \
				GIMBAL_FROM="$$first" || exit 1; \
			if [ -z "$$first" ]; then first=$(OUT)/$${s}_$${v}/gimbal_$${v}.stl; fi; \
		done; \
	done

# --- Board panel (whole, plus quarters for small beds) ----------------
board: dirs
	$(OPENSCAD) $(FLAGS) -D 'QUARTER="all"' -o $(OUT)/board_panel.stl board_panel.scad
	@for q in bl br tl tr; do \
		$(OPENSCAD) $(FLAGS) -D "QUARTER=\"$$q\"" -o $(OUT)/board_panel_$$q.stl board_panel.scad || exit 1; \
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
