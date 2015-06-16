
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.0
#===============================================================================
# Change made
# Version 1.0 
#       1. Create
#       2. Update

class OspfSession {
    inherit RouterEmulationObject
	public variable routeBlock
	public variable hNetworkRange
	public variable protocolhandle
	constructor { port { pHandle null } { hInterface null } } {
		global errNumber
		set routeBlock(obj) ""
		set tag "body OspfSession::ctor [info script]"
		set portObj [ GetObject $port ]
Deputs "----- TAG: $tag -----"      
		#-- add ospf protocol
        if { $pHandle != "null"  } {
            set handle $pHandle  
			set hInt_List [ ixNet getL $handle interface ]
            foreach hInt $hInt_List {
			    set int [ixNet getA $hInt -interfaces ]
			    set interface($int) $hInt	
		    }
        } else {
			if { [ catch {
				set hPort  [ $portObj cget -handle ]
				} ] } {
					error "$errNumber(1) Port Object in DhcpHost ctor"
				}
	Deputs "hPort:$hPort" 
            ixNet setA $hPort/protocols/ospf -enabled True	
			set protocolhandle "$hPort/protocols/ospf"
            set handle [ ixNet add $hPort/protocols/ospf router ]
            ixNet commit
            set handle [ ixNet remapIds $handle ]
            ixNet setM $handle \
				-name $this	\
				-enabled True
			ixNet commit
	Deputs "handle:$handle"
			array set routeBlock [ list ]
			#-- add router interface
			set interface [ ixNet getL $hPort interface]
			if { [ llength $interface ] == 0 } {
				set interface [ ixNet add $hPort interface ]
				ixNet add $interface ipv4
				ixNet commit
				set interface [ ixNet remapIds $interface ]
				ixNet setM $interface \
					-enabled True
				ixNet commit
			Deputs "port interface:$interface"
			}
			if { $hInterface != "null"} {
			} else {
				set hInterface [ lindex $interface 0 ]
			}
			Deputs "hInterface:$hInterface"
			set rb_interface  [ ixNet add $handle interface ]
			ixNet setM $rb_interface \
				-interfaces $hInterface \
				-connectedToDut True \
				-enabled True
			ixNet commit
			set rb_interface [ ixNet remapIds $rb_interface ]
			Deputs "rb_interface:$rb_interface"  
		}
	}    
	
	
    method config { args } {}
	method set_route { args } {}
	method set_topo { args } {}
	method unset_topo { args } {}
	method advertise_topo {} {}
	method withdraw_topo {} {}
	method flapping_topo { args } {}
	method enable {} {}
	method disable {} {}
	method get_status {} {}
	method get_stats {} {}
	method generate_interface { args } {
		set tag "body OspfSession::generate_interface [info script]"
Deputs "----- TAG: $tag -----"
		foreach int $rb_interface {
			set hInt [ ixNet add $handle interface ]
			ixNet setM $hInt -interfaces $int -enabled True -connectedToDut True
			
			ixNet commit
			set hInt [ ixNet remapIds $hInt ]
			if {[ixNet getA $hPort/protocols/ospf -enabled]} {
				ixNet setA $hInt -interfaceIpAddress [ ixNet getA $int/ipv4 -ip ]
			} elseif {[ixNet getA $hPort/protocols/ospfV3 -enabled]} {
				
			} else {
				error "network type setting error"
			}
			ixNet commit
			set interface($int) $hInt	
		}
	}	
}

class Ospfv2Session {
	inherit OspfSession

    constructor { port { pHandle null }  } { chain $port } {
		set tag "body Ospfv2Session::ctor [info script]"
Deputs "----- TAG: $tag -----"
        
		#-- add ospf protocol
        if { $pHandle != "null"  } {
            set handle $pHandle
          
			set hInt_List [ ixNet getL $handle interface ]
            foreach hInt $hInt_List {
			    set int [ixNet getA $hInt -interfaces ]
			
			    set interface($int) $hInt	
		    }
        } else {
            set handle [ ixNet add $hPort/protocols/ospf router ]
            ixNet setA $handle -Enabled True
            ixNet commit
            set handle [ ixNet remapIds $handle ]
            ixNet setA $handle -name $this
            
            generate_interface
        }
    }
	
	method get_status {} {}
	method get_stats {} {}
    method get_fh_stats {} {}
}

class Ospfv3Session {
	inherit OspfSession
	
    constructor { port } { chain $port } {
		set tag "body Ospfv3Session::ctor [info script]"
Deputs "----- TAG: $tag -----"
	    
	    if {[ixNet getA $hPort/protocols/ospf -enabled]} {
		    ixNet setM $hPort/protocols/ospf -enabled False
	    }	    
	    
	   ixNet setM $hPort/protocols/ospfV3 -enabled True
	   ixNet commit 
	    
		#-- add ospf protocol
		set handle [ ixNet add $hPort/protocols/ospfV3 router ]
		ixNet setA $handle -Enabled True
		ixNet commit
		set handle [ ixNet remapIds $handle ]
		ixNet setA $handle -name $this
		
		generate_interface
    }

	method config { agrs } {}
	method get_status {} {}
	method get_stats {} {}
}

class SimulatedSummaryRoute {
	inherit NetObject
	
    constructor { router } {
		global errNumber
	    
		set tag "body SimulatedSummaryRoute::ctor [info script]"
Deputs "----- TAG: $tag -----"

		set routerObj [ GetObject $router ]
		if { [ catch {
			set hRouter   [ $routerObj cget -handle ]
		} ] } {
			error "$errNumber(1) Router Object in SimulatedSummaryRoute ctor"
		}
		
		set hRouteRange [ixNet add $hRouter routeRange]
		ixNet commit
		
		set handle [ ixNet remapIds $hRouteRange ]
		ixNet setA $handle -enalbed True
		ixNet commit
		
		set trafficObj $handle
	}
		
	method config { args } {}
	
}

class SimulatedInterAreaRoute {
	inherit NetObject
	
    constructor { router } {
		global errNumber
	    
		set tag "body SimulatedSummaryRoute::ctor [info script]"
Deputs "----- TAG: $tag -----"

		set routerObj [ GetObject $router ]
		if { [ catch {
			set hRouter   [ $routerObj cget -handle ]
		} ] } {
			error "$errNumber(1) Router Object in SimulatedSummaryRoute ctor"
		}
		
		set hRouteRange [ixNet add $hRouter routeRange]
		ixNet commit
		
		set handle [ ixNet remapIds $hRouteRange ]
		ixNet setA $handle -enalbed True
		ixNet commit
		
		set trafficObj $handle
	}
	
	
	method config { args } {}
	
}

class SimulatedLink {
	inherit NetObject
	
    constructor { router } {
		global errNumber
	    
		set tag "body SimulatedSummaryRoute::ctor [info script]"
Deputs "----- TAG: $tag -----"

		set routerObj [ GetObject $router ]
		if { [ catch {
			set hRouter   [ $routerObj cget -handle ]
		} ] } {
			error "$errNumber(1) Router Object in SimulatedSummaryRoute ctor"
		}
		
		set hRouteRange [ixNet add $hRouter routeRange]
		ixNet commit
		
		set handle [ ixNet remapIds $hRouteRange ]
		ixNet setA $handle -enalbed True
		ixNet commit
		
		set trafficObj $handle
	}
	method config { args } {}
}

class SimulatedRouter {
	inherit NetObject

	public variable hUserlsagroup
	public variable hUserlsa
    constructor { router } {
		global errNumber
	    
		set tag "body SimulatedSummaryRoute::ctor [info script]"
Deputs "----- TAG: $tag -----"

		set routerObj [ GetObject $router ]
		if { [ catch {
			set hRouter   [ $routerObj cget -handle ]
		} ] } {
			error "$errNumber(1) Router Object in SimulatedSummaryRoute ctor"
		}
Deputs "hRouter is: $hRouter"
		set hUserlsagroup [ixNet add $hRouter userLsaGroup]
		ixNet commit
		
		set hUserlsagroup [ ixNet remapIds $hUserlsagroup ]
		ixNet setA $hUserlsagroup -enalbed True
		ixNet commit
	    
	    set hUserlsa [ixNet add $hUserlsagroup userLsa]
	    ixNet commit
	    
	    set hUserlsa [ ixNet remapIds $hUserlsa ]
	    ixNet setA $hUserlsa -enalbed True
	    ixNet commit
		
		set trafficObj $hUserlsa
	}
	method config { args } {}
}

