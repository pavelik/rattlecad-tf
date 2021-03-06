##+##########################################################################
#
# test_canvas_CAD.tcl
# by Manfred ROSENBERGER
#
#   (c) Manfred ROSENBERGER 2010/02/06
#
#   canvas_CAD is licensed using the GNU General Public Licence,
#        see http://www.gnu.org/copyleft/gpl.html
# 
 


set WINDOW_Title      "tcl tubeMiter, based on canvasCAD@rattleCAD"


set APPL_ROOT_Dir [file normalize [file dirname [lindex $argv0]]]

puts "  -> \$APPL_ROOT_Dir $APPL_ROOT_Dir"
set APPL_Package_Dir [file dirname [file dirname $APPL_ROOT_Dir]]
puts "  -> \$APPL_Package_Dir $APPL_Package_Dir"

lappend auto_path [file dirname $APPL_ROOT_Dir]

lappend auto_path "$APPL_Package_Dir"
lappend auto_path [file join $APPL_Package_Dir __ext_libraries]

package require   Tk
package require   tubeMiter
package require   cad4tcl
package require   bikeGeometry
package require   vectormath
package require   appUtil

set cad4tcl::canvasType 1

 
    ##+######################


namespace eval model {
        #
    variable dict_TubeMiter
        #
    dict create dict_TubeMiter {}
    dict append dict_TubeMiter settings \
            [list precision               48 \
                  viewOffset               0 \
            ]
    dict append dict_TubeMiter geometry \
            [list angleTool               90 \
                  angleTube              180 \
                  lengthOffset_z          60 \
            ]
    dict append dict_TubeMiter toolTube \
            [list Diameter_Base           56 \
                  Diameter_Top            28 \
                  Length                 160 \
                  Length_BaseCylinder     10 \
                  Length_Cone             70 \
            ]
    dict append dict_TubeMiter tube \
            [list Diameter_Miter          30 \
                  Length                 100 \
            ]
    dict append dict_TubeMiter result \
            [list Base_Position           {} \
                  Miter_Angle             {} \
                  Profile_Tool            {} \
                  Profile_Tube            {} \
                  Shape_Tool              {} \
                  Shape_Tube              {} \
                  ShapeCone_Tool          {} \
                  Miter_ToolPlane         {} \
                  Miter_BaseDiameter      {} \
                  Miter_TopDiameter       {} \
                  miter_Tool              {} \
                  MiterView_Plane         {} \
                  MiterView_BaseDiameter  {} \
                  MiterView_TopDiameter   {} \
                  MiterView_Tool          {} \
                  MiterView_Cone          {} \
                  Shape_ToolPlane         {} \
                  Shape_Debug             {} \
            ]  
}
namespace eval view {
    variable cvObject
    variable stageCanvas
    variable reportText         {}
}
namespace eval control {
        #
    variable precision                10
        #
    variable angleTube               180
        #
    variable angleTool                90 
    variable lengthOffset_z           50 
    variable lengthOffset_x            0 
    variable diameterToolBase         56 
    variable diameterToolTop          28 
    variable lengthTool              100 
    variable lengthToolBase           30 
    variable lengthToolCone           50 
    variable diameterTube_1           38
    variable diameterTube_2           57
    variable lengthTube              150
    variable angleToolPlane            0    ;# clockwise
        #
    variable result/Base_Position     {}
    variable result/Miter_Angle       {}
    variable result/Profile_Tool      {}
    variable result/Profile_Tube      {}
    variable result/Shape_Tool        {}
    variable result/Shape_Tube        {}
        #
    variable viewMiter              right   ;# 
    variable typeTool            cylinder   ;#  ... plane / cone / cylinder
    variable typeProfile            round   ;#  ... round / oval
        #
    if 1 {
        variable diameterToolTop          28 
        variable lengthOffset_z           59 
        variable typeTool                cone   ;#  ... plane / cone / cylinder
    }
        #
    if 0 {
            # frustum
        variable diameterToolTop           8 
        variable lengthOffset_z           90 
        variable typeTool             frustum   ;#  ... plane / cone / cylinder
    }
    if 1 {
            # cone
        variable angleTool                30 
        variable diameterToolTop          28 
        variable lengthOffset_z           61 
        variable typeTool               cone   ;#  ... plane / cone / cylinder
    }
    if 1 {
            # cone
        variable angleTool                90 
        variable angleToolPlane            0
        variable diameterToolTop          28 
        variable lengthOffset_x            0 
        variable lengthOffset_z           61 
        variable typeTool            cylinder   ;#  ... plane / cone / cylinder
    }
        #
    if 1 {
            # cone
        variable precision                 3 
        variable angleTool                90 
        variable angleToolPlane            0
        variable diameterToolTop          25 
        variable diameterToolBase         50 
        variable diameterTube_1           40
        variable diameterTube_2           40
        variable lengthOffset_x            0 
        variable lengthOffset_z           45 
        variable typeTool               cone   ;#  ... plane / cone / cylinder
    }
        #
    if 1 {
            # cone
        variable precision                10 
        variable angleTool               110 
        variable angleToolPlane            0
        variable diameterToolTop          25 
        variable diameterToolBase         50 
        variable diameterTube_1           40
        variable diameterTube_2           50
        variable lengthOffset_x            0 
        variable lengthOffset_z           45 
        variable typeTool            frustum   ;#  ... frustum / plane / cone / cylinder
    }
        #
    
    
    # trace add variable angleTool  write updateModel
    # trace add variable angleTube      write updateModel
    # trace add variable lengthOffset_z         write updateModel
    # trace add variable diameterToolBase       write updateModel
    # trace add variable diameterToolTop        write updateModel
    # trace add variable lengthTool              write updateModel
    # trace add variable lengthToolBase write updateModel
    # trace add variable lengthToolCone         write updateModel
    # trace add variable diameterTube_1          write updateModel
    # trace add variable lengthTube                  write updateModel
    
    # variable myCanvas
    
        # defaults
    variable start_angle        20
    variable start_length       80
    variable end_length         65
    variable dim_size            5
    variable dim_dist           30
    variable dim_offset          0
    variable dim_type_select    aligned
    variable dim_font_select    vector
    variable std_fnt_scl         1
    variable font_colour        black
    variable demo_type          dimension
    variable drw_scale           1.0
    variable cv_scale            1
    variable debugMode          off
        #
        #
    variable miterObject        [tubeMiter::createMiter cylinder]
        #
    variable miterDebugCylinder [tubeMiter::createMiter cylinder]
    variable miterDebugPlane    [tubeMiter::createMiter plane]
        #
}    
    #
    #
    # -- MODEL --
    #
proc model::xxx {value} {
        #
    # puts "\n\n--< model::setValue >--"
    # puts "      \$dictPath: $_dictPath"
    # puts "      \$value:    $value"
        #
    variable dict_TubeMiter
        #
    set dictPath [string map {"/" " "} $_dictPath]
    dict set dict_TubeMiter {*}$dictPath $value
        #
    # appUtil::pdict $dict_TubeMiter 
        #
    # puts "--< model::setValue >--\n\n"
}
    #
    #
    # -- CONTROL --
    #
