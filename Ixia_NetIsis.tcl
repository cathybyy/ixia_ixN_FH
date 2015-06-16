
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.1
#===============================================================================
# Change made
# Version 1.0 
#       1. Create

class IsisSession {
    inherit RouterEmulationObject
	public variable routeBlock	
    constructor { port { pHandle null } {hInterface null } } {}
    method reborn { {hInterface null} } {}
	method set_route { args } {}
    method config { args } {}
    method get_fh_stats {} {}
	method advertise_route { args } {}
	method withdraw_route { args } {}
	public variable mac_addr
	public variable protocolhandle
}
body IsisSession::constructor { port { pHandle null } {hInterface null} } {
    set tag "body IsisSession::constructor [info script]"
    Deputs "----- TAG: $tag -----"
	
    global errNumber
    set routeBlock(obj) ""
    #-- enable protocol
    set portObj [ GetObject $port ]
Deputs "port:$portObj"
   # if { [ catch {
   #    set hPort   [ $portObj cget -handle ]
    #Deputs "port handle: $hPort"
    #} ] } {
	 #   error "$errNumber(1) Port Object in IsisSession ctor"
    #}
Deputs "initial port..."
    if { $pHandle != "null" } {
        set handle $pHandle
       #set rb_interface  [ ixNet getL $handle interface ]
    } else {
	    reborn $hInterface
    }
Deputs "Step10"
}
body IsisSession::reborn { {hInterface null } } {
	global errNumber
    set tag "body IsisSession::reborn [info script]"
    Deputs "----- TAG: $tag -----"
	#-- add isis protocol
	if { [ catch {
		set hPort  [ $portObj cget -handle ]
		} ] } {
			error "$errNumber(1) Port Object in DhcpHost ctor"
		}
	Deputs "hPort:$hPort"
	set protocolhandle "$hPort/protocols/isis"
	ixNet setA $hPort/protocols/isis -enabled True
	set handle [ ixNet add $hPort/protocols/isis router ]
	ixNet commit
	set handle [ ixNet remapIds $handle]
	ixNet setM $handle \
		-name $this \
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
	set rb_interface  [ ixNet add $handle interface ]
	ixNet setM $rb_interface \
	    -interfaceId $hInterface \
	    -enableConnectedToDut True \
	    -enabled True
	ixNet commit
	set rb_interface [ ixNet remapIds $rb_interface ]
    Deputs "rb_interface:$rb_interface"  
	#-- add vlan
	#set vlan [ ixNet add $interface vlan ]
	#ixNet commit
	
	#-- port/protocols/isis/router/interface
  
}
body IsisSession::config { args } {
    set tag "body IsisSession::config [info script]"
Deputs "----- TAG: $tag -----"
	set active 0
	set metric_type "NW"
	set area_id1 "00.0001"
	#set sys_id "64:01:00:01:00:00"
# in case the handle was removed
    if { $handle == "" } {
	    reborn
    }
	
    Deputs "Args:$args "
    foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-sys_id - 
			-system_id {
				set sys_id $value
			}
			-network_type {
				set value [string tolower $value]
					switch $value {
					p2p {
						set value pointToPoint
					}
					p2mp {
						set value pointToMultipoint
					}
					default {
						set value broadcast
					}
				}
				set network_type $value
			}
            -discard_lsp {
            	set discard_lsp $value
            }
            -interface_metric -
            -metric {
            	set metric $value
            }
            -hello_interval {
            	set hello_interval $value  	    	
            }
			-holding_time -
            -dead_interval {
            	set dead_interval $value  	    	
            }
            -vlan_id {
            	set vlan_id $value
            }
			-level_type {
            	set level_type $value
            }
			-lsp_refresh -
            -lsp_refreshtime {
            	set lsp_refreshtime $value
            }
            -lsp_lifetime {
            	set lsp_lifetime $value
            }
			-mac_addr {
                set value [ MacTrans $value ]
                if { [ IsMacAddress $value ] } {
                    set mac_addr $value
                } else {
Deputs "wrong mac addr: $value"
                    error "$errNumber(1) key:$key value:$value"
                }
				
			}
			-active {
				set active $value
			}
			-router_pri {
			    set route_pri $value
			}
			-area_id1 {
				set area_id1 $value
                set area_id1 [ string replace $area_id1 2 2 "" ]
				set areaList [ list ]
				lappend areaList $area_id1
				puts "areaList $areaList"
			}
			-area_id2 {
				set area_id2 $value
				set area_id2 [ string replace $area_id2 2 2 "" ]
				lappend areaList $area_id2
				puts "areaList $areaList"
			}
			-metric_type {
				set metric_type $value
			}
			-max_lspsize {
				set max_lspsize $value
			}
			-isis_authentication {
				set isis_authentication $value
			}
			-isis_password {
				set isis_password $value
			}
			-isis_md5_keyid {
				set isis_md5_keyid $value
			}
			-area_password {
				set password $value
			}
			-area_md5_keyid {
				set md5_keyid $value
			}
			-area_authentication {
				set area_authentication $value
			}
			-domain_authentication {
				set domain_authentication $value
			}
			-domain_password {
				set password $value
			}
			-domain_md5_keyid {
				set md5_keyid $value
			}
			
		}
    }
	if { [ info exists area_id1 ] || [ info exists area_id2 ] } {
		set areaList [ list ]
		if { [ info exists area_id1 ] } {
			set area_id1 [ string replace $area_id1 2 2 "" ]
			lappend areaList $area_id1
			puts "areaList $areaList"
		}
		if { [ info exists area_id2 ] } {
			set area_id2 [ string replace $area_id2 2 2 "" ]
			lappend areaList $area_id2
			puts "areaList $areaList"
		}
		ixNet setA $handle -areaAddressList $areaList
	}
	if { [ info exists metric_type ] } {
		if { $metric_type == "NW" || $metric_type == "W"} {
			ixNet setA $handle -enableWideMetric true
		}
	}
    if { [ info exists sys_id ] } {
		while { [ ixNet getF $hPort/protocols/isis router -systemId "[ split $sys_id : ]"  ] != "" } {
Deputs "sys_id: $sys_id"		
			set sys_id [ IncrMacAddr $sys_id "00:00:00:00:00:01" ]
		}
Deputs "sys_id: $sys_id"		
	    ixNet setA $handle -systemId $sys_id
    }
    if { [ info exists network_type ] } {
		set interface [ixNet getL $handle interface]
	    ixNet setA $interface -networkType $network_type
    }
    if { [ info exists discard_lsp ] } {
    	ixNet setA $handle -enableDiscardLearnedLsps $discard_lsp
    }
	if { [ info exists level_type ] } {
		set interface [ixNet getL $handle interface]
		switch -exact -- $level_type {
			-L1 {
				set level_type level1
			}
			-L2 {
				set level_type level2
				}
			-L12 {
				set level_type level1Level2
			}
		}
    	ixNet setA $interface -level $level_type
    }
	if { [info exists router_pri ] } {
		set interface [ixNet getL $handle interface]
		if { $level_type == "level1" } {
			ixNet setA $interface -priorityLevel1 $router_pri
		} else {
			ixNet setA $interface -priorityLevel2 $router_pri
		}
	}
	
    if { [ info exists metric ] } {
		set interface [ixNet getL $handle interface]
	    ixNet setA $interface -metric $metric
    }
    if { [ info exists hello_interval ] } {
		set interface [ixNet getL $handle interface]
	    ixNet setA $interface -level1HelloTime $hello_interval
    }
    if { [ info exists dead_interval ] } {
		set interface [ixNet getL $handle interface]
	    ixNet setA $interface -level1DeadTime $dead_interval
    }
    if { [ info exists vlan_id ] } {
	    set vlan [ixNet getL $interface vlan]
	    ixNet setA $vlan -vlanId $vlan_id
    }
    if { [ info exists lsp_refreshtime ] } {
    	ixNet setA $handle -lspRefreshRate $lsp_refreshtime
    }
    if { [ info exists lsp_lifetime ] } {
    	ixNet setA $handle -lspLifeTime $lsp_lifetime
    } 
	if { [ info exists mac_addr ] } {
Deputs "interface:$interface mac_addr:$mac_addr"
		ixNet setA $interface/ethernet -macAddress $mac_addr
	}
	if { [ info exists max_lspsize ] } {
		ixNet setA $handle -lspMaxSize $max_lspsize
	}
	if { [ info exists isis_authentication ] } {
		set interface [ixNet getL $handle interface]
		if { $isis_authentication == "md5" } {
			ixNet setM $interface -circuitAuthType md5 \
				-circuitTransmitPassword $isis_md5_keyid
        }
		if { $isis_authentication == "simple" } {
			ixNet setM $interface -circuitAuthType password \
				-circuitTransmitPassword $isis_password
        } 
	}
	if { [ info exists area_authentication ] } {
		if { $area_authentication == "md5" } {
			ixNet setM $handle -areaAuthType MD5 \
				-areaTransmitPassword $area_md5_keyid
        }
		if { $area_authentication == "simple" } {
			ixNet setM $handle -areaAuthType password \
				-areaTransmitPassword $area_password
        }
	}
	if { [ info exists domain_authentication ] } {
		if { $domain_authentication == "md5" } {
			ixNet setM $handle -domainAuthType MD5 \
				-domainTransmitPassword $domian_md5_keyid
        }
		if { $domain_authentication == "simple" } {
			ixNet setM $handle -domainAuthType password \
				-domainTransmitPassword $domian_password
        }
	}
	# if { [ info exists areaList ] } {
		# ixNet setA $handle -areaAddressList $areaList
	# }
	if { [ info exists active ] } {
		if { $active } {
			ixNet setA $handle -enabled true
		} else {
			ixNet setA $handle -enabled false
		}
	}
    ixNet commit
}

