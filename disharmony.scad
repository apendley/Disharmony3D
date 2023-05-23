
/*//////////////////////////////////////////////////////////////////
              -    FB Aka Heartman/Hearty 2016     -                   
              -   http://heartygfx.blogspot.com    -                  
              -       OpenScad Parametric Box      -                     
              -         CC BY-NC 3.0 License       -                      
////////////////////////////////////////////////////////////////////                                                                                                             
12/02/2016 - Fixed minor bug 
28/02/2016 - Added holes ventilation option                    
09/03/2016 - Added PCB feet support, fixed the shell artefact on export mode. 
23/05/2023 - Tons of modifications to repurpose design to build a remote control (Aaron Pendley)

*/////////////////////////// - Info - //////////////////////////////

// All coordinates are starting as integrated circuit pins.
// From the top view :

//   CoordD           <---       CoordC
//                                 ^
//                                 ^
//                                 ^
//   CoordA           --->       CoordB


////////////////////////////////////////////////////////////////////


////////// - Box parameters - /////////////

/* [STL export] */
// Export top shell?
ExportTop = 1; // [0:No, 1:Yes]
// Export bottom shell?
ExportBottom = 1; // [0:No, 1:Yes]
// Export front panel?
ExportFront = 1; // [0:No, 1:Yes]
// Export back panel?
ExportBack = 1; // [0:No, 1:Yes]
  
/* [Colors] */
// Top Shell color
TopShellColor = "Orange"; // [Orange, OrangeRed, Red, LightGreen, Green, LightBlue, Blue, Yellow, White, Gray, Black]
// Bottom Shell color
BottomShellColor = "Yellow"; // [Orange, OrangeRed, Red, LightGreen, Green, LightBlue, Blue, Yellow, White, Gray, Black]
// Front Panel color
FrontPanelColor = "OrangeRed"; // [Orange, OrangeRed, Red, LightGreen, Green, LightBlue, Blue, Yellow, White, Gray, Black]
// Front Panel color
BackPanelColor = "Gray"; // [Orange, OrangeRed, Red, LightGreen, Green, LightBlue, Blue, Yellow, White, Gray, Black]


/* [Box dimensions] */
// Box length
Length = 190;
// Box Width
Width = 54;
// Box Height                     
Height = 28;  
// Wall thickness  
Thick = 2; //[2:5]
  
/* [Box options] */
// Filet diameter  
Filet = 5; //[0.1:12] 
// Filet resolution (smoothness)  
Resolution = 50; //[1:100] 
// Tolerance (Panel/rails gap)
Tolerance = 0.3;
// PCB Feet?
PCBFeet = 0;// [0:No, 1:Yes]
// Decorations to ventilation holes
Vent = 0;// [0:No, 1:Yes]
// Decoration-Holes width (in mm)
VentWidth = 0;   
  
/* [PCB Feet] */
// All dimensions are from the center foot axis

// Low left corner X position
PCBPosX         = 0;
// Low left corner Y position
PCBPosY         = 0;
// PCB Length
PCBLength       = 71;
// PCB Width
PCBWidth        = 41;
// Feet height
FootHeight      = 10;
// Foot diameter
FootDia         = 8;
// Hole diameter
FootHole        = 3;  

/* [Hidden] */
// Thick X 2 - making decorations thicker if it is a vent to make sure they go through shell
Dec_Thick       = Vent ? Thick*2 : Thick; 
// - Depth decoration
Dec_size        = Vent ? Thick*2 : 0.8;


/////////// - Generic rounded box - //////////
module RoundBox($a=Length, $b=Width, $c=Height) {
    fn=Resolution;  

    translate([0,Filet,Filet]) {  
        minkowski () {                                              
            cube ([$a-(Length/2),$b-(2*Filet),$c-(2*Filet)], center = false);
            rotate([0,90,0]) {
                cylinder(r=Filet,h=Length/2, center = false);
            } 
        }
    }
}