proc control::__changeView {} {
        #
    variable viewMiter
        #
    if {$viewMiter eq "left"} {
        set viewMiter "right"
    } else {
        set viewMiter "left"
    }
        #
    control::update   
        #
}
proc control::moveto_StageCenter {item} {
    set cvObject $::view::cvObject
    set stage       [$cvObject getCanvas]
    set stageCenter [$cvObject getCenter]
    set bottomLeft  [$cvObject getBottomLeft]
    foreach {cx cy} $stageCenter break
    foreach {lx ly} $bottomLeft  break
    $cvObject move $item [expr $cx - $lx] [expr $cy -$ly]
}
proc control::recenter_board {} {
    variable  cv_scale 
    variable  drw_scale 
    set cvObject $::view::cvObject
    puts "\n  -> recenter_board:   $cvObject "
    puts "\n\n============================="
    puts "   -> cv_scale:           $cv_scale"
    puts "   -> drw_scale:          $drw_scale"
    puts "============================="
    puts "\n\n"
    moveto_StageCenter __cvElement__
    set cv_scale [$cvObject configure Canvas Scale]    
}
proc control::refit_board {} {
    variable  cv_scale 
    variable  drw_scale
    set cvObject $::view::cvObject
    puts "\n  -> recenter_board:   $::view::cvObject "
    puts "\n\n============================="
    puts "   -> cv_scale:           $cv_scale"
    puts "   -> drw_scale:          $drw_scale"
    puts "============================="
    puts "\n\n"
    set cv_scale [$cvObject fit]
}
proc control::scale_board {{value {1}}} {
    variable  cv_scale 
    variable  drw_scale 
    set cvObject $::view::cvObject
    puts "\n  -> scale_board:   $cvObject"
    puts "\n\n============================="
    puts "   -> cv_scale:           $cv_scale"
    puts "   -> drw_scale:          $drw_scale"
    puts "============================="
    puts "\n\n"        
    $cvObject center $cv_scale
}
proc control::cleanReport {} {
    # puts " -> control::cleanReport: $::view::reportText"
    catch {$::view::reportText   delete  1.0 end}
}
proc control::writeReport {text} {
    # puts " -> control::writeReport: $::view::reportText"
    catch {$::view::reportText   insert  end "$text\n"}
}
proc control::draw_centerLineEdge {} {
    
    set cvObject $::view::cvObject
    $::view::stageCanvas addtag {__CenterLine__} withtag  [$cvObject  create   circle {0 0}     -radius 2  -outline red        -fill white]
    set basePoints {}
    set p00 {0 0}
    set angle_00 0 
    set p01 [vectormath::addVector $p00 [vectormath::rotateLine {0 0} $control::S01_length $angle_00]]
    set angle_01 [expr $angle_00 + $control::S01_angle]
    set p02 [vectormath::addVector $p01 [vectormath::rotateLine {0 0} $control::S02_length $angle_01]]
    set angle_02 [expr $angle_01 + $control::S02_angle]
    set p03 [vectormath::addVector $p02 [vectormath::rotateLine {0 0} $control::S03_length $angle_02]]
    
    $::view::stageCanvas addtag {__CenterLine__} withtag  [$::view::stageCanvas  create   circle $p01       -radius 5  -outline green        -fill white]
    $::view::stageCanvas addtag {__CenterLine__} withtag  [$::view::stageCanvas  create   circle $p02       -radius 5  -outline green        -fill white]
    $::view::stageCanvas addtag {__CenterLine__} withtag  [$::view::stageCanvas  create   circle $p03       -radius 5  -outline green        -fill white]

    lappend basePoints $p00
    lappend basePoints $p01
    lappend basePoints $p02
    lappend basePoints $p03

    append polyLineDef [canvasCAD::flatten_nestedList $basePoints]
      # puts "  -> $polyLineDef"
    $::view::stageCanvas addtag {__CenterLine__} withtag  {*}[$cvObject  create   line $polyLineDef -tags dimension  -fill green ]
}
proc control::dimensionMessage { x y id} {
        tk_messageBox -message "giveMessage: $x $y $id"  
    }        
    #
proc control::getToolShape {{type {}}} {
        #
    variable diameterToolBase      
    variable diameterToolTop       
    variable lengthTool             
    variable lengthToolBase
    variable lengthToolCone        
    variable lengthOffset_z        
    variable typeTool
        #
    if {$type eq {}} {
        set type $typeTool
    }    
        #
    set toolShape {}
        #
    switch -exact $type {
        plane {
                # puts "  <I> \$typeTool - cone"
                set lng_00      0
                set lng_01      $lengthToolBase
                set lng_02      [expr $lengthToolBase + $lengthToolCone]
                set lng_03      $lengthTool
                set radius_00   [expr 0.5 * $diameterToolBase]
                set radius_03   [expr 0.5 * $diameterToolTop]
                    #
                lappend toolShape [list $lng_00 0]
                lappend toolShape [list $lng_03 0]
            }
        frustum {
                # puts "  <I> \$typeTool - frustum"
                set lng_00      0
                set lng_01      0
                set lng_02      $lengthToolBase
                set lng_03      [expr $lengthToolBase + $lengthToolCone]
                set lng_04      $lengthTool
                set lng_99      $lengthTool
                if {$lng_03 > $lng_04} {
                    set lng_03 $lng_04
                }
                set radius_00   0
                set radius_01   [expr 0.5 * $diameterToolBase]
                set radius_02   [expr 0.5 * $diameterToolBase]
                set radius_03   [expr 0.5 * $diameterToolTop]
                set radius_04   [expr 0.5 * $diameterToolTop]
                set radius_99   0
                    #
                lappend toolShape [list $lng_00 $radius_00]
                    #
                lappend toolShape [list $lng_01 [expr -1.0 * $radius_01]]
                lappend toolShape [list $lng_02 [expr -1.0 * $radius_02]]
                lappend toolShape [list $lng_03 [expr -1.0 * $radius_03]]
                lappend toolShape [list $lng_04 [expr -1.0 * $radius_04]]
                    #
                lappend toolShape [list $lng_99 $radius_99]
                    #
                lappend toolShape [list $lng_04 $radius_04]
                lappend toolShape [list $lng_03 $radius_03]
                lappend toolShape [list $lng_02 $radius_02]
                lappend toolShape [list $lng_01 $radius_01]
                    #
            }
        cone {
                # puts "  <I> \$typeTool - cone"
                    #
                if {$diameterToolBase == $diameterToolTop} {
                    set toolShape   [getToolShape cylinder]
                    return $toolShape
                }
                set a           [expr 0.5 * ($diameterToolBase - $diameterToolTop) / $lengthToolCone] 
                set lengthCone  [expr 0.5 * $diameterToolBase / $a]
                    #
                if {$a >= 0} {
                        #
                    set lng_00      0
                    set lng_01      0
                    set lng_02      $lengthToolBase
                    set lng_03      [expr $lengthToolBase + $lengthToolCone]
                    set lng_04      $lengthTool
                    set lng_99      [expr $lengthToolBase + $lengthCone]
                    if {$lng_03 > $lng_04} {
                        set lng_03 $lng_04
                    }
                    set radius_00   0
                    set radius_01   [expr  0.5 * $diameterToolBase + ($lengthToolBase * $a)]
                    set radius_02   [expr  0.5 * $diameterToolBase]
                    set radius_03   [expr  0.5 * $diameterToolTop]
                    set radius_04   [expr  0.5 * $diameterToolTop - (($lengthTool - ($lengthToolBase + $lengthToolCone)) * $a)]
                    set radius_99   0
                        #
                } else {
                        #
                    set lng_00      [expr $lengthToolBase + $lengthCone]
                    set lng_01      0
                    set lng_02      $lengthToolBase
                    set lng_03      [expr $lengthToolBase + $lengthToolCone]
                    set lng_04      $lengthTool
                    set lng_99      $lengthTool
                        #
                    set radius_00   0
                    set radius_01   [expr  0.5 * $diameterToolBase + ($lengthToolBase * $a)]
                    set radius_02   [expr  0.5 * $diameterToolBase]
                    set radius_03   [expr  0.5 * $diameterToolTop]
                    set radius_04   [expr  0.5 * $diameterToolBase - (($lengthTool - $lengthToolBase) * $a)]
                    set radius_99   0
                        #
                }
                
                lappend toolShape [list $lng_00 $radius_00]
                    #
                lappend toolShape [list $lng_01 [expr -1.0 * $radius_01]]
                lappend toolShape [list $lng_02 [expr -1.0 * $radius_02]]
                lappend toolShape [list $lng_03 [expr -1.0 * $radius_03]]
                lappend toolShape [list $lng_04 [expr -1.0 * $radius_04]]
                    #
                lappend toolShape [list $lng_99 $radius_99]
                    #
                lappend toolShape [list $lng_04 $radius_04]
                lappend toolShape [list $lng_03 $radius_03]
                lappend toolShape [list $lng_02 $radius_02]
                lappend toolShape [list $lng_01 $radius_01]
                    #
                
                    #
                # exit
                    #
            }
        cylinder -
        default {
                # puts "  <I> \$typeTool - cylinder"
                    #
                lappend toolShape [list 0           [expr -0.5 * $diameterToolBase]]
                lappend toolShape [list $lengthTool [expr -0.5 * $diameterToolBase]]
                    #
                lappend toolShape [list $lengthTool [expr  0.5 * $diameterToolBase]]
                lappend toolShape [list 0           [expr  0.5 * $diameterToolBase]]
            }
    }
        #
    foreach {xy} $toolShape {
        # puts "       ---- $typeTool -> $xy"
    }
        #
    set toolShape [vectormath::addVectorPointList [list [expr -1.0 * $lengthOffset_z] 0] $toolShape]
    set toolShape [vectormath::rotatePointList    {0 0} $toolShape 90]
    set toolShape [join $toolShape " "]    
        #
    return $toolShape
        #
}
    #