#{Stat Name} {Port Name} {L2 Sess. Configured} {L2 Sess. Up} {L2 Init State Count} {L2 Full State Count} 
#{L2 Neighbors} {L2 Session Flap Count} {L2 DB Size} {L2 Hellos Rx} {L2 PTP Hellos Rx} {L2 LSP Rx} {L2 CSNP Rx} 
#{L2 PSNP Rx} {L2 Hellos Tx} {L2 PTP Hellos Tx} {L2 LSP Tx} {L2 CSNP Tx} {L2 PSNP Tx} {L1 Sess. Configured} 
#{L1 Sess. Up} {L1 Init State Count} {L1 Full State Count} {L1 Neighbors} {L1 Session Flap Count} {L1 DB Size}
# {L1 Hellos Rx} {L1 PTP Hellos Rx} {L1 LSP Rx} {L1 CSNP Rx} {L1 PSNP Rx} {L1 Hellos Tx} {L1 PTP Hellos Tx} {L1 LSP Tx} 
#{L1 CSNP Tx} {L1 PSNP Tx} {M-GROUP CSNPs Tx} {M-GROUP CSNPs Rx} {M-GROUP PSNPs Tx} {M-GROUP PSNPs Rx} {M-GROUP LSP Tx} 
#{M-GROUP LSP Rx} {Unicast MAC Group Record Tx} {Unicast MAC Group Record Rx} {Multicast MAC Group Record Tx} 
#{Multicast MAC Group Record Rx} {Multicast IPv4 Group Record Tx} {Multicast IPv4 Group Record Rx} {Multicast IPv6 Group Record Tx} 
#{Multicast IPv6 Group Record Rx} {RBChannel Frames Tx} {RBChannel Frames Rx} {RBChannel Echo Request Tx} {RBChannel Echo Request Rx} 
#{RBChannel Echo Reply Tx} {RBChannel Echo Reply Rx} {RBChannel Error Tx} {RBChannel Error Rx} {RBChannel ErrNotif Tx} {RBChannel ErrNotif Rx} 
#{RBridges Learned} {Unicast MAC Ranges Learned} {MAC Group Records Learned}
# {IPv4 Group Records Learned} {IPv6 Group Records Learned} {Rate Control Blocked Sending LSP/MGROUP}
body IsisSession::set_route { args } {

    global errorInfo
    global errNumber
    set tag "body BgpSession::set_route [info script]"
Deputs "----- TAG: $tag -----"

#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -route_block {
            	set route_block $value
				puts "route_block:$route_block"
            }
        }
    }
	if { [ info exists route_block ] } {
		foreach rb $route_block {
		set num 		[ $rb cget -num ]
		set step 		[ $rb cget -step ]
		set prefix_len 	[ $rb cget -prefix_len ]
		set start 		[ $rb cget -start ]
		set type 		[ $rb cget -type ] 
		set active      [ $rb cget -active]
		set metric_route   [ $rb cget -metric_route ]
		set route_type  [ $rb cget -route_type ]
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
		puts "$num; $type; $start; $prefix_len; $step"
			ixNet setM $hRouteBlock \
				-numberOfRoutes $num \
				-firstRoute $start \
				-routeOrigin $route_type \
				-maskWidth $prefix_len \
				-enabled $active \
				-metric $metric_route
			ixNet commit
		}
	}
	
    return [GetStandardReturnHeader]
	

}

