
# Copyright (c) Ixia technologies 2011-2012, Inc.

set releaseVersion 4.32
#===============================================================================
# Change made
# ==2011==
# Version 1.0 
#       1. Create
# Version 1.1
#       2. Release on June 12th
# Version 1.2
#		3. Release on June 14th 
# Version 1.3
# 		4. Release on June 15th
# Version 1.4
#		5. Release on June 28th
# Version 1.5
#		6. Release on June 30th
#		7. Add-in IxOperate package for compatibility
# Version 1.6
#		8. Release on July 21st
# Version 1.7
#		9. Release on July 28th
# Version 1.8
#		10. Release on Aug 4th
# Version 1.9
#		11. Release on Aug 7th
# Version 1.10
#		12. Release on Aug 9th
# Version 1.11
#		13. Release on Aug 9th
# Version 1.12
#		14. Release on Aug 10th
# Version 1.13
#		15. Release on Aug 18th
# Version 1.14
#		16. Release on Aug 25th
# Version 1.15
#		17. Release on Aug 26th
# version 1.16
#		18. Release on Aug 30th
# version 1.17
#		19. Release on Sep 1st
# Version 2.0
#		20. Add Ospf/bgp interface
#		21. Release on Sep 5th
# Version 2.1
#		22. Release on Sep 20th
# Version 2.2
#		23. Release on Oct 20th
# Version 2.3
#		24. Release on Oct 24th
# Version 2.4
#		25. Release on Nov 3rd
# Version 2.5
#		26. Multiuser login 
#		27. Release on Nov 21st
# Version 2.6
#		28. Release on Nov 28th
# Version 2.7
#		29. Release on Nov 30th
# Version 2.8
#		30. Release on Dec 28th
# Version 2.9
#		31. Release on Dec 30th
# ==2012==
# Version 2.10
#		32. Release on Jan 5th
# Version 2.11
#		33. Release on Jan 12th
# Version 2.12
#		34. Release on Jan 13th
# Version 2.13
#		35. Release on Jan 14th
# Version 2.14
#		36. Release on Jan 18th
# Version 2.15
#		37. Release on Jan 20th
# Version 2.16
#		38. Release on Feb 15th
# Version 2.17
#		39. Release on Feb 28th
# Version 2.18
#		40. Release on Mar 20th
# Version 2.19
#		41. Release on Mar 30th
# Version 2.20
#		42. Release on Apr 17th
# Version 2.21
#		43. Release on Apr 18th
# Version 2.23
# 		44. Release on May 5th
# Version 2.24
#		45. Release on May 22nd
# Version 2.25
#		46. Release on June 5th
# Version 3.1
#		47. Add Rfc2544/Trill/DCBX/FC/FCoE interface 
#		48. Release on June 17th
# Version 3.2
#		49. Add DCBX Qaz TLV
#		50. Release on June 26th
# Version 3.3
#		51. Release on June 28th
# Version 3.5
#		52. Release on July 5th
# Version 3.6
#		53. Release on July 10th
# Version 3.7
#		54. Release on July 11th
# Version 3.8
#		55. Release on July 17th
# Version 3.9
#		56. Release on July 18th
# Version 3.10
# 		57. Release on July 24th
# Version 4.0
#		58. Release on July 30th
# Version 4.1
#		59. Release on Aug 2nd
# Version 4.2
#       60. Release on Aug 17th
# Version 4.3
#		61. Release on Aug 17th
# Version 4.4
#		61. Release on Aug 22th
# Version 4.5
#		61. Release on Aug 24th
# Version 4.6
#		62. Release on Sep 10th
# Version 4.7
#		63. Release on Sep 12th
#		64. include rfc2544
# Version 4.8
#		65. Release on Sep 24th
# Version 4.9
#		66. Release on Oct 8th
#       67. Include Ospfv3/PIM/RIP
# Version 4.10
#		68. Release on Oct 15th
# Version 4.11
#		69. Release on Oct 22nd
# Version 4.12
#		70. Release on Nov 1st
# Version 4.13
#		71. Release on Nov 7th
# Version 4.14
#		72. Release on Nov 9th
# Version 4.15
#		73. Release on Nov 17th
# Version 4.16
#		74. Release on Nov 19th
# Version 4.17
#		75. Release on Nov 26th
# Version 4.18
#		76. Release on Nov 29th
# Version 4.19
#		77. Fix Tcl Proxy reconnection defect
#		78. Release on Dec 12nd
# Version 4.20
#		79. Release on Dec 27th
# ==2013==
# Version 4.21
#		80. Release on Jan 10th
# Version 4.22
#		81. Release on Jan 18th
# Version 4.23
#		82. Release on Feb 7th
# Version 4.24
#		83. Release on Feb 22th
# Version 4.25
#       84. Add log file ixlogfile
#		85. Release on Mar 15th
# Version 4.26
#       86. Add force option in proc Login
#       87. Release on Mar 29th
# Version 4.27
#       88. Change log file direction to c:/windows/temp/ixlogfile
#       89. Release on Apr 12th
# Version 4.28
#       90. Release on Apr 19th
# Version 4.29
#       91. Release on May 8th
# Version 4.30
#       92. Release on Jun 21th
# Version 4.31
#       92. Release on Nov 7th
# Version 4.31patch
#		93. Release on Nov 24th
# ==2014==
# Version 4.32
#       94. Add proc loadconfig, modify Login 
#       95. source Ixia_NetDot1xRate.tcl
#       96. Release on Mar 19th