////////////////////////////////// - Shell - //////////////////////////////////         
module Shell() {
    Thick = Thick*2;

    difference() {
        //sides decoration
        difference() {
            union() {    
                //Substraction Fileted box
                difference() {
                    // Median cube slicer
                    difference() {
                        union() {
                            //Shell
                            difference() {
                                RoundBox();

                                translate([Thick/2,Thick/2,Thick/2]) {
                                    RoundBox($a=Length-Thick, $b=Width-Thick, $c=Height-Thick);
                                }
                            }

                            // Rails
                            difference() {
                                // Rails
                                translate([Thick+Tolerance,Thick/2,Thick/2]) {
                                    RoundBox($a=Length-((2*Thick)+(2*Tolerance)), $b=Width-Thick, $c=Height-(Thick*2));
                                }

                                // +0.1 added to avoid the artefact
                                translate([((Thick+Tolerance/2)*1.55),Thick/2,Thick/2+0.1]) { 
                                      RoundBox($a=Length-((Thick*3)+2*Tolerance), $b=Width-Thick, $c=Height-Thick);
                                }           
                            }
                        }

                        // Cube to subtract
                        translate([-Thick,-Thick,Height/2]) {
                            cube ([Length+100, Width+100, Height], center=false);
                        }                                            
                    }

                    // Central subtraction form
                    translate([-Thick/2,Thick,Thick]) {
                        RoundBox($a=Length+Thick, $b=Width-Thick*2, $c=Height-Thick);       
                    }                          
                }                                          

                // wall fixation box legs
                difference() {
                    union() {
                        translate([3*Thick +5,Thick,Height/2]) {
                            rotate([90,0,0]) {
                                $fn=6;
                                cylinder(d=16,Thick/2);
                            }   
                        }
                            
                        translate([Length-((3*Thick)+5),Thick,Height/2]) {
                            rotate([90,0,0]) {
                                $fn=6;
                                cylinder(d=16,Thick/2);
                            }   
                        }
                    }

                    translate([4,Thick+Filet,Height/2-57]) {   
                        rotate([45,0,0]) {
                            cube([Length,40,40]);    
                        }
                    }

                    translate([0,-(Thick*1.46),Height/2]) {
                        cube([Length,Thick*2,10]);
                    }
                }
            }

            // outbox sides decorations
            union() {
                for(i=[0:Thick:Length/4]) {
                    // Ventilation holes part code submitted by Ettie - Thanks ;) 
                    translate([10+i,-Dec_Thick+Dec_size,1]) {
                        cube([VentWidth,Dec_Thick,Height/4]);
                    }

                    translate([(Length-10) - i,-Dec_Thick+Dec_size,1]) {
                        cube([VentWidth,Dec_Thick,Height/4]);
                    }

                    translate([(Length-10) - i,Width-Dec_size,1]) {
                        cube([VentWidth,Dec_Thick,Height/4]);
                    }

                    translate([10+i,Width-Dec_size,1]) {
                        cube([VentWidth,Dec_Thick,Height/4]);
                    }
                }
            }
        }

        //sides holes
        union() {
            holeDiameter = 2;
            $fn = 50;

            translate([3*Thick+5,20,Height/2+4]) {
                rotate([90,0,0]) {
                    cylinder(d=holeDiameter,20);
                }
            }

            translate([Length-((3*Thick)+5),20,Height/2+4]) {
                rotate([90,0,0]) {
                    cylinder(d=holeDiameter,20);
                }
            }

            translate([3*Thick+5,Width+5,Height/2-4]) {
                rotate([90,0,0]) {
                    cylinder(d=holeDiameter,20);
                }
            }

            translate([Length-((3*Thick)+5),Width+5,Height/2-4]) {
                rotate([90,0,0]) {
                    cylinder(d=holeDiameter,20);
                }
            }
        }
    }
}

