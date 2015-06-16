# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.2
#===============================================================================
# Change made
# Version 1.0 
#       1. Create
# Version 1.1
#		2. Add MulticastGroup class
# Version 1.2
#		3. Add join_group method

class IgmpHost {
    inherit RouterEmulationObject   	
    constructor { port { pHandle null } { hInterface null } } {}
    method config { args } {}
	method unconfig {} {
		set tag "body IgmpHost::unconfig [info script]"
Deputs "----- TAG: $tag -----"
		set interface [ list ]
		set group_list	[ list ]
		array set group_handle [list]
		catch {
			foreach hIgmp $handle {
				ixNet remove $hIgmp
			}
			ixNet commit
		}
		set handle ""
	}
    
    method join_group { args } {}
    method leave_group { args } {}
    method get_group_stats { args } {}
    method get_host_stats { args } {}
    
	public variable count
    public variable ipaddr
    public variable ipaddr_step
    public variable vlan_id1_step
    public variable vlan_id2_step
	public variable interface
	public variable group_list
	public variable group_handle

}

body IgmpHost::constructor { port { pHandle null } { hInterface null } } {
    
    global errNumber
    
    set tag "body IgmpHost::ctor [info script]"
Deputs "----- TAG: $tag -----"

    set portObj [ GetObject $port ]
    if { [ catch {
        set hPort   [ $portObj cget -handle ]
    } ] } {
        error "$errNumber(1) Port Object in DhcpHost ctor"
    }

	#-- enable igmp emulation
	ixNet setA $hPort/protocols/igmp -enabled True
	ixNet commit
    set handle ""
    if { $pHandle != "null" } {
        set handle $pHandle
    }
	
    set count 		1
    set ipaddr_step 	0.0.0.1
    set vlan_id1_step	1
    set vlan_id2_step	1
	set interface   [ list ]
	set group_list	[ list ]
	array set group_handle [list]
	if { $hInterface != "null" } {
	    set interface $hInterface
		config
	}
	

}

