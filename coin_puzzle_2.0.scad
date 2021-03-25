use <text_on/text_on.scad>

/* [Coin Props] */
// Diameter of US Nickel 21.21 mm
// Diameter of US Dollar Gold 26.49 mm
// Thickness of US Nickel 1.95 mm
// Thickness of US Dollar Gold 2 mm

// diameter of coin
coin_diameter = 21.21;

// height of coin
coin_height = 1.95;

// amount of space around coin to give it some room to move
coin_gap = .25;

/* [Puzzle Options] */
// the angle the lid makes contact with the slide
lid_angle = 30;

// diameter of bolt
pin_diameter = 3.81;

// desired minimum total length of pin
desired_pin_length = 18.5;

// diameter of nut for bolt
nut_diameter = 7.9;

// height of nut
nut_height = 3.1;

// number of sides on nut
nut_sides = 6;

// minimum thickness of plastic pieces
minimum_thickness = 3.2;

// what percent of the coin is visible through the puzzle
coin_preview = .75;

// is there a bottom window
bottom_window = true;

/* [Text] */

// text to render on top
top_text = " ";

// text height
text_height = .4;

// size of text
text_size = 5;

/* [Parts] */

// render the lid?
render_lid = true;

// render the slide?
render_slide = true;

// render the base?
render_base = true;

/* [Render Options] */

// smoother renders slower
quality = 8; //[1: Pre-Draft, 2:Draft, 4:Medium, 8:Fine, 16:Ultra Fine]

// horizontal padding to account for nozzle size
horizontal_padding = .25;

// vertical padding
vertical_padding = .1;

// show coin
show_debug_shapes = false;

// show a cross-section
show_cross_section = false;

// show exploded view
explode_distance = 0.00001;

// rotate picees
piece_rotation = 0.000001;

/* [Hidden] */

// print quality settings
$fa = 12 / quality;
$fs = 2 / quality;

phi = (1 + sqrt(5)) / 2;

coin_radius = coin_diameter / 2;

coin_cavity_height = coin_height + vertical_padding * 2;
base_height = max(coin_cavity_height + minimum_thickness, nut_height + minimum_thickness);
lid_height = max(minimum_thickness + pin_diameter + vertical_padding, minimum_thickness);
slide_height = max(
  max(minimum_thickness, pin_diameter + vertical_padding) + lid_height + vertical_padding * 2,
  desired_pin_length - base_height - vertical_padding
);

key_width = pin_diameter;
key_length = pin_diameter;
key_height = slide_height * .5;

// coin cavity radius required to calculate the box length
cavity_radius = coin_radius + horizontal_padding + coin_gap;

box_padding = minimum_thickness / 2;
box_width = cavity_radius * 2 + box_padding * 2;
box_radius = (box_width - key_width) / 2;
box_length = key_length + box_padding + cavity_radius * 2 + box_padding + box_width;

cavity_displacement = box_length / 2 - cavity_radius - key_length - box_padding;

pin_cavity_radius = pin_diameter / 2 + horizontal_padding;
pin_cavity_displacement = (box_length - box_width) / 2;

total_pin_height = base_height + slide_height + 2 * explode_distance + vertical_padding;
echo("Total Pin Height: ", total_pin_height);
echo("Box Width: ", box_width);
echo("Box Length: ", box_length);

// debug shapes
module coin() {
  coin_vertical_displaacement = minimum_thickness + vertical_padding;

  color("gold") translate([cavity_displacement, 0, coin_vertical_displaacement])
    cylinder(h = coin_height, r = coin_radius);
}

module pin() {
  color("silver") translate([-pin_cavity_displacement, 0, 0]) {
    cylinder(h = total_pin_height, r = pin_diameter / 2);

    difference() {
      cylinder(h = nut_height, r = nut_diameter / 2, $fn = nut_sides);
      cylinder(h = nut_height, r = pin_cavity_radius);
    }
  }
}

// tools
module rotateAroundPin(angle) {
  translate([-pin_cavity_displacement, 0, 0])
    rotate(angle)
      translate([pin_cavity_displacement, 0, 0])
        children();
}

// puzzle pieces
module box(height, has_preview = true) {
  width_gap = box_width / 2 - box_radius;
  length_gap = box_length / 2 - box_radius;