////////////////////////////// - Experiment - ///////////////////////////////////////////





/////////////////////// - Foot with base filet - /////////////////////////////
module foot(FootDia,FootHole,FootHeight) {
    Filet=2;
    color(TopShellColor)   
    translate([0,0,Filet-1.5])
    difference() {
        difference() {
            cylinder(d=FootDia+Filet,FootHeight-Thick, $fn=100);

            rotate_extrude($fn=100) {
                translate([(FootDia+Filet*2)/2,Filet,0]) {
                    minkowski() {
                        square(10);
                        circle(Filet, $fn=100);
                    }
                }
            }
        }

        cylinder(d=FootHole,FootHeight+1, $fn=100);
    }          
}

//////////////////// - PCB only visible in the preview mode - /////////////////////    
module Feet() {     
    translate([3*Thick+2,Thick+5,FootHeight+(Thick/2)-0.5]) {
        %square ([PCBLength+10,PCBWidth+10]);

        translate([PCBLength/2,PCBWidth/2,0.5]) { 
            color("Olive")
            %text("PCB", halign="center", valign="center", font="Arial black");
        }
    }
    
    ////////////////////////////// - 4 Feet - //////////////////////////////////////////     
    translate([3*Thick+7,Thick+10,Thick/2]) {
        foot(FootDia,FootHole,FootHeight);
    }

    translate([(3*Thick)+PCBLength+7,Thick+10,Thick/2]) {
        foot(FootDia,FootHole,FootHeight);
    }

    translate([(3*Thick)+PCBLength+7,(Thick)+PCBWidth+10,Thick/2]) {
        foot(FootDia,FootHole,FootHeight);
    }        

    translate([3*Thick+7,(Thick)+PCBWidth+10,Thick/2]) {
        foot(FootDia,FootHole,FootHeight);
    }   
}
 
////////////////////////////////////////////////////////////////////////
////////////////////// <- Holes Panel Manager -> ///////////////////////
////////////////////////////////////////////////////////////////////////

module Panel(Length,Width,Thick,Filet) {
    scale([0.5,1,1])
    minkowski() {
        cube([Thick,Width-(Thick*2+Filet*2+Tolerance),Height-(Thick*2+Filet*2+Tolerance)]);
        translate([0,Filet,Filet])
        rotate([0,90,0])
        cylinder(r=Filet,h=Thick, $fn=100);
    }
}

module CircleHole(x, y, diameter, z=2) {
    translate([x, y, -z]) {
        cylinder(d=diameter, 10, $fn=50);
    }
}

module RectHole(Sx, Sy, Sl, Sw, Filet, z=2) {
    minkowski() {
        translate([Sx+Filet/2,Sy+Filet/2,-z])
        cube([Sl-Filet,Sw-Filet,10]);
        cylinder(d=Filet,h=10, $fn=100);
    }
}

module ANORotaryHoles(height) {
    $fn = 50;

    cylHeight = Thick * 2;
    diameter = 36.5;
    screwDiameter = 3;
    zCyl = height - cylHeight * 0.75;

    translate([0, 0, zCyl]) {
        cylinder(d=diameter, cylHeight);
    }

    translate([15.2, 15.2, zCyl]) {
        cylinder(d=screwDiameter, cylHeight);
    }

    translate([-15.2, 15.2, zCyl]) {
        cylinder(d=screwDiameter, cylHeight);
    }

    translate([15.2, -15.2, zCyl]) {
        cylinder(d=screwDiameter, cylHeight);
    }   

    translate([-15.2, -15.2, zCyl]) {
        cylinder(d=screwDiameter, cylHeight);
    }   
}