proc control::update {{key _any} {value {}}} {
        #
    puts "\n\n--< control::update >--"
    puts "      \$key:     $key"
    puts "      \$value:   $value"
        #
    variable precision 
    variable angleTool 
    variable angleTube     
    variable diameterToolBase      
    variable diameterToolTop       
    variable diameterTube_1         
    variable diameterTube_2         
    variable lengthTool             
    variable lengthToolBase
    variable lengthToolCone        
    variable lengthOffset_x        
    variable lengthOffset_z        
    variable lengthTube 
    variable typeTool        
    variable typeProfile        
    variable angleToolPlane
        #
    variable viewMiter    
        #
    puts ""    
    puts "    --------------------------------------------------"    
    puts "          -> \$typeTool           $typeTool"
    puts "          -> \$typeProfile        $typeProfile"
    puts ""
    puts "          -> \$precision          $precision"    
    puts ""
    puts "          -> \$angleTool          $angleTool"    
    puts "          -> \$diameterToolBase   $diameterToolBase"    
    puts "          -> \$diameterToolTop    $diameterToolTop"    
    puts "          -> \$lengthTool         $lengthTool"    
    puts "          -> \$lengthToolBase     $lengthToolBase"    
    puts "          -> \$lengthToolCone     $lengthToolCone"    
    puts "          -> \$lengthOffset_x     $lengthOffset_x"
    puts "          -> \$lengthOffset_z     $lengthOffset_z"
    puts ""    
    puts "          -> \$angleTube          $angleTube"    
    puts "          -> \$diameterTube_1     $diameterTube_1"    
    puts "          -> \$diameterTube_2     $diameterTube_2"    
    puts "          -> \$lengthTube         $lengthTube"        
    puts ""        
    puts "          -> \$angleToolPlane     $angleToolPlane"
        # puts "          -> \$viewMiter          $viewMiter"
    puts "    --------------------------------------------------"    
    puts ""    
        #
        #
    variable miterObject
        #
    variable miterDebugPlane  
    variable miterDebugCylinder  
        #
        #
    if [info exists $key] {
        puts "    -> set $key $value"
        set $key $value
    } else {
        puts "    -> can not set $key $value"
    }
        #
        #
    $miterObject        setScalar   Precision            $precision
        #
    set precision       [$miterObject getScalar   Precision]
        #
        #
    if {$viewMiter eq "right"} {
        set toolRotation $angleToolPlane
    } else {
        set toolRotation [expr -1 * $angleToolPlane]
    }
        
        # -- profile
        #
    switch -exact $typeProfile {
        oval {
            $miterDebugCylinder setProfileDef \
                                    [list   -type           oval \
                                            -diameter_x     $diameterTube_1 \
                                            -diameter_y     $diameterTube_2 \
                                            -rotation       $toolRotation \
                                            -precision      $precision]
            $miterDebugPlane    setProfileDef \
                                    [list   -type           oval \
                                            -diameter_x     $diameterTube_1 \
                                            -diameter_y     $diameterTube_2 \
                                            -rotation       $toolRotation \
                                            -precision      $precision]
            $miterObject        setProfileDef \
                                    [list   -type           oval \
                                            -diameter_x     $diameterTube_1 \
                                            -diameter_y     $diameterTube_2 \
                                            -rotation       $toolRotation \
                                            -precision      $precision]
                #
            # $miterDebugCylinder setProfileType              oval
            # $miterDebugPlane    setProfileType              oval
            # $miterObject        setProfileType              oval
            #     #
            # $miterDebugCylinder setScalar  DiameterTube     $diameterTube_1
            # $miterDebugCylinder setScalar  DiameterTube2    $diameterTube_2
            # $miterDebugPlane    setScalar  DiameterTube     $diameterTube_1
            # $miterDebugPlane    setScalar  DiameterTube2    $diameterTube_2
            # $miterObject        setScalar  DiameterTube     $diameterTube_1
            # $miterObject        setScalar  DiameterTube2    $diameterTube_2
            #     #
            # $miterObject        setScalar  AngleToolPlane   $angleToolPlane
                #
        }
        round -
        default {
            $miterDebugCylinder setProfileDef \
                                    [list   -type           round \
                                            -diameter       $diameterTube_1 \
                                            -rotation       $toolRotation \
                                            -precision      $precision]
            $miterDebugPlane    setProfileDef \
                                    [list   -type           round \
                                            -diameter       $diameterTube_1 \
                                            -rotation       $toolRotation \
                                            -precision      $precision]
            $miterObject        setProfileDef \
                                    [list   -type           round \
                                            -diameter       $diameterTube_1 \
                                            -rotation       $toolRotation \
                                            -precision      $precision]
                #
            # $miterDebugCylinder setProfileType              round
            # $miterDebugPlane    setProfileType              round
            # $miterObject        setProfileType              round
            #     #
            # $miterDebugCylinder setScalar  DiameterTube     $diameterTube_1
            # $miterDebugPlane    setScalar  DiameterTube     $diameterTube_1
            # $miterObject        setScalar  DiameterTube     $diameterTube_1
            #     #
            # $miterObject        setScalar  AngleToolPlane   $angleToolPlane
                #
        } 
    }
        #
        # $miterDebugPlane      setScalar  AngleToolPlane $angleToolPlane
        # $miterDebugCylinder   setScalar  AngleToolPlane $angleToolPlane
        #
        #
        # -- miterDebugCylinder
        #
    $miterDebugCylinder setScalar   AngleTool               $angleTool
    $miterDebugCylinder setScalar   OffsetCenterLine        $lengthOffset_x
    $miterDebugCylinder updateMiter   
        # $miterDebugCylinder setScalar   AngleToolPlane      $angleToolPlane
        #
        #
        # -- miterDebugPlane
        #
    $miterDebugPlane    setScalar   AngleTool               $angleTool
    $miterDebugPlane    setScalar   DiameterTool            $diameterToolBase   
    $miterDebugPlane    setScalar   OffsetToolBase          $lengthOffset_z   
    $miterDebugPlane    updateMiter
        #
        #
        # -- miterObject
        #
    switch -exact $typeTool {
        cone -
        cylinder -
        frustum -
        plane {
            set typeName $typeTool
        }
        default {
            tk_messageBox -message "\$typeTool: $typeTool not defined"
        }
    }
        #
    $miterObject          setToolType                 $typeName
        #
    if {$typeTool eq {cone}} {
            #
        set k   [expr 0.5 * ($diameterToolBase - $diameterToolTop) / $lengthToolCone]
            #
        if {$k >= 0} {
                #
                # set length_01   $lengthToolBase
                # set radius_01   [expr  0.5 * $diameterToolBase]
                # set length_02   $lengthOffset_z
            set radius_02   [expr  0.5 * $diameterToolBase - ($lengthOffset_z - $lengthToolBase) * $k]
            set length_03   [expr  $radius_02 / $k]
                # 
            $miterObject setScalar  HeightToolCone      $length_03 
            $miterObject setScalar  AngleTool           $angleTool
            $miterObject setScalar  DiameterTool        [expr 2.0 * $radius_02]  
            $miterObject setScalar  DiameterTop         $diameterToolTop    
            $miterObject setScalar  OffsetCenterLine    $lengthOffset_x   
            $miterObject setScalar  OffsetToolBase      $length_03 
                #
                # puts ""    
                # puts "           HeightToolCone     [$miterObject  getScalar   HeightToolCone  ]"    
                # puts "           AngleTool          [$miterObject  getScalar   AngleTool       ]"    
                # puts "           DiameterTool       [$miterObject  getScalar   DiameterTool    ]"    
                # puts "           DiameterTop        [$miterObject  getScalar   DiameterTop     ]"    
                # puts "           DiameterTube       [$miterObject  getScalar   DiameterTube    ]"    
                # puts "           OffsetCenterLine   [$miterObject  getScalar   OffsetCenterLine]"    
                # puts "           OffsetToolBase     [$miterObject  getScalar   OffsetToolBase  ]"    
                # puts "           AngleToolPlane     [$miterObject  getScalar   AngleToolPlane  ]"    
                # puts ""    
                #
        } else {
            return 
        }
    } else {
            $miterObject setScalar  AngleTool           $angleTool
            $miterObject setScalar  DiameterTool        $diameterToolBase   
            $miterObject setScalar  DiameterTop         $diameterToolTop    
            $miterObject setScalar  HeightToolCone      $lengthToolCone    
            $miterObject setScalar  OffsetCenterLine    $lengthOffset_x   
            $miterObject setScalar  OffsetToolBase      [expr $lengthOffset_z - $lengthToolBase] 
    }
    $miterObject updateMiter
        #
        #
        # puts "\n\n\n --- update Miter -------\n"    
        #
        #
    puts "\n\n\n --- update Miter --done-\n"    
        #
    control::updateStage
        #
    return
        #
}
proc control::updateStage {{value {0}}} {
        #
    variable dim_size
    variable dim_font_select
        #
    variable typeTool
        #
        #
    set cvObject $::view::cvObject
        #
    $cvObject deleteContent
        #
    cleanReport
        #
    $cvObject configure Style    Fontstyle    $dim_font_select
    $cvObject configure Style    Fontsize     $dim_size
        #
        #
    set mode    B
        #
    switch -exact $mode {
        A {
            createTube      {  10   40}
        }
        B {
            createTube      {  10   40}
            createMiter     {-130   40}
            createDebug     { 150   60}
            createDictView  {  10  110}
        }
        default {
            createTube      {  10   70}
            createMiter     {-130   70}
            createDebug     { 150   90}
        }
    }
        
        #
        #
    control::moveto_StageCenter __CenterLine__ 
    control::moveto_StageCenter __ToolShape__
    control::moveto_StageCenter __TubeShape__
    control::moveto_StageCenter __DebugShape__
        #
        #
    return    
        #
}
    #