class SimulatedNssaRoute {
	inherit NetObject
	
    constructor { router } {
		global errNumber
	    
		set tag "body SimulatedSummaryRoute::ctor [info script]"
Deputs "----- TAG: $tag -----"

		set routerObj [ GetObject $router ]
		if { [ catch {
			set hRouter   [ $routerObj cget -handle ]
		} ] } {
			error "$errNumber(1) Router Object in SimulatedSummaryRoute ctor"
		}
		
		set hRouteRange [ixNet add $hRouter routeRange]
		ixNet commit
		
		set handle [ ixNet remapIds $hRouteRange ]
		ixNet setA $handle -enalbed True
		ixNet commit
		
		set trafficObj $handle
	}
	method config { args } {}
}

class SimulatedExternalRoute {
	inherit NetObject
	
    constructor { router } {
		global errNumber
	    
		set tag "body SimulatedSummaryRoute::ctor [info script]"
Deputs "----- TAG: $tag -----"

		set routerObj [ GetObject $router ]
		if { [ catch {
			set hRouter   [ $routerObj cget -handle ]
		} ] } {
			error "$errNumber(1) Router Object in SimulatedSummaryRoute ctor"
		}
		
		set hRouteRange [ixNet add $hRouter routeRange]
		ixNet commit
		
		set handle [ ixNet remapIds $hRouteRange ]
		ixNet setA $handle -enalbed True
		ixNet commit
		
		set trafficObj $handle
	}
	method config { args } {}
}

class SimulatedLinkRoute {
	inherit NetObject
	
    constructor { router } {
		global errNumber
	    
		set tag "body SimulatedSummaryRoute::ctor [info script]"
Deputs "----- TAG: $tag -----"

		set routerObj [ GetObject $router ]
		if { [ catch {
			set hRouter   [ $routerObj cget -handle ]
		} ] } {
			error "$errNumber(1) Router Object in SimulatedSummaryRoute ctor"
		}
		
		set hRouteRange [ixNet add $hRouter routeRange]
		ixNet commit
		
		set handle [ ixNet remapIds $hRouteRange ]
		ixNet setA $handle -enalbed True
		ixNet commit
		
		set trafficObj $handle
	}
	method config { args } {}
}

class SimulatedIntraAreaRoute {
	inherit NetObject
	
    constructor { router } {
		global errNumber
	    
		set tag "body SimulatedSummaryRoute::ctor [info script]"
Deputs "----- TAG: $tag -----"

		set routerObj [ GetObject $router ]
		if { [ catch {
			set hRouter   [ $routerObj cget -handle ]
		} ] } {
			error "$errNumber(1) Router Object in SimulatedSummaryRoute ctor"
		}
		
		set hRouteRange [ixNet add $hRouter routeRange]
		ixNet commit
		
		set handle [ ixNet remapIds $hRouteRange ]
		ixNet setA $handle -enalbed True
		ixNet commit
		
		set trafficObj $handle
	}
	method config { args } {}
}

body OspfSession::config { args } {
	
    global errorInfo
    global errNumber
	set area_id "0.0.0.0"
	set hello_interval 10
	set if_cost 1
	set network_type "broadcast"
	set options "v6bit | rbit | ebit"
	set router_dead_interval 40
	
	set ipv6_addr 3ffe:3210::2
	set ipv6_prefix_len 64
	set ipv6_gw 3ffe:3210::1
	set intf_num 1
	set active 0
	
    set tag "body OspfSession::config [info script]"
Deputs "----- TAG: $tag -----"
	
#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
			-ospf_id -
            -router_id {
				set router_id $value
			}
			-area_id {			
				set area_id $value
			}
			-hello_interval {
				set hello_interval $value
			}
			-if_cost {
				set if_cost $value
			}
			-network_type {
				set value [string toupper $value]
				set network_type $value
			}
			-options {
				set options $value
			}
		    -option {
				set option $value
			}
		    -router_dead_interval -
			-dead_interval {
				set dead_interval $value
			}
			-retransmit_interval {
				set retransmit_interval $value
			}
			-router_pri -
			-priority {
				set priority $value
			}
		   -ipv6_addr {
				 set ipv6_addr $value
			 }
			-graceful_restart {
				set graceful_restart $value
			}
			-authentication {
				set authentication $value
			}
			-md5_keyid {
				set md5_keyid $value
			}
			-password {
				set password $value
			}
			-active {
				set active $value
			}
        }
    }
	ixNet setA $handle -enabled True
	puts "handle:$handle"
	if { [ info exists graceful_restart ] } {
		if { $graceful_restart } {
			ixNet setA $handle -gracefulRestart true
		} else {
			ixNet setA $handle -gracefulRestart false
		}
		ixNet commit
	}
	if { [ info exists router_id ] } {
		ixNet setA $handle -routerId $router_id
		ixNet commit
	}	
	if { [ info exists area_id ] } {
		# if {[ixNet getA $hPort/protocols/ospf -enabled]} {
			# set attri "-areaId"
		# } elseif {[ixNet getA $hPort/protocols/ospfV3 -enabled]} {
			# set attri "-area"
		# } else {
			# error "area id setting error"
		# }
		set id_hex [IP2Hex $area_id]			
		set area_id [format %i 0x$id_hex]
		puts "interface:$interface"
		set interface [ixNet getL $handle interface]
		ixNet setA $interface -areaId $area_id
		#ixNet setA $interface -area $area_id
		ixNet commit
	}
	if { [ info exists hello_interval ] } {
		set interface [ixNet getL $handle interface]
		ixNet setA $interface -helloInterval $hello_interval	
		ixNet commit
	}
	if { [ info exists if_cost ] } {
		# if {[ixNet getA $hPort/protocols/ospf -enabled]} {
			# set attri "-metric"
		# } elseif {[ixNet getA $hPort/protocols/ospfV3 -enabled]} {
			# set attri "-linkMetric"
		# } else {
			# error "metric setting error"
		# }		
		set interface [ixNet getL $handle interface]
		ixNet setA $interface -metric $if_cost
		#ixNet setA $interface -linkMetric $if_cost
		ixNet commit
	}
	
	# v3 -interfaceType pointToPoint, -interfaceType broadcast
	# v2 -networkType pointToPoint, -networkType broadcast, -networkType pointToMultipoint
	if { [ info exists network_type ] } {
	
		switch $network_type {
		
			NATIVE {
				set network_type pointToMultipoint
			}
			BROADCAST {
				set network_type broadcast
			}
			P2P {
				set network_type pointToPoint
			}
		}
		# if {[ixNet getA $hPort/protocols/ospf -enabled]} {
			# set attri "-networkType"
		# } elseif {[ixNet getA $hPort/protocols/ospfV3 -enabled]} {
			# set attri "-interfaceType"
		# } else {
			# error "network type setting error"
		# }
		puts "networktype:$network_type"
		set interface [ixNet getL $handle interface]
		ixNet setA $interface -networkType $network_type
		#ixNet setA $interface -interfaceType $network_type
		ixNet commit
	}
	
	# v3 -routerOptions
	# v2 -options
	if { [ info exists options ] } { 
		set options [split $options |]
			 
		if {[string match *dcbit* $options]} {
		set dcbit 1
		} else {
			set dcbit 0
		}
		if {[string match *rbit* $options]} {
			set rbit 1
		} else {
			set rbit 0
		}
		if {[string match *nbit* $options]} {
			set nbit 1
		} else {
			set nbit 0
		}
		if {[string match *mcbit* $options]} {
			set mcbit 1
		} else {
			set mcbit 0
		}
		if {[string match *ebit* $options]} {
			set ebit 1
		} else {
			set ebit 0
		}
		if {[string match *v6bit* $options]} {
			set v6bit 1
		} else {
			set v6bit 0
		}
		set opt_val "00$dcbit$rbit$nbit$mcbit$ebit$v6bit"
		set opt_val [BinToDec $opt_val]
#		 set opt_val [Int2Hex $opt_val]	
		set interface [ixNet getL $handle interface]
		ixNet setA $interface -routerOptions $opt_val
		ixNet commit
	}
	
	if { [ info exists dead_interval ] } {
		set interface [ixNet getL $handle interface]
		puts "interface:$interface"
		ixNet setA $interface -deadInterval $dead_interval
		ixNet commit
	}
	
	# v3 
	# v2 -lsaRetransmitTime
	if { [ info exists retransmit_interval ] } {
		set interface [ixNet getL $handle interface]
		puts "interface:$interface"
		ixNet setA $interface -lsaRetransmitTime $retransmit_interval
		ixNet commit
	}
	if { [ info exists priority ] } {
		set interface [ixNet getL $handle interface]
		puts "interface:$interface"
		ixNet setA $interface -priority $priority
		ixNet commit
	}
	if { [ info exists authentication ] } {
		set interface [ixNet getL $handle interface]
		if { $authentication == "md5" } {
			ixNet setM $interface -authenticationMethods md5 
				-md5AuthenticationKeyId $md5_keyid
        }
		if { $authentication == "simple" } {
			ixNet setM $interface -authenticationMethods password \
				-authenticationPassword $password
        }
	}
	if { [ info exists option ] } {
		switch  $option {
			1 {
				set opt 1
			}
			2 {
				set opt 2
			}
			3 {
				set opt 3
			}
			4 {
				set opt 4
			}
			5 {
				set opt 5
			}
			6 {
				set opt 6
			}
			7 {
				set opt 7
			}
			8 {
				set opt 0
			}
		}
		set interface [ixNet getL $handle interface]
		ixNet setA $interface -options $opt
		ixNet commit
	}
	if { [ info exists active ] } {
		if { $active } {
			ixNet setA $handle -enabled true
		} else {
			ixNet setA $handle -enabled false
		} 
	}
	ixNet commit
    return [GetStandardReturnHeader]
	
}
body OspfSession::set_route { args } {

    global errorInfo
    global errNumber
    set tag "body OspfSession::set_route [info script]"
Deputs "----- TAG: $tag -----"

#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -route_block {
            	set route_block $value
            }
			-origin {
				set origin $value
			}
        }
    }
	
	if { [ info exists route_block ] } {
	
		foreach rb $route_block {
			set num 		[ $rb cget -num ]
			set step 		[ $rb cget -step ]
			set prefix_len 	[ $rb cget -prefix_len ]
			set start 		[ $rb cget -start ]
			set active      [ $rb cget -active]	
			set metric_lsa  [ $rb cget -metric_lsa]
			if { [lsearch $routeBlock(obj) $rb] == -1 } {
			    set hRouteBlock [ ixNet add $handle routeRange ]
				ixNet commit
				set hRouteBlock [ ixNet remapIds $hRouteBlock ]
				$rb setHandle $hRouteBlock
				set routeBlock($rb,handle) $hRouteBlock
				lappend routeBlock(obj) $rb
			} else {
			    set hRouteBlock $routeBlock($rb,handle)
				$rb setHandle $hRouteBlock
			}			
		puts "hRouteBlock: $hRouteBlock"	
		puts "$num; $start; $prefix_len; $step"
			ixNet setM $hRouteBlock \
				-numberOfRoutes $num \
				-origin $origin \
				-networkNumber $start \
				-mask $prefix_len \
				-enabled $active \
				-metric $metric_lsa
			ixNet commit
		}
	}
	
    return [GetStandardReturnHeader]
	

}
body SimulatedSummaryRoute::config { args } {
    global errorInfo
    global errNumber
    set tag "body SimulatedSummaryRoute::config [info script]"
Deputs "----- TAG: $tag -----"

#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            
            -age {
				set age $value
            }            
			-checksum {
				set checksum $value
            }
            -metric {
				set metric $value
            }            
			-route_block {
				set route_block $value
            }

        }
    }
	
	if { [ info exists metric ] } {
		ixNet setA $handle -metric $metric
	}
	
	if { [ info exists route_block ] } {
	
		set routeBlock [ GetObject $route_block ]
		$route_block configure -handle $handle
		
		if { $routeBlock == "" } {
		
			return [GetErrorReturnHeader "No object found...-route_block"]
			
		}
		
		set num 		[ $routeBlock cget -num ]
		set start 		[ $routeBlock cget -start ]
		set step		[ $routeBlock cget -step ]
		set prefix_len	[ $routeBlock cget -prefix_len ]
		
		ixNet setM $handle \
			-mask $prefix_len \
			-firstRoute $start \
			-numberOfRoutes $num \
			-step $step
#		-enabled True
		
	} else {
	
		return [GetErrorReturnHeader "Madatory parameter needed...-route_block"]
	}
	
	ixNet commit
	
    return [GetStandardReturnHeader]
	
}