proc GetEnvTcl { product } {
   
   set productKey     "HKEY_LOCAL_MACHINE\\SOFTWARE\\Ixia Communications\\$product"
   set versionKey     [ registry keys $productKey ]
   set latestKey      [ lindex $versionKey end ]

   if { $latestKey == "Multiversion" } {
      set latestKey   [ lindex $versionKey [ expr [ llength $versionKey ] - 2 ] ]
   }
   set installInfo    [ append productKey \\ $latestKey \\ InstallInfo ]            
   return             [ registry get $installInfo  HOMEDIR ]

}

set portlist [list]
set trafficlist [list]
set portnamelist [list]
set trafficnamelist [list]
set tportlist [list]
set flownamelist [list]
set flowlist [list]
set flowitemlist [list]
set traffictxportlist [list]

proc loadconfig { filename } {
    global portlist
    global trafficlist
    global portnamelist
    global trafficnamelist
    global tportlist
    global flownamelist
    global flowlist
    global flowitemlist
    global traffictxportlist
    puts "Loadconfig $filename"
    ixNet exec loadConfig [ixNet readForm $filename]
    set root [ixNet getRoot]
    set portlist [ixNet getL $root vport]
    foreach portobj $portlist {
        lappend portnamelist [ixNet getA $portobj -name]
    }
    
    set trafficlist [ixNet getL [ixNet getL $root traffic] trafficItem]
    foreach trafficItemobj $trafficlist {
	    lappend trafficnamelist [ixNet getA $trafficItemobj -name]
        set itemlist [ixNet getL $trafficItemobj highLevelStream]
        lappend traffictxportlist [ixNet getA [lindex $itemlist 0] -txPortName]
        #lappend flowlist $itemlist
        foreach trafficobj $itemlist {
            lappend flowlist $trafficobj
            lappend flowitemlist $trafficItemobj
            lappend flownamelist [ixNet getA $trafficobj -name]
            lappend tportlist [ixNet getA $trafficobj -txPortName]
        }
		
    }

}

set loginInfo	"localhost/8009"
proc Login { { location "localhost/8009"} { force 0 } { filename null } } {

	global ixN_tcl_v
	global loginInfo
    
    global portlist
    global trafficlist
    global portnamelist
    global trafficnamelist
    global tportlist
    
	set loginInfo $location
puts "Login...$location"	
	if { $location == "" } {
		set port "localhost/8009"
	} else {
		set port $location
	}

	set portInfo [ split $port "/" ]
	set server	 [ lindex $portInfo 0 ]
	if { [ regexp {\d+\.\d+\.\d+\.\d+} $server ] || ( $server == "localhost" ) } {
		set portInfo [ lreplace $portInfo 0 0 ]
	} else {
		set server localhost
	}
	if { [ llength $portInfo ] == 0 } {
		set portInfo 8009
	}
    
    set flag 0
	foreach port $portInfo {
		ixNet disconnect
		ixNet connect $server -version $ixN_tcl_v -port $port
		set root [ ixNet getRoot]
		
		if { $force } {
			puts "Login successfully on port $port."
			#return	
            set flag 1            
		} else {
			if { [ llength [ ixNet getL $root vport ] ] > 0 } {
				puts "The connecting optional port $port is ocuppied, try next port..."
				continue
			} else {
				puts "Login successfully on port $port."
				#return
                set flag 1
			}
		}
		
		ixNet setA $root/traffic/statistics/l1Rates -enabled True
		ixNet setA $root/traffic \
				-enableDataIntegrityCheck False \
				-enableMinFrameSize True
		ixNet commit
        
        if { $flag == 1 } {
            if { $filename != "null" } {
                loadconfig $filename
				after 15000
                
                foreach pname $portnamelist pobj $portlist {
                    Port $pname NULL NULL $pobj
                }
                
                foreach tname $trafficnamelist tobj $trafficlist tport $portnamelist {
                    Traffic $tname $tport $tobj
                }
				
				return
                
            } else {
                return
            }
        }
	}
	puts "Login failed on all port $portInfo."
	return
}