proc control::createMiter {position} {
        #
    variable drw_scale
    variable dim_size
    variable dim_font_select
    variable dim_size
    variable dim_dist 
    variable dim_offset
    variable font_colour
        #
    variable angleTool 
    variable angleTube     
    variable diameterToolBase      
    variable diameterToolTop       
    variable diameterTube_1         
    variable diameterTube_2         
    variable lengthTool             
    variable lengthToolBase
    variable lengthToolCone        
    variable lengthOffset_z        
    variable lengthTube                             
        #
    variable typeTool
    variable viewMiter
        #
    variable miterObject
        #
        #
    set cvObject $::view::cvObject
        #
    array set pos {}
    set pos(TubeOrigin) $position
    set pos(TubeEnd)    [vectormath::addVector      $pos(TubeOrigin) {0 1} [expr -1.0 * $lengthTube]]
        #
        #
    if {$viewMiter eq {right}} {
        set angleToolView   $angleTool
        set dir_Tool        [vectormath::dirCarthesian [expr 270 - $angleTool]]
        set miterView       origin
    } else {
        set angleToolView   [expr 0 - $angleTool]
        set dir_Tool        [vectormath::dirCarthesian [expr 270 + $angleTool]]
        set miterView       opposite
    }
        #
    set pos(ToolOrigin) [vectormath::addVector      $pos(TubeOrigin) $dir_Tool [expr -1.0 * $lengthOffset_z]]  
    set pos(ToolEnd)    [vectormath::addVector      $pos(ToolOrigin) $dir_Tool $lengthTool]  
        #
        #
    set shape_Tool      [control::getToolShape]
    set shape_Origin    [vectormath::addVectorCoordList $pos(TubeOrigin) $shape_Tool]
    set shape_Origin    [vectormath::rotateCoordList    $pos(TubeOrigin) $shape_Origin  [expr 180 - $angleToolView]]
    set shape_End       [vectormath::addVectorCoordList $pos(TubeEnd)    $shape_Tool]
    set shape_End       [vectormath::rotateCoordList    $pos(TubeEnd)    $shape_End                 $angleToolView ]
        #
    set dir_Tube        [vectormath::dirCarthesian [expr 90 + $angleTool]]
        #
        #
    set profile_Origin  [$miterObject getProfile  Origin  right   $miterView]
    set profile_Origin  [vectormath::addVectorCoordList $pos(TubeOrigin) $profile_Origin]
        #
    set profile_End     [$miterObject getProfile  End     right   $miterView]
    set profile_End     [vectormath::addVectorCoordList $pos(TubeEnd) $profile_End]
        #
    set shapeTube       [join "$profile_Origin $profile_End" " "]
        #
        #
        #
    $cvObject  create polygon       $shape_Origin       [list -tags __ToolShape__  -outline red    -fill gray80 -width 0.1]
    $cvObject  create polygon       $shape_End          [list -tags __ToolShape__  -outline red    -fill gray80 -width 0.1]
        #
        #
    if {$profile_Origin eq {}} {
        puts "   -> \$profile_Origin  $profile_Origin  ... leer"
        puts "   -> \$profile_End     $profile_End  ... leer"
        return
    }    
        #
    $cvObject  create polygon       $shapeTube          [list -tags __TubeShape__  -outline blue    -fill gray80 -width 0.1]
        # $cvObject  create polygon $profile_Origin     -tags __TubeShape__  -outline blue    -fill gray80 -width 0.1
        # $cvObject  create polygon $profile_End        -tags __TubeShape__  -outline blue    -fill gray80 -width 0.1
        #
        #
    $cvObject  create centerline    [list $pos(TubeOrigin) $pos(TubeEnd)]   [list -fill orange    -width 0.035     -tags __CenterLine__]
    $cvObject  create circle        $pos(TubeEnd)       [list -radius  1       -outline orange    -width 0.035     -tags __CenterLine__]
    $cvObject  create circle        $pos(TubeOrigin)    [list -radius  1       -outline orange    -width 0.035     -tags __CenterLine__]
        #
    $cvObject  create centerline    [list $pos(ToolOrigin) $pos(ToolEnd)]   [list -fill orange    -width 0.035     -tags __CenterLine__]
    $cvObject  create circle        $pos(ToolEnd)       [list -radius  1       -outline orange    -width 0.035     -tags __CenterLine__]
    $cvObject  create circle        $pos(ToolOrigin)    [list -radius  1       -outline orange    -width 0.035     -tags __CenterLine__]
        #
        #
    return    
        #
}
    