body IgmpHost::config { args } {
    global errorInfo
    global errNumber
    set tag "body IgmpHost::config [info script]"
Deputs "----- TAG: $tag -----"
	
	set version "v2"
#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -force_leave {
            	set force_leave $value
            }
            -force_robust_join {			
            	set force_robust_join $value
            }
            -insert_checksum_errors {
            	set insert_checksum_errors $value
            }
            -insert_length_errors {
            	set insert_length_errors $value
            }
            -ipv4_dont_fragment  {
            	set ipv4_dont_fragment  $value
            }
            -pack_reports {
            	set pack_reports $value
            }
            -robustness_variable {
            	set robustness_variable $value
            }
            -v1_router_present_timeout {
            	set v1_router_present_timeout $value
            }
            -version {
            	set version $value
            }
            -ipaddr {
            	set ipaddr $value
            }
            -ipaddr_step {
            	set ipaddr_step $value
            }
            -count {
            	set count $value
            }
			-outer_vlan_id -
            -vlan_id1 {
            	set vlan_id1 $value
            }
			-outer_vlan_step -
            -vlan_id1_step {
            	set vlan_id1_step $value
            }
			-inner_vlan_id -
            -vlan_id2 {
            	set vlan_id2 $value
            }
			-inner_vlan_step -
            -vlan_id2_step {
            	set vlan_id2_step $value
            }
			-group_specific {
                set trans [ BoolTrans $value ]
                if { $trans == "1" || $trans == "0" } {
					set group_specific $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-general_query {
                set trans [ BoolTrans $value ]
                if { $trans == "1" || $trans == "0" } {
				set general_query $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-router_alert {
                set trans [ BoolTrans $value ]
                if { $trans == "1" || $trans == "0" } {
					set router_alert $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-unsolicited {
                set trans [ BoolTrans $value ]
                if { $trans == "1" || $trans == "0" } {
					set unsolicited $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
            -unsolicited_report_interval {
            	set unsolicited_report_interval $value
            }
		}
    }
		
    if { [ info exists ipaddr ] } {
Deputs "Step10"
	set ipv4_addr $ipaddr
		set int_cnt [ llength $interface ]
    	if { $int_cnt > 0 && $int_cnt == $count } {

			foreach int $interface {
				ixNet setA $int -enabled True
				set ip [ ixNet add $int ipv4 ]
				ixNet commit
				set ip [ ixNet remapIds $ip ]
				ixNet setA $int/ipv4 -ip  $ipv4_addr
				ixNet commit
				set pfx [GetStepPrefixlen $ipaddr_step]
				set ipv4_addr [ IncrementIPAddr	$ipv4_addr $pfx ]
			}
		    
    	} else {
			foreach int $interface {
				ixNet remove $int
				ixNet commit
			}
            for { set index 0 } { $index < $count } { incr index } {
            	set int [ ixNet add $hPort interface ]
            	ixNet setA $int -enabled True
            	ixNet commit
            	set int [ixNet remapIds $int]
            	set ip [ ixNet add $int ipv4 ]
            	ixNet commit
            	set ip [ ixNet remapIds $ip ]
            	ixNet setA $ip -ip  $ipv4_addr
            	ixNet commit
            	lappend interface $int
            	set pfx [GetStepPrefixlen $ipaddr_step]
            	set ipv4_addr [ IncrementIPAddr	$ipv4_addr $pfx ]
            }
    	}
    }
    
    if { [ info exists vlan_id1 ] } {
Deputs Step20
		set vlanId	$vlan_id1
		set int_cnt [ llength $interface ]
		if { $int_cnt > 0 && $int_cnt == $count } {
			foreach int $interface {
				ixNet setA $int -enabled True
				ixNet setM $int/vlan \
					-count 1 \
					-vlanEnable True \
					-vlanId $vlanId
				ixNet commit
				incr vlan_id1 $vlan_id1_step
			}	

    	} else {
Deputs "Bad count of interface...$int_cnt"
    	}
    }
    
    if { [ info exists vlan_id2 ] } {
Deputs Step30
		set int_cnt [ llength $interface ]
		if { $int_cnt > 0 && $int_cnt == $count } {

			set vlanId	$vlan_id2
			foreach int $interface {
				set vlanId1	[ ixNet getA $int/vlan -vlanId ]
				set vlanId	"${vlanId1},${vlanId}"
			
				ixNet setA $int -enabled True
				ixNet setM $int/vlan \
					-count 2 \
					-vlanEnable True \
					-vlanId $vlanId
				ixNet commit
				incr vlan_id2 $vlan_id2_step
			}			
		} else {
Deputs "Bad count of interface...$int_cnt"
    	}
    }



	#-- enable igmp emulation
	ixNet setA $hPort/protocols/igmp -enabled True
	ixNet commit

Deputs "int len:[ llength $interface ]"	
	if { [ llength $interface ] > 0 } {
		if { $handle == "" } {
		   foreach int $interface {

				set host [ ixNet add $hPort/protocols/igmp host ]
				
				ixNet setM $host \
					-interfaceType {Protocol Interface} \
					-enabled True 
				
				ixNet commit
				lappend handle [ixNet remapIds $host]

		Deputs "protocol interface:$int"
				ixNet setA $handle -interfaces $int
				ixNet commit
			}
		}
	}


# -gqResponseMode True \
# -interfaceIndex 1 \
# -reportFreq 120 \
# -respToQueryImmediately False \
# -routerAlert True \
# -sqResponseMode True \
# -suppressReports False \
# -upResponseMode False \
# -version igmpv2    

	foreach h $handle {
		if { [ info exists version ] } {
			switch $version {
			    igmpv1 -
				v1 {
					set ixversion igmpv1
				}
				igmpv2 -
				v2 {
					set ixversion igmpv2
				}
				igmpv3 -
				v3 {
					set ixversion igmpv3
				}
			}
			ixNet setA $h -version $ixversion
		}
		if { [ info exists group_specific ] } {
			ixNet setA $h -sqResponseMode $group_specific
		}
		if { [ info exists general_query ] } {
			ixNet setA $h -gqResponseMode $general_query
		}
		if { [ info exists router_alert ] } {
			ixNet setA $h -routerAlert $router_alert
		}
		if { [ info exists unsolicited ] } {
			ixNet setA $h -upResponseMode $unsolicited
		}
		if { [ info exists unsolicited_report_interval ] } {
			ixNet setA $h -reportFreq $unsolicited_report_interval
		}
		ixNet commit
	}
    	
	
	return [ GetStandardReturnHeader ]	
	
}

body IgmpHost::join_group { args } {
    global errNumber
    
    set tag "body IgmpHost::join_group [info script]"
Deputs "----- TAG: $tag -----"

    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -group {
            	set groupList $value
            }
            -rate {
            	set rate $value
            }
        }
    }

	if { [ info exists rate ] } {
		ixNet setMultiAttrs $hPort/protocols/igmp \
			-numberOfGroups $rate \
			-timePeriod 1000
		ixNet commit
	}
	
	if { [ info exists groupList ] } {
		foreach group $groupList {
	Deputs Step10
			if { [ $group isa MulticastGroup ] == 0 } {
				return [ GetErrorReturnHeader "Invalid MultcastGroup object... $group" ]
			}
	Deputs Step20
			set grpIndex [ lsearch $group_list $group ]
			if { $grpIndex >= 0 } {
	Deputs Step30
	           
				set group_ip [ $group cget -group_ip ]
				set group_num [ $group cget -group_num ]
				set group_step [ $group cget -group_step ]
				
				foreach hIgmp $handle {

					set hGroup	$group_handle($group,$hIgmp)
					ixNet setA $hGroup -enabled True
					ixNet setM $hGroup \
						-enabled True \
						-groupCount $group_num \
						-groupFrom $group_ip \
						-incrementStep $incrStep 
						
					ixNet commit
				}
			} else {
	Deputs Step40
				set filter_mode [ $group cget -filter_mode ]
				set group_ip [ $group cget -group_ip ]
				set group_num [ $group cget -group_num ]
				set group_step [ $group cget -group_step ]
				set group_modbit [ $group cget -group_modbit ]
				set source_ip [ $group cget -source_ip ]
				set source_num [ $group cget -source_num ]
				set source_step [ $group cget -source_step ]
				set source_modbit [ $group cget -source_modbit ]
	Deputs "=group prop= filter_mode:$filter_mode group_ip:$group_ip group_num:$group_num group_step:$group_step group_modbit:$group_modbit source_ip:$source_ip source_num:$source_num source_step:$source_step source_modbit:$source_modbit"
	Deputs Step45
				foreach hIgmp $handle {
					set hGroup [ ixNet add $hIgmp group ]
					set incrStep [ GetPrefixV4Step $group_modbit $group_step ]
					ixNet setM $hGroup \
						-enabled True \
						-groupCount $group_num \
						-groupFrom $group_ip \
						-incrementStep $incrStep \
						-sourceMode $filter_mode
					ixNet commit
		Deputs Step50			
		Deputs "group handle:$hGroup"
		Deputs "group handle array names: [ array names group_handle ]"
					set group_handle($group,$hIgmp) $hGroup
		Deputs Step60
					lappend group_list $group
		Deputs "group handle names:[ array names group_handle ]"
		Deputs "group list:$group_list"
				}			
			}
		}
	}

	return [ GetStandardReturnHeader ]
}
body IgmpHost::leave_group { args } {
    global errNumber
    
    set tag "body IgmpHost::leave_group [info script]"
Deputs "----- TAG: $tag -----"

    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -group {
            	set group $value
            }
            -rate {
            	set rate $value
            }
        }
    }

	if { [ info exists rate ] } {
		ixNet setMultiAttrs $hPort/protocols/igmp \
			-numberOfGroups $rate \
			-timePeriod 1000
		ixNet commit
	}
	
	if { [ info exists group ] } {
Deputs Step10
		if { [ $group isa MulticastGroup ] == 0 } {
			return [ GetErrorReturnHeader "Invalid MultcastGroup object... $group" ]
		}
Deputs Step20
		set grpIndex [ lsearch $group_list $group ]
		if { $grpIndex >= 0 } {
Deputs Step30
			foreach hIgmp $handle {

				set hGroup	$group_handle($group,$hIgmp)
				ixNet setA $hGroup -enabled False
				ixNet commit
			}
		} else {
			return [ GetErrorReturnHeader "No such group:$group" ]
		}
	}

	return [ GetStandardReturnHeader ]
}
body IgmpHost::get_group_stats { args } {
	return [ GetErrorReturnHeader "Method not supported..." ]
}
body IgmpHost::get_host_stats { args } {
    set tag "body IgmpHost::get_host_stats [info script]"
Deputs "----- TAG: $tag -----"
    
	#{::ixNet::OBJ-/statistics/view:"Port Statistics"}
    set root [ixNet getRoot]
	set view {::ixNet::OBJ-/statistics/view:"IGMP Aggregated Statistics"}
    # set view  [ ixNet getF $root/statistics view -caption "Port Statistics" ]
Deputs "view:$view"
    set captionList             [ ixNet getA $view/page -columnCaptions ]
Deputs "caption list:$captionList"
# tx_v1_reports
# tx_v2_reports
# tx_v2_leave_reports
# tx_v3_reports
# rx_v1_general_queries
# rx_v2_general_queries
# rx_v3_general_queries
# rx_v1_specific_queries
# rx_v2_specific_queries
# rx_v3_group_specific_queries
# rx_v3_group_source_specific_queries
# send_includes
# send_excludes

# {Stat Name} 
# {Host v1 Membership Rpts. Rx} 
# {Host v2 Membership Rpts. Rx} 
# {v1 Membership Rpts. Tx} 
# {v2 Membership Rpts. Tx} 
# {v3 Membership Rpts. Tx} 
# {v2 Leave Tx} 
# {Host Total Frames Tx} 
# {Host Total Frames Rx} 
# {Host Invalid Packets Rx} 
# {General Queries Rx} 
# {Grp. Specific Queries Rx} 
# {v3 Grp. & Src. Specific Queries Rx}
	set tx_v1_reports			[ lsearch -exact $captionList {v1 Membership Rpts. Tx} ]
    set tx_v2_reports          [ lsearch -exact $captionList {v2 Membership Rpts. Tx}  ]
    set tx_v2_leave_reports          [ lsearch -exact $captionList  {v2 Leave Tx} ]
    set tx_v3_reports         	[ lsearch -exact $captionList {v3 Membership Rpts. Tx} ]
    set rx_v1_general_queries         	[ lsearch -exact $captionList {General Queries Rx} ]
    set rx_v2_general_queries         	[ lsearch -exact $captionList {General Queries Rx} ]
    set rx_v3_general_queries       		[ lsearch -exact $captionList {General Queries Rx} ]
    set rx_v1_specific_queries        	[ lsearch -exact $captionList {Grp. Specific Queries Rx} ]
    set rx_v2_specific_queries	[ lsearch -exact $captionList {Grp. Specific Queries Rx} ]
    set rx_v3_group_specific_queries       		[ lsearch -exact $captionList {Grp. Specific Queries Rx} ]
    set rx_v3_group_source_specific_queries        	[ lsearch -exact $captionList {v3 Grp. & Src. Specific Queries Rx} ]
    # set send_includes	[ lsearch -exact $captionList {Data Integrity Frames Rx.} ]
    # set send_excludes	[ lsearch -exact $captionList {Data Integrity Frames Rx.} ]

    set ret [ GetStandardReturnHeader ]
	
    set stats [ ixNet getA $view/page -rowValues ]
Deputs "stats:$stats"

    foreach row $stats {
        
        eval {set row} $row
Deputs "row:$row"

        set statsItem   "tx_v1_reports"
        set statsVal    [ lindex $row $tx_v1_reports ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
          
        set statsItem   "tx_v2_reports"
        set statsVal    [ lindex $row $tx_v2_reports ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
              
        set statsItem   "tx_v2_leave_reports"
        set statsVal    [ lindex $row $tx_v2_leave_reports ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "tx_v3_reports"
        set statsVal    [ lindex $row $tx_v3_reports ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "rx_v1_general_queries"
        set statsVal    [ lindex $row $rx_v1_general_queries ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
          
        set statsItem   "rx_v2_general_queries"
        set statsVal    [ lindex $row $rx_v2_general_queries ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
              
        set statsItem   "rx_v3_general_queries"
        set statsVal    [ lindex $row $rx_v3_general_queries ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

        set statsItem   "rx_v1_specific_queries"
        set statsVal    [ lindex $row $rx_v1_specific_queries ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
          
        set statsItem   "rx_v2_specific_queries"
        set statsVal    [ lindex $row $rx_v2_specific_queries ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
              
        set statsItem   "rx_v3_group_specific_queries"
        set statsVal    [ lindex $row $rx_v3_group_specific_queries ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

        set statsItem   "rx_v3_group_source_specific_queries"
        set statsVal    [ lindex $row $rx_v3_group_source_specific_queries ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "send_includes"
        set statsVal    "NA"
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  
        set statsItem   "send_excludes"
        set statsVal    "NA"
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

Deputs "ret:$ret"

    }
        
    return $ret	
}

class MulticastGroup {

	inherit NetObject

	public variable filter_mode
	public variable source_ip
	public variable source_num
	public variable source_step
	public variable source_modbit
	public variable group_ip
	public variable group_num
	public variable group_step
	public variable group_modbit
	public variable up_device

	method config { args } {}
	method SetUpDevice { updevice } {
	    set up_device $updevice
	}
	
	constructor { } {
		set filter_mode 		exclude
		set source_ip			0.0.0.0
		set source_num			1
		set source_step			1
		set source_modbit		32
		set group_ip			225.0.0.1
		set group_num			1
		set group_step			1
		set group_modbit		32
	}
}

body MulticastGroup::config { args } {

    global errNumber
    
    set tag "body MulticastGroup::config [info script]"
Deputs "----- TAG: $tag -----"

	set EFilterMode		[ list include exclude ]
	
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -filter_mode {
				set value [ string tolower $value ]
                if { [ lsearch -exact $EFilterMode $value ] >= 0 } {
                    
                    set filter_mode $value
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -source_ip {
Deputs "set ip address...$value"
			  set source_ip $value
#                if { [ IsIPv4Address $value ] } {
#                    set source_ip $value
#                } else {
#                    error "$errNumber(1) key:$key value:$value"
#                }
            }
            -source_num {
                set trans [ UnitTrans $value ]
                if { [ string is integer $trans ] } {
                    set source_num $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -source_step {
                if { [ IsIPv4Address $value ] } {
                    set source_step $value
                } else {
                    set trans [ UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set source_step $trans
                    } else {
                        error "$errNumber(1) key:$key value:$value"
                    }
                }
            }
            -source_modbit {
                set trans [ UnitTrans $value ]
                if { [ string is integer $trans ] && $trans <= 32 && $trans >= 1 } {
                    set source_modbit $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }                    
            }
			-group_start_ip -
            -group_ip {
			  set group_ip $value
#                if { [ IsIPv4Address $value ] } {
#                    set group_ip $value
#                } else {
#                    error "$errNumber(1) key:$key value:$value"
#                }
            }
            -group_num {
                set trans [ UnitTrans $value ]
                if { [ string is integer $trans ] } {
                    set group_num $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
			-group_ip_setp -
            -group_step {
                if { [ IsIPv4Address $value ] } {
                    set group_step $value
                } else {
                    set trans [ UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set group_step $trans
                    } else {
                        error "$errNumber(1) key:$key value:$value"
                    }
                }
            }
            -group_modbit {
                set trans [ UnitTrans $value ]
			  set group_modbit $trans
#                if { [ string is integer $trans ] && $trans <= 32 && $trans >= 1 } {
#                    set group_modbit $trans
#                } else {
#                    error "$errNumber(1) key:$key value:$value"
#                }                    
            }

        }
    }	

	return [ GetStandardReturnHeader ]
}

class IgmpOverDhcpHost {
	inherit IgmpHost
	public variable Dhcp
	
	constructor { dhcp } {
		set Dhcp $dhcp
		set portObj [ $Dhcp  cget -portObj ]

		chain $portObj
		
	} {
		set tag "body IgmpOverDhcpHost::ctor [info script]"
Deputs "----- TAG: $tag -----"
		reborn
	}
		
	method reborn {} {}
	method config { args } {}
	method start {} {}
	method stop {} {}
}
body IgmpOverDhcpHost::reborn {} {
    set tag "body IgmpOverDhcpHost::reborn [info script]"
Deputs "----- TAG: $tag -----"
	
		
	set interface [ list ]
	set hDhcp [ $Dhcp cget -handle ]

Deputs "hDhcp:$hDhcp"
	set count [ ixNet getA $hDhcp/dhcpRange -count ]
Deputs "count:$count"
	for { set index 1 } { $index <= $count } { incr index } {
Deputs "hPort:$hPort"	
		set host [ ixNet add $hPort/protocols/igmp host ]
Deputs "IgmpoDhcp host: $host index:$index"		
		ixNet setM $host \
			-interfaceType DHCP \
			-interfaceIndex $index \
			-enabled True 
		ixNet commit
		lappend handle [ixNet remapIds $host]
		ixNet setA $host -interfaces $hDhcp
		ixNet commit
	}
Deputs "handle:$handle"	
}
body IgmpOverDhcpHost::config { args } {
    set tag "body IgmpHost::config [info script]"
Deputs "----- TAG: $tag -----"

# Deputs "handle:$handle"	
	if { [ llength $handle ] == 0 } {
		reborn
	}
	
	eval chain $args
	
	foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -group {
            	set groupList $value
            }
            -rate {
            	set rate $value
            }
        }
    }

	if { [ info exists rate ] } {
		ixNet setMultiAttrs $hPort/protocols/igmp \
			-numberOfGroups $rate \
			-timePeriod 1000
		ixNet commit
	}
	
	if { [ info exists groupList ] } {
		foreach group $groupList {
	Deputs Step10
			if { [ $group isa MulticastGroup ] == 0 } {
				return [ GetErrorReturnHeader "Invalid MultcastGroup object... $group" ]
			}
	Deputs Step20
			set grpIndex [ lsearch $group_list $group ]
			if { $grpIndex >= 0 } {
	Deputs Step30
				foreach hIgmp $handle {

					set hGroup	$group_handle($group,$hIgmp)
					ixNet setA $hGroup -enabled True
					ixNet commit
				}
			} else {
	Deputs Step40
				set filter_mode [ $group cget -filter_mode ]
				set group_ip [ $group cget -group_ip ]
				set group_num [ $group cget -group_num ]
				set group_step [ $group cget -group_step ]
				set group_modbit [ $group cget -group_modbit ]
				set source_ip [ $group cget -source_ip ]
				set source_num [ $group cget -source_num ]
				set source_step [ $group cget -source_step ]
				set source_modbit [ $group cget -source_modbit ]
Deputs "=group prop= filter_mode:$filter_mode group_ip:$group_ip group_num:$group_num group_step:$group_step group_modbit:$group_modbit source_ip:$source_ip source_num:$source_num source_step:$source_step source_modbit:$source_modbit"
Deputs Step45
Deputs "handle:$handle"	
				foreach hIgmp $handle {
					set hGroup [ ixNet add $hIgmp group ]
Deputs "hGroup:$hGroup"					
					set incrStep [ GetPrefixV4Step $group_modbit $group_step ]
Deputs "incrStep:$incrStep"					
					ixNet setM $hGroup \
						-enabled 		True \
						-groupCount 	$group_num \
						-groupFrom 		$group_ip \
						-incrementStep 	$incrStep \
						-sourceMode 	$filter_mode
						
					ixNet commit
Deputs Step50			
Deputs "group handle:$hGroup"
Deputs "group handle array names: [ array names group_handle ]"
					set group_handle($group,$hIgmp) $hGroup
		Deputs Step60
					lappend group_list $group
		Deputs "group handle names:[ array names group_handle ]"
		Deputs "group list:$group_list"
				}			
			}
		}
	}

	return [ GetStandardReturnHeader ]
	
}
body IgmpOverDhcpHost::start {} {
    set tag "body IgmpOverDhcpHost::start [info script]"
Deputs "----- TAG: $tag -----"
	ixNet exec start $hPort/protocols/igmp
	return [ GetStandardReturnHeader ]

}
body IgmpOverDhcpHost::stop {} {
    set tag "body IgmpOverDhcpHost::stop [info script]"
Deputs "----- TAG: $tag -----"
	ixNet exec stop $hPort/protocols/igmp
	return [ GetStandardReturnHeader ]

}

class IgmpQuerier {
	inherit IgmpHost	
	
	constructor { port { pHandle null } { hInterface null } } {		

		chain $port $pHandle $hInterface
		
	} {
		set tag "body IgmpQuerier::ctor [info script]"
Deputs "----- TAG: $tag -----"
		
	}
			
	method config { args } {}

}

body IgmpQuerier::config { args } {
    global errorInfo
    global errNumber
    set tag "body IgmpQuerier::config [info script]"
Deputs "----- TAG: $tag -----"
    set version 2
	set query_interval 125
	set query_respon_interval 2
	
#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -query_interval {
            	set query_interval $value
            }
            -query_respon_interval {
            	set query_respon_interval $value
            }
            -version {
            	set version $value
            }
            -startup_query_count {
            	set startup_query_count $value
            }
            -last_member_query_interval {
            	set last_member_query_interval $value
            }
            -last_member_query_count {
            	set last_member_query_count $value
            }
		}
    }
		   


	#-- enable igmp emulation
	ixNet setA $hPort/protocols/igmp -enabled True
	ixNet commit

Deputs "int len:[ llength $interface ]"	
	if { [ llength $interface ] > 0 } {
		if {$handle == ""} {
			# -- add igmp querier
			foreach int $interface {

				set  querier [ ixNet add $hPort/protocols/igmp querier ]
				
				ixNet setM $querier \
					-interfaceType {Protocol Interface} \
					-enabled True 
				
				ixNet commit
				lappend handle [ixNet remapIds $querier]

		Deputs "protocol interface:$int"
				ixNet setA $handle -interfaces $int
				ixNet commit
			}
		}
	}

   

	foreach h $handle {
		if { [ info exists version ] } {
			switch $version {
			    1 -
				v1 {
					set ixversion igmpv1
				}
				2 -
				v2 {
					set ixversion igmpv2
				}
				3 -
				v3 {
					set ixversion igmpv3
				}
			}
			ixNet setA $h -version $ixversion
		}
		if { [ info exists query_interval ] } {
			ixNet setA $h -generalQueryInterval $query_interval
		}
		if { [ info exists query_respon_interval ] } {
			ixNet setA $h -gqResponseInterval $query_respon_interval
		}
		if { [ info exists startup_query_count ] } {
			ixNet setA $h -startupQueryCount $startup_query_count
		}
		if { [ info exists last_member_query_interval ] } {
			ixNet setA $h -sqResponseInterval $last_member_query_interval
		}
		if { [ info exists last_member_query_count ] } {
			ixNet setA $h -sqTransmissionCount $last_member_query_count
		}
		ixNet commit
	}
    	
	
	return [ GetStandardReturnHeader ]	
	
}

class MldHost {
	inherit RouterEmulationObject 
	public variable group_list
	public variable group_handle
	
    constructor { port { pHandle null } { hInterface null } } {}
	method join_group { args } {}
	method config { args } {
		eval chain $args -ip_version ipv6 
	}
}
body MldHost::constructor { port { pHandle null } { hInterface null } } { 
    global errNumber
    
    set tag "body MldHost::ctor [info script]"
Deputs "----- TAG: $tag -----"

    set portObj [ GetObject $port ]
    if { [ catch {
        set hPort   [ $portObj cget -handle ]
    } ] } {
        error "$errNumber(1) Port Object in DhcpHost ctor"
    }

	#-- enable mld emulation
	ixNet setA $hPort/protocols/mld -enabled True
	ixNet commit
    set handle ""
    if { $pHandle != "null" } {
        set handle $pHandle
    }
	
    set count 		1
    set ipaddr_step 	0.0.0.1
    set vlan_id1_step	1
    set vlan_id2_step	1
	set interface   [ list ]
	set group_list	[ list ]
	array set group_handle [list]
	if { $hInterface != "null" } {
	    set interface $hInterface
		config
	}
	

}
	# global errNumber
	# set portObj [ GetObject $port ]
	# set tag "body MldHost::ctor [info script]"
# Deputs "----- TAG: $tag -----"
	# if { [ catch {
		# set hPort   [ $portObj cget -handle ]
	# } ] } {
		# error "$errNumber(1) Port Object in DhcpHost ctor"
	# }

	# #-- enable mld emulation
	# ixNet setA $hPort/protocols/mld -enabled True
	# ixNet commit
	# if { $pHandle != "null" } {
		# set handle $pHandle
	# } else {
		# set handle [ ixNet add $hPort/protocols/mld host ]
# Deputs "handle:$handle"		
		# set handle [ ixNet remapIds $handle ]
	# }
	# ixNet setA $handle \
	# -name $this \
	# -enabled True
	# ixNet commit
	# if { $hInterface != "null" } {
		# set interface $hInterface
		# ixNet setM $handle \
			# -enabled True \
			# -interfaces $interface
		# ixNet commit
		# config
	# } 	
	# set protocol mld
body MldHost::config { args } {
    global errorInfo
    global errNumber
    set tag "body MldHost::config [info script]"
Deputs "----- TAG: $tag -----"
	
	set version "1"
#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -force_leave {
            	set force_leave $value
            }
            -force_robust_join {			
            	set force_robust_join $value
            }
            -insert_checksum_errors {
            	set insert_checksum_errors $value
            }
            -insert_length_errors {
            	set insert_length_errors $value
            }
            -ipv4_dont_fragment  {
            	set ipv4_dont_fragment  $value
            }
            -pack_reports {
            	set pack_reports $value
            }
            -robustness_variable {
            	set robustness_variable $value
            }
            -v1_router_present_timeout {
            	set v1_router_present_timeout $value
            }
            -version {
            	set version $value
            }
            -ipaddr {
            	set ipaddr $value
            }
            -ipaddr_step {
            	set ipaddr_step $value
            }
            -count {
            	set count $value
            }
			-outer_vlan_id -
            -vlan_id1 {
            	set vlan_id1 $value
            }
			-outer_vlan_step -
            -vlan_id1_step {
            	set vlan_id1_step $value
            }
			-inner_vlan_id -
            -vlan_id2 {
            	set vlan_id2 $value
            }
			-inner_vlan_step -
            -vlan_id2_step {
            	set vlan_id2_step $value
            }
			-group_specific {
                set trans [ BoolTrans $value ]
                if { $trans == "1" || $trans == "0" } {
					set group_specific $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-general_query {
                set trans [ BoolTrans $value ]
                if { $trans == "1" || $trans == "0" } {
				set general_query $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-router_alert {
                set trans [ BoolTrans $value ]
                if { $trans == "1" || $trans == "0" } {
					set router_alert $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-unsolicited {
                set trans [ BoolTrans $value ]
                if { $trans == "1" || $trans == "0" } {
					set unsolicited $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
			}
            -unsolicited_report_interval {
            	set unsolicited_report_interval $value
            }
		}
    }
		
    if { [ info exists ipaddr ] } {
Deputs "Step10"
	set ipv6_addr $ipaddr
		set int_cnt [ llength $interface ]
    	if { $int_cnt > 0 && $int_cnt == $count } {

			foreach int $interface {
				ixNet setA $int -enabled True
				set ip [ ixNet add $int ipv6 ]
				ixNet commit
				set ip [ ixNet remapIds $ip ]
				ixNet setA $int/ipv4 -ip  $ipv6_addr
				ixNet commit
				set pfx [GetStepPrefixlen $ipaddr_step]
				set ipv6_addr [ IncrementIPAddr	$ipv6_addr $pfx ]
			}
		    
    	} else {
			foreach int $interface {
				ixNet remove $int
				ixNet commit
			}
            for { set index 0 } { $index < $count } { incr index } {
            	set int [ ixNet add $hPort interface ]
            	ixNet setA $int -enabled True
            	ixNet commit
            	set int [ixNet remapIds $int]
            	set ip [ ixNet add $int ipv6 ]
            	ixNet commit
            	set ip [ ixNet remapIds $ip ]
            	ixNet setA $ip -ip  $ipv6_addr
            	ixNet commit
            	lappend interface $int
            	set pfx [GetStepPrefixlen $ipaddr_step]
            	set ipv6_addr [ IncrementIPAddr	$ipv6_addr $pfx ]
            }
    	}
    }
    
    if { [ info exists vlan_id1 ] } {
Deputs Step20
		set vlanId	$vlan_id1
		set int_cnt [ llength $interface ]
		if { $int_cnt > 0 && $int_cnt == $count } {
			foreach int $interface {
				ixNet setA $int -enabled True
				ixNet setM $int/vlan \
					-count 1 \
					-vlanEnable True \
					-vlanId $vlanId
				ixNet commit
				incr vlan_id1 $vlan_id1_step
			}	

    	} else {
Deputs "Bad count of interface...$int_cnt"
    	}
    }
    
    if { [ info exists vlan_id2 ] } {
Deputs Step30
		set int_cnt [ llength $interface ]
		if { $int_cnt > 0 && $int_cnt == $count } {

			set vlanId	$vlan_id2
			foreach int $interface {
				set vlanId1	[ ixNet getA $int/vlan -vlanId ]
				set vlanId	"${vlanId1},${vlanId}"
			
				ixNet setA $int -enabled True
				ixNet setM $int/vlan \
					-count 2 \
					-vlanEnable True \
					-vlanId $vlanId
				ixNet commit
				incr vlan_id2 $vlan_id2_step
			}			
		} else {
Deputs "Bad count of interface...$int_cnt"
    	}
    }



	#-- enable mld emulation
	ixNet setA $hPort/protocols/mld -enabled True
	ixNet commit

Deputs "int len:[ llength $interface ]"	
	if { [ llength $interface ] > 0 } {
		if { $handle == "" } {
		   foreach int $interface {

				set host [ ixNet add $hPort/protocols/mld host ]
				set host [ ixNet remapIds $host ]
				ixNet setM $host \
					-interfaces $interface \
					-enabled True 
				ixNet commit
				lappend handle [ixNet remapIds $host]
 Deputs "handle:$handle"		
			}
		}
	}


# -gqResponseMode True \
# -interfaceIndex 1 \
# -reportFreq 120 \
# -respToQueryImmediately False \
# -routerAlert True \
# -sqResponseMode True \
# -suppressReports False \
# -upResponseMode False \
# -version igmpv2    

	foreach h $handle {
		if { [ info exists version ] } {
			switch $version {
			    1 -
				v1 {
					set ixversion version1
				}
				2 -
				v2 {
					set ixversion version2
				}
			}
			ixNet setA $h -version $ixversion
		}
		if { [ info exists group_specific ] } {
			ixNet setA $h -sqResponseMode $group_specific
		}
		if { [ info exists general_query ] } {
			ixNet setA $h -gqResponseMode $general_query
		}
		if { [ info exists router_alert ] } {
			ixNet setA $h -routerAlert $router_alert
		}
		if { [ info exists unsolicited ] } {
			ixNet setA $h -upResponseMode $unsolicited
		}
		if { [ info exists unsolicited_report_interval ] } {
			ixNet setA $h -reportFreq $unsolicited_report_interval
		}
		ixNet commit
	}
    	
	
	return [ GetStandardReturnHeader ]	
	
}	
body MldHost::join_group { args } {
    global errNumber
    set group_list	[ list ]
	array set group_handle [list]
    set tag "body MldHost::join_group [info script]"
Deputs "----- TAG: $tag -----"

    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -group {
            	set groupList $value
            }
            -rate {
            	set rate $value
            }
        }
    }

	if { [ info exists rate ] } {
		ixNet setMultiAttrs $hPort/protocols/mld \
			-numberOfGroups $rate \
			-timePeriod 1000
		ixNet commit
	}
	
	if { [ info exists groupList ] } {
		foreach group $groupList {
	Deputs Step10
			if { [ $group isa MulticastGroup ] == 0 } {
				return [ GetErrorReturnHeader "Invalid MultcastGroup object... $group" ]
			}
	Deputs Step20
			set grpIndex [ lsearch $group_list $group ]
			if { $grpIndex >= 0 } {
	Deputs Step30
				foreach hMld $handle {

					set hGroup	$group_handle($group,$hMld)
					ixNet setA $hGroup -enabled True
					ixNet commit
				}
			} else {
	Deputs Step40
				set filter_mode [ $group cget -filter_mode ]
				set group_ip [ $group cget -group_ip ]
				set group_num [ $group cget -group_num ]
				set group_step [ $group cget -group_step ]
				set group_modbit [ $group cget -group_modbit ]
				set source_ip [ $group cget -source_ip ]
				set source_num [ $group cget -source_num ]
				set source_step [ $group cget -source_step ]
				set source_modbit [ $group cget -source_modbit ]
	Deputs "=group prop= filter_mode:$filter_mode group_ip:$group_ip group_num:$group_num group_step:$group_step group_modbit:$group_modbit source_ip:$source_ip source_num:$source_num source_step:$source_step source_modbit:$source_modbit"
	Deputs Step45
				foreach hMld $handle {
					set hGroup [ ixNet add $hMld groupRange ]
					ixNet setM $hGroup \
						-enabled True \
						-groupCount $group_num \
						-groupIpFrom $group_ip \
						-incrementStep $group_step \
						-sourceMode $filter_mode
					ixNet commit
					set hGroup [ ixNet remapIds $hGroup ]
		Deputs Step50			
		Deputs "group handle:$hGroup"
		Deputs "group handle array names: [ array names group_handle ]"
					set group_handle($group,$hMld) $hGroup
		Deputs Step60
					lappend group_list $group
		Deputs "group handle names:[ array names group_handle ]"
		Deputs "group list:$group_list"
					$group configure -handle $hGroup
					# $group configure -portObj $portObj
					# $group configure -hPort $hPort
					#$group configure -protocol "mld"
				}			
			}
		}
	}

	start
	return [ GetStandardReturnHeader ]
}

class MldQuerier {
	inherit MldHost	
	
	constructor { port { pHandle null } { hInterface null } } {		

		chain $port $pHandle $hInterface
	} {
		set tag "body MldQuerier::ctor [info script]"
Deputs "----- TAG: $tag -----"
		
	}
			
	method config { args } {}

}
body MldQuerier::config { args } {
    global errorInfo
    global errNumber
    set tag "body MldQuerier::config [info script]"
Deputs "----- TAG: $tag -----"
    set version 1
	set query_interval 125
	set query_respon_interval 10000
	
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -query_interval {
            	set query_interval $value
            }
            -query_respon_interval {
            	set query_respon_interval $value
            }
            -version {
            	set version $value
            }
            -startup_query_count {
            	set startup_query_count $value
            }
            -last_member_query_interval {
            	set last_member_query_interval $value
            }
            -last_member_query_count {
            	set last_member_query_count $value
            }
		}
    }
		   


	ixNet setA $hPort/protocols/mld -enabled True
	ixNet commit

Deputs "int len:[ llength $interface ]"	
	if { [ llength $interface ] > 0 } {
		if {$handle == ""} {
			foreach int $interface {

				set  querier [ ixNet add $hPort/protocols/mld querier ]
				
				ixNet setM $querier \
					-interfaceType {Protocol Interface} \
					-enabled True 
				
				ixNet commit
				lappend handle [ixNet remapIds $querier]

		Deputs "protocol interface:$int"
				ixNet setA $handle -interfaces $int
				ixNet commit
			}
		}
	}

   

	foreach h $handle {
		if { [ info exists version ] } {
			switch $version {
			    1 -
				v1 {
					set ixversion version1
				}
				2 -
				v2 {
					set ixversion version2
				}
			}
			ixNet setA $h -version $ixversion
		}
		if { [ info exists query_interval ] } {
			ixNet setA $h -generalQueryInterval $query_interval
		}
		if { [ info exists query_respon_interval ] } {
			ixNet setA $h -gqResponseInterval $query_respon_interval
		}
		if { [ info exists startup_query_count ] } {
			ixNet setA $h -startupQueryCount $startup_query_count
		}
		if { [ info exists last_member_query_interval ] } {
			ixNet setA $h -sqResponseInterval $last_member_query_interval
		}
		if { [ info exists last_member_query_count ] } {
			ixNet setA $h -sqTransmissionCount $last_member_query_count
		}
		ixNet commit
	}
    	
	
	return [ GetStandardReturnHeader ]	
	
}