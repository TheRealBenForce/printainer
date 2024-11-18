include <BOSL2/std.scad>
include <BOSL2/threading.scad>

/* [Container Size] */

// interior radius of the container
inner_radius = 20; // [6:125]

// interior height of the container
interior_height = 100; // [10:250]

// Amount of sides for the container
sides = 12; // [4:64]

// wall thickness
wall = 3; // [2:10]

rounding=.5;

/* [Lid Size] */

// Make a lid for the container
lid_toggle = true;

// A percentage of the overall container between .1 and .5
lid_height_percent = .2;

// Thread pitch. Lower is fine. Higher is more course.
pitch = 2; // [1:8]

/////////////////////////////////////////////

/* [Tolerances] */

// Smoothness of curved surfaces in preview mode
preview_smoothness = 32; // [8:128]

// Smoothness of curved surfaces in render mode
render_smoothness = 64; // [8:128]

// The printer-specific slop value to make parts fit just right. Read more here: https://github.com/BelfrySCAD/BOSL2/wiki/constants.scad#constant-slop
$slop = 0.2;

/////////////////////////////////////////////

/* [Printer Dimensions] */

// printer max length
print_max_depth = 256; // [50:500]

// printer max width
print_max_width = 256; // [50:500]

// printer max height
print_max_height = 256; // [50:500]

/////////////////////////////////////////////

/* [Hidden] */

$fn = $preview ? preview_smoothness : render_smoothness;

thread_radius           = lid_toggle ? inner_radius + 3 : inner_radius; // 3 should probably be based on a ratio to fit at different sizes.
outer_radius            = lid_toggle ? thread_radius / cos(180 / sides) : inner_radius / cos(180 / sides) ;
total_radius            = outer_radius + wall;
total_height            = lid_toggle ? interior_height + (wall * 2) : interior_height + wall;
total_lid_height        = lid_toggle ? total_height * lid_height_percent : 0;
total_container_height  = total_height - total_lid_height;


echo ("Thread Radius: ", thread_radius);

echo ("Total Radius: ", total_radius);
echo ("Total Height: ", total_height);
echo ("Total Lid Height: ", total_lid_height);
echo ("Total Container Height: ", total_container_height);


/////////////////////////////////////////////
// ERROR CHECKING
/////////////////////////////////////////////

// assert if the total height is greater than the printer height
assert(total_height <= print_max_height, "Total height is greater than the printer height.");
assert((total_radius * 2) <= print_max_width, "Total diamter is greater than the printer width.");
assert((total_radius * 2) <= print_max_depth, "Total diamter is greater than the printer depth.");


/////////////////////////////////////////////
// REFERENCE OBJECTS
/////////////////////////////////////////////

module dollar_bill() {
    color([0.5, 1, 0.5])
    cube([66, .1, 156], anchor=DOWN);
}

/////////////////////////////////////////////
// CONSTRUCTION METHODS
/////////////////////////////////////////////

module empty_space() {
    color("blue", .1)
    cyl(l=interior_height, r=inner_radius, rounding=rounding, anchor=DOWN);
}

module reference_exterior() {
    color("purple")
    regular_prism(sides, r=total_radius, h=total_height, rounding2=rounding, anchor=DOWN);

}

module lid() {
    color("orange")
    up(total_lid_height)
    xrot(180)
    difference () {
        regular_prism(sides, r=total_radius, h=total_lid_height, realign=true, rounding2=rounding, anchor=DOWN);
        thread_template(internal=true);
    }
}

module container() {
    color("red")
    difference() {
        if (lid_toggle) { 
            union() {
                regular_prism(sides, r=total_radius, h=total_container_height, realign=true, rounding1=rounding, anchor=DOWN);
                up(total_container_height)
                thread_template();
            }
        } else {
            regular_prism(sides, r=total_radius, h=total_container_height, realign=true, rounding2=rounding, anchor=DOWN);
        }
        up(wall)
        empty_space();
    }
}

module thread_template(internal=false) {
    dimensions=get_thread_dimensions();
    threaded_rod(d= dimensions, height=total_lid_height - wall, pitch=pitch, internal=internal, anchor=DOWN);
}

/////////////////////////////////////////////
// UTILITY METHODS
/////////////////////////////////////////////

function get_thread_dimensions(inner_radius=inner_radius, pitch=pitch) =
    let (d_min = inner_radius * 2)      // Minor diameter in mm
    let (h = 0.866 * pitch)  // Thread height based on pitch
    let (d_major = d_min + 2 * h)  // Major diameter
    let (d_pitch = d_major - h)      // Pitch diameter
    [d_min, d_pitch, d_major];


module display(reference_object=false) {
    xdistribute(spacing=total_radius * 2.2) {
        if (lid_toggle) { thread_template(internal=true); }
        up(wall)
        empty_space();
        reference_exterior();
        if (lid_toggle) {
            union() {
                container();
                up(total_height)
                xrot(180)
                lid();
            }
        }
        print_output();
    }
    if (reference_object) {
        back(50)
        dollar_bill();
    }
}


module print_output() {
    container();
    if (lid_toggle) {
        right(total_radius * 2.2)
        lid();
    }

}

//display(reference_object=true);
print_output();