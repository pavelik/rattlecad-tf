#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"


 ##+##########################################################################
 #
 # rattleCAD.tcl
 #
 #   rattleCAD is software of Manfred ROSENBERGER
 #       based on tclTk and BWidgets and their 
 #       own Licenses.
 # 
 # Copyright (c) Manfred ROSENBERGER, 2010/10/24
 #
 # The author  hereby grant permission to use,  copy, modify, distribute,
 # and  license this  software  and its  documentation  for any  purpose,
 # provided that  existing copyright notices  are retained in  all copies
 # and that  this notice  is included verbatim  in any  distributions. No
 # written agreement, license, or royalty  fee is required for any of the
 # authorized uses.  Modifications to this software may be copyrighted by
 # their authors and need not  follow the licensing terms described here,
 # provided that the new terms are clearly indicated on the first page of
 # each file where they apply.
 #
 # IN NO  EVENT SHALL THE AUTHOR  OR DISTRIBUTORS BE LIABLE  TO ANY PARTY
 # FOR  DIRECT, INDIRECT, SPECIAL,  INCIDENTAL, OR  CONSEQUENTIAL DAMAGES
 # ARISING OUT  OF THE  USE OF THIS  SOFTWARE, ITS DOCUMENTATION,  OR ANY
 # DERIVATIVES  THEREOF, EVEN  IF THE  AUTHOR  HAVE BEEN  ADVISED OF  THE
 # POSSIBILITY OF SUCH DAMAGE.
 #
 # THE  AUTHOR  AND DISTRIBUTORS  SPECIFICALLY  DISCLAIM ANY  WARRANTIES,
 # INCLUDING,   BUT   NOT  LIMITED   TO,   THE   IMPLIED  WARRANTIES   OF
 # MERCHANTABILITY,    FITNESS   FOR    A    PARTICULAR   PURPOSE,    AND
 # NON-INFRINGEMENT.  THIS  SOFTWARE IS PROVIDED  ON AN "AS  IS" BASIS,
 # AND  THE  AUTHOR  AND  DISTRIBUTORS  HAVE  NO  OBLIGATION  TO  PROVIDE
 # MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 #
 

  ###########################################################################
  #
  #                 I  -  N  -  I  -  T                        -  Application
  #
  ###########################################################################

    puts "\n\n ====== I N I T ============================ \n\n"
        
        # -- ::APPL_Config(BASE_Dir)  ------
    set BASE_Dir  [file normalize [file join [file dirname [file normalize $::argv0]] ..]]
    puts "   -> BASE_Dir: $BASE_Dir\n"
      
        # -- redefine on Starkit  -----
        #         exception for starkit compilation
        #        .../rattleCAD.exe
    set APPL_Type       [file tail $BASE_Dir]    
    if {$APPL_Type == {rattleCAD.exe}}    {    
        set BASE_Dir    [file dirname $BASE_Dir]
    }



        # -- Libraries  ---------------
    lappend auto_path           [file join $BASE_Dir lib]
    
	    # puts "  \$auto_path  $auto_path"
	
    package require   rattleCAD     3.4 

    
    
        # -- msgcat -1.5.0.tm - workaround  ----- on windows platforms
    switch $tcl_platform(platform) {
	windows {    
	    puts "\n     ... check registry: HKEY_CURRENT_USER\\Control Panel\\International\n "
            package require   registry 
	    set regPath {HKEY_CURRENT_USER\Control Panel}    
	    if { [catch {registry keys $regPath\\International} fid] } {
			# puts stderr "Could not get keys of $regPath\International\n$fid"
		foreach key [registry keys $regPath] {
		    puts "             $regPath\\$key"
		}
		set interPath $regPath\\International
		puts "\n             $interPath"
		registry set $interPath
		puts   "             ... check: clock format -> [clock format [clock seconds]]\n"
	    } 
	}   
    }
    

    
  ###########################################################################
  #
  #                 R  -  U  -  N  -  T  -  I  -  M  -  E 
  #
  ###########################################################################

    
    if {$argc == 1} {
	init_rattleCAD $BASE_Dir [lindex $argv 0]
    } else {	    
	init_rattleCAD $BASE_Dir
    }
    
 
    puts "\n\n ====== R U N T I M E ============================ \n\n"
        
        
        # -- destroy intro - image ----
    after  0 destroy .intro

        # -- keep on top --------------
    wm deiconify .
   
        # -- test: integrationComplete --------------
    lib_gui::select_cadCanvas  cv_Custom00
    rattleCAD_Test::controlDemo demo_01

    