body IsisSession::get_fh_stats {} {

    set tag "body IsisSession::get_fh_stats [info script]"
Deputs "----- TAG: $tag -----"


    set root [ixNet getRoot]
	set view {::ixNet::OBJ-/statistics/view:"ISIS Aggregated Statistics"}
    # set view  [ ixNet getF $root/statistics view -caption "Port Statistics" ]
Deputs "view:$view"
    set captionList             [ ixNet getA $view/page -columnCaptions ]
Deputs "caption list:$captionList"
	set port_name				[ lsearch -exact $captionList {Stat Name} ]
    set session_conf            [ lsearch -exact $captionList {Sess. Configured} ]
    set session_succ            [ lsearch -exact $captionList {Sess. Up} ]
    
    #set AdjacencyLevel          [ lsearch -exact $captionList {Sess. Up} ]
    set RxL1LspCount            [ lsearch -exact $captionList {L1 LSP Rx} ]
    set RxL2LspCount            [ lsearch -exact $captionList {L2 LSP Rx} ]
    set RxL1CsnpCount           [ lsearch -exact $captionList {L1 CSNP Rx} ]
    set RxL1LanHelloCount       [ lsearch -exact $captionList {L1 Hellos Rx} ]
    set RxL2CsnpCount           [ lsearch -exact $captionList {L2 CSNP Rx} ]
    set RxL2LanHelloCount       [ lsearch -exact $captionList {L2 Hellos Rx} ]
    set TxL1CsnpCount           [ lsearch -exact $captionList {L1 CSNP Tx} ]
    set TxL1LanHelloCount       [ lsearch -exact $captionList {L1 Hellos Tx} ]
    set TxL1LspCount            [ lsearch -exact $captionList {L1 LSP Tx} ]                  
    set TxL2CsnpCount           [ lsearch -exact $captionList {L2 CSNP Tx} ]
    set TxL2LanHelloCount       [ lsearch -exact $captionList {L2 Hellos Tx} ]
    set TxL2LspCount            [ lsearch -exact $captionList {L2 LSP Tx} ]
    set TxPtpHelloCount         [ lsearch -exact $captionList {L2 PTP Hellos Tx} ]
	
    set ret ""
	
    set stats [ ixNet getA $view/page -rowValues ]
Deputs "stats:$stats"

    set connectionInfo [ ixNet getA $hPort -connectionInfo ]
Deputs "connectionInfo :$connectionInfo"
    regexp -nocase {chassis=\"([0-9\.]+)\" card=\"([0-9\.]+)\" port=\"([0-9\.]+)\"} $connectionInfo match chassis card port
Deputs "chas:$chassis card:$card port$port"

    foreach row $stats {
        
        eval {set row} $row
Deputs "row:$row"
Deputs "portname:[ lindex $row $port_name ]"
		if { [ string length $card ] == 1 } {
			set card "0$card"
		}
		if { [ string length $port ] == 1 } {
			set port "0$port"
		}
		if { "${chassis}/Card${card}/Port${port}" != [ lindex $row $port_name ] } {
			continue
		}

        set statsItem   "RxL1LspCount"
        set statsVal    [ lindex $row $RxL1LspCount ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
          
              
        set statsItem   "RxL2LspCount"
        set statsVal    [ lindex $row $RxL2LspCount ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
        
        set statsItem   "RxL1CsnpCount"
        set statsVal    [ lindex $row $RxL1CsnpCount ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
          
              
        set statsItem   "RxL1LanHelloCount"
        set statsVal    [ lindex $row $RxL1LanHelloCount ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
       
       set statsItem   "RxL2CsnpCount"
        set statsVal    [ lindex $row $RxL2CsnpCount ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
          
              
        set statsItem   "RxL2LanHelloCount"
        set statsVal    [ lindex $row $RxL2LanHelloCount ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
        
        set statsItem   "TxL1CsnpCount"
        set statsVal    [ lindex $row $TxL1CsnpCount ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
          
              
        set statsItem   "TxL1LanHelloCount"
        set statsVal    [ lindex $row $TxL1LanHelloCount ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
        
        set statsItem   "TxL1LspCount"
        set statsVal    [ lindex $row $TxL1LspCount ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
          
              
        set statsItem   "TxL2CsnpCount"
        set statsVal    [ lindex $row $TxL2CsnpCount ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
        
        set statsItem   "TxL2LanHelloCount"
        set statsVal    [ lindex $row $TxL2LanHelloCount ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
          
              
        set statsItem   "TxL2LspCount"
        set statsVal    [ lindex $row $TxL2LspCount ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
        
        set statsItem   "TxL1CsnpCount"
        set statsVal    [ lindex $row $TxL1CsnpCount ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
          
              
        set statsItem   "TxPtpHelloCount"
        set statsVal    [ lindex $row $TxPtpHelloCount ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
			  

Deputs "ret:$ret"

    }
        
    return $ret

	
}

body IsisSession::advertise_route { args } {
    global errorInfo
    global errNumber
    set tag "body IsisSession::advertise_route [info script]"
Deputs "----- TAG: $tag -----"

#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -route_block {
            	set route_block $value
            }
        }
    }
	
	if { [ info exists route_block ] } {
		ixNet setA $routeBlock($route_block,handle) \
			-enabled True
	} else {
		foreach hRouteBlock $routeBlock(obj) {
Deputs "hRouteBlock : $hRouteBlock"		
			ixNet setA $routeBlock($hRouteBlock,handle) -enabled True
		}
	}
	ixNet commit
	return [GetStandardReturnHeader]

}

body IsisSession::withdraw_route { args } {
    global errorInfo
    global errNumber
    set tag "body IsisSession::config [info script]"
Deputs "----- TAG: $tag -----"

#param collection
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -route_block {
            	set route_block $value
            }
        }
    }
	
	if { [ info exists route_block ] } {
		ixNet setA $routeBlock($route_block,handle) \
			enabled False
	} else {
		foreach hRouteBlock $routeBlock(obj) {
			ixNet setA $hRouteBlock -enabled False
		}
	}
	ixNet commit
	return [GetStandardReturnHeader]

}