proc GetAllPortObj {} {

	set portObj [list]
	set objList [ find objects ]
	foreach obj $objList {
		if { [ $obj isa Port ] } {
			lappend portObj [ $obj cget -handle ]
		}
	}
	return $portObj
}

set currDir [file dirname [info script]]
puts "Package Directory $currDir"
puts "load package Ixia_Util..."
if { [ catch {
	source [file join $currDir Ixia_Util.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetObj..."
if { [ catch {
	source [file join $currDir Ixia_NetObj.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetTester..."
if { [ catch {
	source [file join $currDir Ixia_NetTester.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetPort..."
if { [ catch {
	source [file join $currDir Ixia_NetPort.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetTraffic..."
if { [ catch {
	source [file join $currDir Ixia_NetTraffic.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetDhcp..."
if { [ catch {
	source [file join $currDir Ixia_NetDhcp.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetIgmp..."
if { [ catch {
	source [file join $currDir Ixia_NetIgmp.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetCapture..."
if { [ catch {
	source [file join $currDir Ixia_NetCapture.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetCaptureFilter..."
if { [ catch {
	source [file join $currDir Ixia_NetCaptureFilter.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetOspf..."
if { [ catch {
	source [file join $currDir Ixia_NetOspf.tcl]
} err ] } {
	puts "load package fail...$err"
}
puts "load package Ixia_NetL3Vpn6Vpe..." 
if { [ catch {
	source [file join $currDir Ixia_NetL3Vpn6Vpe.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetLdp..."
if { [ catch {
	source [file join $currDir Ixia_NetLdp.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetIsis..."

if { [ catch {
	source [file join $currDir Ixia_NetIsis.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetTrill..."
if { [ catch {
	source [file join $currDir Ixia_NetTrill.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetDcbx..."
if { [ catch {
	source [file join $currDir Ixia_NetDcbx.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetFcoe..."
if { [ catch {
	source [file join $currDir Ixia_NetFcoe.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetPPPoX..."
if { [ catch {
	source [file join $currDir Ixia_NetPPPoX.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetBgp..."
if { [ catch {
	source [file join $currDir Ixia_NetBgp.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetRfc2544..."
if { [ catch {
	source [file join $currDir Ixia_NetRFC2544.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetDot1xRate..."
if { [ catch {
	source [file join $currDir Ixia_NetDot1xRate.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetRip..."
if { [ catch {
	source [file join $currDir Ixia_NetRip.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetPim...."
if { [ catch {
	source [file join $currDir Ixia_NetPim.tcl]
} err ] } {
	puts "load package fail...$err"
} 
puts "load package Ixia_NetFlow...."
if { [ catch {
	source [file join $currDir Ixia_NetFlow.tcl]
} err ] } {
	puts "load package fail...$err"
}
puts "load package IxOperate..."
if { [ catch {
	source [file join $currDir IxOperate.tcl]
} err ] } {
	puts "load package fail...$err"
} 

set errNumber(1)    "Bad argument value or out of range..."
set errNumber(2)    "Madatory argument missed..."
set errNumber(3)    "Unsupported parameter..."
set errNumber(4)    "Confilct argument..."
puts "set error message list..."

set ixN_tcl_v "6.0"
puts "connect to ixNetwork Tcl Server version $ixN_tcl_v"
if { $::tcl_platform(platform) == "windows" } {
	puts "windows platform..."
	package require registry

    if { [ catch {
	    lappend auto_path  "[ GetEnvTcl IxNetwork ]/TclScripts/lib/IxTclNetwork"
    } err ] } {
        puts "Failed to invoke IxNetwork environment...$err"
	}

puts "load package IxTclNetwork..."
	package require IxTclNetwork
	puts "load package IxTclHal..."	
	catch {	
		source [ GetEnvTcl IxOS ]/TclScripts/bin/ixiawish.tcl
	}
	catch {package require IxTclHal}
}

package provide IxiaNet $releaseVersion
puts "package require success on version $releaseVersion"

# catch { console hide }

rename ixNet IxNet
proc ixNet { args } {
	DeputsCMD "ixNet $args"
	eval IxNet $args
}

if { [file exist "c:/windows/temp/ixlogfile"] } {
} else {
    file mkdir "c:/windows/temp/ixlogfile"
}
set timeVal  [ clock format [ clock seconds ] -format %Y%m%d_%H_%M ]
set clickVal [ clock clicks ]
set logfile_name "c:/windows/temp/ixlogfile/$timeVal.txt"

IxDebugOn
IxDebugCmdOn