proc control::createTube {position} {
        #
    variable drw_scale
    variable dim_size
    variable dim_font_select
    variable dim_size
    variable dim_dist 
    variable dim_offset
    variable font_colour
        #
    variable angleTool 
    variable angleTube     
    variable diameterToolBase      
    variable diameterToolTop       
    variable diameterTube_1         
    variable diameterTube_2         
    variable lengthTool             
    variable lengthToolBase
    variable lengthToolCone        
    variable lengthOffset_z        
    variable lengthTube                             
        #
    variable typeTool
    variable viewMiter
        #
    variable miterObject
        #
        #
    set PI $vectormath::CONST_PI
        #
        #
    set cvObject $::view::cvObject
        #
        #
    array set pos {}
    set pos(TubeOrigin) $position
    set pos(TubeEnd)    [vectormath::addVector      $pos(TubeOrigin) {0 1} [expr -1.0 * $lengthTube]]
        #
        #
        # -- viewMiter
        #
    if {$viewMiter eq "right"} {
        set topView    "top"        ;# default
        set leftView   "opposite"   ;# default
        set rightView  "origin"     ;# default
    } else {
        set topView    "bottom"        ;# default
        set leftView   "origin"
        set rightView  "opposite"
    }
        #
    set miterOrigin     [$miterObject getMiter Origin $rightView]
    set miterOrigin     [vectormath::addVectorCoordList $pos(TubeOrigin) $miterOrigin]
        #
    set miterEnd        [$miterObject getMiter End    $rightView]
    set miterEnd        [vectormath::addVectorCoordList $pos(TubeEnd)    $miterEnd]
        #
        # -- viewPosition
        #
    set xLeft           [expr -0.5 * $diameterTube_1 * ($PI - 1)]  
    set xRight          [expr  0.5 * $diameterTube_1 * ($PI - 1)]  
        #
        #
        #
        # -- tube: top view
        #
    set profileOrigin   [$miterObject getProfile  Origin  $topView      $rightView]
        # set profileOrigin   [$miterObject getProfile  Origin  top     $rightView]
        # puts " -> \$profileOrigin  $profileOrigin "
        #
    set profileOrigin   [vectormath::addVectorCoordList $pos(TubeOrigin)    $profileOrigin]
        #
    set profileEnd      [$miterObject getProfile  End     $topView      $rightView]
    set profileEnd      [vectormath::addVectorCoordList $pos(TubeEnd)   $profileEnd]
        #
    set shapeTube_Top   [join "$profileOrigin $profileEnd" " "]    
        #
        #return
        #
        # -- tube: bottom view
        #
    set profileOrigin   {}
    set profileOrigin_  [$miterObject getProfile  Origin  bottom        $rightView]
    foreach {x y} $profileOrigin_ {
        lappend profileOrigin [expr -1.0 * $x] $y
    }
    set profileOrigin   [vectormath::addVectorCoordList $pos(TubeOrigin)    $profileOrigin]
        #
    set profileEnd      {}
    set profileEnd_     [$miterObject getProfile  End     bottom        $rightView]
    foreach {x y} $profileEnd_ {
        lappend profileEnd    [expr -1.0 * $x] $y
    }
    set profileEnd      [vectormath::addVectorCoordList $pos(TubeEnd)       $profileEnd]
        #
    set shapeTube_Bottom [join "$profileOrigin $profileEnd" " "] 
        #
    set shapeTube_Debug [vectormath::addVectorCoordList {10 20}       $shapeTube_Bottom]
        #
    if {$shapeTube_Bottom eq {}} {
        puts "  -> \$shapeTube_Bottom $shapeTube_Bottom ... leer"    
        return
    }    
    if {$shapeTube_Top eq {}} {
        puts "  -> \$shapeTube_Top $shapeTube_Top ... leer"    
        return
    }    
        #
    $cvObject  create polygon       $shapeTube_Bottom   [list     -outline green -fill gray60    -width 0.035     -tags __CenterLine__]
    $cvObject  create polygon       $shapeTube_Top      [list     -outline red   -fill gray80    -width 0.035     -tags __CenterLine__]
        # $cvObject  create polygon $shapeTube_Debug        -outline green -fill gray80    -width 0.035     -tags __CenterLine__
        #
        # return
        #
        # -- tube: left view (default)
        #
    set profileOrigin   [$miterObject getProfile  Origin  right     $rightView]
    set profileOrigin   [vectormath::addVectorCoordList $pos(TubeOrigin)    $profileOrigin]
        #
    set profileEnd      [$miterObject getProfile  End     right     $rightView]
    set profileEnd      [vectormath::addVectorCoordList $pos(TubeEnd)       $profileEnd]
        #
    set leftView_Front [join "$profileOrigin $profileEnd" " "]    
        #
        #
    set profileOrigin   [$miterObject getProfile  Origin  left      $leftView]
    set profileOrigin   [vectormath::addVectorCoordList $pos(TubeOrigin) $profileOrigin]
        #
    set profileEnd      [$miterObject getProfile  End     left      $leftView]
    set profileEnd      [vectormath::addVectorCoordList $pos(TubeEnd)    $profileEnd]
        #
    set leftView_Back   [join "$profileOrigin $profileEnd" " "]    
        #
        #
        # puts "  -> \$shapeTube_Bottom $shapeTube_Bottom"
        #
    set leftView_Back   [vectormath::addVectorCoordList [list $xLeft 0]  $leftView_Back]
    set leftView_Front  [vectormath::addVectorCoordList [list $xLeft 0]  $leftView_Front]
        #
    $cvObject  create polygon       $leftView_Back     [list     -outline blue   -fill gray60    -width 0.035     -tags __CenterLine__]
    $cvObject  create polygon       $leftView_Front    [list     -outline blue   -fill gray80    -width 0.035     -tags __CenterLine__]
        #
        # return
        #
        # -- tube: right view front (default)
        #
    set profileOrigin   [$miterObject getProfile  Origin  right  $leftView]
    set profileOrigin   [vectormath::addVectorCoordList $pos(TubeOrigin)    $profileOrigin]
        #
    set profileEnd      [$miterObject getProfile  End     right  $leftView]
    set profileEnd      [vectormath::addVectorCoordList $pos(TubeEnd)       $profileEnd]
        #
    set rightView_Front  [join "$profileOrigin $profileEnd" " "]    
        #
        #
    set profileOrigin   [$miterObject getProfile  Origin  left   $rightView]
    set profileOrigin   [vectormath::addVectorCoordList $pos(TubeOrigin) $profileOrigin]
        #
    set profileEnd      [$miterObject getProfile  End     left   $rightView]
    set profileEnd      [vectormath::addVectorCoordList $pos(TubeEnd)    $profileEnd]
        #
    set rightView_Back [join "$profileOrigin $profileEnd" " "]    
        #
        # puts "  -> \$shapeTube_Bottom $shapeTube_Bottom"    
        #
    set rightView_Back  [vectormath::addVectorCoordList [list $xRight 0]  $rightView_Back]
    set rightView_Front [vectormath::addVectorCoordList [list $xRight 0]  $rightView_Front]
        #
    $cvObject  create polygon       $rightView_Back     [list     -outline blue   -fill gray60    -width 0.035     -tags __CenterLine__]
    $cvObject  create polygon       $rightView_Front    [list     -outline blue   -fill gray80    -width 0.035     -tags __CenterLine__]
        #
        # return
        #
        # ---- miter profiles
        #
        #
    $cvObject  create line          $miterOrigin        [list                     -fill orange    -width 0.035     -tags __CenterLine__]
    $cvObject  create line          $miterEnd           [list                     -fill orange    -width 0.035     -tags __CenterLine__]
        #
        # return
        #
        # ---- help lines
        #
    $cvObject  create centerline    [list $pos(TubeOrigin) $pos(TubeEnd)] [list   -fill orange    -width 0.035     -tags __CenterLine__]    
    $cvObject  create circle        $pos(TubeEnd)       [list -radius  1       -outline orange    -width 0.035     -tags __CenterLine__]
    $cvObject  create circle        $pos(TubeOrigin)    [list -radius  1       -outline orange    -width 0.035     -tags __CenterLine__]
        #
}
proc control::createDebug {position} {
        #
        # --- upper right view
        #
    variable drw_scale
    variable dim_size
    variable dim_font_select
    variable dim_size
    variable dim_dist 
    variable dim_offset
    variable font_colour
        #
    variable angleTool 
    variable angleTube     
    variable diameterToolBase      
    variable diameterToolTop       
    variable diameterTube_1         
    variable diameterTube_2         
    variable lengthTool             
    variable lengthToolBase
    variable lengthToolCone        
    variable lengthOffset_x        
    variable lengthOffset_z        
    variable lengthTube                             
        #
    variable typeTool
    variable typeProfile
    variable viewMiter
        #
        #
    variable miterObject
        #
    variable miterDebugCylinder
    variable miterDebugPlane
        #
        #
    set cvObject $::view::cvObject
        #
        #
    set scale_y  [expr cos(180 - $angleTool)]
        #
        #
    array set pos {}
    set dir_Tube        [vectormath::dirCarthesian 180]
    set pos(TubeOrigin) {0 0}
    set pos(TubeEnd)    [vectormath::addVector      {0 0} $dir_Tube [expr  0.5 * $lengthTube]]
        #
        #
        #
        # -- definitions
        #
    if {$viewMiter eq {right}} {
        set angleToolView   [expr  90 - $angleTool]     ;# Shape
        set dir_Tool        [vectormath::dirCarthesian [expr  180 - $angleTool]]
    } else {
        set angleToolView   [expr  90 + $angleTool]     ;# Shape
        set dir_Tool        [vectormath::dirCarthesian [expr  180 + $angleTool]]
    }
        #
    set pos(ToolOrigin) [vectormath::addVector      {0 0} $dir_Tool [expr -1.0 * $lengthOffset_z]]  
    set pos(ToolEnd)    [vectormath::addVector      $pos(ToolOrigin) $dir_Tool $lengthTool]  
        #
        # return
        #
        # -- shape of tool 
        #
    set shape_Tool      {}
    set shape_Tool_     [control::getToolShape]
    set shape_Tool_     [vectormath::rotateCoordList    {0 0} $shape_Tool_ $angleToolView]
    foreach {x y} $shape_Tool_ {
        #lappend shape_Tool $x [expr $scale_y * $y]
    }
    set shape_Tool      $shape_Tool_
        #
        # return
        #
        # -- shape of debug miters 
        #
        # puts "\n    -> \$viewMiter $viewMiter"     
    if {$viewMiter eq {right}} {
        set miterView       origin
    } else {
        set miterView       opposite
    }
        # puts "    -> \$miterView $miterView\n"     
        #
    set planeView_XZ    [$miterDebugPlane   getProfile  Origin  right   $miterView]
        #
    if {$planeView_XZ eq {}} {
        return
    }    
        #
    set pos(PlaneTop)    [lrange $planeView_XZ 0 1]
    set pos(PlaneBottom) [lrange $planeView_XZ 2 3]
        #
        # return
        #
        # -- create tube
        #
    set profileView_XZ  [$miterObject getProfile  Origin  right   $miterView]
    set profileView_XZ  [vectormath::rotateCoordList    {0 0} $profileView_XZ   270]
    set profileView_XZ  [vectormath::addVectorCoordList {0 0} $profileView_XZ]
    switch -exact $typeProfile {
        oval {
            set pos_01  [vectormath::perpendicular  $pos(TubeEnd)   {0 0}    [expr 0.5 * $diameterTube_2]] 
            set pos_02  [vectormath::perpendicular  $pos(TubeEnd)   {0 0}    [expr 0.5 * $diameterTube_2] left] 
        }
        round -
        default {
            set pos_01  [vectormath::perpendicular  $pos(TubeEnd)   {0 0}    [expr 0.5 * $diameterTube_1]] 
            set pos_02  [vectormath::perpendicular  $pos(TubeEnd)   {0 0}    [expr 0.5 * $diameterTube_1] left] 
        } 
    }
    set profileView_XZ  [join "$profileView_XZ $pos_01 $pos_02" " "]
        #
        #
    set pos(TubeTop)    [lrange $profileView_XZ 0 1]
    set pos(TubeBottom) [lrange $profileView_XZ end-1 end]
        #
    set myPolygon       [vectormath::addVectorCoordList $position $shape_Tool]
    $cvObject  create polygon   $myPolygon  [list -outline red  -fill gray80    -width 0.1      -tags __ToolShape__]
        #
        # puts "  -> [llength $shape_Tool] -> \$shape_Tool $shape_Tool" 
        #
    set myPolygon       [vectormath::addVectorCoordList $position $profileView_XZ]
    $cvObject  create polygon   $myPolygon  [list -outline blue -fill gray80    -width 0.1      -tags __DebugShape__]
    set myPositon       [vectormath::addVector          $position $pos(TubeTop)]
    $cvObject  create circle    $myPositon  [list -radius 1   -outline blue     -width 0.035    -tags __CenterLine__]
    set myPositon       [vectormath::addVector          $position $pos(TubeBottom)]
    $cvObject  create circle    $myPositon  [list -radius 1   -outline blue     -width 0.035    -tags __CenterLine__]
    set myPositon       [vectormath::addVector          $position $pos(PlaneTop)]
    $cvObject  create circle    $myPositon  [list -radius 1   -outline orange   -width 0.035    -tags __CenterLine__]
    
    
puts "   -> \$planeView_XZ $planeView_XZ"
puts "   -> \$position $position"
puts "   -> \$pos(PlaneBottom) $pos(PlaneBottom)"    
    
    set myPositon       [vectormath::addVector          $position $pos(PlaneBottom)]
    $cvObject  create circle    $myPositon  [list -radius 1   -outline orange   -width 0.035    -tags __CenterLine__]
        #
        # return
        #
        # -- do some representations depending on ... $typeTool
        #
    switch -exact $typeTool {
        cone {
                #
            set k           [expr  0.5 * ($diameterToolBase - $diameterToolTop) / $lengthToolCone]
            set radius_02   [expr  0.5 * $diameterToolBase - ($lengthOffset_z - $lengthToolBase) * $k]
            set length_03   [expr  $radius_02 / $k]
                # 
                # $miterObject  setScalar   HeightToolCone      $length_03 
                # $miterObject  setScalar   AngleTool           $angleTool
            
            
        #    set cutProfile [tubeMiter::CutConeProfile $radius_02 $length_03 $lengthOffset_x [expr 0.5 * $diameterTube_1] $angleTool]
                # tubeMiter::CutConeProfile {r h x rt angle}
        #    set myLine  [vectormath::rotateCoordList    {0 0} $cutProfile -90]
        #    set myLine  [vectormath::addVectorCoordList $position $myLine]
        #    $cvObject  create line      $myLine             [list -tags __ToolShape__                   -fill darkred  -width 0.1]
                #
        }
    }
    switch -exact $typeTool {
        cone -
        frustum {
            set pos_01 [lrange $shape_Tool  4  5]
            set pos_02 [lrange $shape_Tool  6  7]
            set pos_03 [lrange $shape_Tool 14 15]
            set pos_04 [lrange $shape_Tool 16 17]
            set line_01 [join "$pos_01 $pos_04" " "]
            set line_02 [join "$pos_02 $pos_03" " "]
            catch {
                set myLine  [vectormath::addVectorCoordList $position $line_01]
                $cvObject  create line      $myLine            [list -tags __ToolShape__                  -fill orange -width 0.1]
                set myLine  [vectormath::addVectorCoordList $position $line_02]
                $cvObject  create line      $myLine            [list -tags __ToolShape__                  -fill orange -width 0.1]
            }
        }
    }
    
        # --- get debug miterprofiles of top and base cylinder 
        #
    switch -exact $typeTool {
        cone -
        frustum__ {
                #
            if {$diameterToolBase == $diameterToolTop} {
                return
            }
                #
            set p_cone_00   [list [expr -0.5 * $diameterToolBase] $lengthToolBase]
            set p_cone_00   [vectormath::addVector          [list 0 [expr -1.0 * $lengthOffset_z]] $p_cone_00]
            set p_cone_00   [vectormath::rotateCoordList    {0 0} $p_cone_00 $angleToolView]
            set p_cone_50   [list 0 $lengthToolBase]
            set p_cone_50   [vectormath::addVector          [list 0 [expr -1.0 * $lengthOffset_z]] $p_cone_50]
            set p_cone_50   [vectormath::rotateCoordList    {0 0} $p_cone_50 $angleToolView]
            set p_cone_99   [list 0 [expr $lengthToolBase + (0.5 * $diameterToolBase) / (0.5 * ($diameterToolBase - $diameterToolTop) / $lengthToolCone)]]
            set p_cone_99   [vectormath::addVector          [list 0 [expr -1.0 * $lengthOffset_z]] $p_cone_99]
            set p_cone_99   [vectormath::rotateCoordList    {0 0} $p_cone_99 $angleToolView]
                #
            set myPositon   [vectormath::addVector          $position   $p_cone_00]
            $cvObject  create circle    $myPositon  [list -radius 1    -outline red  -width 0.035    -tags __CenterLine__]
            set myPositon       [vectormath::addVector      $position   $p_cone_50]
            $cvObject  create circle    $myPositon  [list -radius 1    -outline red  -width 0.035    -tags __CenterLine__]
            set myPositon       [vectormath::addVector      $position   $p_cone_99]
            $cvObject  create circle    $myPositon  [list -radius 1    -outline red  -width 0.035    -tags __CenterLine__]
                #
            switch -exact $typeProfile {
                oval {
                    set l_tube_Top  [vectormath::parallel {0 0} $pos(TubeEnd) [expr 0.5 * $diameterTube_2]]
                    set l_tube_Bot  [vectormath::parallel {0 0} $pos(TubeEnd) [expr 0.5 * $diameterTube_2] left]
                }
                round {
                    set l_tube_Top  [vectormath::parallel {0 0} $pos(TubeEnd) [expr 0.5 * $diameterTube_1]]
                    set l_tube_Bot  [vectormath::parallel {0 0} $pos(TubeEnd) [expr 0.5 * $diameterTube_1] left]
                }
            }   
                #
            foreach {p_tube_00 p_tube_99} $l_tube_Top break
                #
            set p_sect_Top  [vectormath::intersectPoint $p_cone_00 $p_cone_99 $p_tube_00 $p_tube_99 center]
            set r_sect_Top  [vectormath::distancePerp   $p_cone_50 $p_cone_99 $p_sect_Top]
                #
            $miterDebugCylinder setScalar   DiameterTool    [expr 2.0 * $r_sect_Top]
            $miterDebugCylinder updateMiter   
                #
            set profileSect_XZ  [$miterDebugCylinder getProfile Origin  right   $viewMiter]
                #
            set myPositon       [vectormath::addVector          $position $p_sect_Top]
            $cvObject  create circle    $myPositon          [list  -radius  1   -outline red -width 0.035    -tags __CenterLine__]
            set myLine          [vectormath::addVectorCoordList $position $profileSect_XZ]
            $cvObject  create line      $myLine             [list               -fill red    -width 0.1      -tags __ToolShape__]
                #
                # -----------
                #
            foreach {p_tube_00 p_tube_99} $l_tube_Bot break
                #
            set p_sect_Bot  [vectormath::intersectPoint $p_cone_00 $p_cone_99 $p_tube_00 $p_tube_99]
            set r_sect_Bot  [vectormath::distancePerp   $p_cone_50 $p_cone_99 $p_sect_Bot]
                #
            $miterDebugCylinder setScalar   DiameterTool    [expr 2.0 * $r_sect_Bot]
            $miterDebugCylinder updateMiter   
                #
            set profileSect_XZ  [$miterDebugCylinder getProfile Origin  right   $viewMiter]
                #
            set myPositon       [vectormath::addVector          $position $p_sect_Bot]
            $cvObject  create circle    $myPositon          [list  -radius  1   -outline red    -width 0.035    -tags __CenterLine__]
            set myLine          [vectormath::addVectorCoordList $position $profileSect_XZ]
            $cvObject  create line      $myLine             [list               -fill red       -width 0.1      -tags __ToolShape__]
                #
        }

    }
    switch -exact $typeTool {
        cone__ -
        frustum -
        plane {
                #
            $miterDebugCylinder setScalar   DiameterTool    $diameterToolTop
            $miterDebugCylinder updateMiter   
                #
            set profileTop_XZ   [$miterDebugCylinder getProfile Origin  right   $viewMiter]
               #
            set myLine          [vectormath::addVectorCoordList $position $profileTop_XZ]
            $cvObject  create line  $myLine             [list  -fill orange  -width 0.1  -tags __ToolShape__]
                #
        }
    }
    switch -exact $typeTool {
        cone__ -
        frustum {
                #
            $miterDebugCylinder setScalar   DiameterTool    $diameterToolBase
            $miterDebugCylinder updateMiter   
                #
            set profileBase_XZ  [$miterDebugCylinder getProfile Origin  right   $viewMiter]
                #
            set myLine          [vectormath::addVectorCoordList $position $profileBase_XZ]
            $cvObject  create line  $myLine             [list  -fill orange  -width 0.1  -tags __ToolShape__]
                #
        }
    }
        #
        #
        # -- shape of profile 
        #
    set shape_Profile   [$miterObject getProfileShape]    
    set myLine          [vectormath::addVectorCoordList $position $shape_Profile]
    $cvObject  create line      $myLine            [list -tags __ToolShape__                  -fill orange -width 0.1]
        #
        #
    set myLine                  [vectormath::addVectorPointList $position [list {0 0} $pos(TubeEnd)]]
    $cvObject  create centerline    $myLine             [list -fill orange  -width 0.035     -tags __CenterLine__]
        #
    set myLine                  [vectormath::addVectorPointList $position [list $pos(ToolOrigin) $pos(ToolEnd)]]
    $cvObject  create centerline    $myLine             [list -fill orange  -width 0.035     -tags __CenterLine__]
        #
    set myPositon               [vectormath::addVector          $position {0 0}]
    $cvObject  create circle        $myPositon          [list -radius  1    -outline orange    -width 0.035     -tags __CenterLine__]
        #
    set myPositon               [vectormath::addVector          $position $pos(ToolEnd)]
    $cvObject  create circle        $myPositon          [list -radius  1    -outline orange    -width 0.035     -tags __CenterLine__]
        #
    set myPositon               [vectormath::addVector          $position $pos(ToolOrigin)]
    $cvObject  create circle        $myPositon          [list -radius  1    -outline orange    -width 0.035     -tags __CenterLine__]
        
        #
        #
        #
        # control::refit_board
        #
        #
    return    
        #
}
    
