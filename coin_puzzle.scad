/* [Coin Props] */
// Diameter of US Nickel 21.21 mm
// Diameter of US Dollar Gold 26.49 mm
// Thickness of US Nickel 1.95 mm
// Thickness of US Dollar Gold 2 mm

// diameter of coin
coin_diameter = 21.21;

// height of coin
coin_height = 1.95;

/* [Puzzle Options] */

// diameter of screw
pin_diameter = 4.95;

// diameter of bead
bead_diameter = 4;        

/* [Render Options] */

// smoother renders slower
quality = 8; //[2:Draft, 4:Medium, 8:Fine, 16:Ultra Fine]

// horizontal padding to account for nozzle size
horizontal_padding = .25;

// vertical padding
vertical_padding = .1;

// show exploded view
show_explode = 0;  

// build the printable model
show_print = 1;     

// show the ball mold
show_ball_mold = 0; 

/* [Hidden] */

// print quality settings
$fa = 12 / quality;
$fs = 2 / quality;

// Puzzle box
in=25.4;
gap = horizontal_padding * 2;;
                     
// Pad the cutouts a smidgen
Dcavity = coin_diameter + gap;
depth_cavity = coin_height + vertical_padding;

////////////////////////////////////////////////////////////////////////

H_ball_pocket=bead_diameter+gap;

padding = 3.5;
width = Dcavity + 2 * padding;
length=Dcavity * 2.56;

D_CB=.5*in;
H_CB=.175*in;

Htop=H_ball_pocket+.07*in;
Hmiddle=H_ball_pocket+Htop;
Hbottom=H_CB+.1*in; //10


angle=60;
Dtap=pin_diameter; //.15*in is the tap drill size if you want to tap the plastic;
Xhole=12;
Lslot=pin_diameter/2+max(bead_diameter,pin_diameter)/2+gap;

Xcavity=width;

Dcavity_through= .7 * Dcavity;
tcavity=Hbottom-depth_cavity;
wx=50;


Wkey=pin_diameter;
Lkey=min(pin_diameter,bead_diameter);
radius=(width-Wkey)/2;

WkeyG=Wkey+2*gap;
bead_diameter_hole=bead_diameter+2*gap;

LkeyG=Lkey+gap;
Xcoin = (length - Dcavity) / 2 - Lkey - padding;

if (show_explode)
{
    explode_dist=20;
    Bottom_Part(explode_dist);
    Middle_Part(explode_dist);
    Top_Part(explode_dist);
}

if (show_print)
{
    translate([0,-width*1.2,0]) Bottom_Part();
    translate([0,0,-Hbottom]) Middle_Part();
    translate([0,width*1.2,-Hmiddle-Hbottom+Htop]) Top_Part();
}

if (show_ball_mold)
{
    Ball_mold();
    rotate([0,0,180])Ball_mold();
}

module Ball_mold(explode=0)
{
    Dnozzle=.4;
    Wmold=bead_diameter*3;
    Hmold=bead_diameter/2*1.5;
    hpin=bead_diameter/2;
    D_trough=bead_diameter/2;
    g=.2;
    
    translate([Wmold,0,Hmold])
    {
        rotate([180,0,0])
        {
            difference()
            {
                translate([0,0,Hmold/2]) cube([Wmold,Wmold,Hmold],center=true);
                sphere(d=bead_diameter);
                rotate_extrude()
                {
                    translate([bead_diameter/2+D_trough/2+Dnozzle,0])circle(d=D_trough);
                }
                translate([ Wmold/2*.7, Wmold/2*.7,0])
                    cylinder(d1=bead_diameter/2+g,d2=Dnozzle+g,h=hpin+g);
                rotate([0,90,0])
                    translate([0,0,bead_diameter/2+D_trough/2+Dnozzle])
                        cylinder(d=D_trough,h=Wmold);
                rotate([0,-90,0])
                    translate([0,0,bead_diameter/2+D_trough/2+Dnozzle])
                        cylinder(d=D_trough,h=Wmold);
                rotate([90,0,0])
                    translate([0,0,bead_diameter/2+D_trough/2+Dnozzle])
                        cylinder(d=D_trough,h=Wmold);
                rotate([-90,0,0])
                    translate([0,0,bead_diameter/2+D_trough/2+Dnozzle])
                        cylinder(d=D_trough,h=Wmold);
            }
            
            translate([-Wmold/2*.7,-Wmold/2*.7,-hpin])
                cylinder(d2=bead_diameter/2,d1=Dnozzle,h=hpin);
        }
    }
}



module Bottom_Part(explode=0)
{
    difference()
    {
        union()
        {
            box(length,width,Hbottom,radius);
            translate([length/2-Lkey/2,0,Hbottom])
                cube([Lkey,Wkey,Wkey*2],center=true);
        }
        translate([-length/2+Xhole,0,0])
                    cylinder(d=Dtap,h=Hbottom*2,center=true);
        translate([Xcoin,0,tcavity])
                    cylinder(d=Dcavity,h=Hbottom*2,center=false);
        translate([Xcoin,0,0])
            cylinder(d=Dcavity_through,h=Hbottom*2,center=true);
        translate([-length/2+Xhole,0,0])
                    cylinder(d=D_CB,h=H_CB*2,center=true);
    }
    
}

module Middle_Part(explode=0)
{
    color("blue")
    translate([0,0,Hbottom+explode])
    {
        difference()
        {
            box(length,width,Hmiddle,radius);
            
            translate([Xcoin,0,Hmiddle-Htop])
                    rotate([0,0,90-angle])
                        translate([-length,-width/2*wx,0])
                            cube([length,width*wx,Htop],center=false);            
            hull()
                {
                translate([-length/2+Xhole,0,0])
                    cylinder(d=pin_diameter,h=Hmiddle*2,center=true);
                translate([-length/2+Xhole+Lslot,0,0])
                    cylinder(d=max(bead_diameter_hole,pin_diameter),h=Hmiddle*2,center=true);

                }
                
            translate([length/2,0,0])
                cube([LkeyG*2,WkeyG,WkeyG*2],center=true);

            translate([Xcoin,0,0])
                    cylinder(d=Dcavity_through,h=Hmiddle*2,center=true);
                
        }
    }
}


module Top_Part(explode=0)
{
    color("red")
        translate([0,0,Hbottom+Hmiddle-Htop+explode+explode])
        {
            difference()
            {
                box(length,width,Htop,radius);                
                translate([Xcoin - gap,0,0])
                    rotate([0,0,(90-angle)])
                        translate([0,-width/2*wx,0])
                            cube([length,width*wx,Htop],center=false);
                
                
                translate([-length/2+Xhole,0,0])
                    cylinder(d=pin_diameter,h=Htop*2,center=true);
                
                hull()
                {
                    translate([-length/2+Xhole,0,0])
                        cylinder(d=pin_diameter,h=H_ball_pocket*2,center=true);
                    translate([-length/2+Xhole+Lslot,0,0])
                        cylinder(d=max(bead_diameter_hole,pin_diameter),h=H_ball_pocket*2,center=true);
                }
                
                translate([Xcoin,0,0])
                    cylinder(d=Dcavity_through,h=Htop*2,center=true);
            }  
    }
}


module box(L,W,H,R)
{
    hull()
    {
        translate([-L/2+R,-W/2+R,0])cylinder(r=R,h=H);
        translate([-L/2+R,W/2-R,0])cylinder(r=R,h=H);
        translate([L/2-R,-W/2+R,0])cylinder(r=R,h=H);
        translate([L/2-R,W/2-R,0])cylinder(r=R,h=H);
    }
}