  difference() {
    hull() {
      translate([-length_gap, width_gap, 0]) cylinder(r = box_radius, h = height);
      translate([-length_gap, -width_gap, 0]) cylinder(r = box_radius, h = height);
      translate([length_gap, width_gap, 0]) cylinder(r = box_radius, h = height);
      translate([length_gap, -width_gap, 0]) cylinder(r = box_radius, h = height);
    }

    if (has_preview)
      coinPreview(height);
  }
}

module coinPreview(height) {
  translate([cavity_displacement, 0, 0])
    cylinder(h = height, r = coin_radius * coin_preview);
}

module base() {
  nut_interior_angle = 180 - 360 / nut_sides;

  nut_cavity_radius = nut_diameter / 2 + horizontal_padding / sin(nut_interior_angle / 2);
  nut_cavity_height = nut_height + vertical_padding;

  color("red") difference() {
    union() {
      box(base_height, bottom_window);

      translate([box_length / 2 - key_length, -key_width / 2, 0])
        cube([key_length, key_width, base_height + key_height]);
    }

    translate([cavity_displacement, 0, base_height - coin_cavity_height])
      cylinder(h = coin_cavity_height, r = cavity_radius);

    translate([-pin_cavity_displacement, 0, 0]) {
      cylinder(h = base_height, r = pin_cavity_radius);
      cylinder(h = nut_cavity_height, r = nut_cavity_radius, $fn = nut_sides);
    }
  }
}

module slide() {
  lid_gap_size = box_length * 3;
  lid_gap_height = lid_height + vertical_padding;

  color("blue") difference() {
    box(slide_height);

    hull() {
      translate([-pin_cavity_displacement, 0, 0])
        cylinder(h = slide_height, r = pin_cavity_radius);

      translate([-pin_cavity_displacement + pin_cavity_radius * 2, 0, 0])
        cylinder(h = slide_height, r = pin_cavity_radius);
    }

    translate([box_length / 2 - key_length - horizontal_padding, -key_width / 2 - horizontal_padding, 0])
      cube([key_length + horizontal_padding, key_width + horizontal_padding * 2, key_height + vertical_padding]);

    translate([cavity_displacement, 0, slide_height - lid_gap_height])
      rotate([0, 0, -lid_angle])
        translate([-lid_gap_size, -lid_gap_size / 2, 0])
          cube([lid_gap_size, lid_gap_size, lid_gap_height]);
  }
}

module lid() {
  lid_gap_size = box_length * 3;
  margin_for_angle = horizontal_padding / cos(lid_angle);

  color("green") difference() {
    box(lid_height);

    translate([-box_length / 4, box_width / 4, lid_height - text_height / 2])
      text_extrude(t = top_text, size = text_size, extrusion_height = text_height);

    translate([-pin_cavity_displacement, 0, 0])
      cylinder(h = lid_height, r = pin_cavity_radius);

    hull() {
      translate([-pin_cavity_displacement, 0, 0])
        cylinder(h = pin_diameter + vertical_padding, r = pin_cavity_radius);

      translate([-pin_cavity_displacement + pin_cavity_radius * 2, 0, 0])
        cylinder(h = pin_diameter + vertical_padding, r = pin_cavity_radius);
    }

    translate([cavity_displacement - margin_for_angle, 0, 0])
      rotate([0, 0, -lid_angle])
        translate([0, -lid_gap_size / 2, 0])
          cube([lid_gap_size, lid_gap_size, lid_height]);
  }
}

difference() {
  union () {
    if (render_base) {
      base();
    }

    if (render_slide) {
      rotateAroundPin(piece_rotation) translate([0, 0, base_height + explode_distance + vertical_padding]) slide();
    }

    if (render_lid) {
      rotateAroundPin(piece_rotation * 2) translate([0, 0, (base_height + slide_height - lid_height) + explode_distance * 2 + vertical_padding]) lid();
    }

    if (show_debug_shapes) {
      pin();
      coin();
    }
  }

  if (show_cross_section) {
    translate([-box_length, -box_width, -5])
      cube([box_length * 2, box_width, 1000]);
  }
}