proc control::createDictView {position} {
        #
        # --- upper dict view
        #
    variable miterObject
    variable diameterTube_1         
    variable diameterTube_2         
        #
    set cvObject $::view::cvObject
        #
        #
    set pos(CoordOrigin)    {0 0}
    set viewLength          150
        #
    set miterDict   [$miterObject getDictionary]
        #
    set indexList   [lsort   [dict keys $miterDict]]
    set indexCount  [llength $indexList]
    puts "    -> createDictView: \$indexCount $indexCount"
        #
    set keyLeft     [lindex $indexList   0]
    set keyRight    [lindex $indexList end]
        #
    set dict_phi    {}    
    set dict_x      {}
    set dict_y      {}
    set dict_z      {}
        #
    set key_00      {} 
        #
    set pos_left    [dict get $miterDict $keyLeft phi_grd]    
    set pos_right   [dict get $miterDict [lindex $indexList end] phi_grd]    
        #
        #
    set i           0    
        #
    dict for {key keyDict} $miterDict {
            #
            # puts "    -> \$key $key"    
            #
        set phi_grd [dict get $keyDict phi_grd]
        set phi_rad [dict get $keyDict phi_rad]
        set x       [dict get $keyDict x]
        set y       [dict get $keyDict y]
        set z       [dict get $keyDict z]
            #
        dict set dict_x     $i phi  $phi_rad   
        dict set dict_x     $i y    $x
        dict set dict_y     $i phi  $phi_rad
        dict set dict_y     $i y    $y
        dict set dict_z     $i phi  $phi_rad
        dict set dict_z     $i y    $z
            #
        if {$phi_grd <= 0} {
            set key_00      $i
        }   
            #
        incr i    
            #
    }
        #
        # set l_complete  [expr $pos_right - $pos_left]
        #
    set dL          [expr 1.0 * $viewLength / ($indexCount - 1)]
        #
    puts "    -> createDictView: \$dL $dL"
        #
        #
        #
    set help_00 [list [expr (0 - $key_00) * $dL] 0  [expr (($indexCount - 1) - $key_00) * $dL] 0 ]    
    set myLine  [vectormath::addVectorCoordList $position $help_00]
    $cvObject  create line   $myLine    [list -outline gray20               -width 0.01     -tags __DebugShape__]
        #

        #
    set list__x {}
    dict for {key keyDict} $dict_x {
            #
        set phi [dict get $keyDict phi]
        set y   [dict get $keyDict y]
            #
        set pos_x           [expr 2 * $diameterTube_1 * $phi / $vectormath::CONST_PI]
        lappend list__x     $pos_x $y
            #
    }
        #
    set myLine  [vectormath::addVectorCoordList $position $list__x]
    $cvObject  create line   $myLine    [list -outline blue                 -width 0.1      -tags __DebugShape__]
        #
        #
    set list__y {}
    dict for {key keyDict} $dict_y {
            #
        set phi [dict get $keyDict phi]
        set y   [dict get $keyDict y]
            #
        set pos_x           [expr 2 * $diameterTube_1 * $phi / $vectormath::CONST_PI]
        lappend list__y     $pos_x $y
            #
    }
        #
    set myLine  [vectormath::addVectorCoordList $position $list__y]
    $cvObject  create line   $myLine    [list -outline lightblue            -width 0.1      -tags __DebugShape__]
        #
        #
    set list__z {}
    dict for {key keyDict} $dict_z {
            #
        set phi [dict get $keyDict phi]
        set y   [dict get $keyDict y]
            #
        set pos_x           [expr 2 * $diameterTube_1 * $phi / $vectormath::CONST_PI]
        lappend list__z     $pos_x $y
            #
    }
        #
    set myLine  [vectormath::addVectorCoordList $position $list__z]
    $cvObject  create line   $myLine    [list -outline red                  -width 0.1      -tags __DebugShape__]
        #
        #
        #
    #set myPolygon       [vectormath::addVectorCoordList $position $profileView_XZ]
    #$cvObject  create polygon   $myPolygon  [list -outline blue -fill gray80    -width 0.1      -tags __DebugShape__]

        #
    set pos(CoordLeft)      [vectormath::addVector          $pos(CoordOrigin)   [list [expr -0.5 * $diameterTube_1 * $vectormath::CONST_PI] 0]]
    set myPositon           [vectormath::addVector          $position $pos(CoordLeft)]
    $cvObject  create circle        $myPositon          [list -radius  1    -outline orange    -width 0.035     -tags __CenterLine__]
        #
    set pos(CoordRight)     [vectormath::addVector          $pos(CoordOrigin)   [list [expr  0.5 * $diameterTube_1 * $vectormath::CONST_PI] 0]]
    set myPositon           [vectormath::addVector          $position $pos(CoordRight)]
    $cvObject  create circle        $myPositon          [list -radius  1    -outline orange    -width 0.035     -tags __CenterLine__]
        #
    set myPositon           [vectormath::addVector          $position $pos(CoordOrigin)]
    $cvObject  create circle        $myPositon          [list -radius  5    -outline orange    -width 0.035     -tags __CenterLine__]
        
        #
        #
        #
        # control::refit_board
        #
        #
    return    
        #
}
    #
    #
    # -- VIEW --
    #
