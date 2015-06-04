
# Copyright (c) Ixia technologies 2014, Inc.

set FHreleaseVersion 2.2
#===============================================================================
# Change made
# ==2014==
# Version 1.0 
#       1. Create traffic part
# Version 2.0 
#       1. Create protocol part
set FHlogname ""

set fh_testname ""

set currDir [file dirname [info script]]
puts "Package Directory $currDir"
puts "load package IxiaNet..."
if { [ catch {
	source [file join $currDir IxiaNet.tcl]
} err ] } {
	puts "load package fail...$err"
} 
package req IxiaNet
IxDebugOff
IxDebugCmdOff


set fhportlist [list]
set savecapport [list]
set headindex 0
set pppoeclientlist [list]
set pppoeserverlist [list]
set trafficinfo {}
set loadflag 0

namespace eval IxiaFH {
   namespace export *
   
} ;

namespace eval IxiaFH {

	proc Logto { args } {
	  
	  
	    global FHlogname
		global fh_testname
		global ::LOG_PATH
        if {$FHlogname == ""} {
            set currDir [file dirname [info script]]
            set tail [file tail [info script]]
            set fh_testname [lindex [split $tail .] 0]
            set FtimeVal  [ clock format [ clock seconds ] -format %Y%m%d%H%M%S ]
            set FHlogfile "${fh_testname}_${FtimeVal}.log"
           
			if {[info exists ::LOG_PATH ] && $::LOG_PATH != "" } {
		        file mkdir $::LOG_PATH
			    set sp $::LOG_PATH
			} else {
				set sp [file split $currDir]				
				set sp [lreplace $sp end end logs]
				
			}
            set FHlogname [eval file join $sp $FHlogfile]
			puts $FHlogname
        } else {
		    set currDir [file dirname [info script]]
			
            set tail [file tail [info script]]
            set temfh_testname [lindex [split $tail .] 0]
			if {$temfh_testname != $fh_testname } {
			
			    set fh_testname $temfh_testname
				set FtimeVal  [ clock format [ clock seconds ] -format %Y%m%d%H%M%S ]
				
				set FHlogfile "${fh_testname}_${FtimeVal}.log"
				
				if {[info exists ::LOG_PATH ] && $::LOG_PATH != "" } {
				    file mkdir $::LOG_PATH
			        set sp $::LOG_PATH
				} else {
					set sp [file split $currDir]
					set sp [lreplace $sp end end logs]
				}

				set FHlogname [eval file join $sp $FHlogfile]
			}
		}
	    set timeVal  [ clock format [ clock seconds ] -format %T ]
	    set clickVal [ clock clicks ]
	    foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-msg {
					puts "\[<IXIA>TIME:$timeVal\]-msg $value"
					set logIO [open $FHlogname a+]
					puts $logIO "\[<IXIA>TIME:$timeVal\]-msg $value"
					close $logIO
				}
				-info {
					puts "\[<IXIA>TIME:$timeVal\]-info $value"
					set logIO [open $FHlogname a+]
					puts $logIO "\[<IXIA>TIME:$timeVal\]-info $value"
					close $logIO
				}
				default {
					puts "\[<IXIA>TIME:$timeVal\] $value"
					set logIO [open $FHlogname a+]
					puts $logIO "\[<IXIA>TIME:$timeVal\] $value"
					close $logIO
				}
			}
		}
	  
	}

	proc instrument_info_load {args} {
	}

	proc instrument_config_init {args} {
		set tag "instrument_config_init [info script]"
		
		Logto -info "----- TAG: $tag -----"
        global errNumber
		global loadflag
	   
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-configfile {
					set configfile $value
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		
		Login
		
		if { [ info exists configfile ] } {
			loadconfig $configfile
			set loadflag 1
			
		} else {
		   error "$errNumber(2) key:configfile "
		}
		
	}

    proc nstype { namelist } {
        set tag "nstype [info script]"
		Logto -info "----- TAG: $tag -----"
        set newlist {}
        foreach na $namelist {
            lappend newlist "::IxiaFH::$na"
        }
		return $newlist
    
    }

	proc port_reserve {args} {
		set tag "port_reserve "
		Logto -info "----- TAG: $tag -----"
		set offline 0
		global loadflag
        global errNumber
		global portlist
		global trafficlist
		global portnamelist
		global trafficnamelist
		global tportlist
        global flownamelist
        global flowlist
        global flowitemlist
        global traffictxportlist
		
		global fhportlist
		global deviceList
        global pppoeclientlist 
        global pppoeserverlist 
		#trafficinfo use to create flow in same item
		global trafficinfo
		
		
        set pppoeclientlist ""
        set pppoeserverlist ""
		set deviceList "" 
        set fhportlist [::IxiaFH::nstype $portnamelist]
        set tportlist [::IxiaFH::nstype $tportlist]
        set traffictxportlist [::IxiaFH::nstype $traffictxportlist]
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set hw_list $value
				}
				-offline {
					set offline $value
				} 
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		
		set index 0
		after 15000  
		if {[ info exists hw_list ]} {
			if {$offline == 0 } {
				 
				foreach hw_id_org $hw_list {

				  
					if {[regexp {^//(.+)} $hw_id_org b hw_id] == 1} {				
		Logto -info "hw_id:$hw_id"
						set port_handle [lindex $portlist $index]
		Logto -info "port_handle: $port_handle"				
						set portn [lindex $portnamelist $index]
                        if { $loadflag } {
						    Port $portn $hw_id NULL $port_handle
                        } else {
                            $portn Connect $hw_id NULL 0 $port_handle
                        }
						incr index
					} else {
						error "$errNumber(2) :hw_id_org:$hw_id_org"
					}
				}
			} else {
				foreach portn $portnamelist {
	Logto -info "portn:$portn"
					set port_handle [lindex $portlist $index]
	Logto -info "port_handle: $port_handle"
				
					Port $portn NULL NULL $port_handle $offline
					incr index
				}
			}
            if { $loadflag } {
				foreach tname $trafficnamelist tobj $trafficlist tport $traffictxportlist {
						Traffic $tname $tport $tobj
					}

				foreach fname $flownamelist fobj $flowlist tport $tportlist tobj $flowitemlist {
					Flow $fname $tport $fobj $tobj
				}
			}
		} else {
			error "$errNumber(2) :-ports"
			
		}
		# set root [ixNet getRoot]
		# ixNet exec apply $root/traffic
		# after 1000
		
	}
	proc port_create {args} {
		set tag "port_create "
		Logto -info "----- TAG: $tag -----"

		set port_type ethernetcooper
        global errNumber
		global portlist
		global portnamelist		
		global fhportlist
		 
        set len [llength $args]
		puts $len
		set arg [lindex $args 0]
		set flag [llength $arg]
		puts $flag 
		if {$flag==1} {
		    set len 1
		    set arg $args
		}
		puts $arg
		for {set i 0} {$i < $len} {incr i} {
		    foreach { key value } $arg {
			    set key [string tolower $key]
			    switch -exact -- $key {
				    -name {
					    set name $value
				    }
					-port_location {
					    set port_location $value
				    }
				    -port_type {
					    set value [ string tolower $value ]
					    switch $value {
						    ethernet100gigfiber -
							ethernet10gigfiber -
							ethernet40gigfiber -
							ethernetfiber {
							    set port_type "fiber"
							}
							ethernet10gigcopper -
							ethernetcopper {
							    set port_type "copper"
							}
						
						}
					    
				    } 
				    default {
					    error "$errNumber(3) key:$key value:$value"
				    }
			    }
		    }
		    set index 0
            set portn $name
			#set portn [::IxiaFH::nstype $name]
		    
		    if {[ info exists port_location ]} {	
			
			
				if {[regexp {^//(.+)} $port_location b hw_id] == 1} {				
				Logto -info "hw_id:$hw_id"			
					Port $portn $hw_id $port_type 						   
				} else {
					error "$errNumber(2) :hw_id:$hw_id"
				}				    
			} else {
			puts "aaaa"
			Logto -info "offline :$portn"		
					Port $portn NULL NULL NULL 1
			}
            lappend portlist  [$name cget -handle]
		    lappend portnamelist $name
	        set arg [lindex $args [expr $i+1]]
	    }
		# set root [ixNet getRoot]
		# ixNet exec apply $root/traffic
		# after 1000
		
	}
	proc port_config { args } {
		set tag "port_config "
		Logto -info "----- TAG: $tag -----"
		global fhportlist
        global errNumber
				
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port_config $value
                    
                    
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		
		if {[ info exists port_config ]} {
			
			foreach {portname portcfg} $port_config {
			
				foreach { key value } $portcfg {
					set key [string tolower $key]
					Logto -info "portname:$portname; key: $key; value:$value"
					switch -exact -- $key {
						-media {  
							if {$portname == "port*"}  {
								foreach portobj $fhportlist {
									$portobj config -media $value -fhflag 1
									Logto -info "$portobj config -media $value -fhflag 1"
			
								}
							} else {                        
								$portname config -media $value -fhflag 1
                                Logto -info "$portname config -media $value -fhflag 1"								
							}
						}
						-speed {
							set value [ string toupper $value ]
								switch $value {
									10M - 
									100M -
									1G -
									40G -
									100G {
										if {$portname == "port*"}  {
											foreach portobj $fhportlist { 
												$portobj config -speed $value -auto_neg 0 -fhflag 1
												Logto -info "$portobj config -speed $value -fhflag 1"
											
											}
											
										} else {                        
											$portname config -speed $value -auto_neg 0 -fhflag 1
											Logto -info "$portname config -speed $value -fhflag 1"
										
										}
									   
									}
									10G_LAN -
									10G_WAN {
										if {$portname == "port*"}  {
											foreach portobj $fhportlist {  
												$portobj config -type $value -fhflag 1
												Logto -info "$portobj config -type $value -fhflag 1"
											}
										} else {                        
											$portname config -type $value -fhflag 1
											Logto -info "$portname config -type $value -fhflag 1"
										}

									} 
									AUTO_NEG {
										if {$portname == "port*"}  {
											foreach portobj $fhportlist {  
												$portobj config -auto_neg 1 -fhflag 1
												Logto -info "$portobj config -auto_neg $value -fhflag 1"
											}
										} else {                        
											$portname config -auto_neg 1 -fhflag 1
											Logto -info "$portname config -auto_neg $value -fhflag 1"
										}
									}
								}    
						} 
						default {
							error "$errNumber(3) key:$key value:$value"
						}
					}
				}
			}
		} else {
			error "$errNumber(2) :-ports"
			
		}
		after 2000
		# set root [ixNet getRoot]
		# ixNet exec apply $root/traffic
		# after 1000
	     return 1
	}

	proc traffic_start { args } {
		set tag "traffic_start "
		Logto -info "----- TAG: $tag -----"
		global fhportlist
		global trafficnamelist
        global trafficlist
        global flownamelist 
        global flowlist
        global errNumber
        
        set restartCapture 0
        set arp_enable 0
		set regenerate 0
				
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port_list $value
				}
				-streamblock {
					set streamblock $value
				}
				-arp {
					set arp_enable $value
					set regenerate $value
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
        
        set root [ixNet getRoot]
        set temportList [ ixNet getL $root vport ]
        puts "temportList: $temportList"
        if { $arp_enable } {
            foreach hPort $temportList {
            Logto -info "send arp"
                ixNet exec sendArp $hPort
                after 1000
			    
			}
		}
        
        # set txlist
        set txList ""
        set txItemList ""
        if { [info exists port_list ] } {			                
            foreach portobj $port_list {
                if { [regexp {(.+)\*} $portobj a pname ]} {
			
                    foreach fhport $fhportlist {
                        if {[regexp $pname $fhport]} {
                        
                            set phandle [$fhport cget -handle]
                            foreach flow $flowlist {                                    
                                set txPort [ ixNet getA $flow -txPortId ] 
                                if { $txPort == $phandle } {
                                    lappend txList $flow
                                    regexp {^(.+)\/highLevelStream.+$} $flow a txItem 
                                    if { [ lsearch -exact $txItemList $txItem ] == -1 } {
                                        lappend txItemList $txItem
                                    }
                                    
                                }      
                            }    
                        }
                    }
                
                } else { 	
              				
                    set phandle [$portobj cget -handle]
                    foreach flow $flowlist {                                    
                        set txPort [ ixNet getA $flow -txPortId ] 
                        if { $txPort == $phandle } {
						puts $txPort 
                            lappend txList $flow
							puts $txList
                            #set txItem [$flow cget -hTraffic]
							regexp {^(.+)\/highLevelStream.+$} $flow a txItem 
                            if { [ lsearch -exact $txItemList $txItem ] == -1 } {
                                lappend txItemList $txItem
								puts $txItemList
                            }
                        }      
                    }                        
                                            
                }
            }
        }
			
        if { [info exists streamblock ] } {           
            foreach streamobj $streamblock {
                if { [regexp {(.+)\*} $streamobj a stream ]} {
                    foreach sobj $flownamelist {
                        if {[regexp $stream $sobj]} {
                            lappend txList [ $sobj cget -handle ]
                            set txItem [$sobj cget -hTraffic]
							puts $txItem
                            if { [ lsearch -exact $txItemList $txItem ] == -1 } {
                                lappend txItemList $txItem
					
                            }
                            
                        }
                    }                   
                
                } else {
                    lappend txList [ $streamobj cget -handle ]  
                    set txItem [$streamobj cget -hTraffic]
					puts $txItem
                    if { [ lsearch -exact $txItemList $txItem ] == -1 } {
                        lappend txItemList $txItem
				
                    }                    
                }
            }
        }
	
		#-- capture
		#puts "temportList: $temportList"
		foreach hPort $temportList {
			if { [ ixNet getA $hPort/capture    -hardwareEnabled  ] } {
				set restartCapture 1
		    Logto -info "restartCapture enabled"
                ixNet exec stopCapture
                after 1000
				break
			}
		}
        if { $arp_enable } {
            set suspendList [list]
			puts "txItemList: $txItemList"
			if {$txItemList == ""} {
			    set txItemList $trafficlist
				set txList $flowlist
				# puts "txItemList: $txItemList"
				# puts "txList: $txList"
			}
			if { $regenerate } { 
			    set rg_namelist ""
				set rg_ratelist ""
				set rg_ratemode ""
				set rg_sizetype ""
				set rg_fixedsize ""
				set rg_incrfrom ""
				set rg_incrstep ""
				set rg_incrto ""
				
				
			    foreach flow $txList {
				 
				    lappend rg_namelist [ ixNet getA $flow -name ]
					set frame_rate [ ixNet getL $flow frameRate ]
					lappend rg_ratelist [ ixNet getA $frame_rate -rate ]
					lappend rg_ratemode [ ixNet getA $frame_rate -type ]
					set frame_size [ ixNet getL $flow frameSize ]
					lappend rg_sizetype [ ixNet getA $frame_size -type ]
					lappend rg_fixedsize [ ixNet getA $frame_size -fixedSize ]
					lappend rg_incrfrom [ ixNet getA $frame_size -incrementFrom ]
					lappend rg_incrstep [ ixNet getA $frame_size -incrementStep ]
					lappend rg_incrto [ ixNet getA $frame_size -incrementTo ]
					
					
				}
				
					
			}
            foreach item $txItemList { 
            puts $item			
                ixNet exec generate $item
            }
			
			if { $regenerate } { 
			    set rgname ""
				set rgrate ""
				set rgmode ""
				set rgsizetype ""
				set rgfixed ""
				set rgincrfrom ""
				set rgincrstep ""
				set rgincrto ""
			   
			    foreach flow $txList rgname $rg_namelist rgrate $rg_ratelist rgmode $rg_ratemode \
				rgsizetype $rg_sizetype rgfixed $rg_fixedsize rgincrfrom $rg_incrfrom \
				rgincrstep $rg_incrstep rgincrto $rg_incrto {
					# puts "flow: $flow"
					# puts "rgname:$rgname"
				# puts "rgrate:$rgrate" 
				# puts "rgmode:$rgmode"
				# puts "rgsizetype:$rgsizetype" 
				# puts "rgfixed :$rgfixed "
				# puts "rgincrfrom:$rgincrfrom" 
				# puts "rgincrstep:$rgincrstep"
				# puts "rgincrto:$rgincrto"
				    ixNet setA $flow -name  $rgname
					set frame_rate [ ixNet getL $flow frameRate ]
					ixNet setM $frame_rate -type $rgmode  \
					                       -rate $rgrate 
					                       
					set frame_size [ ixNet getL $flow frameSize ]
					ixNet setM $frame_size -type $rgsizetype  \
					                       -fixedSize $rgfixed \
                                           -incrementFrom $rgincrfrom \
										   -incrementStep  $rgincrstep \
										   -incrementTo    $rgincrto
					
					
					
				}
				
				
				ixNet commit
				ixNet commit
			}
		
            after 5000
            foreach fname $flownamelist fobj $flowlist  {
                ixNet setA $fobj -name $fname
            }
            ixNet commit
            foreach tname $trafficnamelist tobj $trafficlist  {
                ixNet setA $tobj -name $tname
            }
            ixNet commit
            ixNet exec apply $root/traffic
            after 3000
            
   
            #ixNet exec start $root/traffic
			ixNet exec startStatelessTraffic $txList
			set timeout 30
			set stopflag 0
			while { 1 } {
				if { !$timeout } {
					break
				}
				set state [ ixNet getA $root/traffic -state ] 
				if { $state != "started" } {
					if { [string match startedWaiting* $state ] } {
						set stopflag 1
					} elseif {[string match stopped* $state ] && ($stopflag == 1)} {
						break	
					}	
					after 1000		
				} else {
					break
				}
				incr timeout -1
			}
			after 3000
			Tester::stop_traffic
            ixNet exec closeAllTabs
			# ixNet exec clearStats
            # foreach item [ ixNet getL $root/traffic trafficItem ] {
               # ixNet exec startDefaultLearning $item
            # }
          
		} else {
            ixNet exec apply $root/traffic
            after 3000
        }
        
        if { $restartCapture } {
			catch { 				
		
				ixNet exec closeAllTabs
                ixNet exec startCapture
                after 3000
			}
		}
         
        
        
		
		if { [info exists port_list] || [info exists streamblock] } {
			
            ixNet exec startStatelessTraffic $txList
            return 1								
			
		} else {
			Tester::start_traffic 1 1
			return 1
		}
	}

	proc traffic_stop { args } {
		set tag "traffic_stop "
		Logto -info "----- TAG: $tag -----"
		global fhportlist
		global trafficnamelist
        global errNumber
				
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port_list $value                    
				}
				-streamblock {
					set streamblock $value
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		
		
		if { [info exists port_list] || [info exists streamblock] } {
			
			if { [info exists port_list ] } {
				foreach portobj $port_list {
					if { [regexp {(.+)\*} $portobj a pname ]} {
						foreach fhport $fhportlist {
							if {[regexp $pname $fhport]} {
								$fhport stop_traffic
							}
						}
					
					} else {
						$portobj stop_traffic					
					}
				}
				return 1
			}
			
			if { [info exists streamblock ] } {
				foreach streamobj $streamblock {
					if { [regexp {(.+)\*} $streamobj a stream ]} {
						foreach sobj $flownamelist {
							if {[regexp $stream $sobj]} {
								$sobj stop
							}
						}
					
					} else {
						$streamobj stop					
					}
				}
				return 1
			}
					
			
		} else {
			Tester::stop_traffic
		}
	}

	proc results_get { args } {
		set tag "results_get "
		Logto -info "----- TAG: $tag -----"
		global fhportlist
		global trafficnamelist
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-counter {
					set counter $value
				   
				}
				-filter {
					set filter $value
				} 
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		
		set base "%10s "
		set sp " "
		
		if {[regexp {^P:([0-9a-zA-Z]+)\.*} $counter a portobj]} {
			set result [$portobj get_stats -fhflag "${portobj}\."]
			set len [llength $result]
			set fmtlist "%10s "

			set index 0
			while {$index < $len } {
				set fmtlist $fmtlist$base
				incr index 2
			}
			
			set collist "{$fmtlist} Portname "
			set vlist "{$fmtlist} $portobj "
			foreach { key value } $result {
				set coln [lindex [split $key .] 1]
				set collist $collist$coln$sp
				set vlist $vlist$value$sp				
			}
			
			set  info [eval format $collist]
			Logto -info $info
			set info [eval format $vlist]	
			Logto -info $info	
			
			return $result
		}
		if {$counter == "P:*.*"} {
			set result {}
			set flag 0
			foreach portobj $fhportlist {
			    regexp {::IxiaFH::(.+)} $portobj a portflag
				set tempres [$portobj get_stats -fhflag "${portflag}\."]
				set len [llength $tempres]
				if { $flag == 0 } {
					set fmtlist "%10s "

					set index 0
					while {$index < $len } {
						set fmtlist $fmtlist$base
						incr index 2
					}
					set collist "{$fmtlist} Portname "
					foreach { key value } $tempres {
						set coln [lindex [split $key .] 1]
						set collist $collist$coln$sp			
					} 
					set  info [eval format $collist]
					Logto -info $info
					set flag 1
				}
					
				set vlist "{$fmtlist} $portflag "
				foreach { key value } $tempres {
					set vlist $vlist$value$sp				
				}
				

				set info [eval format $vlist]	
				Logto -info $info	
				
				set result "${result} ${tempres}"
			}
			return $result
		}
		if {[regexp {^S:([0-9a-zA-Z_]+)\.*} $counter a streamobj]} {
			set result [$streamobj get_stats -fhflag "${streamobj}\."]
			set len [llength $result]
			set fmtlist "%10s "

			set index 0
			while {$index < $len } {
				set fmtlist $fmtlist$base
				incr index 2
			}
			
			set collist "{$fmtlist} Streamname "
			set vlist "{$fmtlist} $streamobj "
			foreach { key value } $result {
				set coln [lindex [split $key .] 1]
				set collist $collist$coln$sp
				set vlist $vlist$value$sp				
			}
			
			set  info [eval format $collist]
			Logto -info $info
			set info [eval format $vlist]	
			Logto -info $info	
			return $result
		}
		if {$counter == "S:*.*"} {
			set result {}
			set flag 0
            set tempreslist [Tester::getAllStats]
			#Deputs "tempreslist:$tempreslist"
			foreach tempres $tempreslist {
				Deputs "tempres:$tempres"
				set len [llength $tempres]
				if { $flag == 0 } {
					set fmtlist "%10s "

					set index 0
					while {$index < $len } {
						set fmtlist $fmtlist$base
						incr index 2
					}
					set collist "{$fmtlist} Streamname "
					foreach { key value } $tempres {
						
						set coln [lindex [split $key .] 1]
						set collist $collist$coln$sp			
					} 
					set  info [eval format $collist]
					Logto -info $info
					set flag 1
				}
				
				set streamobj [lindex [split [lindex $tempres 0] .] 0 ]
				Deputs "streamobj:$streamobj"
					
				set vlist "{$fmtlist} $streamobj "
				foreach { key value } $tempres {
					set vlist $vlist$value$sp				
				}
				

				set info [eval format $vlist]	
				Logto -info $info	
				set result "${result} ${tempres}"
			}
			return $result
		}
	}


	proc result_clean {} {
		set tag "result_clean "
		Logto -info "----- TAG: $tag -----"
		ixNet exec clearStats
		ixNet exec closeAllTabs
		return 1
	}

	proc clean_up {} {
		set tag "clean_up "
		Logto -info "----- TAG: $tag -----"
		global portlist
		global trafficlist
		global portnamelist
		global trafficnamelist
		global tportlist
        global flownamelist
        global flowlist
        global flowitemlist
        global traffictxportlist
		
		global fhportlist
		global deviceList
		
		set portlist ""
		set trafficlist ""
		set portnamelist ""
		set trafficnamelist ""
		set tportlist ""
        set flownamelist ""
        set flowlist ""
        set flowitemlist ""
        set traffictxportlist ""
		
		set fhportlist ""
		set deviceList ""
		Tester::cleanup -release_port 1
		
		return 1
	}

	proc traffic_rate_set { args } {
		set tag "traffic_rate_set "
		Logto -info "----- TAG: $tag -----"
		
		global fhportlist
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port_list $value
				}
				-mode {
					set mode $value
				}
				-streamblock {
					set streamlist $value
				}
				-load {
					regexp {([0-9]+)([a-zA-Z]+)} $value load stream_load load_unit 
					
				}
				-burst_count {
					
					set burst_count $value
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		
		if { [info exists port_list ] } {
			foreach portobj $port_list {
				if { [regexp {(.+)\*} $portobj a pname ]} {
					foreach fhport $fhportlist {
						if {[regexp $pname $fhport]} {
							$fhport set_port_flow_load -stream_load $stream_load \
																	 -load_unit $load_unit
						}
					}
				
				} else {
					$portobj set_port_flow_load -stream_load $stream_load \
															 -load_unit $load_unit
				}
			}
			return 1
		}
		
		if { [info exists streamlist ] } {
			foreach streamobj $streamlist {
				if {[info exists mode]} {
					if {$mode == "cont" } {
						set mode "continuous"
					}
					$streamobj config -tx_mode $mode
				}
				if {[info exists load]} {
					$streamobj config -stream_load $stream_load \
												 -load_unit $load_unit
				}
				if {[info exists burst_count]} {
					$streamobj config -tx_num $burst_count
				}
			}
			# set root [ixNet getRoot]
		    # ixNet exec apply $root/traffic
		    # after 1000

			return 1
		}
		
	}
	proc traffic_create {args} {
		set tag "traffic_create "
		Logto -info "----- TAG: $tag -----"
		global headindex
        global errNumber
		global fhportlist
		global trafficnamelist
        global trafficlist
        global flownamelist 
        global flowlist
		global trafficinfo
        set len [llength $args]
		puts $len
		set arg [lindex $args 0]
		set flag [llength $arg]
		puts $flag
		if {$flag==1} {
		    set len 1
		    set arg $args
		}
		puts $arg
		for {set i 0} {$i < $len} {incr i} {
		    set flag 0
		    foreach { key value } $arg {
			    set key [string tolower $key]
			    switch -exact -- $key {
				    -name {
					    set name $value
				    }
					-port {
					    set port $value
				    }
					-rxport {
					    set rxportlist $value
					}
				    default {
					    set flag 1
				    }
			    }
		    }
			set portn [::IxiaFH::nstype $port]
			set tname [::IxiaFH::nstype $name]	
		
            if { [info exists rxportlist] } {
			    set rxportlist [::IxiaFH::nstype $rxportlist]
			    if {[llength $rxportlist] == 1} {
				  set rxportlist [ lindex $rxportlist 0 ]
				  if { $trafficinfo== {} } {
				    puts "trafficinfo is empty"
				    Flow $tname $portn 
					$tname config -rcv_ports $rxportlist 
					set thandle [$tname cget -hTraffic]
					set fhandle [$tname cget -handle]
					lappend trafficinfo [list $thandle $portn $rxportlist ]
					lappend flownamelist $tname
					lappend flowlist $fhandle 
					traffic_config -name $name -srcmac 00:00:94:00:00:02 -dstmac 00:00:01:00:00:01
					traffic_config -name $name -srcip 192.85.1.2  -dstip 192.0.0.1 
				  } else {
				   
				    set thandle ""
				    foreach tinfo $trafficinfo {
					Deputs $tinfo
					    if {[lsearch $tinfo $portn] != -1 && [lsearch $tinfo $rxportlist] != -1} {
						
						    set thandle [lindex $tinfo 0]
							break
						}
					}
					if { $thandle == "" } {
				       puts "trafficinfo is not matched"
					   Flow $tname $portn 
					   $tname config -rcv_ports $rxportlist
					   set thandle [$tname cget -hTraffic]
					   set fhandle [$tname cget -handle]
					   lappend trafficinfo [list $thandle $portn $rxportlist ] 
					   lappend flownamelist $tname
					   lappend flowlist $fhandle 
					    traffic_config -name $name -srcmac 00:00:94:00:00:02 -dstmac 00:00:01:00:00:01 
						#-srcmac_count 1  -srcmac_type increment -srcmac_step 00:00:00:00:00:01 -dstmac_count 1 -dstmac_type increment  -dstmac_step 00:00:00:00:00:01
						traffic_config -name $name -srcip 192.85.1.2  -dstip 192.0.0.1
					    #-srcip_count 1  -srcip_type increment -srcip_step  0.0.0.1 -dstip_count 1  -dstip_type increment  -dstip_step 0.0.0.1
					} else {
				       puts "trafficinfo get thandle :$thandle"
					   Flow $tname $portn "NULL" $thandle 
					   $tname config -rcv_ports $rxportlist
					   set fhandle [$tname cget -handle]
					   puts "fhandle:$fhandle"
					   lappend flownamelist $tname
					   lappend flowlist $fhandle
					   puts $name
						traffic_config -name $name -srcmac 00:00:94:00:00:02 -dstmac 00:00:01:00:00:01
						traffic_config -name $name -srcip 192.85.1.2  -dstip 192.0.0.1 
					}
				  }
				
				} else {
					Traffic $tname $portn 
					
					$tname config -traffic_type raw  -rcv_ports $rxportlist
					# #$tname config -traffic_type raw  -dst $rxportlist
					lappend trafficnamelist $tname
					lappend trafficlist [$tname cget -handle]
					set thandle [$tname cget -handle]
					Deputs "thandle:$thandle"
					foreach fhandle [ ixNet getL $thandle highLevelStream ] {
					Deputs "fhandle: $fhandle"
					lappend flownamelist [ixNet getA $fhandle -name]
					Deputs "fname: $flownamelist"
					lappend flowlist $fhandle
					traffic_config -name $name -srcmac 00:00:94:00:00:02 -dstmac 00:00:01:00:00:01
					traffic_config -name $name -srcip 192.85.1.2  -dstip 192.0.0.1 
					}
		   
				}
			} else {
			    Traffic $tname $portn 
				lappend trafficnamelist $tname
                lappend trafficlist [$tname cget -handle]
				traffic_config -name $name -srcmac 00:00:94:00:00:02 -dstmac 00:00:01:00:00:01
				traffic_config -name $name -srcip 192.85.1.2  -dstip 192.0.0.1 
			}		
			 			
		    after 15000 
            if {$flag == 1 } {		
			    eval traffic_config $arg
			}
	        set arg [lindex $args [expr $i+1]]
	    }
		# set root [ixNet getRoot]
		# ixNet exec apply $root/traffic
		# after 1000
		
	}
	proc device_create {args} {
		set tag "device_create "
		Logto -info "----- TAG: $tag -----"
        global errNumber
        set len [llength $args]
		puts $len
		set arg [lindex $args 0]
		set flag [llength $arg]
		puts $flag
		if {$flag == 1} {
		    set len 1
		    set arg $args
		}
		puts $arg
		puts "len: $len"
		for {set i 0} {$i < $len} { incr i } {
		    set flag 0
		    foreach { key value } $arg {
			    set key [string tolower $key]
			    switch -exact -- $key {
				    -name {
					    set name $value
				    }
					-obj_type {
						set obj_type $value
					}
					-port {
					    set port $value
						set portn [::IxiaFH::nstype $port]
				    }
					default {
					   set flag 1
					}
			    }
		    }
			set lastName [ lindex [split $name "."] end ]
			set hostName [ lindex [split $name "."] 0   ]
			set lastName [ ::IxiaFH::nstype $lastName   ]
			set hostName [ ::IxiaFH::nstype $hostName   ]
			if { [info exists portn] == 0 } {			 
			   set portn [$hostName cget -portObj]
			}
			set obj_type [ string tolower $obj_type]
            switch -exact -- $obj_type {
			    device {
				    Host $hostName $portn
				}
				device.ospfv2 {
				    set ospfInt     [ $hostName cget -handle    ]
					puts "ospfInt: $ospfInt"
					set session [ lindex [split $name "."] 1 ]
					set session [ ::IxiaFH::nstype $session  ] 
					puts "session:$session"
					eval OspfSession $lastName $portn "null" $ospfInt 
					$hostName SetSession $session
					$lastName config -network_type broadcast     
				}
				device.ospfv2.netsummarylsa {
					set UpDevice [ lindex [split $name "."] 1 ]
					set UpDevice [ ::IxiaFH::nstype $UpDevice   ]
					puts "UpDevice:$UpDevice"
				    RouteBlock $lastName 
					$lastName SetUpDevice $UpDevice
					$lastName config -active 1 -start_ip 192.0.1.0 -prefix_len 24 -metric_lsa 1	
					eval device_config $args
				}
				device.ospfv2.externalsa {
					set UpDevice [ lindex [split $name "."] 1 ]
					set UpDevice [ ::IxiaFH::nstype $UpDevice   ]
					puts "UpDevice:$UpDevice"
				    RouteBlock $lastName 
					$lastName SetUpDevice $UpDevice
					$lastName config -active 1 -start_ip 192.0.1.0 -prefix_len 24 -metric_lsa 1	
					eval device_config $args
				}
				device.isis {
					set isisInt     [ $hostName cget -handle    ]
					puts "isisInt: $isisInt"
					set session [ lindex [split $name "."] 1 ]
					set session [ ::IxiaFH::nstype $session  ] 
					puts "session:$session"
					$hostName SetSession $session
					eval IsisSession $lastName $portn "null" $isisInt
					$lastName config -network_type broadcast -metric 1 -hello_interval 10 -dead_interval 30 -max_lspsize 1492 -lsp_refresh 900 
				}
				device.isis.isis_ipv4route {
					set UpDevice [ lindex [split $name "."] 1 ]
					set UpDevice [ ::IxiaFH::nstype $UpDevice   ]
					puts "UpDevice:$UpDevice"
				    RouteBlock $lastName 
					$lastName SetUpDevice $UpDevice
					$lastName config -active 1 -route_type internal -route_count 1 -start_ip 192.0.1.0 -prefix_len 24 -metric_route 1
					eval device_config $args
				}
				device.isis.isis_ipv6route {
					set UpDevice [ lindex [split $name "."] 1 ]
					set UpDevice [ ::IxiaFH::nstype $UpDevice   ]
					puts "UpDevice:$UpDevice"
				    RouteBlock $lastName 
					$lastName SetUpDevice $UpDevice
					$lastName config -active 1 -route_type internal -route_count 1 -start_ip 2001::0 -prefix_len 64 -metric_route 1
					eval device_config $args
				}
				device.bgp {				 				
					set bgpInt     [ $hostName cget -handle    ]
					set bgpID      [ $hostName cget -ipv4Addr  ]	
					set session [ lindex [split $name "."] 1 ]
					set session [ ::IxiaFH::nstype $session  ] 
					puts "session:$session"
					$hostName SetSession $session
				    BgpSession $lastName $portn "null" $bgpInt
					eval $lastName config  -bgp_id $bgpID -as_num 1 \
					    -bgp_type "ebgp" -hold_time 10
				}
				device.bgp.bgp_ipv4route {
				    set UpDevice [ lindex [split $name "."] 1 ]
					set UpDevice [ ::IxiaFH::nstype $UpDevice   ]
					puts "UpDevice:$UpDevice"
				    RouteBlock $lastName 
					$lastName SetUpDevice $UpDevice
					$lastName config -start_ip "192.0.1.0" -prefix_len 24
				}
				device.bgp.bgp_ipv6route {
				    set UpDevice [ lindex [split $name "."] 1 ]
					set UpDevice [ ::IxiaFH::nstype $UpDevice   ]
					puts "UpDevice:$UpDevice"
				    RouteBlock $lastName 
					$lastName SetUpDevice $UpDevice
					$lastName config -start_ip "2000::1" -prefix_len 64
				}
				device.dhcpv4_client {
				    Dhcpv4Host $lastName $portn
				}
				device.dhcpv4_server {
				    set serverIp      [ $hostName cget -ipv4Addr  ]
					set serverIpStep  [ $hostName cget -ipv4Step  ]
					set serverIpCount  [ $hostName cget -ipv4Count  ]
				    DhcpServer $lastName $portn
					if { $serverIp != "" } {
					    $lastName config -ipv4_addr $serverIp \
						    -ipv4_addr_step $serverIpStep \
							-count $serverIpCount \
							-pool_address_start "192.85.1.15"  \
							-pool_address_step "0.0.0.1"  \
							-pool_address_count 248
					}
				}
				device.dhcpv4_relay_agent {
				    Dhcpv4Host $lastName $portn
					$lastName config -enable_relay_agent 1 \
					    -relay_agent_server_ip "20.0.0.1"  \
						-relay_agent_server_ip_step "0.0.1.0"  \
						-relay_agent_pool_ip "20.0.0.100"   \
						-relay_agent_pool_ip_step "0.0.0.1"  \
                        -broadcast_flag 0						
										
				}
				device.pppoe_client {
				    PppoeHost $lastName $portn
					$lastName config -authen_mode "none" \
					    -username "fiberhome"  \
						-passwork "fiberhome"
				}
				device.pppoe_server {
				    set pppoeIp     [ $hostName cget -ipv4Addr    ]	
				    Pppoev4Server $lastName $portn
					$lastName config -authen_mode "none"  \
					    -username "fiberhome"   \
						-passwork "fiberhome"   \
						-ac_name  "instument"   \
						-server_ip $pppoeIp  \
						-pppoe_ipv4_address_start "192.0.1.0" \
						-pppoe_ipv4_address_step  "0.0.0.1"    \
						-pppoe_ipv4_address_count 1
						
				}
				device.igmp {
				    set igmpInt     [ $hostName cget -handle    ]										
				    IgmpHost $lastName $portn "null" $igmpInt
					MulticastGroup ${lastName}_group 
					${lastName}_group SetUpDevice $lastName
					${lastName}_group config -group_num 1 \
					    -group_start_ip "225.0.0.1" \
						-group_ip_step "0.0.0.1"
					$lastName join_group -group ${lastName}_group
					
				}
				device.igmp_querier {
				    set igmpInt     [ $hostName cget -handle    ]										
				    IgmpQuerier $lastName $portn "null" $igmpInt
					
					
				}
				device.mld {
				    set mldInt     [ $hostName cget -handle    ]										
				    MldHost $lastName $portn "null" $mldInt
					MulticastGroup ${lastName}_group 
					${lastName}_group SetUpDevice $lastName
					${lastName}_group config -group_num 1 \
					    -group_start_ip "ff1e::1" \
						-group_ip_step "::1"
					$lastName join_group -group ${lastName}_group
					
				}
				device.mld_querier {
				    set mldInt     [ $hostName cget -handle    ]										
				    MldQuerier $lastName $portn "null" $mldInt
					
					
				}
            }
			if { $flag } {
			    device_config  $arg
			}		
			
			
	        set arg [lindex $args [expr $i+1]]
			puts "i:$i"
	    }
		# set root [ixNet getRoot]
		# ixNet exec apply $root/traffic
		# after 1000
		
	}
	
	proc device_config { args } {
		set tag "device_config "
		Logto -info "----- TAG: $tag -----"
        global errNumber
        set len [llength $args]
		puts $len
		set arg [lindex $args 0]
		set flag [llength $arg]
		puts $flag
		if { $flag == 1 } {
		    set len 1
		    set arg $args
		}
		puts $arg
		for {set j 0} { $j < $len } { incr j } {
		    set args_value_pairs ""
			set obj_name ""
		    foreach { key value } $arg {
			    set key [string tolower $key]
			    switch -exact -- $key {
				    -name {
					    set name [lindex [split $value "."] end]
						
				    }
					-obj_type {
						set obj_type $value
					}
					-args_value {
					    set args_value_pairs $value
                        puts "args_value_pairs:$args_value_pairs"
				    }					
			    }
		    }
		
			if { $args_value_pairs != "" && $name != "" } {
				foreach { key value } $args_value_pairs {
					set key [string tolower $key]
				}
				set dname [::IxiaFH::nstype $name]
				set obj_type [ string tolower $obj_type]
				switch -exact -- $obj_type {
					device {
						eval $dname config $args_value_pairs						
					}
					ospfv2 -
					device.ospfv2 {						
						eval $dname config $args_value_pairs
					}
					netsummarylsa -
					device.ospfv2.netsummarylsa {
						eval $dname config $args_value_pairs
						set UpDevice [ $dname cget -up_device ]
						puts "UpDevice:$UpDevice"
						set origin sameArea
						$UpDevice set_route -route_block $dname -origin $origin					
					}
					externalsa -
					device.ospfv2.externalsa {
						eval $dname config $args_value_pairs
						set UpDevice [ $dname cget -up_device ]
						puts "UpDevice:$UpDevice"
						set origin externalType1
						#set origin externalType2
						$UpDevice set_route -route_block $dname -origin $origin
					}
					isis -
					device.isis {
						eval $dname config $args_value_pairs
					}
					isis_ipv4route -
					device.isis.isis_ipv4route -
					isis_ipv6route -
					device.isis.isis_ipv6route {
						eval $dname config $args_value_pairs
						set UpDevice [ $dname cget -up_device ]
						puts "UpDevice:$UpDevice"
						$UpDevice set_route -route_block $dname   
					}
					bgp -
					device.bgp {				 
						eval $dname config  $args_value_pairs 
					}
					bgp_ipv4route -
					device.bgp.bgp_ipv4route -
					bgp_ipv6route -
					device.bgp.bgp_ipv6route {
						eval $dname config $args_value_pairs
						set UpDevice [ $dname cget -up_device ]
						puts "UpDevice:$UpDevice"
						$UpDevice set_route -route_block $dname
					}
					dhcpv4_client -
					device.dhcpv4_client -
					dhcpv4_server -
					device.dhcpv4_server -
					dhcpv4_relay_agent -
					device.dhcpv4_relay_agent {
						eval $dname config $args_value_pairs
					}
					pppoe_client -
					device.pppoe_client -
					pppoe_server -
					device.pppoe_server {
						eval $dname config $args_value_pairs
						
					}
					igmp -
					device.igmp {
						eval ${dname}_group config $args_value_pairs
						set UpDevice [ ${dname}_group cget -up_device ]
						puts "UpDevice:$UpDevice"
						$UpDevice join_group -group ${dname}_group
					}
					igmp_querier -
					device.igmp_querier {
						eval $dname config $args_value_pairs
					}
					mld -
					device.mld {
						eval ${dname}_group config $args_value_pairs
						set UpDevice [ ${dname}_group cget -up_device ]
						puts "UpDevice:$UpDevice"
						$UpDevice join_group -group ${dname}_group
					}
					mld_querier -
					device.mld_querier {
						eval $dname config $args_value_pairs
					}
				}
			} else {
					
				set dname [::IxiaFH::nstype $name]
				set obj_type [ string tolower $obj_type]
				switch -exact -- $obj_type {
					device {
						eval $dname config $arg						
					}
					ospfv2 -
					device.ospfv2 {						
						eval $dname config $arg
					}
					netsummarylsa -
					device.ospfv2.netsummarylsa {
						eval $dname config $arg
						set UpDevice [ $dname cget -up_device ]
						puts "UpDevice:$UpDevice"
						set origin sameArea
						$UpDevice set_route -route_block $dname -origin $origin					
					}
					externalsa -
					device.ospfv2.externalsa {
						eval $dname config $arg
						set UpDevice [ $dname cget -up_device ]
						puts "UpDevice:$UpDevice"
						set origin externalType1
						#set origin externalType2
						$UpDevice set_route -route_block $dname -origin $origin
					}
					isis -
					device.isis {
						eval $dname config $arg
					}
					isis_ipv4route -
					device.isis.isis_ipv4route -
					isis_ipv6route -
					device.isis.isis_ipv6route {
						eval $dname config $arg
						set UpDevice [ $dname cget -up_device ]
						puts "UpDevice:$UpDevice"
						$UpDevice set_route -route_block $dname   
					}
					bgp -
					device.bgp {				 
						eval $dname config  $arg 
					}
					bgp_ipv4route -
					device.bgp.bgp_ipv4route -
					bgp_ipv6route -
					device.bgp.bgp_ipv6route {
						eval $dname config $arg
						set UpDevice [ $dname cget -up_device ]
						puts "UpDevice:$UpDevice"
						$UpDevice set_route -route_block $dname
					}
					dhcpv4_client -
					device.dhcpv4_client -
					dhcpv4_server -
					device.dhcpv4_server -
					dhcpv4_relay_agent -
					device.dhcpv4_relay_agent {
						eval $dname config $arg
					}
					pppoe_client -
					device.pppoe_client -
					pppoe_server -
					device.pppoe_server {
						eval $dname config $arg
						
					}
					igmp -
					device.igmp {
						eval ${dname}_group config $arg
						set UpDevice [ ${dname}_group cget -up_device ]
						puts "UpDevice:$UpDevice"
						$UpDevice join_group -group ${dname}_group
					}
					igmp_querier -
					device.igmp_querier {
						eval $dname config $arg
					}
					mld -
					device.mld {
						eval ${dname}_group config $arg
						set UpDevice [ ${dname}_group cget -up_device ]
						puts "UpDevice:$UpDevice"
						$UpDevice join_group -group ${dname}_group
					}
					mld_querier -
					device.mld_querier {
						eval $dname config $arg
					}
				}
			}
			
			
			
	        set arg [lindex $args [expr $j+1]]
	}
		# set root [ixNet getRoot]
		# ixNet exec apply $root/traffic
		# after 1000
		
}
	
	proc traffic_config { args } {
		set tag "traffic_config "
		Logto -info "----- TAG: $tag -----"	
		global headindex
        global errNumber
		global flownamelist
		global trafficnamelist
        global flowlist
		global loadflag

		set Eframelength_mode [list fixed increment decrement random auto]
		set Eload_mode [list fixed increment decrement]
		set headlist {}
		set cmd {}
		set len [llength $args]
		puts $len
		set arg [lindex $args 0]
		set flag [llength $arg]
		if {$flag==1} {
			set len 1
			set arg $args
		}
		for {set i 0} {$i < $len} {incr i} {
			foreach { key value } $arg {
				set key [string tolower $key]
				switch -exact -- $key {
					-name -
					-streamblock {
						incr headindex
						set streamobj $value
						EtherHdr ${streamobj}EtherH${headindex} 
						${streamobj}EtherH${headindex} ChangeType MOD				
						SingleVlanHdr ${streamobj}VlanH${headindex}
						${streamobj}VlanH${headindex} SetProtocol vlan2					
						#${streamobj}VlanH${headindex} ChangeType MOD
						SingleVlanHdr ${streamobj}VlanH2${headindex} 
						#${streamobj}VlanH2${headindex} ChangeType MOD					
						Ipv4Hdr ${streamobj}ipv4H${headindex}
						#${streamobj}ipv4H${headindex} ChangeType MOD
						UdpHdr ${streamobj}udpH${headindex}
						#${streamobj}udpH${headindex} ChangeType MOD
						TcpHdr ${streamobj}tcpH${headindex}
						#${streamobj}tcpH${headindex} ChangeType MOD
						set tname [::IxiaFH::nstype $streamobj] 
						set highLevelStream [ $tname cget -handle ]
						puts "highLevelStream:$highLevelStream"
						foreach pro [ ixNet getList $highLevelStream stack ] {
		Deputs "pro:$pro"
							if { [ regexp -nocase IPv4 $pro ] } {
								${streamobj}ipv4H${headindex} ChangeType MOD
							}
						}
						if { $loadflag } {
							${streamobj}EtherH${headindex} ChangeType MOD
							${streamobj}VlanH${headindex} ChangeType MOD
							${streamobj}VlanH2${headindex} ChangeType MOD
							${streamobj}ipv4H${headindex} ChangeType MOD
							${streamobj}udpH${headindex} ChangeType MOD
							${streamobj}tcpH${headindex} ChangeType MOD
						}						
					}
					-framesize {
						set framesize $value
						#$streamobj config -frame_len $value
						
					}
					-active {
						set trans [ BoolTrans $value ]
						if { $trans == "1" || $trans == "0" } {
							set active $value
						} else {
							error "$errNumber(1) key:$key value:$value"
						}
						#$streamobj config -sig $value
					}
					-framelength_mode {
						set value [ string tolower $value ]
						if { [ lsearch -exact $Eframelength_mode $value ] >= 0 } {
							set framelength_mode $value
						} else {
							error "$errNumber(1) key:$key value:$value"
						}
						#$streamobj config -frame_len_type $value
					}
					-framesize_fix {
						set framesize_fix $value
						# $streamobj config -frame_len_type fixed \
							# -frame_len $value
					}
					-framesize_crement {
						set framesize_crement $value
					}
					-framesize_random {
						set framesize_random $value
					}
					-load_mode {
						set value [ string tolower $value ]
						if { [ lsearch -exact $Eload_mode $value ] >= 0 } {
						  
							set load_mode $value
						} else {
							error "$errNumber(1) key:$key value:$value"
						}
						set load_mode $value
						set cmd "${cmd}-tx_mode $load_mode "
					}
					-load_unit {
						set load_unit $value						 
						set cmd  "${cmd}-load_unit $load_unit "
						
					}
					-load {				
						set load $value
							
						set cmd "${cmd}-stream_load $load "
							
					}
					-srcbinding {
						set srcbinding $value
					}
					-dstbinding {
						set dstbinding $value
					}
					-bindinglevel {
						set bindinglevel $value
					}
					-srcmac {
						set srcmac [MacTrans $value]					
						set srcmac_count 1
						set srcmac_type incr
						set srcmac_step "00:00:00:00:00:01"
							
						if { [lsearch $headlist ${streamobj}EtherH${headindex}]!= -1} {    
						} else { 
							lappend headlist ${streamobj}EtherH${headindex}
						}
					}
					-srcmac_count {
						set srcmac_count $value					
					}
					-srcmac_type {
						if {$value == "increment" } {
							set srcmac_type incr
						}
						if {$value == "decrement" } {
							set srcmac_type decr
						}

					}
					-srcmac_step {
							
						set srcmac_step [MacTrans $value]

					}
					-srcmac_mask {
							
						set srcmac_mask $value
					}
					-dstmac {
						set dstmac [MacTrans $value]
							
						set dstmac_count 1
						set dstmac_type incr
						set dstmac_step "00:00:00:00:00:01"
						if { [lsearch $headlist ${streamobj}EtherH${headindex}]!= -1} {    
						} else { 
							lappend headlist ${streamobj}EtherH${headindex}
						}
					}
					-dstmac_count {
						set dstmac_count $value 	
					}
					-dstmac_type {                

						if {$value == "increment" } {
							set dstmac_type incr
						}
						if {$value == "decrement" } {
							set dstmac_type decr
						}
					}
					-dstmac_step {
							
						set dstmac_step [MacTrans $value]
					}
					-dstmac_mask {
							
						set dstmac_mask $value
					}
					-srcip {
						puts "123456"
						set srcip $value
						set srcip_count 1
						set srcip_type incr
						set srcip_step "0.0.0.1"

						if { [lsearch $headlist ${streamobj}ipv4H${headindex}]!= -1} {
						} else { 
							lappend headlist ${streamobj}ipv4H${headindex}
						}
					}
					-srcip_count {
						set srcip_count $value 

					}
					-srcip_type {
								
						if {$value == "increment" } {
							set srcip_type incr
						}
						if {$value == "decrement" } {
							set srcip_type decr
						}
					}
					-srcip_step {					
						set srcip_step $value
					}
					-srcip_mask {
							
						set srcip_mask $value
					}
					-dstip {
						set dstip $value
						set dstip_count 1
						set dstip_type incr
						set dstip_step "0.0.0.1"
						if { [lsearch $headlist ${streamobj}ipv4H${headindex}]!= -1} {
						} else { 
							lappend headlist ${streamobj}ipv4H${headindex}
						}
					}
					-dstip_count {
						set dstip_count $value
					}
					-dstip_type {
												
						if {$value == "increment" } {
							set dstip_type incr
						}
						if {$value == "decrement" } {
							set dstip_type decr
						}

					}
					-dstip_step {
							
						set dstip_step $value

					}
					-dstip_mask {
							
						set dstip_mask $value
					}
					-cvlanpri {
						set cvlanpri $value
						set cvlanpri_count 1

						if { [lsearch $headlist ${streamobj}VlanH${headindex}] != -1 } {
						} else { 
							lappend headlist ${streamobj}VlanH${headindex}
						}
					}
					-cvlanpri_count {
						set cvlanpri_count $value 
					}
					-cvlanpri_type {
							
						set cvlanpri_type $value
						if {$value == "increment" } {
							set cvlanpri_type Incrementing
						}
						if {$value == "decrement" } {
							set cvlanpri_type Decrementing
						}
							
					}
					-cvlanpri_step {
															
						set cvlanpri_step $value 
					}
					-cvlanid {
						set cvlanid $value
						set cvlanid_count 1
						set cvlanid_step 1

						if { [lsearch $headlist ${streamobj}VlanH${headindex}] != -1 } {
						} else { 
							lappend headlist ${streamobj}VlanH${headindex}
						}
					}
					-cvlanid_count {
						set cvlanid_count $value

					}
					-cvlanid_type {
						
						set cvlanid_type $value
					}
					-cvlanid_step {
						
						set cvlanid_step $value
					}
					-svlanpri {
						set svlanpri $value
						set svlanpri_count 1

						if { [lsearch $headlist ${streamobj}VlanH2${headindex}] != -1 } {
						} else { 
							lappend headlist ${streamobj}VlanH2${headindex}
						}
					}
					-svlanpri_count {
						set svlanpri_count $value
						
					}
					-svlanpri_type {
						
						set svlanpri_type $value
					}
					-svlanpri_step {
						
						set svlanpri_step $value
					}
					-svlanid {
						set svlanid $value
						set svlanid_count 1
						set svlanid_step 1

						if { [lsearch $headlist ${streamobj}VlanH2${headindex}] != -1 } {
						} else { 
							lappend headlist ${streamobj}VlanH2${headindex}
						}
					}
					-svlanid_count {
						set svlanid_count $value

					}
					-svlanid_type {
						
						set svlanid_type $value
					}
					-svlanid_step {
						
						set svlanid_step $value
					}
					-ethtype {
						set EType [ list internet_ip ipv6 arp  rarp pppoe_session ppp pppoe_dis ]
						set ETypeVal [ list "0800" "86dd" "0806"  "8035" "8864" "880b" "8863" ]
						set eindex [lsearch -exact $EType $value]
						if {$eindex == -1 } {
							error "No this ethtype $value supported"
						} else {
						   set ethtype [lindex $ETypeVal $eindex]
						}

						${streamobj}EtherH${headindex} config -type $ethtype
						if { [lsearch $headlist ${streamobj}EtherH${headindex}]!= -1} {    
						} else { 
							lappend headlist ${streamobj}EtherH${headindex}
						}
					}
					-ipprotocoltype {
						
						set ipprotocoltype $value

						${streamobj}ipv4H${headindex} config -protocol_type $ipprotocoltype
						if { [lsearch $headlist ${streamobj}ipv4H${headindex}]!= -1} {
						} else { 
							lappend headlist ${streamobj}ipv4H${headindex}
						}
					}
					-iptosdscp_type {
						set iptosdscp_type $value
					}
					-iptosdscp_value {
						
						set iptosdscp_value $value

						${streamobj}ipv4H${headindex} config -precedence $value
						if { [lsearch $headlist ${streamobj}ipv4H${headindex}]!= -1} {
						} else { 
							lappend headlist ${streamobj}ipv4H${headindex}
						}
					}
					-udpsrcport {							
						
						${streamobj}udpH${headindex} config -src_port $value
						if { [lsearch $headlist ${streamobj}udpH${headindex}] != -1} {
						} else { 
							lappend headlist ${streamobj}udpH${headindex}
						}		
					}
					-tcpsrcport {

						${streamobj}tcpH${headindex} config -src_port $value
						if { [lsearch $headlist ${streamobj}tcpH${headindex}] != -1} {
						} else { 
							lappend headlist ${streamobj}tcpH${headindex}
						}	
					}
					-udpdstport {

						${streamobj}udpH${headindex} config -dst_port $value
						if { [lsearch $headlist ${streamobj}udpH${headindex}] != -1} {
						} else { 
							lappend headlist ${streamobj}udpH${headindex}
						}	
					}
					-tcpdstport {
			
						${streamobj}tcpH${headindex} config -dst_port $value
						if { [lsearch $headlist ${streamobj}tcpH${headindex}] != -1} {
						} else { 
							lappend headlist ${streamobj}tcpH${headindex}
						}	
					}
					-mplsid {
						SingleMplsHdr ${streamobj}mplsH${headindex}
						if { $loadflag } {
							${streamobj}mplsH${headindex} ChangeType MOD
						}						
						set mplsid $value
						${streamobj}mplsH${headindex} config -label_id $value
						lappend headlist ${streamobj}mplsH${headindex}
					}
					-rxport -
					-port {
					}
					default {
						error "$errNumber(3) key:$key value:$value"
					}
				}
			}
			if {[info exists srcbinding] && [info exists dstbinding]} {
				set srcbinding [::IxiaFH::nstype $srcbinding]
				set dstbinding [::IxiaFH::nstype $dstbinding]
				$streamobj config -src $srcbinding -dst $dstbinding
				set thandle [$streamobj cget -handle]
				Deputs "thandle: $thandle"
				foreach fhandle [ixNet getL $thandle highLevelStream ] {
				puts "fhandle: $fhandle"
				   lappend flownamelist [ixNet getA $fhandle -name]
				  puts "$flownamelist"
				   lappend flowlist $fhandle
				}
			
			}
			if { [info exists iptosdscp_type] && [info exists iptosdscp_value] } {
				${streamobj}ipv4H${headindex} config -iptdtype $iptosdscp_type -iptdvalue $iptosdscp_value
				if { [lsearch $headlist ${streamobj}ipv4H${headindex}]!= -1} {
				} else { 
						lappend headlist ${streamobj}ipv4H${headindex}
				}	
			}
			if {[info exists srcmac] || [info exists dstmac]} {
				if {[info exists srcmac] && [info exists dstmac]} {
					${streamobj}EtherH${headindex} config -src $srcmac -src_num $srcmac_count \
						-src_range_mode $srcmac_type  -src_mac_step $srcmac_step \
						-dst $dstmac -dst_num $dstmac_count \
						-dst_range_mode $dstmac_type  -dst_mac_step $dstmac_step
				} elseif {[info exists srcmac]} {
					${streamobj}EtherH${headindex} config -src $srcmac -src_num $srcmac_count \
						-src_range_mode $srcmac_type  -src_mac_step $srcmac_step
					# set dstmac "00:00:94:00:00:01"
					# set dstmac_count 1
					# set dstmac_type incr
					# set dstmac_step "00:00:00:00:00:01"	
				 } elseif { [info exists dstmac] } {
				    ${streamobj}EtherH${headindex} config -dst $dstmac -dst_num $dstmac_count \
					-dst_range_mode $dstmac_type  -dst_mac_step $dstmac_step
					  # set srcmac "00:00:00:00:00:01"
					  # set srcmac_count 1
					  # set srcmac_type incr
					  # set srcmac_step "00:00:00:00:00:01"
				 }
				
				
				# ${streamobj}EtherH${headindex} config -src $srcmac -src_num $srcmac_count \
					# -src_range_mode $srcmac_type  -src_mac_step $srcmac_step \
					# -dst $dstmac -dst_num $dstmac_count \
					# -dst_range_mode $dstmac_type  -dst_mac_step $dstmac_step
			}
			
			if {[info exists srcip]} {
				${streamobj}ipv4H${headindex} config -src $srcip -src_num $srcip_count \
					-src_range_mode $srcip_type  -src_step $srcip_step
				
			}
			if {[info exists dstip]} {		    
				${streamobj}ipv4H${headindex} config -dst $dstip -dst_num $dstip_count \
					-dst_range_mode $dstip_type  -dst_step $dstip_step
			}
			if {[info exists cvlanpri]} {		    
				${streamobj}VlanH${headindex} config -pri1 $cvlanpri -pri1_num $cvlanpri_count
			}
			if {[info exists cvlanid]} {		    
				${streamobj}VlanH${headindex} config -id1 $cvlanid -id1_num $cvlanid_count \
						-id1_step $cvlanid_step 
			}
			if {[info exists svlanpri]} {		    
				${streamobj}VlanH2${headindex} config -pri1 $svlanpri -pri1_num $svlanpri_count
			}
			if {[info exists svlanid]} {		    
				${streamobj}VlanH2${headindex} config -id1 $svlanid -id1_num $svlanid_count \
						-id1_step $svlanid_step 
			}
			if {[info exists framesize_fix]} {
				
				$streamobj config -frame_len_type fixed \
				 -frame_len $framesize_fix
			} 
			if {[info exists framesize_crement]} {
				set fram_len_step [lindex $framesize_crement 0]				
				set min_fram_len [lindex $framesize_crement 1]				
				set max_fram_len [lindex $framesize_crement 2]	
				$streamobj config -frame_len_type incr \
				-frame_len_step $fram_len_step \
				-min_frame_len $min_fram_len \
				-max_frame_len $max_fram_len
			}
			if {[info exists framesize_random]} {
				set min_fram_len [lindex $framesize_random 0]
				set max_fram_len [lindex $framesize_random 1]
				$streamobj config -frame_len_type random \
				-min_frame_len $min_fram_len \
				-max_frame_len $max_fram_len
			}
			if {[info exists framesize]} {
				$streamobj config -frame_len $framesize
			}
			if {[info exists active]} {
				$streamobj config -sig $active
			}
			if {[info exists framelength_mode]} {
				$streamobj config -frame_len_type $framelength_mode
			}
			if { $headlist == "" } {
				if {$cmd != "" } {
				   eval $streamobj config $cmd
				}
			   
			} else {
				set headlist [::IxiaFH::nstype $headlist]
				
				eval $streamobj config -pdu $headlist $cmd
			}	
			# set root [ixNet getRoot]
			# ixNet exec apply $root/traffic
			# after 1000
			set arg [lindex $args [expr $i+1]]
	}	

}
	proc device_start { args } {
		set tag "device_start "
		Logto -info "----- TAG: $tag -----"
        global errNumber
        global fhportlist
		global loadflag
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-device {
					set device_list $value
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		if { $loadflag } {	
			if {[info exists device_list] } {
				foreach devicename $device_list {
					set devicelist   [ split $devicename  _ ]
					set portname     [ lindex $devicelist 0 ]
					set protocoltype [ lindex $devicelist 1 ]
					
					# set EPType { bgp isis ospf igmp mld ldp}
					# set protocoltype [string tolower $protocoltype]
					# foreach ptype $EPType {
						# if { [regexp .*$ptype.* $protocoltype] } {
							# set protocoltype $ptype
							# Logto -info "protocol type $ptype"
							# break
						# }
						
					# }
					set EPType { bgp ebgp ibgp isis ospf igmp mld ldp}
					set protocoltype [string tolower $protocoltype]
					foreach ptype $EPType {
						if { [regexp ^$ptype.* $protocoltype] } {
						   if { $ptype == "ibgp" || $ptype == "ebgp" } {
							  set ptype "bgp"
						   }
							set protocoltype $ptype
							Logto -info "protocol type $ptype"
							break
						}
						
					}
				 
					foreach fhport $fhportlist {
						if {[regexp $portname $fhport]} {
							set phandle [$fhport cget -handle]
							set prothandle [ixNet getL $phandle/protocols $protocoltype]
							Logto -info "protocol handle $prothandle"
							
							switch -exact -- $protocoltype {
								isis {
									set routerlist [ ixNet getL $prothandle router ]
									foreach router $routerlist {
									Logto -info "router handle $router"
										set rinterface [ ixNet getL $router interface ]
										set inter_handle [ixNet getA $rinterface -interfaceId ]
										set inter_name [ ixNet getA $inter_handle -description ] 
										if {[  regexp {^([0-9a-zA-Z_]+)\*$} $devicename a predevice ]} {
											if { [regexp $predevice.* $inter_name ] } {
												ixNet setA $router -enabled true
												#ixNet commit 
											}
										} elseif { $inter_name == $devicename } {
											ixNet setA $router -enabled true
											#ixNet commit    
											
										}    
									}   
									
								}
								bgp {
									set routerlist [ ixNet getL $prothandle neighborRange ]
									foreach router $routerlist { 
										Logto -info "router handle $router"
										set inter_handle [ixNet getA $router -interfaces ]
										set inter_name [ ixNet getA $inter_handle -description ] 
										if {[  regexp {^([0-9a-zA-Z_]+)\*$} $devicename a predevice ]} {
											if { [regexp $predevice.* $inter_name ] } {
												ixNet setA $router -enabled true
												#ixNet commit 
											}
										} elseif { $inter_name == $devicename } {
											ixNet setA $router -enabled true
											#ixNet commit    
											
										}    
									}
								}
								ospf {
									set routerlist [ ixNet getL $prothandle router ]
									foreach router $routerlist {
										Logto -info "router handle $router"
										set rinterface [ ixNet getL $router interface ]
										set inter_handle [ixNet getA $rinterface -interfaces ]
										set inter_name [ ixNet getA $inter_handle -description ] 
										if {[  regexp {^([0-9a-zA-Z_]+)\*$} $devicename a predevice ]} {
											if { [regexp $predevice.* $inter_name ] } {
												ixNet setA $router -enabled true
												#ixNet commit 
											}
										} elseif { $inter_name == $devicename } {
											ixNet setA $router -enabled true
											#ixNet commit    
											
										}    
									}
								}
							}
							ixNet commit
							after 1000
									
							set prostate [ ixNet getA $prothandle -runningState ]
							if { $prostate == "stopped" } {
							Logto -info "router start $prothandle"
							   ixNet exec start $prothandle
							   after 5000
							}
							   
						}
					}            
				}    	
			} else {
				set protocollist {isis ospf bgp}
				foreach protocoltype $protocollist {
					foreach fhport $fhportlist {
					   
						set phandle [$fhport cget -handle]
						set prothandle [ixNet getL $phandle/protocols $protocoltype]
						Logto -info "protocol handle $prothandle"
						
						switch -exact -- $protocoltype {
							isis {
								set routerlist [ ixNet getL $prothandle router ]
								foreach router $routerlist {                           
									ixNet setA $router -enabled true
									#ixNet commit                                           
								}                               
							}
							bgp {
								set routerlist [ ixNet getL $prothandle neighborRange ]
								foreach router $routerlist { 
									Logto -info "router handle $router"
								 
									ixNet setA $router -enabled true
									#ixNet commit    
		  
								}
							}
							ospf {
								set routerlist [ ixNet getL $prothandle router ]
								foreach router $routerlist {
									Logto -info "router handle $router"                              
									ixNet setA $router -enabled true
									#ixNet commit                                        
								}
							}
						}
								
						
					}
				}
				ixNet commit
				after 1000
				Tester::start_router 
				after 5000
			}
		} else {
			
			set device_list [ ::IxiaFH::nstype $device_list ]
			set dhandle [ $device_list cget -protocolhandle ]
			if { [ $device_list isa Host ] } {
				Tester::start_router 
			} else {
				set prostate [ ixNet getA $dhandle -runningState ]
					if { $prostate == "stopped" } {
						Logto -info "router start $dhandle"
						ixNet exec start $dhandle	
			        }
			}
		}
		
		# set root [ixNet getRoot]
		# ixNet exec apply $root/traffic
		# after 1000
		
	}

	proc device_stop { args } {
		set tag "device_stop "
		Logto -info "----- TAG: $tag -----"
        global errNumber
        global fhportlist
		global loadflag
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-device {
					set device_list $value
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		if { $loadflag } {
			if {[info exists device_list] } {
				foreach devicename $device_list {
					set devicelist   [ split $devicename  _ ]
					set portname     [ lindex $devicelist 0 ]
					set protocoltype [ lindex $devicelist 1 ]
					
					# set EPType { bgp isis ospf igmp mld ldp}
					# set protocoltype [string tolower $protocoltype]
					# foreach ptype $EPType {
						# if { [regexp .*$ptype.* $protocoltype] } {
							# set protocoltype $ptype
							# Logto -info "protocol type $ptype"
							# break
						# }
						
					# }
					set EPType { bgp ebgp ibgp isis ospf igmp mld ldp}
					set protocoltype [string tolower $protocoltype]
					foreach ptype $EPType {
						if { [regexp ^$ptype.* $protocoltype] } {
						   if { $ptype == "ibgp" || $ptype == "ebgp" } {
							  set ptype "bgp"
						   }
							set protocoltype $ptype
							Logto -info "protocol type $ptype"
							break
						}
						
					}
					set stopflag 1
				 
					foreach fhport $fhportlist {
						if {[regexp $portname $fhport]} {
							set phandle [$fhport cget -handle]
							set prothandle [ixNet getL $phandle/protocols $protocoltype]
							Logto -info "protocol handle $prothandle"
							
							switch -exact -- $protocoltype {
								isis {
									set routerlist [ ixNet getL $prothandle router ]
									foreach router $routerlist {
									Logto -info "router handle $router"
										set rinterface [ ixNet getL $router interface ]
										set inter_handle [ixNet getA $rinterface -interfaceId ]
										set inter_name [ ixNet getA $inter_handle -description ] 
										if {[  regexp {^([0-9a-zA-Z_]+)\*$} $devicename a predevice ]} {
											if { [regexp $predevice.* $inter_name ] } {
												ixNet setA $router -enabled false
												#ixNet commit 
												
											}
										} elseif { $inter_name == $devicename } {
											ixNet setA $router -enabled false
											#ixNet commit 
											Logto -info "router handle $router disabled"                                         
											
										} 
										   
									}  
									foreach router $routerlist {    
										set routerstate [ixNet getA $router -enabled ]
										if { $routerstate == "true" } {
											set stopflag 0
										}                                           
									}                                 
									
								}
								bgp {
									set routerlist [ ixNet getL $prothandle neighborRange ]
									foreach router $routerlist { 
										Logto -info "router handle $router"
										set inter_handle [ixNet getA $router -interfaces ]
										set inter_name [ ixNet getA $inter_handle -description ] 
										if {[  regexp {^([0-9a-zA-Z_]+)\*$} $devicename a predevice ]} {
											if { [regexp $predevice.* $inter_name ] } {
												ixNet setA $router -enabled false
												#ixNet commit 
												
											}
										} elseif { $inter_name == $devicename } {
											ixNet setA $router -enabled false
										   # ixNet commit 
											Logto -info "router handle $router disabled"                                         
											
										}   
									}
									foreach router $routerlist {    
										set routerstate [ixNet getA $router -enabled ]
										if { $routerstate == "true" } {
											set stopflag 0
										}                                           
									}
								}
								ospf {
									set routerlist [ ixNet getL $prothandle router ]
									foreach router $routerlist {
										Logto -info "router handle $router"
										set rinterface [ ixNet getL $router interface ]
										set inter_handle [ixNet getA $rinterface -interfaces ]
										set inter_name [ ixNet getA $inter_handle -description ] 
										if {[  regexp {^([0-9a-zA-Z_]+)\*$} $devicename a predevice ]} {
											if { [regexp $predevice.* $inter_name ] } {
												ixNet setA $router -enabled false
												#ixNet commit 
												
											}
										} elseif { $inter_name == $devicename } {
											ixNet setA $router -enabled false
										   # ixNet commit 
											Logto -info "router handle $router disabled"                                         
											
										}   
									}
									foreach router $routerlist {    
										set routerstate [ixNet getA $router -enabled ]
										if { $routerstate == "true" } {
											set stopflag 0
										}                                           
									}
								}
							}
									
							ixNet commit 
							after 1000
							if { $stopflag == 1 } {
							Logto -info "router stop $prothandle"
							   ixNet exec stop $prothandle
							   after 5000
							}
							   
						}
					}            
				} 
			} else {
				set protocollist {isis ospf bgp}
				foreach protocoltype $protocollist {
					foreach fhport $fhportlist {
					   
						set phandle [$fhport cget -handle]
						set prothandle [ixNet getL $phandle/protocols $protocoltype]
						Logto -info "protocol handle $prothandle"
						
						switch -exact -- $protocoltype {
							isis {
								set routerlist [ ixNet getL $prothandle router ]
								foreach router $routerlist {                           
									ixNet setA $router -enabled false
									#ixNet commit                                           
								}                               
							}
							bgp {
								set routerlist [ ixNet getL $prothandle neighborRange ]
								foreach router $routerlist { 
									Logto -info "router handle $router"
								 
									ixNet setA $router -enabled false
								   # ixNet commit    
		  
								}
							}
							ospf {
								set routerlist [ ixNet getL $prothandle router ]
								foreach router $routerlist {
									Logto -info "router handle $router"                              
									ixNet setA $router -enabled false
								   # ixNet commit                                        
								}
							}
						}
								
						
					}
				}
				after 2000
				Tester::stop_router
			}
		} else {
			set device_list [ ::IxiaFH::nstype $device_list ]
			set dhandle [ $device_list cget -protocolhandle ]
			if { [ $device_list isa Host ] } {
				Tester::stop_router 
			} else {
				set prostate [ ixNet getA $dhandle -runningState ]
				Logto -info "router stop $dhandle"
				ixNet exec stop $dhandle	
			}
		}
		
	}
	proc capture_start {args } {
		set tag "capture_start "
		Logto -info "----- TAG: $tag -----"
        global errNumber	  
		global fhportlist  
        
           
        set capturemode "data"
		set EMode [ list data control both ]
        
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port_list $value
				}
                -mode {
                    if { [ lsearch -exact $EMode $value ] >= 0 } {
                        set capturemode $value
                        Deputs "capturemode:$capturemode"    
                    } else {
                        error "$errNumber(1) key:$key value:$value"
                    }                    
                }
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		
		if {[info exists port_list] } {
		
			foreach portobj $port_list {
		Logto -info "aa:portobj: $portobj"
		        if { [ObjectExist ::IxiaFH::${portobj}cap ]} {
				
				} else {
			
				    Capture ${portobj}cap $portobj
				}
                if {$capturemode == "data"} {
				    ${portobj}cap enable
                } elseif {$capturemode == "control" } {
                    ${portobj}cap enable_control
                } else {
                    ${portobj}cap enable
                    ${portobj}cap enable_control
                }
                ${portobj}cap configure -content [list]
			}
			
		} else {
			foreach portobj $fhportlist {
			Logto -info "bb:portobj: $portobj"
				Capture ${portobj}cap $portobj
				if {$capturemode == "data"} {
				    ${portobj}cap enable
                } elseif {$capturemode == "control" } {
                    ${portobj}cap enable_control
                } else {
                    ${portobj}cap enable
                    ${portobj}cap enable_control
                }
                ${portobj}cap configure -content [list]
			}
			
		}
		ixNet exec closeAllTabs

    Logto -info "start capture..."
	    ixNet exec startCapture

		after 3000
		return 1
			
	}

	proc capture_stop_save { args } {
		set tag "capture_stop_save "
		Logto -info "----- TAG: $tag -----"
		global savecapport
        global errNumber
               
        set capturemode "data"
        
		set EMode [ list data control]
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set portobj $value
					set savecapport $portobj
				}
				-file {
					set SavePath $value				              
                }
                -mode {
                    if { [ lsearch -exact $EMode $value ] >= 0 } {
                        set capturemode $value
                        Deputs "capturemode:$capturemode"    
                    } else {
                        error "$errNumber(1) key:$key value:$value,value can only be data ,control"
                    }                    
                }
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		
	   
		

		Logto -info "stop $portobj capture"
		ixNet exec stopCapture
		after 1000

		if { [ info exists SavePath ]  } {

			set dir     [ file dirname $SavePath ]
			set file    [ file tail $SavePath ]
			catch {
				ixNet exec saveCapture $dir
			}
		  
			cd $dir
            if { $capturemode == "data" } {
                if { [ catch {
                    set fileCap [ glob *${portobj}_{HW}*.cap ]
                    file delete -force "$dir/$file"
                    file rename -force "$dir/$fileCap" "$dir/$file"
                } err] } {
                    return $err                       
                }
            } else {
                if { [ catch {
                    set fileCap [ glob *${portobj}_{SW}*.cap ]
                    file delete -force "$dir/$file"
                    file rename -force "$dir/$fileCap" "$dir/$file"
                } err] } {
                    return $err                       
                }
            }
            
            
			if { [ catch {
				if { [ catch {set elseCap [ glob *{HW}*.cap ] } ] } {
				} else {
					foreach efile $elseCap {
					   file delete -force "$dir/$efile"
					}
				}
                if { [ catch {set elseCap [ glob *{SW}*.cap ] } ] } {
				} else {
					foreach efile $elseCap {
					   file delete -force "$dir/$efile"
					}
				}
			} err] } {
				return $err                       
			}
        }
		Logto -info "disable $portobj capture"
        
        if { $capturemode == "data" } {
		    ${portobj}cap disable
        } else {
            ${portobj}cap disable_control
        }
		after 1000
		
		return 1
	}

	proc capture_analyze { args } {
		set tag "capture_analyze "
		Logto -info "----- TAG: $tag -----"
		global savecapport
        global errNumber
		
		set frame_index 1
		set offset 1
		set length 1
		   
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
				}
				-ref {
					
					set ref [ string toupper $value ]
				}
				-frame_index {
					set frame_index $value
				}
				-offset {
					set index [expr $value -1 ]
				}
				-length {
					set offset [expr $value -1 ]
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		
		set hex [${port}cap get_content -packet_index $frame_index \
									-index $index  -offset $offset -fhflag 1  ]
		set len [ string length $hex ]
		for { set index 0 } { $index < $len } { incr index } {
			if { [ string index $hex $index ] == " " } {
				
				set hex [ string replace $hex $index $index "" ] 
				
			}
		}
	Logto -info "hex:$hex"
		if {$hex == $ref } {
			return 1 
		} else {
			return "capture hex: $hex; ref :$ref"
		}
			
		
	}

    proc access_protocol_handle { args } {
		set tag "access_protocol_handle "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
                -protocoltype {
					set protocoltype $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
        
		switch -exact -- $protocoltype {
            dhcp {
                set proEndpoint dhcpEndpoint
                set proRange dhcpRange
                                
            }
            pppoe {
                set proEndpoint pppoxEndpoint
                set proRange pppoxRange
				                             
            }
			pppoeserver {
                set proEndpoint pppoxEndpoint
                set proRange pppoxRange				
                              
            }
            dhcpserver {
                set proEndpoint dhcpServerEndpoint
                set proRange dhcpServerRange 
                               
            }
            default {
					error "$errNumber(3) protocoltype:$protocoltype "
		    }
        }
        
		if { [lsearch $deviceList $device] == -1 } {
		    set devicelist   [ split $device  _ ]
            set portname     [ lindex $devicelist 0 ]
		    set port [::IxiaFH::nstype $portname]
			set phandle [$port cget -handle]
            set ethernetList [ixNet getL $phandle/protocolStack ethernet]
            foreach sg_ethernet $ethernetList {
                Logto -info "protocol handle $sg_ethernet"
                set sg_proendpoint [ixNet getL $sg_ethernet $proEndpoint]
                if { $sg_proendpoint != "" } {
                    set prorangelist [ixNet getL $sg_proendpoint range]
                    foreach sg_prorange $prorangelist {
                        set sg_proname [ixNet getA $sg_prorange/$proRange -name]
                        if { $sg_proname == $device } { 
                            if { $protocoltype == "dhcp"} {
                                Dhcpv4Host $device $port null $sg_prorange
                            } elseif { $protocoltype == "pppoe" || $protocoltype == "pppoeserver" } {
                                PppoeHost $device $port null $sg_prorange
                            } elseif { $protocoltype == "dhcpserver"} {
                                DhcpServer $device $port null $sg_prorange
                            }
                            lappend deviceList $device
                             
                        }
                    }
                }
            }
		}
		
	}	
    
    proc protocol_handle { args } {
		set tag "protocol_handle "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
                -protocoltype {
					set protocoltype $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
        
        if { [ lsearch $deviceList $device ] == -1 } {
            set devicelist   [ split $device  .]
            set portname     [ lindex $devicelist 0 ]
            set fhport [::IxiaFH::nstype $portname]
            set phandle [$fhport cget -handle]
            set prothandle [ixNet getL $phandle/protocols $protocoltype]
            Logto -info "protocol handle $prothandle"
            
            switch -exact -- $protocoltype {
                igmp {
                    set routerlist [ ixNet getL $prothandle host ]
                    foreach router $routerlist {
                        Logto -info "router handle $router"
                        set rinterface [ ixNet getA $router -interfaces ]                        
                        set inter_name [ ixNet getA $rinterface -description ] 
                        if { $inter_name == $device } {                      
                            IgmpHost $device $fhport $router  
                            lappend deviceList $device                                  
                        }                          
                    }  
                } 
                isis {
                    set routerlist [ ixNet getL $prothandle router ]
                    foreach router $routerlist {
                    Logto -info "router handle $router"
                        set rinterface [ ixNet getL $router interface ]
                        set inter_handle [ixNet getA $rinterface -interfaceId ]
                        set inter_name [ ixNet getA $inter_handle -description ] 
                        if { $inter_name == $device } {                      
                            IsisSession $device $fhport $router  
                            lappend deviceList $device                                 
                        }    
                    }   
                    
                }
                bgp {
                    set routerlist [ ixNet getL $prothandle neighborRange ]
                    foreach router $routerlist { 
                        Logto -info "router handle $router"
                        set inter_handle [ixNet getA $router -interfaces ]
                        set inter_name [ ixNet getA $inter_handle -description ] 
                        if { $inter_name == $device } {                      
                            BgpSession $device $fhport $router  
                            lappend deviceList $device                                
                        }   
                    }
                }
                ospf {
                    set routerlist [ ixNet getL $prothandle router ]
                    foreach router $routerlist {
                        Logto -info "router handle $router"
                        set rinterface [ ixNet getL $router interface ]
                        set inter_handle [ixNet getA $rinterface -interfaces ]
                        set inter_name [ ixNet getA $inter_handle -description ] 
                        if { $inter_name == $device } {                      
                            Ospfv2Session $device $fhport $router  
                            lappend deviceList $device                            
                        }   
                    }
                }                
                default {
                        error "$errNumber(3) protocoltype:$protocoltype "
                }
            }
        }
	
	}	
	
    
    proc device_config_old { args } {
		set tag "device_config "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-obj_name {
					set obj_name $value
                        
				}
				-obj_type {
					set obj_type $value
                        
				}
				-args_value_pairs {
					set args_value $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
        set devicelist   [ split $obj_name  _ ]
        set portname     [ lindex $devicelist 0 ]
        set protocoltype [ lindex $devicelist 1 ]
        set EPType { dhcp pppoe igmp dhcpserver bgp isis ospf}
        set protocoltype [string tolower $obj_type]
        foreach ptype $EPType {
            if { [regexp ^$ptype.* $protocoltype] } {               
                set protocoltype $ptype
                Logto -info "protocol type $ptype"
                break
            }
            
        }
        if { $protocoltype == "bgp" || $protocoltype == "isis" || $protocoltype == "ospf" ||$protocoltype == "igmp"} {
            protocol_handle  -device $device -protocoltype $protocoltype
        } else {
        
            access_protocol_handle -port $portname -device $obj_name -protocoltype $protocoltype 
        }
        foreach { key value } $args_value {
			set key [string tolower $key]
			switch -exact -- $key {
				-src_mac {
					$obj_name config -mac_addr $value
                        
				}
				-dst_mac {					                       
				}
				-vlan {
					$obj_name config -vlan_id1 $value                        
				}
                -src_ip {
                    if {$protocoltype == "igmp" } {
                        $obj_name config -ipaddr $value
                    }                    
				}
				-gateway_ip {
					                        
				}
				-ospf_area_id {
					$obj_name config  -area_id $value
                        
				}
				-ospf_network_type {
					$obj_name config  -network_type $value
                        
				}
				-isis_system_id {
					$obj_name config  -system_id $value
                        
				}
				-isis_level {
				    if { $value == 0 } {
					    set value "level2"
					} elseif { $value == 1 } {
					    set value "level1"
					} elseif { $value == 2 } {
					    set value "level1Level2"
					}
					$obj_name config  -level_type $value
                        
				}
				-isis_network_type {
					$obj_name config  -network_type $value
                        
				}
				-isis_metric_mode {
					$obj_name config  -metric $value
                        
				}
				-bgp_mode {
				    if { $value == 0 } {
					    set value "external"
					} elseif { $value == 1 } {
					    set value "internal"
					}
					$obj_name config  -type $value
                        
				}
				-bgp_dut_as {
					$obj_name config  -dut_as $value
                        
				}
				-bgp_local_as {
					$obj_name config  -as $value
                        
				}
				-dhcp_pool_address_start {
					$obj_name config  -pool_ip_start $value
                        
				}
                -dhcp_pool_host_address_start {
					$obj_name config  -pool_ip_pfx $value
                        
				}
                -dhcp_pool_address_count {
					$obj_name config  -pool_ip_count $value
                        
				}
                -dhcp_enable_broadcast_flag {
					$obj_name config  -use_broadcast_flag $value
                        
				}
                -pppoe_auth {
					$obj_name config  -authentication $value
                        
				}
                -pppoe_usename {
					$obj_name config  -user_name $value
                        
				}
                -pppoe_password {
					$obj_name config  -password $value
                        
				}
                -multicast_version {
					$obj_name config  -version $value
                        
				}
                -igmp_start_group_ip {
					$obj_name config  -ipaddr $value
                        
				} 
                -igmp_group_step {
					$obj_name config  -ipaddr_step $value
                        
				}
                -igmp_group_num {
					$obj_name config  -count $value
                        
				} 
                -pim_mode {
					$obj_name config  -pim_mode $value
                        
				}
                -pim_role {
					$obj_name config  -pim_role $value
                        
				}                
			}
		}		   
			
	}
	
	proc dhcp_client_bind { args } {
		set tag "dhcp_client_bind "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
        global fhportlist
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
        if { [ info exists device ] } {
            access_protocol_handle  -device $device -protocoltype dhcp
            $device request	
        } elseif { [ info exists port ] } {
            set port [::IxiaFH::nstype $port]
			set phandle [$port cget -handle]
            set ethernetList [ixNet getL $phandle/protocolStack ethernet]
            set sg_proendpoint_list ""
            foreach sg_ethernet $ethernetList {
                set sg_proendpoint [ixNet getL $sg_ethernet dhcpEndpoint]
                if { $sg_proendpoint != "" } {
                    lappend sg_proendpoint_list $sg_proendpoint
                }
            }
            ixNet exec dhcpClientStart $sg_proendpoint_list
        } else {
            set dhcpclientlist ""       
            foreach port $fhportlist {
                set phandle [$port cget -handle]
                set ethernetList [ixNet getL $phandle/protocolStack ethernet]                   
                foreach sg_ethernet $ethernetList {
                    set sg_proendpoint [ixNet getL $sg_ethernet dhcpEndpoint]
                    if { $sg_proendpoint != "" } {
                        lappend dhcpclientlist $sg_proendpoint
                    }
                }        
            }                        
            ixNet exec dhcpClientStart $dhcpclientlist
        }
	}
    
    proc dhcp_client_release { args } {
		set tag "dhcp_client_release "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
        global fhportlist
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
        if { [ info exists device ] } {
            access_protocol_handle  -device $device -protocoltype dhcp
            $device release	
        } elseif { [ info exists port ] } {
            set port [::IxiaFH::nstype $port]
			set phandle [$port cget -handle]
            set ethernetList [ixNet getL $phandle/protocolStack ethernet]
            set sg_proendpoint_list ""
            foreach sg_ethernet $ethernetList {
                set sg_proendpoint [ixNet getL $sg_ethernet dhcpEndpoint]
                if { $sg_proendpoint != "" } {
                    lappend sg_proendpoint_list $sg_proendpoint
                }
            }
            ixNet exec dhcpClientStop $sg_proendpoint_list
        } else {
            set dhcpclientlist ""       
            foreach port $fhportlist {
                set phandle [$port cget -handle]
                set ethernetList [ixNet getL $phandle/protocolStack ethernet]                   
                foreach sg_ethernet $ethernetList {
                    set sg_proendpoint [ixNet getL $sg_ethernet dhcpEndpoint]
                    if { $sg_proendpoint != "" } {
                        lappend dhcpclientlist $sg_proendpoint
                    }
                }        
            }                        
            ixNet exec dhcpClientStop $dhcpclientlist
        }
	}
    
    proc dhcp_stats_get { args } {
		set tag "dhcp_stats_get "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
                -counter {
					set counter $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
        if { [ info exists device ] } {
            access_protocol_handle  -device $device -protocoltype dhcp
            if { $counter == "*" } {
                return [ $device get_fh_stats ]
            } elseif { $counter == "BindRate" } {
                return [ $device get_fh_stats -currentboundcount 0 ]
            } elseif { $counter == "CurrentBoundCount" } {
                return [ $device get_fh_stats -bindrate 0 ]
            }
          
        } else {
            set root [ixNet getRoot]

            set view [ lindex [ ixNet getF $root/statistics view -caption "dhcpPerRangeView" ] 0 ]
            if { $view == "" } {
                if { [ catch {
                    set view [ DhcpHost::CreateDhcpPerRangeView ]
                } ] } {
                    return [ GetErrorReturnHeader "Can't fetch stats view, please make sure the session starting correctly." ]
                }
            }
            
            set captionList         [ ixNet getA $view/page -columnCaptions ]
            set rangeIndex          [ lsearch -exact $captionList {Range Name} ]
        Deputs "index:$rangeIndex"
            
            set offerRecIndex       [ lsearch -exact $captionList {Offers Received} ]
        Deputs "index:$offerRecIndex"
            if { $offerRecIndex < 0 } {
                set offerRecIndex       [ lsearch -exact $captionList {Replies Received} ]
        Deputs "index:$offerRecIndex"
            }

            set stats [ ixNet getA $view/page -rowValues ]
        Deputs "stats:$stats"
            set ret ""
            # set rangeFound 0
            foreach row $stats {
                eval {set row} $row
                Deputs "row:$row"

                
                if { $bindrate == 1 } {
                    set statsItem   "bind_rate"
                    if { [ info exists requestDuration ] == 0 || $requestDuration < 1 } {
                        set statsVal NA
                    } else {
                        set statsVal    [ expr [ lindex $row $offerRecIndex ] / $requestDuration ]
                    }
            Deputs "stats val:$statsVal"
                    set ret "$ret$statsItem $statsVal "
                }
                
                
                if { $currentboundcount == 1 } {
                    set statsItem   "current_bound_count"
                    if { $offerRecIndex >= 0 } {
                        set statsVal    [ lindex $row $offerRecIndex ]
                    } else {
                        set statsVal    "NA"
                    }
            Deputs "stats val:$statsVal"
                    set ret "$ret$statsItem $statsVal "
                } 
            }                
        }
	}
    
    proc dhcp_server_start { args } {
		set tag "dhcp_server_start "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
        global fhportlist
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
        
        if { [ info exists device ] } {
            access_protocol_handle  -device $device -protocoltype dhcpserver
            $device start	
        } elseif { [ info exists port ] } {
            set port [::IxiaFH::nstype $port]
			set phandle [$port cget -handle]
            set ethernetList [ixNet getL $phandle/protocolStack ethernet]
            set sg_proendpoint_list ""
            foreach sg_ethernet $ethernetList {
                set sg_proendpoint [ixNet getL $sg_ethernet dhcpServerEndpoint]
                if { $sg_proendpoint != "" } {
                    lappend sg_proendpoint_list $sg_proendpoint
                }
            }
            ixNet exec dhcpServerStart $sg_proendpoint_list
        } else {
            set dhcpsetverlist ""       
            foreach port $fhportlist {
                set phandle [$port cget -handle]
                set ethernetList [ixNet getL $phandle/protocolStack ethernet]                   
                foreach sg_ethernet $ethernetList {
                    set sg_proendpoint [ixNet getL $sg_ethernet dhcpServerEndpoint]
                    if { $sg_proendpoint != "" } {
                        lappend dhcpsetverlist $sg_proendpoint
                    }
                }        
            }                        
            ixNet exec dhcpServerStart $dhcpsetverlist
        }
	}
    
    proc dhcp_server_stop { args } {
		set tag "dhcp_server_stop "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
        global fhportlist
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
        
        if { [ info exists device ] } {
            access_protocol_handle  -device $device -protocoltype dhcpserver
            $device stop	
        } elseif { [ info exists port ] } {
            set port [::IxiaFH::nstype $port]
			set phandle [$port cget -handle]
            set ethernetList [ixNet getL $phandle/protocolStack ethernet]
            set sg_proendpoint_list ""
            foreach sg_ethernet $ethernetList {
                set sg_proendpoint [ixNet getL $sg_ethernet dhcpServerEndpoint]
                if { $sg_proendpoint != "" } {
                    lappend sg_proendpoint_list $sg_proendpoint
                }
            }
            ixNet exec dhcpServerStop $sg_proendpoint_list
        } else {
            set dhcpsetverlist ""       
            foreach port $fhportlist {
                set phandle [$port cget -handle]
                set ethernetList [ixNet getL $phandle/protocolStack ethernet]                   
                foreach sg_ethernet $ethernetList {
                    set sg_proendpoint [ixNet getL $sg_ethernet dhcpServerEndpoint]
                    if { $sg_proendpoint != "" } {
                        lappend dhcpsetverlist $sg_proendpoint
                    }
                }        
            }                        
            ixNet exec dhcpServerStop $dhcpsetverlist
        }
	}
    
    proc pppoe_connect { args } {
		set tag "pppoe_connect "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
        global fhportlist
        global pppoeclientlist 
        
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
        if { [ info exists device ] } {
            access_protocol_handle  -device $device -protocoltype pppoe
            $device start	
        } elseif { [ info exists port ] } {
            set port [::IxiaFH::nstype $port]
			set phandle [$port cget -handle]
            set ethernetList [ixNet getL $phandle/protocolStack ethernet]
            set sg_proendpoint_list ""
            foreach sg_ethernet $ethernetList {
                set sg_proendpoint [ixNet getL $sg_ethernet pppoxEndpoint]
                if { $sg_proendpoint != "" } {
                    lappend sg_proendpoint_list $sg_proendpoint
                }
            }
            ixNet exec pppoxStart $sg_proendpoint_list 
        } else {
            if {$pppoeclientlist == "" } {            
                foreach port $fhportlist {
                    set phandle [$port cget -handle]
                    set pppOption [ixNet getL $phandle/protocolStack pppoxOptions]
                    if {$pppOption != "" } {
                        set pppRole [ ixNet getA $pppOption -role]
                        if {$pppRole == "client"} {
                            set ethernetList [ixNet getL $phandle/protocolStack ethernet]
                            foreach sg_ethernet $ethernetList {
                                set sg_proendpoint [ixNet getL $sg_ethernet pppoxEndpoint]
                                if { $sg_proendpoint != "" } {
                                   
                                    lappend pppoeclientlist $sg_proendpoint
                                }
                            }
                        }
                    }
                }              
            }
            puts $pppoeclientlist
            ixNet exec pppoxStart $pppoeclientlist 
        }
	}
    
    proc pppoe_disconnect { args } {
		set tag "pppoe_disconnect "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
        global fhportlist
        global pppoeclientlist 
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
        if { [ info exists device ] } {
            access_protocol_handle  -device $device -protocoltype pppoe
            $device stop	
        } elseif { [ info exists port ] } {
            set port [::IxiaFH::nstype $port]
			set phandle [$port cget -handle]
            set ethernetList [ixNet getL $phandle/protocolStack ethernet]
            set sg_proendpoint_list ""
            foreach sg_ethernet $ethernetList {
                set sg_proendpoint [ixNet getL $sg_ethernet pppoxEndpoint]
                if { $sg_proendpoint != "" } {
                    lappend sg_proendpoint_list $sg_proendpoint
                }
            }
            ixNet exec pppoxStop $sg_proendpoint_list
        } else {
            if {$pppoeclientlist == "" } {            
                foreach port $fhportlist {
                    set phandle [$port cget -handle]
                    set pppOption [ixNet getL $phandle/protocolStack pppoxOptions]
                    if {$pppOption != "" } {
                        set pppRole [ ixNet getA $pppOption -role]
                        if {$pppRole == "client"} {
                            set ethernetList [ixNet getL $phandle/protocolStack ethernet]
                            foreach sg_ethernet $ethernetList {
                                set sg_proendpoint [ixNet getL $sg_ethernet pppoxEndpoint]
                                if { $sg_proendpoint != "" } {
                                    
                                    lappend pppoeclientlist $sg_proendpoint
                                }
                            }
                        }
                    }
                }              
            }
            ixNet exec  pppoxStop $pppoeclientlist
        }
	}
    
    proc pppoe_stats_get { args } {
		set tag "pppoe_stats_get "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
                -counter {
					set counter $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
        set sessions 0
        set sessionsuo 0
        set succsetuprate 0
        if { $counter == "*" } {
            set sessions 1
            set sessionsup 1
            set succsetuprate 1
        } else {
            if { [lsearch $counter "Sessions"] != -1 } {
                set sessions 1
            }
            if { [lsearch $counter "SessionsUp"] != -1 } {
                set sessionsup 1
            }
            if { [lsearch $counter "succsetuprate"] != -1 } {
                set succsetuprate 1
            }
        }
        if { [ info exists device ] } {
            access_protocol_handle  -device $device -protocoltype pppoe
            if { $counter == "*" } {
                return [ $device get_fh_stats ]
            } else  {
                return [ $device get_fh_stats -sessions $sessions -sessionsup $sessionsup -succsetuprate $succsetuprate  ]
            }
          
        } else {
           
            set root [ixNet getRoot]
            set view {::ixNet::OBJ-/statistics/view:"PPP General Statistics"}
            # set view  [ ixNet getF $root/statistics view -caption "Port Statistics" ]
        Deputs "view:$view"
            set captionList             [ ixNet getA $view/page -columnCaptions ]
        Deputs "caption list:$captionList"
            set port_name				[ lsearch -exact $captionList {Port Name} ]
            set attempted_count          [ lsearch -exact $captionList {Sessions Initiated} ]
            set connected_success_count          [ lsearch -exact $captionList {Sessions Succeeded} ]
            set success_setup_rate         [ lsearch -exact $captionList {Client Average Setup Rate} ]  
	
            set ret ""
	
            set stats [ ixNet getA $view/page -rowValues ]
            Deputs "stats:$stats"
                
            foreach row $stats {
                
                eval {set row} $row
        Deputs "row:$row"
                set statsItem   "Port_name"
                set statsVal    [ lindex $row $port_name ]
                Deputs "stats val:$statsVal"
                set ret "$ret$statsItem $statsVal "
                
                if { $sessions == 1 } {
                    set statsItem   "Sessions"
                    set statsVal    [ lindex $row $attempted_count ]
            Deputs "stats val:$statsVal"
                    set ret "$ret$statsItem $statsVal "
                }
                
                if { $sessionsup == 1 } {     
                    set statsItem   "SessionsUp"
                    set statsVal    [ lindex $row $connected_success_count ]
            Deputs "stats val:$statsVal"
                    set ret "$ret$statsItem $statsVal "
                }
                if { $succsetuprate == 1 } {     
                    set statsItem   "SuccSetupRate"
                    set statsVal    [ lindex $row $success_setup_rate ]
            Deputs "stats val:$statsVal"
                    set ret "$ret$statsItem $statsVal "
                } 
            }
            return $ret
        }
	}
    
    proc pppoe_server_start { args } {
		set tag "pppoe_server_start "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
        global fhportlist 
        global pppoeserverlist 
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
        if { [ info exists device ] } {      
            access_protocol_handle  -device $device -protocoltype pppoeserver
            $device start	
        } elseif { [ info exists port ] } {
            set port [::IxiaFH::nstype $port]
			set phandle [$port cget -handle]
            set ethernetList [ixNet getL $phandle/protocolStack ethernet]
            set sg_proendpoint_list ""
            foreach sg_ethernet $ethernetList {
                set sg_proendpoint [ixNet getL $sg_ethernet pppoxEndpoint]
                if { $sg_proendpoint != "" } {
                    lappend sg_proendpoint_list $sg_proendpoint
                }
            }
            ixNet exec pppoxStart $sg_proendpoint_list 
        } else {
            if {$pppoeserverlist == "" } {            
                foreach port $fhportlist {
                    set phandle [$port cget -handle]
                    
                    set pppOption [ixNet getL $phandle/protocolStack pppoxOptions]
                    if {$pppOption != "" } {
                        set pppRole [ ixNet getA $pppOption -role]
                        if {$pppRole == "server"} {
                            set ethernetList [ixNet getL $phandle/protocolStack ethernet]
                            foreach sg_ethernet $ethernetList {
                                set sg_proendpoint [ixNet getL $sg_ethernet pppoxEndpoint]
                                if { $sg_proendpoint != "" } {
                                 
                                    lappend pppoeserverlist $sg_proendpoint
                                }
                            }
                        }
                    }
                }              
            }
            puts $pppoeserverlist
            ixNet exec  pppoxStart $pppoeserverlist 
        }
	}
    
    proc pppoe_server_stop { args } {
		set tag "pppoe_server_stop "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
        global fhportlist 
        global pppoeserverlist
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
        if { [ info exists device ] } {
            access_protocol_handle  -device $device -protocoltype pppoeserver
            $device stop	
        } elseif { [ info exists port ] } {
            set port [::IxiaFH::nstype $port]
			set phandle [$port cget -handle]
            set ethernetList [ixNet getL $phandle/protocolStack ethernet]
            set sg_proendpoint_list ""
            foreach sg_ethernet $ethernetList {
                set sg_proendpoint [ixNet getL $sg_ethernet pppoxEndpoint]
                if { $sg_proendpoint != "" } {
                    lappend sg_proendpoint_list $sg_proendpoint
                }
            }
            ixNet exec pppoxStop $sg_proendpoint_list
        } else {
            if {$pppoeserverlist == "" } {            
                foreach port $fhportlist {
                    set phandle [$port cget -handle]
                    set pppOption [ixNet getL $phandle/protocolStack pppoxOptions]
                    if {$pppOption != "" } {
                        set pppRole [ ixNet getA $pppOption -role]
                        if {$pppRole == "server"} {
                            set ethernetList [ixNet getL $phandle/protocolStack ethernet]
                            foreach sg_ethernet $ethernetList {
                                set sg_proendpoint [ixNet getL $sg_ethernet pppoxEndpoint]
                                if { $sg_proendpoint != "" } {
                                    
                                    lappend pppoeserverlist $sg_proendpoint
                                }
                            }
                        }
                    }
                }              
            }
            ixNet exec  pppoxStop $pppoeserverlist
        }
	}
    
    
    proc igmp_querier_start { args } {
		set tag "igmp_querier_start "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
        global fhportlist
        foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
        if {[ info exists port ]} {
            set port [::IxiaFH::nstype $port]
            set phandle [$port cget -handle]
            set prohandle [ ixNet getL $phandle/protocols igmp ]
            if { $prohandle != "" } {
                ixNet exec start $prohandle
            } else {
                Logto -err "No port $port, device $device exists"
            }
        } else {
            set igmp_list ""
            foreach port $fhportlist {
                set phandle [$port cget -handle]
                set prohandle [ ixNet getL $phandle/protocols igmp ]
                if { $prohandle != "" } {
                    lappend igmp_list $prohandle
                }
            }                
            ixNet exec start $igmp_list
        }
    }
    
    proc igmp_querier_stop { args } {
		set tag "igmp_querier_stop "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
        global fhportlist
        foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
        if {[ info exists port ]} {
            set port [::IxiaFH::nstype $port]
            set phandle [$port cget -handle]
            set prohandle [ ixNet getL $phandle/protocols igmp ]
            if { $prohandle != "" } {
                ixNet exec stop $prohandle
            } else {
                Logto -err "No port $port, device $device exists"
            }
        } else {
            set igmp_list ""
            foreach port $fhportlist {
                set phandle [$port cget -handle]
                set prohandle [ ixNet getL $phandle/protocols igmp ]
                if { $prohandle != "" } {
                    lappend igmp_list $prohandle
                }
            }                
            ixNet exec stop $igmp_list
        }
    }
    
    proc igmp_join { args } {
		set tag "igmp_join "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
        global fhportlist
        foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
        
        if {[ info exists port ]} {
            set port [::IxiaFH::nstype $port]
            set phandle [$port cget -handle]
            set prohandle [ ixNet getL $phandle/protocols igmp ]
            if { $prohandle != "" } {
                ixNet exec join $prohandle
            } else {
                Logto -err "No port $port, device $device exists"
            }
        } else {
            set igmp_list ""
            foreach port $fhportlist {
                set phandle [$port cget -handle]
                set prohandle [ ixNet getL $phandle/protocols igmp ]
                if { $prohandle != "" } {
                    lappend igmp_list $prohandle
                }
            }                
            ixNet exec join $igmp_list
        }
    }
    
    proc igmp_leave { args } {
		set tag "igmp_leave "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
        global fhportlist
        foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
        
        if {[ info exists port ]} {
            set port [::IxiaFH::nstype $port]
            set phandle [$port cget -handle]
            set prohandle [ ixNet getL $phandle/protocols igmp ]
            if { $prohandle != "" } {
                ixNet exec leave $prohandle
            } else {
                Logto -err "No port $port, device $device exists"
            }
        } else {
            set igmp_list ""
            foreach port $fhportlist {
                set phandle [$port cget -handle]
                set prohandle [ ixNet getL $phandle/protocols igmp ]
                if { $prohandle != "" } {
                    lappend igmp_list $prohandle
                }
            }                
            ixNet exec leave $igmp_list
        }
    }
    
    proc igmp_rejoin { args } {
		set tag "igmp_rejoin "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
        global fhportlist
        foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
        
        if {[ info exists port ]} {
            set port [::IxiaFH::nstype $port]
            set phandle [$port cget -handle]
            set prohandle [ ixNet getL $phandle/protocols igmp ]
            if { $prohandle != "" } {
                ixNet exec join $prohandle
            } else {
                Logto -err "No port $port, device $device exists"
            }
        } else {
            set igmp_list ""
            foreach port $fhportlist {
                set phandle [$port cget -handle]
                set prohandle [ ixNet getL $phandle/protocols igmp ]
                if { $prohandle != "" } {
                    lappend igmp_list $prohandle
                }
            }                
            ixNet exec join $igmp_list
        }
        
    }
    
    proc igmp_pim_start { args } {
		set tag "igmp_pim_start "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
        global fhportlist
        foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
        
        if {[ info exists port ]} {
            set port [::IxiaFH::nstype $port]
            set phandle [$port cget -handle]
            set prohandle [ ixNet getL $phandle/protocols pimsm ]
            if { $prohandle != "" } {
                ixNet exec start $prohandle
            } else {
                Logto -err "No port $port, device $device exists"
            }
        } else {
            set igmp_list ""
            foreach port $fhportlist {
                set phandle [$port cget -handle]
                set prohandle [ ixNet getL $phandle/protocols pimsm ]
                if { $prohandle != "" } {
                    lappend igmp_list $prohandle
                }
            }                
            ixNet exec start $igmp_list
        }
    }
    
    proc igmp_pim_stop { args } {
		set tag "igmp_pim_stop "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
        global fhportlist
        foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
        
        if {[ info exists port ]} {
            set port [::IxiaFH::nstype $port]
            set phandle [$port cget -handle]
            set prohandle [ ixNet getL $phandle/protocols pimsm ]
            if { $prohandle != "" } {
                ixNet exec stop $prohandle
            } else {
                Logto -err "No port $port, device $device exists"
            }
        } else {
            set igmp_list ""
            foreach port $fhportlist {
                set phandle [$port cget -handle]
                set prohandle [ ixNet getL $phandle/protocols pimsm ]
                if { $prohandle != "" } {
                    lappend igmp_list $prohandle
                }
            }                
            ixNet exec stop $igmp_list
        }
    }
    
	proc ospfv2_create { args } {
		set tag "ospfv2_create "
		Logto"----- TAG: $tag -----"	
	}
    proc ospfv2_start { args } {
		set tag "ospfv2_start "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
       
        protocol_handle  -device $device -protocoltype ospf
        $device start	
        
	}
    
    proc ospfv2_stop { args } {
		set tag "ospfv2_stop "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		
       
        protocol_handle  -device $device -protocoltype ospf
        $device stop	
        
	}
    
   
    proc ospfv2_stats_get { args } {
		set tag "ospfv2_stats_get "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
                -counter {
					set counter $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		
        if { [ info exists device ] } {
           protocol_handle  -device $device -protocoltype ospf
            if { $counter == "*" } {
                return [ $device get_fh_stats ]
            }
       
        set results [ $device get_fh_stats ]
        return $results        
        
	    }
    }
    
    proc ospfv2_route_advertise { args } {
		set tag "ospfv2_route_advertise "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
                -route_block_name {
                    set route_block_name $value
                }
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
       
        protocol_handle  -device $device -protocoltype ospf
        $device advertise_topo	
        
	}
    
    proc ospfv2_route_undo { args } {
		set tag "ospfv2_route_undo "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
                -route_block_name {
                    set route_block_name $value
                }
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
       
        protocol_handle  -device $device -protocoltype ospf
        $device withdraw_topo	
        
	}
    
    proc isis_start { args } {
		set tag "isis_start "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
       
        protocol_handle  -device $device -protocoltype isis
        $device start	
        
	}
    
    proc isis_stop { args } {
		set tag "isis_stop "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
       
        protocol_handle  -device $device -protocoltype isis
        $device stop	
        
	}
    
    proc isis_stats_get { args } {
		set tag "isis_stats_get "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
                -counter {
					set counter $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		
        if { [ info exists device ] } {
           protocol_handle  -device $device -protocoltype bgp
            if { $counter == "*" } {
                return [ $device get_fh_stats ]
            }
       
        set results [ $device get_fh_stats ]
        return $results        
        
	    }
    }
    
    proc isis_route_advertise { args } {
		set tag "isis_route_advertise "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
                -route_block_name {
                    set route_block_name $value
                }
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
       
        protocol_handle  -device $device -protocoltype bgp
        $device advertise_topo	
        
	}
    
    proc isis_route_undo { args } {
		set tag "isis_route_undo "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
                -route_block_name {
                    set route_block_name $value
                }
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
       
        protocol_handle  -device $device -protocoltype bgp
        $device withdraw_topo	
        
	}
    
    proc bgp_start { args } {
		set tag "bgp_start "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
       
        protocol_handle  -device $device -protocoltype bgp
        $device start	
        
	}
    
    proc bgp_stop { args } {
		set tag "bgp_stop "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
       
        protocol_handle  -device $device -protocoltype bgp
        $device stop	
        
	}
    
    proc bgp_stats_get { args } {
		set tag "bgp_stats_get "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
                -counter {
					set counter $value
                        
				}
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		
        if { [ info exists device ] } {
           protocol_handle  -device $device -protocoltype bgp
            if { $counter == "*" } {
                return [ $device get_fh_stats ]
            }
       
        set results [ $device get_fh_stats ]
        return $results        
        
	    }
    }
    
    proc bgp_route_advertise { args } {
		set tag "bgp_route_advertise "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
                -route_block_name {
                    set route_block_name $value
                }
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
       
        protocol_handle  -device $device -protocoltype bgp
        $device advertise_topo	
        
	}
    
    proc bgp_route_undo { args } {
		set tag "bgp_route_undo "
		Logto -info "----- TAG: $tag -----"
		global deviceList
        global errNumber
		
		foreach { key value } $args {
			set key [string tolower $key]
			switch -exact -- $key {
				-port {
					set port $value
                        
				}
				-device {
					set device $value
                        
				}
                -route_block_name {
                    set route_block_name $value
                }
				default {
					error "$errNumber(3) key:$key value:$value"
				}
			}
		}
		#set newdevice [::IxiaFH::nstype $device]
       
        protocol_handle  -device $device -protocoltype bgp
        $device withdraw_topo	
        
	}
}

package provide IxiaFH $FHreleaseVersion
puts "package require success on version $FHreleaseVersion"

namespace import IxiaFH::*