body OspfSession::advertise_topo {} {

	set tag "body OspfSession::advertise_topo [info script]"
Deputs "----- TAG: $tag -----"

	foreach route [ ixNet getL $handle routeRange ] {
	
		ixNet setA $route -enabled True
	}
	ixNet setA $hNetworkRange -enabled True
	ixNet commit
    return [GetStandardReturnHeader]
}

body OspfSession::withdraw_topo {} {

	set tag "body OspfSession::withdraw_topo [info script]"
Deputs "----- TAG: $tag -----"

	foreach route [ ixNet getL $handle routeRange ] {
	
		ixNet setA $route -enabled False
	}
	
	ixNet setA $hNetworkRange -enabled False
	ixNet commit
    return [GetStandardReturnHeader]
}

body OspfSession::flapping_topo { args } {

	set tag "body OspfSession::flapping_topo [info script]"
Deputs "----- TAG: $tag -----"


    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
		
			-times {
				set times $value
			}
			-interval {
				set interval $value
			}
		}
	}
	
	for { set index 0 } { $index < $times } { incr index } {
		foreach route [ ixNet getL $handle routeRange ] {
		
			ixNet setA $route -enabled True
		}
		ixNet commit
		
		after [ expr $interval * 1000 ]
		
		foreach route [ ixNet getL $handle routeRange ] {
		
			ixNet setA $route -enabled False
		}
		ixNet commit
		
	}
	
	ixNet commit
    return [GetStandardReturnHeader]
}