proc view::create_config_line {w lb_text entry_var start end  } {        
        frame   $w
        pack    $w
 
        global $entry_var

        label   $w.lb    -text $lb_text            -width 20  -bd 1  -anchor w 
        entry   $w.cfg    -textvariable $entry_var  -width 10  -bd 1  -justify right -bg white 
     
        scale   $w.scl  -width        12 \
                        -length       120 \
                        -bd           1  \
                        -sliderlength 15 \
                        -showvalue    0  \
                        -orient       horizontal \
                        -command      "control::update $entry_var" \
                        -variable     $entry_var \
                        -from         $start \
                        -to           $end 
                            # -resolution   $resolution
                            # -command      "control::updateStage" \

        pack      $w.lb  $w.cfg $w.scl    -side left  -fill x            
}
proc view::create_status_line {w lb_text entry_var} {         
        frame   $w
        pack    $w
 
        global $entry_var

        label     $w.lb     -text $lb_text            -width 20  -bd 1  -anchor w 
        entry     $w.cfg    -textvariable $entry_var  -width 10  -bd 1  -justify right -bg white 
        pack      $w.lb  $w.cfg    -side left  -fill x            
}
proc view::demo_canvasCAD {} {
          
      variable  stageCanvas
      
      $stageCanvas  create   line           {0 0 20 0 20 20 0 20 0 0}       -tags {Line_01}  -fill blue   -width 2 
      $stageCanvas  create   line           {30 30 90 30 90 90 30 90 30 30} -tags {Line_01}  -fill blue   -width 2 
      $stageCanvas  create   line           {0 0 30 30 }                    -tags {Line_01}  -fill blue   -width 2 
      
      $stageCanvas  create   rectangle      {180 120 280 180 }              -tags {Line_01}  -fill violet   -width 2 
      $stageCanvas  create   polygon        {40 60  80 50  120 90  180 130  90 150  50 90 35 95} -tags {Line_01}  -outline red  -fill yellow -width 2 

      $stageCanvas  create   oval           {30 160 155 230 }               -tags {Line_01}  -fill red   -width 2         
      $stageCanvas  create   circle         {160 60}            -radius 50  -tags {Line_01}  -fill blue   -width 2 
      $stageCanvas  create   arc            {270 160}           -radius 50  -start 30       -extent 170 -tags {Line_01}  -outline gray  -width 2  -style arc
      
      $stageCanvas  create   text           {140 90}  -text "text a"
      $stageCanvas  create   vectortext     {120 70}  -text "vectorText ab"
      $stageCanvas  create   vectortext     {100 50}  -text "vectorText abc"  -size 10
      $stageCanvas  create   text           {145 95}  -text "text abcd" -size 10
}
proc view::create {windowTitle} {
        #
    variable reportText
    variable stageCanvas
        #
    variable cvObject
    variable cv_scale
    variable drw_scale
        #
    frame .f0 
    set f_view      [labelframe .f0.f_view          -text "view"]
    set f_config    [labelframe .f0.f_config        -text "config"]

    pack  .f0      -expand yes -fill both
    pack  $f_view  $f_config    -side left -expand yes -fill both
    pack  configure  $f_config    -fill y
    
    
    set f_board     [labelframe $f_view.f_board     -text "board"]
    set f_report    [labelframe $f_view.f_report    -text "report"]
    pack  $f_board  $f_report    -side top -expand yes -fill both
   
  
        #
        ### -- G U I - canvas 
    set cvObject    [cad4tcl::new  $f_board  800 600  A3  1.0  25]
    set stageCanvas [$cvObject getCanvas]
    set cv_scale    [$cvObject configure Canvas Scale]
    set drw_scale   [$cvObject configure Stage Scale]
    
        #
        ### -- G U I - canvas report
        #
    set reportText  [text       $f_report.text  -width 50  -height 7]
    set reportScb_x [scrollbar  $f_report.sbx   -orient hori  -command "$reportText xview"]
    set reportScb_y [scrollbar  $f_report.sby   -orient vert  -command "$reportText yview"]
    $reportText     conf -xscrollcommand "$reportScb_x set"
    $reportText     conf -yscrollcommand "$reportScb_y set"
        grid $reportText $reportScb_y   -sticky news
        grid             $reportScb_x   -sticky news
        grid rowconfig    $f_report  0  -weight 1
        grid columnconfig $f_report  0  -weight 1

        #
        ### -- G U I - canvas demo
            
    set f_settings  [labelframe .f0.f_config.f_settings  -text "Test - Settings" ]
        
    labelframe  $f_config.tool            -text "Tool"
    labelframe  $f_config.geometry        -text "Geometry"
    labelframe  $f_config.profile         -text "Profile"
    labelframe  $f_config.config          -text "Config"
    labelframe  $f_config.demo            -text demo
    labelframe  $f_config.tooltype        -text "ToolType:"
    labelframe  $f_config.miterView       -text "MiterView:"
    labelframe  $f_config.scale           -text scale

    pack    $f_config.profile   \
            $f_config.tool      \
            $f_config.config    \
            $f_config.geometry  \
            $f_config.demo      \
            $f_config.tooltype  \
            $f_config.miterView \
            $f_config.scale     \
        -fill x -side top
        
    view::create_config_line $f_config.profile.d_1        "Diameter:            "     control::diameterTube_1      20    60   ;#   0
    view::create_config_line $f_config.profile.d_2        "Diameter-2:          "     control::diameterTube_2      30    80   ;#   0
    view::create_config_line $f_config.profile.l          "Length:              "     control::lengthTube         100   250   ;#   0
    
    view::create_config_line $f_config.tool.l_cone        "Length Cone:         "     control::lengthToolCone      10   120   ;#   0
    view::create_config_line $f_config.tool.l_base        "Length BaseCylinder: "     control::lengthToolBase       0    30   ;#   0
    view::create_config_line $f_config.tool.d_top         "Diameter Top   :     "     control::diameterToolTop      5    60   ;#   0
    view::create_config_line $f_config.tool.d_bse         "Diameter Base  :     "     control::diameterToolBase    30    70   ;#   0
    view::create_config_line $f_config.tool.l             "Length:              "     control::lengthTool          90   250   ;#   0
    
    view::create_config_line $f_config.config.prec        "Precision:           "     control::precision            0   120   ;#  10
    
    view::create_config_line $f_config.geometry.d_tt      "Angle Tool:          "     control::angleTool            0   180   ;#   0
    view::create_config_line $f_config.geometry.o_t_z     "Offset Tool z:       "     control::lengthOffset_z       0   120   ;#   0
    view::create_config_line $f_config.geometry.o_t_y     "Offset Tool x:       "     control::lengthOffset_x     -20    20   ;#  24
    view::create_config_line $f_config.geometry.t_a       "Angle Tool-Plane     "     control::angleToolPlane    -120   120   ;#   0
            
    radiobutton  $f_config.profile.typeCircle       -text "Circle"          -variable control::typeProfile   -command control::update    -value round    
    radiobutton  $f_config.profile.typeEllipse      -text "Ellipse"         -variable control::typeProfile   -command control::update    -value oval 

    pack    $f_config.profile.typeCircle  \
            $f_config.profile.typeEllipse \
        -side top  -fill x
        

    
    radiobutton  $f_config.tooltype.typePlane       -text "Plane"           -variable control::typeTool   -command control::update    -value plane    
    radiobutton  $f_config.tooltype.typeCylinder    -text "Cylinder"        -variable control::typeTool   -command control::update    -value cylinder 
    radiobutton  $f_config.tooltype.typeCone        -text "Cone"            -variable control::typeTool   -command control::update    -value cone     
    radiobutton  $f_config.tooltype.typeCombined    -text "Frustum"         -variable control::typeTool   -command control::update    -value frustum 
        
    pack    $f_config.tooltype.typePlane    \
            $f_config.tooltype.typeCylinder \
            $f_config.tooltype.typeCone     \
            $f_config.tooltype.typeCombined \
        -side top  -fill x
        
    radiobutton  $f_config.miterView.viewRight      -text "right"           -variable control::viewMiter  -command control::update    -value right    
    radiobutton  $f_config.miterView.viewLeft       -text "left"            -variable control::viewMiter  -command control::update    -value left
    
    pack    $f_config.miterView.viewRight \
            $f_config.miterView.viewLeft \
        -side top  -fill x
    
    $f_config.geometry.d_tt.scl     configure       -resolution 0.1
    $f_config.geometry.o_t_z.scl    configure       -resolution 0.1
    $f_config.geometry.o_t_y.scl    configure       -resolution 0.1
    $f_config.geometry.t_a.scl      configure       -resolution 0.1
    
    
    
    
    
        # view::create_config_line $f_config.scale.drw_scale    " Drawing scale "           control::drw_scale  0.2  2  
        #   $f_config.scale.drw_scale.scl      configure       -resolution 0.1
        # button             $f_config.scale.recenter   -text   "recenter"      -command {control::recenter_board}
    view::create_config_line $f_config.scale.cv_scale     " Canvas scale  "           control::cv_scale   0.1   2.0  
                       $f_config.scale.cv_scale.scl       configure       -resolution 0.1  -command "control::scale_board"
    button             $f_config.scale.refit      -text   "refit"         -command {control::refit_board}

    pack      \
            $f_config.scale.cv_scale \
            $f_config.scale.refit \
        -side top  -fill x                                                          
                     
    pack  $f_config  -side top -expand yes -fill both
         
            #
            ### -- G U I - canvas print
            #    
        #set f_print  [labelframe .f0.f_config.f_print  -text "Print" ]
        #    button  $f_print.bt_print   -text "print"  -command {$view::stageCanvas print "E:/manfred/_devlp/_svn_sourceforge.net/canvasCAD/trunk/_print"} 
        #pack  $f_print  -side top     -expand yes -fill x
        #    pack $f_print.bt_print     -expand yes -fill x
        
        
        #
        ### -- G U I - canvas demo
        #   
    set f_demo  [labelframe .f0.f_config.f_demo  -text "Demo" ]
        button  $f_demo.bt_clear   -text "clear"    -command {$::view::cvObject deleteContent} 
        button  $f_demo.bt_update  -text "update"   -command {control::updateStage}
     
    pack  $f_demo  -side top    -expand yes -fill x
        pack $f_demo.bt_clear   -expand yes -fill x
        pack $f_demo.bt_update  -expand yes -fill x
    
    
        #
        ### -- F I N A L I Z E
        #

    control::cleanReport
    control::writeReport "aha"
        # exit
        
        
        ####+### E N D
        
    update
    
    wm minsize . [winfo width  .]   [winfo height  .]
    wm title   . $windowTitle
    
    $cvObject fit

    return . $stageCanvas

}
    #
    #
    # -- INIT --
    #
set returnValues [view::create $WINDOW_Title]
    #
    
control::refit_board
    #
# $::view::stageCanvas reportXMLRoot
        
    #
# appUtil::pdict $::model::dict_TubeMiter 
    #
control::update