module ssh1107_128_OLEDHoles(x, y, z=2) {
    color(FrontPanelColor) {
        // screen
        screenLength = 23;
        screenHeight = 23;
        xScreenOffset = 1.2;
        yScreenOffset = 9;
        RectHole(x + xScreenOffset, y + yScreenOffset, screenLength, screenHeight, 0);

        screwDiameter = 3;

        $fn = 50;

        xScrewDistance = 25.4;
        yScrewDistance = 35.6;        

        // bottom left
        translate([x, y, -z]) {
            cylinder(d=screwDiameter, 10);
        }

        // bottom right
        translate([x + xScrewDistance, y, -z]) {
            cylinder(d=screwDiameter, 10);
        }

        // top left
        translate([x, y + yScrewDistance, -z]) {
            cylinder(d=screwDiameter, 10);
        }

        // top right
        translate([x + xScrewDistance, y + yScrewDistance, -z]) {
            cylinder(d=screwDiameter, 10);
        }        
    }    
}

////////////////////// <- Front Panel -> //////////////////////
module FrontPanel() {
    difference() {
        color(FrontPanelColor)
        Panel(Length,Width,Thick,Filet);

        inset = (Thick + Filet - Tolerance) * 2;
        panelWidth = Width - inset;
        panelHeight = Height - inset;

        rotate([90,0,90]) {
            color(FrontPanelColor) {
                usbWidth = 10;
                usbHeight = 4.6;
                xUSB = 20;
                yUSB = 10.8;
                RectHole(xUSB, yUSB, usbWidth, usbHeight, 1);
            }
        }
    }
}

////////////////////// <- Front Panel -> //////////////////////
module BackPanel() {
    difference() {
        color(BackPanelColor)
        Panel(Length,Width,Thick,Filet);

        inset = (Thick + Filet - Tolerance) * 2;
        panelLength = Width - inset;
        panelHeight = Height - inset;

        rotate([90,0,90]) {
            color(BackPanelColor) {
                CircleHole(panelLength - 6, 11.75, 16);
            }
        }
    }
}


/////////////////////////// <- Main part -> /////////////////////////

// Top shell
if(ExportTop == 1) {
    difference() {
        color(TopShellColor, 1) {
            translate([0,Width,Height+0.2]) {
                rotate([0,180,180]) {
                    Shell();
                }
            }
        }

        {
            xPowerButton = 16;
            yPowerButton = 16;

            translate([yPowerButton, xPowerButton, Height]) {
                CircleHole(0, 0, 16);
            }
        }        
        
        rotate([0,0,90]) {
            translate([0, 0, Height]) {
                ssh1107_128_OLEDHoles(14.0, -66);
            }
        }            

        {
            xHomeButton = 16;
            yHomeButton = 80;

            translate([yHomeButton, xHomeButton, Height]) {
                CircleHole(0, 0, 16);
            }
        }        

        {
            xMuteButton = Width - 16;
            yMuteButton = 80;

            translate([yMuteButton, xMuteButton, Height]) {
                CircleHole(0, 0, 16);
            }
        }                

        {
            xPlayButton = 16;
            yPlayButton = 102;

            translate([yPlayButton, xPlayButton, Height]) {
                CircleHole(0, 0, 16);
            }
        }

        {
            xBackButton = Width - 16;
            yBackButton = 102;

            translate([yBackButton, xBackButton, Height]) {
                CircleHole(0, 0, 16);
            }
        }

        translate([134, Width/2, 0]) {
            ANORotaryHoles(Height);
        }
    }
}

// Bottom shell
if (ExportBottom == 1) {
    color(BottomShellColor) { 
        Shell();
    }
}

// PCB feet
if ( PCBFeet == 1) {
    translate([PCBPosX,PCBPosY,0]) { 
        Feet();
    }
}

// Front panel
if (ExportFront == 1) {
    translate([Length-(Thick*2+Tolerance/2),Thick+Tolerance/2,Thick+Tolerance/2])
    FrontPanel();
}

// Back panel
if (ExportBack == 1) {
    translate([Thick+Tolerance/2,Thick+Tolerance/2,Thick+Tolerance/2])
    BackPanel();
}