body Ospfv2Session::get_status {} {

	set tag "body OspfSession::get_status [info script]"
Deputs "----- TAG: $tag -----"

    set root [ixNet getRoot]
Deputs "root $root"
	if {[ixNet getA $hPort/protocols/ospf -enabled]} {
		set view {::ixNet::OBJ-/statistics/view:"OSPF Aggregated Statistics"}
	} elseif {[ixNet getA $hPort/protocols/ospfV3 -enabled]} {
		set view {::ixNet::OBJ-/statistics/view:"OSPFv3 Aggregated Statistics"}
	} else {
		error "No ospf or ospfv3 aggregated statistics"
	}
#    set view {::ixNet::OBJ-/statistics/view:"OSPF Aggregated Statistics"}
    set captionList         [ ixNet getA $view/page -columnCaptions ]
	
    set name_index        		[ lsearch -exact $captionList {Stat Name} ]
	set down_index 				[ lsearch -exact $captionList {Down State Count} ]
    set attempt_index      		[ lsearch -exact $captionList {Attempt State Count} ]
	set init_index 				[ lsearch -exact $captionList {Init State Count} ]
	set twoway_index 			[ lsearch -exact $captionList {TwoWay State Count} ]
	set exstart_index			[ lsearch -exact $captionList {ExStart State Count} ]
	set exchange_index			[ lsearch -exact $captionList {Exchange State Count} ]
	set loading_index			[ lsearch -exact $captionList {Loading State Count} ]
	set full_index				[ lsearch -exact $captionList {Full State Count} ]
	
	set stats [ ixNet getA $view/page -rowValues ]
Deputs "stats:$stats"
    set portFound 0
    foreach row $stats {
        eval {set row} $row
Deputs "row:$row"
Deputs "port index:$name_index"
        set rowPortName [ lindex $row $name_index ]
Deputs "row port name:$name_index"
    set connectionInfo [ ixNet getA $hPort -connectionInfo ]
Deputs "connectionInfo :$connectionInfo"
    regexp -nocase {chassis=\"([0-9\.]+)\" card=\"([0-9\.]+)\" port=\"([0-9\.]+)\"} $connectionInfo match chassis card port
Deputs "chas:$chassis card:$card port$port"
	set portName ${chassis}/Card${card}/Port${port}
Deputs "filter name: $portName"
        if { [ regexp $portName $rowPortName ] } {
            set portFound 1
            break
        }
    }	
	

	set status "down"

	# down、attempt、init、two_ways、exstart、exchange、loading、full	
    if { $portFound } {
		set down    	[ lindex $row $down_index ]
		set attempt    	[ lindex $row $attempt_index ]
		set init    	[ lindex $row $init_index ]
		set twoway    	[ lindex $row $twoway_index ]
		set exstart     [ lindex $row $exstart_index ]
		set exchange    [ lindex $row $exchange_index ]
		set loading     [ lindex $row $loading_index ]
		set full    	[ lindex $row $full_index ]
		if { $down } {
			set status "down"
		}
		if { $attempt } {
			set status "attempt"
		}
		if { $init } {
			set status "init"
		}
		if { $twoways } {
			set status "two_ways"
		}
		if { $exstart } {
			set status "exstart"
		}
		if { $exchange } {
			set status "exchange"
		}
		if { $loading } {
			set status "loading"
		}
		if { $full } {
			set status "full"
		}
		
	}	
	
    set ret [ GetStandardReturnHeader ]
    set ret $ret[ GetStandardReturnBody "status" $status ]
	return $ret
	
}

body Ospfv2Session::get_stats {} {
	set tag "body OspfSession::get_status [info script]"
Deputs "----- TAG: $tag -----"

    set root [ixNet getRoot]
Deputs "root $root"
    set view {::ixNet::OBJ-/statistics/view:"OSPF Aggregated Statistics"}
    set captionList         [ ixNet getA $view/page -columnCaptions ]

	# {LSAs Acknowledged} 
	# {LSA Acknowledges Rx} 
	# {SummaryASLSA Tx} 
	# {SummaryASLSA Rx} 
	# {OpaqueLocalLSA Tx} 
	# {OpaqueLocalLSA Rx} 
	# {OpaqueAreaLSA Tx} 
	# {OpaqueAreaLSA Rx} 
	# {OpaqueDomainLSA Tx} 
	# {OpaqueDomainLSA Rx} 
	# {GraceLSA Rx} 
	# {HelperMode Attempted} 
	# {HelperMode Failed} 
	# {Rate Control Blocked Flood LSUpdate}
	
	# rx_te_lsa
	# tx_te_lsa
	
    set name_index        		[ lsearch -exact $captionList {Stat Name} ]
    set rx_ack_index          	[ lsearch -exact $captionList {LS Ack Rx} ]
    set tx_ack_index          	[ lsearch -exact $captionList {LS Ack Tx} ]
	set rx_dd_index				[ lsearch -exact $captionList {DBD Rx} ]
	set tx_dd_index				[ lsearch -exact $captionList {DBD Tx} ]
	set rx_hello_index			[ lsearch -exact $captionList {Hellos Rx} ]
	set tx_hello_index			[ lsearch -exact $captionList {Hellos Tx} ]
	set rx_network_lsa_index	[ lsearch -exact $captionList {NetworkLSA Rx} ]
	set tx_network_lsa_index	[ lsearch -exact $captionList {NetworkLSA Tx} ]
	set rx_nssa_lsa_index		[ lsearch -exact $captionList {NSSALSA Rx} ]
	set tx_nssa_lsa_index		[ lsearch -exact $captionList {NSSALSA Tx} ]
	set rx_request_index		[ lsearch -exact $captionList {LS Request Rx} ]
	set tx_request_index		[ lsearch -exact $captionList {LS Request Tx} ]
	set rx_router_lsa_index		[ lsearch -exact $captionList {RouterLSA Rx} ]
	set tx_router_lsa_index		[ lsearch -exact $captionList {RouterLSA Tx} ]
	set rx_summary_lsa_index	[ lsearch -exact $captionList {SummaryIPLSA Rx} ]
	set tx_summary_lsa_index	[ lsearch -exact $captionList {SummaryIPLSA Tx} ]
	set rx_as_external_lsa_index 	[ lsearch -exact $captionList {ExternalLSA Rx} ]
	set tx_as_external_lsa_index 	[ lsearch -exact $captionList {ExternalLSA Tx} ]
    set rx_asbr_summary_lsa_index 	[ lsearch -exact $captionList  {LinkState Advertisement Rx}  ]
    set tx_asbr_summary_lsa_index 	[ lsearch -exact $captionList  {LinkState Advertisement Tx}  ]
    set rx_update_index	 		[ lsearch -exact $captionList  {LS Update Rx}  ]
    set tx_update_index	 		[ lsearch -exact $captionList  {LS Update Tx}  ]

	set stats [ ixNet getA $view/page -rowValues ]
Deputs "stats:$stats"
    set portFound 0
    foreach row $stats {
        eval {set row} $row
Deputs "row:$row"
Deputs "port index:$name_index"
        set rowPortName [ lindex $row $name_index ]
Deputs "row port name:$name_index"
    set connectionInfo [ ixNet getA $hPort -connectionInfo ]
Deputs "connectionInfo :$connectionInfo"
    regexp -nocase {chassis=\"([0-9\.]+)\" card=\"([0-9\.]+)\" port=\"([0-9\.]+)\"} $connectionInfo match chassis card port
Deputs "chas:$chassis card:$card port$port"
	set portName ${chassis}/Card${card}/Port${port}
Deputs "filter name: $portName"
        if { [ regexp $portName $rowPortName ] } {
            set portFound 1
            break
        }
    }	
	


    set ret "Status : true\nLog : \n"
    
    if { $portFound } {
        set statsItem   "rx_ack"
		set statsVal    [ lindex $row $rx_ack_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "tx_ack"
		set statsVal    [ lindex $row $tx_ack_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

        set statsItem   "rx_dd"
		set statsVal    [ lindex $row $rx_dd_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "tx_dd"
		set statsVal    [ lindex $row $tx_dd_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "rx_hello"
		set statsVal    [ lindex $row $rx_hello_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "tx_hello"
		set statsVal    [ lindex $row $tx_hello_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "rx_network_lsa"
		set statsVal    [ lindex $row $rx_network_lsa_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "tx_network_lsa"
		set statsVal    [ lindex $row $tx_network_lsa_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "rx_nssa_lsa"
		set statsVal    [ lindex $row $rx_nssa_lsa_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "tx_nssa_lsa"
		set statsVal    [ lindex $row $tx_nssa_lsa_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "rx_request"
		set statsVal    [ lindex $row $rx_request_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "tx_request"
		set statsVal    [ lindex $row $tx_request_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "rx_router_lsa"
		set statsVal    [ lindex $row $rx_router_lsa_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "tx_router_lsa"
		set statsVal    [ lindex $row $tx_router_lsa_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "rx_summary_lsa"
		set statsVal    [ lindex $row $rx_summary_lsa_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "tx_summary_lsa"
		set statsVal    [ lindex $row $tx_summary_lsa_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "rx_as_external_lsa"
		set statsVal    [ lindex $row $rx_as_external_lsa_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "tx_as_external_lsa"
		set statsVal    [ lindex $row $tx_as_external_lsa_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "rx_asbr_summary_lsa"
		set statsVal    [ lindex $row $rx_asbr_summary_lsa_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "tx_asbr_summary_lsa"
		set statsVal    [ lindex $row $tx_asbr_summary_lsa_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "rx_update"
		set statsVal    [ lindex $row $rx_update_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "tx_update"
		set statsVal    [ lindex $row $tx_update_index ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "rx_te_lsa"
		set statsVal    "NA"
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        set statsItem   "tx_te_lsa"
		set statsVal    "NA"
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
        
        
    }

Deputs "ret:$ret"
	
    return $ret
	
}

body Ospfv2Session::get_fh_stats {} {
	set tag "body OspfSession::get_fh_status [info script]"
Deputs "----- TAG: $tag -----"

    set root [ixNet getRoot]
Deputs "root $root"
    set view {::ixNet::OBJ-/statistics/view:"OSPF Aggregated Statistics"}
    set captionList         [ ixNet getA $view/page -columnCaptions ]

	
	
    set name_index        		    [ lsearch -exact $captionList {Stat Name} ]
    set rx_ack_index          	    [ lsearch -exact $captionList {LS Ack Rx} ]
    set tx_ack_index          	    [ lsearch -exact $captionList {LS Ack Tx} ]
	set rx_dd_index				    [ lsearch -exact $captionList {DBD Rx} ]
	set tx_dd_index				    [ lsearch -exact $captionList {DBD Tx} ]
	set rx_hello_index			    [ lsearch -exact $captionList {Hellos Rx} ]
	set tx_hello_index			    [ lsearch -exact $captionList {Hellos Tx} ]
	set rx_network_lsa_index	    [ lsearch -exact $captionList {NetworkLSA Rx} ]
	set tx_network_lsa_index	    [ lsearch -exact $captionList {NetworkLSA Tx} ]
	set rx_nssa_lsa_index		    [ lsearch -exact $captionList {NSSALSA Rx} ]
	set tx_nssa_lsa_index		    [ lsearch -exact $captionList {NSSALSA Tx} ]
	set rx_request_index		    [ lsearch -exact $captionList {LS Request Rx} ]
	set tx_request_index		    [ lsearch -exact $captionList {LS Request Tx} ]
	set rx_router_lsa_index		    [ lsearch -exact $captionList {RouterLSA Rx} ]
	set tx_router_lsa_index		    [ lsearch -exact $captionList {RouterLSA Tx} ]
	set rx_summary_lsa_index	    [ lsearch -exact $captionList {SummaryIPLSA Rx} ]
	set tx_summary_lsa_index	    [ lsearch -exact $captionList {SummaryIPLSA Tx} ]
	set rx_as_external_lsa_index 	[ lsearch -exact $captionList {ExternalLSA Rx} ]
	set tx_as_external_lsa_index 	[ lsearch -exact $captionList {ExternalLSA Tx} ]
    set rx_asbr_summary_lsa_index 	[ lsearch -exact $captionList  {LinkState Advertisement Rx}  ]
    set tx_asbr_summary_lsa_index 	[ lsearch -exact $captionList  {LinkState Advertisement Tx}  ]
    set rx_update_index	 		    [ lsearch -exact $captionList  {LS Update Rx}  ]
    set tx_update_index	 		    [ lsearch -exact $captionList  {LS Update Tx}  ]

	set stats [ ixNet getA $view/page -rowValues ]
Deputs "stats:$stats"
    set portFound 0
    foreach row $stats {
        eval {set row} $row
Deputs "row:$row"
Deputs "port index:$name_index"
        set rowPortName [ lindex $row $name_index ]
Deputs "row port name:$name_index"
    set connectionInfo [ ixNet getA $hPort -connectionInfo ]
Deputs "connectionInfo :$connectionInfo"
    regexp -nocase {chassis=\"([0-9\.]+)\" card=\"([0-9\.]+)\" port=\"([0-9\.]+)\"} $connectionInfo match chassis card port
Deputs "chas:$chassis card:$card port$port"
	set portName ${chassis}/Card${card}/Port${port}
Deputs "filter name: $portName"
        if { [ regexp $portName $rowPortName ] } {
            set portFound 1
            break
        }
    }	
	


    set ret ""
    
    if { $portFound } {
        set statsItem   "RxHello"
		set statsVal    [ lindex $row $rx_hello_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
       
        
        set statsItem   "TxHello"
		set statsVal    [ lindex $row $tx_hello_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
        
        set statsItem   "RxDd"
		set statsVal    [ lindex $row $rx_dd_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
        
        set statsItem   "TxDd"
		set statsVal    [ lindex $row $tx_dd_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
        
        set statsItem   "RxAck"
		set statsVal    [ lindex $row $rx_ack_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
        
        set statsItem   "TxAck"
		set statsVal    [ lindex $row $tx_ack_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal

        set statsItem   "RxRequest"
		set statsVal    [ lindex $row $rx_request_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
        
        set statsItem   "TxRequest"
		set statsVal    [ lindex $row $tx_request_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
        
        set statsItem   "RxUpdate"
		set statsVal    [ lindex $row $rx_update_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
        
        set statsItem   "TxUpdate"
		set statsVal    [ lindex $row $tx_update_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
        
        set statsItem   "RxRouterLsa"
		set statsVal    [ lindex $row $rx_router_lsa_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
        
        set statsItem   "TxRouterLsa"
		set statsVal    [ lindex $row $tx_router_lsa_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
      
        
        set statsItem   "RxNetworkLsa"
		set statsVal    [ lindex $row $rx_network_lsa_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
        
        set statsItem   "TxNetworkLsa"
		set statsVal    [ lindex $row $tx_network_lsa_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
        
        set statsItem   "RxSummaryLsa"
		set statsVal    [ lindex $row $rx_summary_lsa_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
        
        set statsItem   "TxSummaryLsa"
		set statsVal    [ lindex $row $tx_summary_lsa_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
        
        set statsItem   "RxAsExternalLsa"
		set statsVal    [ lindex $row $rx_as_external_lsa_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
        
        set statsItem   "TxAsExternalLsa"
		set statsVal    [ lindex $row $tx_as_external_lsa_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
        
        set statsItem   "RxNssaLsa"
		set statsVal    [ lindex $row $rx_nssa_lsa_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
        
        set statsItem   "TxNssaLsa"
		set statsVal    [ lindex $row $tx_nssa_lsa_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
               
        set statsItem   "RxAsbrSummaryLsa"
		set statsVal    [ lindex $row $rx_asbr_summary_lsa_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
        
        set statsItem   "TxAsbrSummaryLsa"
		set statsVal    [ lindex $row $tx_asbr_summary_lsa_index ]
Deputs "stats val:$statsVal"
        lappend ret $statItem $statsVal
       
        
        
    }

Deputs "ret:$ret"
	
    return $ret
	
}

body OspfSession::set_topo {args} {
	
	set tag "body OspfSession::set_topo [info script]"
Deputs "----- TAG: $tag -----"

	set hRouter $handle
	set hNetworkRange [ixNet add $hRouter networkRange]
	ixNet commit

	set hNetworkRange [ ixNet remapIds $hNetworkRange ]
	ixNet setA $hNetworkRange -enalbed True
	ixNet commit
	
	
	foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-topo {
				set topo $value
			}
		}
	}
	
	if { [ info exists topo ] } {
		
		
		if { $topo == "" || [ $topo isa Topology ] == 0 } {
			return [GetErrorReturnHeader "No valid object found...-topo $topo"]
		}
		
		set type [$topo cget -type]
		set sim_rtr_num [$topo cget -sim_rtr_num]
		set row_num [$topo cget -row_num]
		set column_num [$topo cget -column_num]
		set attach_row [$topo cget -attach_row]
		set attach_column [$topo cget -attach_column]
		
		ixNet setM $hNetworkRange \
			-numRows $row_num \
			-numCols $column_num \
			-entryRow $attach_row \
			-entryColumn $attach_column
		
	} else {
		return [GetErrorReturnHeader "Madatory parameter needed...-topo"]
	}
	ixNet commit
	
	return [GetStandardReturnHeader]
}

body OspfSession::unset_topo {} {
	
	set tag "body OspfSession::unset_topo [info script]"
Deputs "----- TAG: $tag -----"

	ixNet remove $hNetworkRange
	ixNet commit
}

body SimulatedInterAreaRoute::config { args } {
    global errorInfo
    global errNumber
    set tag "body SimulatedInterAreaRoute::config [info script]"
Deputs "----- TAG: $tag -----"

#param collection
Deputs "Args:$args "
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  
		  -age {
				set age $value
		  }            
			-checksum {
				set checksum $value
		  }
		  -metric {
				set metric $value
		  }   
		   -prefix_options {
			   set prefix_options $value
		   } 
		   -seq_num  {
			   set seq_num  $value
		   } 
			-route_block {
				set route_block $value
		  }

	   }
    }
	
	if { [ info exists metric ] } {
		ixNet setA $handle -metric $metric
	}
	
	if { [ info exists route_block ] } {
	
		set routeBlock [ GetObject $route_block ]
		$route_block configure -handle $handle
		
		if { $routeBlock == "" } {
		
			return [GetErrorReturnHeader "No object found...-route_block"]
			
		}
		
		set num 		[ $routeBlock cget -num ]
		set start 		[ $routeBlock cget -start ]
		set step		[ $routeBlock cget -step ]
		set prefix_len	[ $routeBlock cget -prefix_len ]
		
		ixNet setM $handle \
		-numberOfRoutes $num \
		-firstRoute $start \
		-step $step \
		-mask $prefix_len 
		
	} else {
	
		return [GetErrorReturnHeader "Madatory parameter needed...-route_block"]
	}
	
	ixNet commit
	
    return [GetStandardReturnHeader]
	
}

body Ospfv3Session::get_status {} {

	set tag "body Ospfv3Session::get_status [info script]"
Deputs "----- TAG: $tag -----"

    set root [ixNet getRoot]
Deputs "root $root"
    set view {::ixNet::OBJ-/statistics/view:"OSPFv3 Aggregated Statistics"}
	after 5000
    set captionList         [ ixNet getA $view/page -columnCaptions ]
	
    set name_index        		[ lsearch -exact $captionList {Stat Name} ]
	set down_index 				[ lsearch -exact $captionList {Down State Count} ]
    set attempt_index      		[ lsearch -exact $captionList {Attempt State Count} ]
	set init_index 				[ lsearch -exact $captionList {Init State Count} ]
	set twoway_index 			[ lsearch -exact $captionList {TwoWay State Count} ]
	set exstart_index			[ lsearch -exact $captionList {ExStart State Count} ]
	set exchange_index			[ lsearch -exact $captionList {Exchange State Count} ]
	set loading_index			[ lsearch -exact $captionList {Loading State Count} ]
	set full_index				[ lsearch -exact $captionList {Full State Count} ]
	
	set stats [ ixNet getA $view/page -rowValues ]
Deputs "stats:$stats"
    set portFound 0
    foreach row $stats {
	   eval {set row} $row
Deputs "row:$row"
Deputs "port index:$name_index"
	   set rowPortName [ lindex $row $name_index ]
Deputs "row port name:$name_index"
    set connectionInfo [ ixNet getA $hPort -connectionInfo ]
Deputs "connectionInfo :$connectionInfo"
    regexp -nocase {chassis=\"([0-9\.]+)\" card=\"([0-9\.]+)\" port=\"([0-9\.]+)\"} $connectionInfo match chassis card port
Deputs "chas:$chassis card:$card port$port"
	set portName ${chassis}/Card${card}/Port${port}
Deputs "filter name: $portName"
	   if { [ regexp $portName $rowPortName ] } {
		  set portFound 1
		  break
	   }
    }	
	

	set status "down"

	# down、attempt、init、two_ways、exstart、exchange、loading、full	
    if { $portFound } {
		set down    	[ lindex $row $down_index ]
		set attempt    	[ lindex $row $attempt_index ]
		set init    	[ lindex $row $init_index ]
		set twoway    	[ lindex $row $twoway_index ]
		set exstart     [ lindex $row $exstart_index ]
		set exchange    [ lindex $row $exchange_index ]
		set loading     [ lindex $row $loading_index ]
		set full    	[ lindex $row $full_index ]
		if { $down } {
			set status "down"
		}
		if { $attempt } {
			set status "attempt"
		}
		if { $init } {
			set status "init"
		}
		if { $twoways } {
			set status "two_ways"
		}
		if { $exstart } {
			set status "exstart"
		}
		if { $exchange } {
			set status "exchange"
		}
		if { $loading } {
			set status "loading"
		}
		if { $full } {
			set status "full"
		}
		
	}	
	
    set ret [ GetStandardReturnHeader ]
    set ret $ret[ GetStandardReturnBody "status" $status ]
	return $ret
	
}

body Ospfv3Session::get_stats {} {
	set tag "body Ospfv3Session::get_status [info script]"
Deputs "----- TAG: $tag -----"

    set root [ixNet getRoot]
Deputs "root $root"
    set view {::ixNet::OBJ-/statistics/view:"OSPFv3 Aggregated Statistics"}
	after 5000
    set captionList         [ ixNet getA $view/page -columnCaptions ]
	
    set name_index        		[ lsearch -exact $captionList {Stat Name} ]
    set rx_ack_index          	[ lsearch -exact $captionList {LS Ack Rx} ]
    set tx_ack_index          	[ lsearch -exact $captionList {LS Ack Tx} ]
	set rx_dd_index				[ lsearch -exact $captionList {DBD Rx} ]
	set tx_dd_index				[ lsearch -exact $captionList {DBD Tx} ]
	set rx_hello_index			[ lsearch -exact $captionList {Hellos Rx} ]
	set tx_hello_index			[ lsearch -exact $captionList {Hellos Tx} ]
	set rx_network_lsa_index	[ lsearch -exact $captionList {NetworkLSA Rx} ]
	set tx_network_lsa_index	[ lsearch -exact $captionList {NetworkLSA Tx} ]
	set rx_nssa_lsa_index		[ lsearch -exact $captionList {NSSALSA Rx} ]
	set tx_nssa_lsa_index		[ lsearch -exact $captionList {NSSALSA Tx} ]
	set rx_request_index		[ lsearch -exact $captionList {LS Request Rx} ]
	set tx_request_index		[ lsearch -exact $captionList {LS Request Tx} ]
	set rx_router_lsa_index		[ lsearch -exact $captionList {RouterLSA Rx} ]
	set tx_router_lsa_index		[ lsearch -exact $captionList {RouterLSA Tx} ]
	set rx_as_external_lsa_index 	[ lsearch -exact $captionList {ExternalLSA Rx} ]
	set tx_as_external_lsa_index 	[ lsearch -exact $captionList {ExternalLSA Tx} ]
	set rx_update_index	 		[ lsearch -exact $captionList  {LS Update Rx}  ]
	set tx_update_index	 		[ lsearch -exact $captionList  {LS Update Tx}  ]
	
    set rx_inter_area_prefix_lsa_index 	[ lsearch -exact $captionList  {InterareaPrefixLSA Rx}  ]
    set tx_inter_area_prefix_lsa_index 	[ lsearch -exact $captionList  {InterareaPrefixLSA Tx}  ]
	set rx_inter_area_router_lsa_index	[ lsearch -exact $captionList {InterareaRouterLSA Rx} ]
	set tx_inter_area_router_lsa_index	[ lsearch -exact $captionList {InterareaRouterLSA Tx} ]
	set rx_intra_area_prefix_lsa_index	[ lsearch -exact $captionList {IntraareaPrefixLSA Rx} ]
	set tx_intra_area_prefix_lsa_index	[ lsearch -exact $captionList {InterareaPrefixLSA Tx} ]
	set rx_link_lsa_index	[ lsearch -exact $captionList {LinkLSA Rx} ]
	set tx_link_lsa_index	[ lsearch -exact $captionList {LinkLSA Tx} ]


	set stats [ ixNet getA $view/page -rowValues ]
Deputs "stats:$stats"
    set portFound 0
    foreach row $stats {
	   eval {set row} $row
Deputs "row:$row"
Deputs "port index:$name_index"
	   set rowPortName [ lindex $row $name_index ]
Deputs "row port name:$name_index"
    set connectionInfo [ ixNet getA $hPort -connectionInfo ]
Deputs "connectionInfo :$connectionInfo"
    regexp -nocase {chassis=\"([0-9\.]+)\" card=\"([0-9\.]+)\" port=\"([0-9\.]+)\"} $connectionInfo match chassis card port
Deputs "chas:$chassis card:$card port$port"
	set portName ${chassis}/Card${card}/Port${port}
Deputs "filter name: $portName"
	   if { [ regexp $portName $rowPortName ] } {
		  set portFound 1
		  break
	   }
    }	
	


    set ret "Status : true\nLog : \n"
    
    if { $portFound } {
	   set statsItem   "rx_ack"
		set statsVal    [ lindex $row $rx_ack_index ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "tx_ack"
		set statsVal    [ lindex $row $tx_ack_index ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]

	   set statsItem   "rx_dd"
		set statsVal    [ lindex $row $rx_dd_index ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "tx_dd"
		set statsVal    [ lindex $row $tx_dd_index ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "rx_hello"
		set statsVal    [ lindex $row $rx_hello_index ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "tx_hello"
		set statsVal    [ lindex $row $tx_hello_index ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "rx_network_lsa"
		set statsVal    [ lindex $row $rx_network_lsa_index ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "tx_network_lsa"
		set statsVal    [ lindex $row $tx_network_lsa_index ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "rx_nssa_lsa"
		set statsVal    [ lindex $row $rx_nssa_lsa_index ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "tx_nssa_lsa"
		set statsVal    [ lindex $row $tx_nssa_lsa_index ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "rx_request"
		set statsVal    [ lindex $row $rx_request_index ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "tx_request"
		set statsVal    [ lindex $row $tx_request_index ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "rx_router_lsa"
		set statsVal    [ lindex $row $rx_router_lsa_index ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "tx_router_lsa"
		set statsVal    [ lindex $row $tx_router_lsa_index ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]	   
	   
	   set statsItem   "rx_as_external_lsa"
		set statsVal    [ lindex $row $rx_as_external_lsa_index ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "tx_as_external_lsa"
		set statsVal    [ lindex $row $tx_as_external_lsa_index ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "rx_update"
		set statsVal    [ lindex $row $rx_update_index ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "tx_update"
		set statsVal    [ lindex $row $tx_update_index ]
Deputs "stats val:$statsVal"
	   set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	      
	    set statsItem   "rx_inter_area_prefix_lsa"
	    set statsVal    [ lindex $row $rx_inter_area_prefix_lsa_index ]
Deputs "stats val:$statsVal"
	  set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	   
	   set statsItem   "tx_inter_area_prefix_lsa"
	   set statsVal    [ lindex $row $tx_inter_area_prefix_lsa_index ]
Deputs "stats val:$statsVal"
	 set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	    
	    set statsItem   "rx_inter_area_router_lsa"
	    set statsVal    [ lindex $row $rx_inter_area_router_lsa_index ]
Deputs "stats val:$statsVal"
	  set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	    
	    set statsItem   "tx_inter_area_router_lsa"
	    set statsVal    [ lindex $row $tx_inter_area_router_lsa_index ]
Deputs "stats val:$statsVal"
	  set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	    
	    set statsItem   "rx_intra_area_prefix_lsa"
	    set statsVal    [ lindex $row $rx_intra_area_prefix_lsa_index ]
Deputs "stats val:$statsVal"
	  set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	    
	    set statsItem   "tx_intra_area_prefix_lsa"
	    set statsVal    [ lindex $row $tx_intra_area_prefix_lsa_index ]
Deputs "stats val:$statsVal"
	  set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	    
	    set statsItem   "rx_link_lsa"
	    set statsVal    [ lindex $row $rx_link_lsa_index ]
Deputs "stats val:$statsVal"
	  set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	    
	    set statsItem   "tx_link_lsa"
	    set statsVal    [ lindex $row $tx_link_lsa_index ]
Deputs "stats val:$statsVal"
	  set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
	    
    }

Deputs "ret:$ret"
	
    return $ret
	
}

body SimulatedRouter::config { args } {
	global errorInfo
     global errNumber
	
	set type normal
     set tag "body SimulatedRouter::config [info script]"
Deputs "----- TAG: $tag -----"

Deputs "Args:$args "
	foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-id {
				set id $value
			}            
			-type {
				set type $value
			}
		}
	}
	
	if { [ info exists id ] } {
		ixNet setA $hUserlsa -advertisingRouterId $id
	}
	
	if { [ info exists type ] } {
		switch $type {						
			abr {
				ixNet setM $hUserlsa/router -bBit True
			}
			asbr {
				ixNet setM $hUserlsa/router -eBit True								
			}	
			vl {
				ixNet setM $hUserlsa/router -vBit True
			}
			normal {
				ixNet setM $hUserlsa/router \
				-bBit False \
				-eBit False \
				-vBit False \
				-wBit False
			}
		}
	}
	
	ixNet commit
	return [GetStandardReturnHeader]
	
}

body Ospfv3Session::config { args } {
	global errorInfo
	global errNumber
	
	set ipv6_addr 3ffe:3210::2
	set ipv6_prefix_len 64
	set ipv6_gw 3ffe:3210::1
	
	set ipv6_addr_step	::1
	set outer_vlan_step	1
	set inner_vlan_step	1
	set outer_vlan_num 1
	set inner_vlan_num 1
	set outer_vlan_priority 0
	set inner_vlan_priority 0

	set count 		1
	set enabled 		True
	
	set tag "body Ospfv3Session::config [info script]"
Deputs "----- TAG: $tag -----"
	
Deputs "Args:$args "
	foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-ipv6_addr {
				set ipv6_addr $value
			}
			-ipv6_prefix_len {
				if { [ string is integer $value ] && $value <= 128 } {
					set ipv6_prefix_len $value					
				} else {
					error "$errNumber(1) key:$key value:$value"					
				}				
			}
			-ipv6_gw {
				set ipv6_gw $value
			}
			-outer_vlan_id {
				if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 4096 ) } {
					set outer_vlan_id $value
					set flagOuterVlan   1					
				} else {
					error "$errNumber(1) key:$key value:$value"					
				}
			}
			-outer_vlan_step {
				if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 4096 ) } {
					set outer_vlan_step $value
					set flagOuterVlan   1					
				} else {
					error "$errNumber(1) key:$key value:$value"					
				}				
			}
			-outer_vlan_num {
				if { [ string is integer $value ] && ( $value >= 0 ) } {
					set outer_vlan_num $value
					set flagOuterVlan   1					
				} else {
					error "$errNumber(1) key:$key value:$value"					
				}				
			}
			-outer_vlan_priority {
				if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 8 ) } {
					set outer_vlan_priority $value
					set flagOuterVlan   1					
				} else {
					error "$errNumber(1) key:$key value:$value"					
				}				
			}
			-inner_vlan_id {
				if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 4096 ) } {
					set inner_vlan_id $value
					set flagInnerVlan   1					
				} else {
					error "$errNumber(1) key:$key value:$value"					
				}				
			}
			-inner_vlan_step {
				if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 4096 ) } {
					set inner_vlan_step $value
					set flagInnerVlan   1					
				} else {
					error "$errNumber(1) key:$key value:$value"					
				}				
			}
			-inner_vlan_num {
				if { [ string is integer $value ] && ( $value >= 0 ) } {
					set inner_vlan_num $value
					set flagInnerVlan   1					
				} else {
					error "$errNumber(1) key:$key value:$value"					
				}				
			}
			-inner_vlan_priority {
				if { [ string is integer $value ] && ( $value >= 0 ) && ( $value < 8 ) } {
					set inner_vlan_priority $value
					set flagInnerVlan   1					
				} else {
					error "$errNumber(1) key:$key value:$value"					
				}				
			}
			-outer_vlan_cfi {
				set outer_vlan_cfi $value				
			}
			-inner_vlan_cfi {
				set inner_vlan_cfi $value				
			}
		}
	}
	if { [ info exists ipv6_addr ] } {
		foreach int $rb_interface {
			if { [ llength [ ixNet getList $int ipv6 ] ] == 0 } {
				set ipv6Int   [ ixNet add $int ipv6 ]				
			} else {
				set ipv6Int   [ lindex [ ixNet getList $int ipv6 ] 0 ]				
			}
			ixNet setA $ipv6Int -ip $ipv6_addr 
			ixNet setA $ipv6Int -prefixLength $ipv6_prefix_len
			ixNet setA $ipv6Int -gateway $ipv6_gw
		}
		ixNet commit
	}	
	
	if {[ info exists outer_vlan_id ]} {
		foreach int $rb_interface {
			for { set index 0 } { $index < $count } { incr index } {
				Deputs "int:$int"	
				if { [ info exists outer_vlan_id ] } {
					set vlanId $outer_vlan_id
				ixNet setM $int/vlan \
					-count 1 \
					-vlanEnable True \
					-vlanId $vlanId \
					-vlanPriority   $outer_vlan_priority
				ixNet commit
				incr outer_vlan_id $outer_vlan_step
					
				}
				if { [ info exists inner_vlan_id ] } {
					set vlanId $inner_vlan_id
					set innerPri $inner_vlan_priority
					set vlanId1	[ ixNet getA $int/vlan -vlanId ]					
					set vlanId	"${vlanId1},${vlanId}"
					
					set outerPri [ ixNet getA $int/vlan -vlanPriority]
					set Pri "${outerPri},${innerPri}"
					ixNet setM $int/vlan \
								-count 2 \
								-vlanEnable True \
								-vlanId $vlanId \
					               -vlanPriority $Pri
					ixNet commit
					incr inner_vlan_id $inner_vlan_step
					
				}
#				if { [ info exists outer_vlan_priority ] } {
#					set vlanId $outer_vlan_priority
#				ixNet setM $int/vlan \
#					-count 1 \
#				     -vlanEnable True \
#					-vlanId $vlanId
#					ixNet commit
#					incr outer_vlan_id $outer_vlan_step					
#				}
#				
#				if { [ info exists inner_vlan_id ] } {
#					set vlanId $inner_vlan_id
#					set vlanId1	[ ixNet getA $int/vlan -vlanId ]
#					set vlanId	"${vlanId1},${vlanId}"
#					ixNet setM $int/vlan \
#					-count 2 \
#					-vlanEnable True \
#					-vlanId $vlanId
#					ixNet commit
#					incr inner_vlan_id $inner_vlan_step
#					
#				}
				if { [ info exists enabled ] } {
					ixNet setA $int -enabled $enabled
					ixNet commit			
					
				}
				
			}
			
		}
	}
	
	ixNet commit
	return [GetStandardReturnHeader]
	
}

body SimulatedLink::config { args } {
    global errorInfo
    global errNumber
    set tag "body SimulatedLink::config [info script]"
Deputs "----- TAG: $tag -----"

#param collection
Deputs "Args:$args "
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  
		  -age {
				set age $value
		  }            
			-checksum {
				set checksum $value
		  }
		  -metric {
				set metric $value
		  }            
			-route_block {
				set route_block $value
		  }

	   }
    }
	
	if { [ info exists metric ] } {
		ixNet setA $handle -metric $metric
	}
	
	if { [ info exists route_block ] } {
	
		set routeBlock [ GetObject $route_block ]
		$route_block configure -handle $handle
		
		if { $routeBlock == "" } {
		
			return [GetErrorReturnHeader "No object found...-route_block"]
			
		}
		
		set num 		[ $routeBlock cget -num ]
		set start 		[ $routeBlock cget -start ]
		set step		[ $routeBlock cget -step ]
		set prefix_len	[ $routeBlock cget -prefix_len ]
		
		ixNet setM $handle \
			-mask $prefix_len \
			-firstRoute $start \
			-numberOfRoutes $num \
			-step $step
#		-enabled True
		
	} else {
	
		return [GetErrorReturnHeader "Madatory parameter needed...-route_block"]
	}
	
	ixNet commit
	
    return [GetStandardReturnHeader]
	
}

body SimulatedNssaRoute::config { args } {
    global errorInfo
    global errNumber
    set tag "body SimulatedNssaRoute::config [info script]"
Deputs "----- TAG: $tag -----"

#param collection
Deputs "Args:$args "
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  
		  -age {
				set age $value
		  }            
			-checksum {
				set checksum $value
		  }
		  -metric {
				set metric $value
		  }            
			-route_block {
				set route_block $value
		  }

	   }
    }
	
	if { [ info exists metric ] } {
		ixNet setA $handle -metric $metric
	}
	
	if { [ info exists route_block ] } {
	
		set routeBlock [ GetObject $route_block ]
		$route_block configure -handle $handle
		
		if { $routeBlock == "" } {
		
			return [GetErrorReturnHeader "No object found...-route_block"]
			
		}
		
		set num 		[ $routeBlock cget -num ]
		set start 		[ $routeBlock cget -start ]
		set step		[ $routeBlock cget -step ]
		set prefix_len	[ $routeBlock cget -prefix_len ]
		
		ixNet setM $handle \
			-mask $prefix_len \
			-firstRoute $start \
			-numberOfRoutes $num \
			-step $step
#		-enabled True
		
	} else {
	
		return [GetErrorReturnHeader "Madatory parameter needed...-route_block"]
	}
	
	ixNet commit
	
    return [GetStandardReturnHeader]
	
}

body SimulatedExternalRoute::config { args } {
    global errorInfo
    global errNumber
    set tag "body SimulatedExternalRoute::config [info script]"
Deputs "----- TAG: $tag -----"

#param collection
Deputs "Args:$args "
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  
		  -age {
				set age $value
		  }            
			-checksum {
				set checksum $value
		  }
		  -metric {
				set metric $value
		  }            
			-route_block {
				set route_block $value
		  }

	   }
    }
	
	if { [ info exists metric ] } {
		ixNet setA $handle -metric $metric
	}
	
	if { [ info exists route_block ] } {
	
		set routeBlock [ GetObject $route_block ]
		$route_block configure -handle $handle
		
		if { $routeBlock == "" } {
		
			return [GetErrorReturnHeader "No object found...-route_block"]
			
		}
		
		set num 		[ $routeBlock cget -num ]
		set start 		[ $routeBlock cget -start ]
		set step		[ $routeBlock cget -step ]
		set prefix_len	[ $routeBlock cget -prefix_len ]
		
		ixNet setM $handle \
			-mask $prefix_len \
			-firstRoute $start \
			-numberOfRoutes $num \
			-step $step
#		-enabled True
		
	} else {
	
		return [GetErrorReturnHeader "Madatory parameter needed...-route_block"]
	}
	
	ixNet commit
	
    return [GetStandardReturnHeader]
	
}

body SimulatedLinkRoute::config { args } {
    global errorInfo
    global errNumber
    set tag "body SimulatedLinkRoute::config [info script]"
Deputs "----- TAG: $tag -----"

#param collection
Deputs "Args:$args "
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  
		  -age {
				set age $value
		  }            
			-checksum {
				set checksum $value
		  }
		  -metric {
				set metric $value
		  }            
			-route_block {
				set route_block $value
		  }

	   }
    }
	
	if { [ info exists metric ] } {
		ixNet setA $handle -metric $metric
	}
	
	if { [ info exists route_block ] } {
	
		set routeBlock [ GetObject $route_block ]
		$route_block configure -handle $handle
		
		if { $routeBlock == "" } {
		
			return [GetErrorReturnHeader "No object found...-route_block"]
			
		}
		
		set num 		[ $routeBlock cget -num ]
		set start 		[ $routeBlock cget -start ]
		set step		[ $routeBlock cget -step ]
		set prefix_len	[ $routeBlock cget -prefix_len ]
		
		ixNet setM $handle \
			-mask $prefix_len \
			-firstRoute $start \
			-numberOfRoutes $num \
			-step $step
#		-enabled True
		
	} else {
	
		return [GetErrorReturnHeader "Madatory parameter needed...-route_block"]
	}
	
	ixNet commit
	
    return [GetStandardReturnHeader]
	
}

body SimulatedIntraAreaRoute::config { args } {
    global errorInfo
    global errNumber
    set tag "body SimulatedIntraAreaRoute::config [info script]"
Deputs "----- TAG: $tag -----"

#param collection
Deputs "Args:$args "
    foreach { key value } $args {
	   set key [string tolower $key]
	   switch -exact -- $key {
		  
		  -age {
				set age $value
		  }            
			-checksum {
				set checksum $value
		  }
		  -metric {
				set metric $value
		  }            
			-route_block {
				set route_block $value
		  }

	   }
    }
	
	if { [ info exists metric ] } {
		ixNet setA $handle -metric $metric
	}
	
	if { [ info exists route_block ] } {
	
		set routeBlock [ GetObject $route_block ]
		$route_block configure -handle $handle
		
		if { $routeBlock == "" } {
		
			return [GetErrorReturnHeader "No object found...-route_block"]
			
		}
		
		set num 		[ $routeBlock cget -num ]
		set start 		[ $routeBlock cget -start ]
		set step		[ $routeBlock cget -step ]
		set prefix_len	[ $routeBlock cget -prefix_len ]
		
		ixNet setM $handle \
			-mask $prefix_len \
			-firstRoute $start \
			-numberOfRoutes $num \
			-step $step
#		-enabled True
		
	} else {
	
		return [GetErrorReturnHeader "Madatory parameter needed...-route_block"]
	}
	
	ixNet commit
	
    return [GetStandardReturnHeader]
	
}