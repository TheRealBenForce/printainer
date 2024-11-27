include <BOSL2/std.scad>
include <BOSL2/threading.scad>

/* [Container Size] */

// interior radius of the container
inner_radius = 20; // [6:125]

// interior height of the container
interior_height = 100; // [10:250]

// Amount of sides for the container
sides = 12; // [4:64]

// Round up outer radius to nearest mm
round_up = true;

// Add additional thickness to the container
side_wall_padding = 1; // [0:10]

// Thickness between the empty space and top or bottom of the container
z_wall_thickness = 3; // [2:10]

// Add roundness to the top and bottom of the container
rounding=0; // [0:10]


/* [Lid Size] */

// Make a lid for the container
lid_toggle = true;

// A percentage of the overall container between .1 and .5
lid_height_percent = .2;

// Amount of full revolutions needed to screw on the lid
revolutions = 4;



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

/* [EXPERIMENTAL] */

// How big each radius gets compared to the last
radius_multiplier = 1.1; // [0:4:.1]


/////////////////////////////////////////////

/* [Hidden] */

echo (str(""));
echo (str("XXXXXXXXX INITIAL VARIABLES XXXXXXXXXXXXX"));

$fn = $preview ? preview_smoothness : render_smoothness;

total_container_height  = lid_toggle ? interior_height + (z_wall_thickness * 2) : interior_height + z_wall_thickness;
total_lid_height        = lid_toggle ? total_container_height * lid_height_percent : 0;
total_thread_height     = lid_toggle ? total_lid_height - z_wall_thickness : 0;
total_base_height       = total_container_height - total_lid_height;

echo (str("Total Container Height: ", total_container_height));
echo (str("Total Lid Height: ", total_lid_height));
echo (str("Total Thread Height: ", total_thread_height));
echo (str("Total Base Height: ", total_base_height));



inner_container_radius = inner_radius; // from params but fits naming convention better
inner_thread_radius = lid_toggle ? inner_container_radius * radius_multiplier : 0;
//outer_thread_radius = lid_toggle ? (get_thread_dimensions()[2]) / 2 : 0;
outer_thread_radius = lid_toggle ?  inner_thread_radius * radius_multiplier : 0;
//min_outer_radius = lid_toggle ? outer_thread_radius / cos(180 / sides) : inner_container_radius + side_wall_padding;
outer_container_radius = lid_toggle ? (outer_thread_radius / cos(180 / sides) + side_wall_padding) :  (inner_container_radius / cos(180 / sides) + side_wall_padding) ;
total_radius = round_up ? ceil(outer_container_radius) : outer_container_radius;


// Thread pitch. Lower is fine. Higher is more course.
pitch = calculate_pitch(); 

echo (str("Inner Container Radius: ", inner_container_radius));
echo (str("Inner Thread Radius: ", inner_thread_radius));
echo (str("Outer Thread Radius: ", outer_thread_radius));
//echo (str("Min Outer Radius: ", min_outer_radius));
echo (str("Outer Container Radius: ", outer_container_radius));
echo (str("Total Radius: ", total_radius));


/////////////////////////////////////////////
// ERROR CHECKING
/////////////////////////////////////////////

// assert if the total height is greater than the printer height
 assert(total_container_height <= print_max_height, "Total height is greater than the printer height.");
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
    cyl(l=interior_height, r=inner_container_radius, anchor=DOWN);
}

module reference_exterior() {
    color("purple")
    regular_prism(sides, r=total_radius, h=total_container_height, rounding2=rounding, anchor=DOWN);

}

module lid() {
    color("orange")
    up(total_lid_height)
    xrot(180)
    difference () {
        regular_prism(sides, r=outer_container_radius, h=total_lid_height, realign=true, rounding2=rounding, anchor=DOWN);
        thread_template(internal=true);
    }
}

module container() {
    color("red")
    difference() {
        if (lid_toggle) { 
            union() {
                regular_prism(sides, r=outer_container_radius, h=total_base_height, realign=true, rounding1=rounding, anchor=DOWN);
                up(total_base_height)
                thread_template();
            }
        } else {
            regular_prism(sides, r=outer_container_radius, h=total_base_height, realign=true, rounding1=rounding, anchor=DOWN);
        }
        up(z_wall_thickness)
        up(.01) // delete later
        empty_space();
    }
}

module thread_template(internal=false) {
    dimensions=get_thread_dimensions();
    threaded_rod(d=dimensions, height=total_thread_height, pitch=pitch, internal=internal, anchor=DOWN);
}

/////////////////////////////////////////////
// UTILITY METHODS
/////////////////////////////////////////////

function calculate_pitch() = (total_lid_height - z_wall_thickness) / revolutions;

function get_thread_dimensions() =
    let (pitch = calculate_pitch())
    let (r_inner = inner_thread_radius * radius_multiplier)          // Inner radius in mm
    //let (d_min = r_inner * 2)      // Minor diameter in mm
    let (d_min = inner_thread_radius)      // Minor diameter in mm
    let (h = 0.866 * pitch)             // Thread height based on pitch
    //let (d_major = d_min + 2 * h)       // Major diameter
    //let (d_major = d_min * 1.1)       // Major diameter
    let (d_major = outer_thread_radius)       // Major diameter
    let (d_pitch = d_major - h)         // Pitch diameter
    [d_min, d_pitch, d_major];


module display(reference_object=false) {
    xdistribute(spacing=total_radius * 2.2) {
        if (lid_toggle) { thread_template(internal=true); }
        up(z_wall_thickness)
        empty_space();
        reference_exterior();
        if (lid_toggle) {
            union() {
                container();
                up(total_container_height)
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