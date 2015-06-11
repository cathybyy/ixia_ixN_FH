
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.0
#===============================================================================
# Change made
# Version 1.0 
#       1. Create

class BgpSession {
    inherit RouterEmulationObject
 	public variable routeBlock
    public variable protocolhandle   
    constructor { port { pHandle null } { hInterface null } } {

		set tag "body BgpSession::ctor [info script]"
Deputs "----- TAG: $tag -----"
        set routeBlock(obj) ""
		set portObj [ GetObject $port ]
        if { $pHandle != "null" } {
            set handle $pHandle
            
        } else {
		    reborn $hInterface
        }
	}
	

	method reborn { { hInterface null }} {
		global errNumber
		
		set tag "body BgpSession::reborn [info script]"
Deputs "----- TAG: $tag -----"

		if { [ catch {
			set hPort   [ $portObj cget -handle ]
		} ] } {
			error "$errNumber(1) Port Object in DhcpHost ctor"
		}		
		
		ixNet setA $hPort/protocols/bgp -enabled True
			
		#-- add bgp protocol
		set protocolhandle "$hPort/protocols/bgp"
		set handle [ ixNet add $hPort/protocols/bgp neighborRange ]
		ixNet commit
		set handle [ ixNet remapIds $handle ]
		ixNet setA $handle \
			-name $this \
			-enabled True
		ixNet commit
		array set routeBlock [ list ]
		
		#-- add interface
		set interface [ ixNet getL $hPort interface ]
		if { [ llength $interface ] == 0 } {
			set interface [ ixNet add $hPort interface ]
			ixNet add $interface ipv4
			ixNet commit
			set interface [ ixNet remapIds $interface ]
			ixNet setM $interface \
				-enabled True
			ixNet commit
		}
		if { $hInterface != "null" } {		    
		} else {
		    set hInterface [ lindex $interface 0 ]
		}
		ixNet setA $handle \
			-interfaceType "Protocol Interface" \
			-interfaces $hInterface
		ixNet commit
		set interface $hInterface

	}
    method config { args } {}
	method enable {} {}
	method disable {} {}
	method get_status {} {}
	method get_stats {} {}
    method get_fh_stats {} {}
	method set_route { args } {}
	method advertise_route { args } {}
	method withdraw_route { args } {}
	method wait_session_up { args } {}
}

body BgpSession::config { args } {
    global errorInfo
    global errNumber
    set tag "body BgpSession::config [info script]"
Deputs "----- TAG: $tag -----"
	set hold_time_interval 10
	set active 0
#param collection
    
Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -afi {
            	set afi $value
            }
            -sub_afi {
            	set sub_afi $value
            }
			-as_num -
            -as {
            	set as $value
            }
            -dut_ip {
            	set dut_ip $value
            }
            -dut_as {
            	set dut_as $value
            }
            -enable_pack_routes {
            	set enable_pack_routes $value
            }
            -max_routes_per_update {
            	set max_routes_per_update $value
            }
            -enable_refresh_routes {
            	set enable_refresh_routes $value
            }
			-hold_time -
            -hold_time_interval {
            	set hold_time_interval $value
            }
			-keep_time {
            	set keep_time_interval $value
            }
            -ip_version {
            	set ip_version $value
            }
			-ipv4_addr {
				set ipv4_addr $value
			}
			-ipv4_gw {
				set ipv4_gw $value
			}
			-bgp_type -
			-type {
			    if {$value == "ebgp"} {
				   set type "external"
				} elseif {$value == "ibgp" } {
				   set type "internal"
				} else {
				   set type $value
				}
				
			
			}
			-bgp_id {
				set bgp_id $value
			}
			-active {
				set active $value
			}
			-authentication {
				set authentication $value
			}
			-password {
				set password $value
			}			
		}
    }
	
	if { $handle == "" } {
		reborn
	}
	
	if { [ info exists ipv4_addr ] } {
Deputs "ipv4: [ixNet getL $interface ipv4]"	
Deputs "interface:$interface"
		ixNet setA $interface/ipv4 -ip $ipv4_addr
	}
	if { [ info exists ipv4_gw ] } {
		ixNet setA $interface/ipv4 -gateway $ipv4_gw		
	}
	if {[ info exists as ] && [ info exists dut_as ]} {
	    if { $as == $dut_as } {
		    set type "internal"
		} else {
		    set type "external"
		}
	}
	if { [ info exists type ] } {
		ixNet setA $handle -type $type
	}
    if { [ info exists afi ] } {
Deputs "not implemented parameter: afi"
    }
    if { [ info exists sub_afi ] } {
Deputs "not implemented parameter: safi"
    }
    if { [ info exists as ] } {
    	ixNet setA $handle -localAsNumber $as
    }
    if { [ info exists dut_ip ] } {
    	ixNet setA $handle -dutIpAddress $dut_ip
    }
    if { [ info exists dut_as ] } {
    }
    if { [ info exists enable_pack_routes ] } {
    }
    if { [ info exists Max_routes_per_update ] } {
    }
    if { [ info exists enable_refresh_routes ] } {
    }
    if { [ info exists hold_time_interval ] } {
	    ixNet setA $handle  -holdTimer $hold_time_interval
    }
    if { [ info exists ip_version ] } {
    }
	if { [ info exists authentication ] } {
	    if { $authentication == "md5"} {
		    ixNet setM $handle -authentication md5 \
		    -md5Key $password
		}
	    
    }
	if { [ info exists bgp_id ] } {
		ixNet setA $handle -bgpId $bgp_id
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

body BgpSession::set_route { args } {

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
			
			if { [lsearch $routeBlock(obj) $rb] == -1 } {
			    set hRouteBlock [ ixNet add $handle routeRange ]
				ixNet commit
				set hRouteBlock [ ixNet remapIds $hRouteBlock ]
				set routeBlock($rb,handle) $hRouteBlock
				lappend routeBlock(obj) $rb
			} else {
			    set hRouteBlock $routeBlock($rb,handle)
			}
			
		puts "hRouteBlock: $hRouteBlock"	
		puts "$num; $type; $start; $prefix_len; $step"
			ixNet setM $hRouteBlock \
				-numRoutes $num \
				-ipType $type \
				-networkAddress $start \
				-fromPrefix $prefix_len \
				-iterationStep $step  \
				-enabled $active
			ixNet commit
		}
	}
	
    return [GetStandardReturnHeader]
	

}

body BgpSession::advertise_route { args } {
    global errorInfo
    global errNumber
    set tag "body BgpSession::advertise_route [info script]"
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

body BgpSession::withdraw_route { args } {
    global errorInfo
    global errNumber
    set tag "body BgpSession::config [info script]"
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


body BgpSession::get_stats {} {

    set tag "body BgpSession::get_stats [info script]"
Deputs "----- TAG: $tag -----"


    set root [ixNet getRoot]
	set view {::ixNet::OBJ-/statistics/view:"BGP Aggregated Statistics"}
    # set view  [ ixNet getF $root/statistics view -caption "Port Statistics" ]
Deputs "view:$view"
    set captionList             [ ixNet getA $view/page -columnCaptions ]
Deputs "caption list:$captionList"
	set port_name				[ lsearch -exact $captionList {Stat Name} ]
    set session_conf          [ lsearch -exact $captionList {Sess. Configured} ]
    set session_succ          [ lsearch -exact $captionList {Sess. Up} ]

	
    set ret [ GetStandardReturnHeader ]
	
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

        set statsItem   "session_conf"
        set statsVal    [ lindex $row $session_conf ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
          
              
        set statsItem   "session_succ"
        set statsVal    [ lindex $row $session_succ ]
Deputs "stats val:$statsVal"
        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
			  

Deputs "ret:$ret"

    }
        
    return $ret

	
}

#{Stat Name} {Port Name} {Sess. Configured} {Sess. Up} {Session Flap Count} {Idle State Count} {Connect State Count} {Active State Count} 
#{OpenSent State Count} {OpenConfirm State Count} {Established State Count} {Routes Advertised} {Routes Withdrawn} {Messages Tx} {Messages Rx} 
#{Updates Tx} {Updates Rx} {Routes Rx} {Route Withdraws Rx} {Opens Tx} {Opens Rx} {KeepAlives Tx} {KeepAlives Rx} {Notifications Tx} 
#{Notifications Rx} {Graceful Restarts Attempted} {Graceful Restarts Failed} {Routes Rx Graceful Restart} {Starts Occurred}
body BgpSession::get_fh_stats {} {

    set tag "body BgpSession::get_fh_stats [info script]"
Deputs "----- TAG: $tag -----"


    set root [ixNet getRoot]
	set view {::ixNet::OBJ-/statistics/view:"BGP Aggregated Statistics"}
    # set view  [ ixNet getF $root/statistics view -caption "Port Statistics" ]
Deputs "view:$view"
    set captionList             [ ixNet getA $view/page -columnCaptions ]
Deputs "caption list:$captionList"
	set port_name				[ lsearch -exact $captionList {Stat Name} ]
    set session_conf            [ lsearch -exact $captionList {Sess. Configured} ]   
    set session_succ            [ lsearch -exact $captionList {Sess. Up} ]
    
    set OutstandingRoute        [ lsearch -exact $captionList {Active State Count} ]
    set RxUpdateRoute           [ lsearch -exact $captionList {Updates Rx} ]
    set RxAdvertisedRoute       [ lsearch -exact $captionList {Routes Advertised} ]
    set RxWithdrawn             [ lsearch -exact $captionList {Route Withdraws Rx} ]
    set TxWithdrawn             [ lsearch -exact $captionList {Routes Withdrawn} ]   

    set RxOpen                  [ lsearch -exact $captionList {Opens Rx} ]
    set TxOpen                  [ lsearch -exact $captionList {Opens Tx} ]
    set RxNotification          [ lsearch -exact $captionList {Notifications Rx} ]
    set TxNotification          [ lsearch -exact $captionList {Notifications Tx} ]
    set RxKeepAlive             [ lsearch -exact $captionList {KeepAlives Rx} ]
    set TxKeepAlive             [ lsearch -exact $captionList {KeepAlives Tx} ]



	
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

        set statsItem   "LastRxUpdateRouteCount"
        set statsVal    [ lindex $row $RxUpdateRoute ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
          
              
        set statsItem   "OutstandingRouteCount"
        set statsVal    [ lindex $row $OutstandingRoute ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
        
        set statsItem   "RxAdvertisedRouteCount"
        set statsVal    [ lindex $row $RxAdvertisedRoute ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
        
        set statsItem   "RxKeepAliveCount"
        set statsVal    [ lindex $row $RxKeepAlive ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
        
        set statsItem   "RxNotificationCount"
        set statsVal    [ lindex $row $RxNotification ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
        
        set statsItem   "RxOpenCount"
        set statsVal    [ lindex $row $RxOpen ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
        
        set statsItem   "RxWithdrawnRouteCount"
        set statsVal    [ lindex $row $RxWithdrawnRoute ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
        
        set statsItem   "TxKeepAliveCount"
        set statsVal    [ lindex $row $TxKeepAlive ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
        
        set statsItem   "TxNotificationCount"
        set statsVal    [ lindex $row $TxNotification ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
        
        set statsItem   "TxOpenCount"
        set statsVal    [ lindex $row $TxOpen ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
        
        set statsItem   "TxWithdrawnRouteCount"
        set statsVal    [ lindex $row $TxWithdrawnRoute ]
Deputs "stats val:$statsVal"
        set ret "$ret$statsItem $statsVal "
			  



    }
        
    return $ret

	
}


body BgpSession::wait_session_up { args } {
    set tag "body BgpSession::wait_session_up [info script]"
Deputs "----- TAG: $tag -----"

	set timeout 300

    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -timeout {
				set trans [ TimeTrans $value ]
                if { [ string is integer $trans ] } {
                    set timeout $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }

        }
    }
	
	set startClick [ clock seconds ]
	
	while { 1 } {
		set click [ clock seconds ]
		if { [ expr $click - $startClick ] >= $timeout } {
			return [ GetErrorReturnHeader "timeout" ]
		}
		
		set stats [ get_stats ]
		set initStats [ GetStatsFromReturn $stats session_conf ]
		set succStats [ GetStatsFromReturn $stats session_succ ]
		
		if { $succStats == $initStats && $initStats > 0 } {
			break	
		}
		
		after 3000
	}
	
	return [GetStandardReturnHeader]

}
# =======================
# Neighbor Range
# =======================
# Child Lists:
	# bgp4VpnBgpAdVplsRange (kLegacyUnknown : getList)
	# interfaceLearnedInfo (kLegacyUnknown : getList)
	# l2Site (kLegacyUnknown : getList)
	# l3Site (kLegacyUnknown : getList)
	# learnedFilter (kLegacyUnknown : getList)
	# learnedInformation (kLegacyUnknown : getList)
	# mplsRouteRange (kLegacyUnknown : getList)
	# opaqueRouteRange (kLegacyUnknown : getList)
	# routeImportOptions (kLegacyUnknown : getList)
	# routeRange (kLegacyUnknown : getList)
	# userDefinedAfiSafi (kLegacyUnknown : getList)
# Attributes:
	# -asNumMode (readOnly=False, type=(kEnumValue)=fixed,increment, deprecated)
	# -authentication (readOnly=False, type=(kEnumValue)=md5,null)
	# -bfdModeOfOperation (readOnly=False, type=(kEnumValue)=multiHop,singleHop)
	# -bgpId (readOnly=False, type=(kIP))
	# -dutIpAddress (readOnly=False, type=(kIP))
	# -enable4ByteAsNum (readOnly=False, type=(kBool))
	# -enableActAsRestarted (readOnly=False, type=(kBool))
	# -enableBfdRegistration (readOnly=False, type=(kBool))
	# -enableBgpId (readOnly=False, type=(kBool))
	# -enabled (readOnly=False, type=(kBool))
	# -enableDiscardIxiaGeneratedRoutes (readOnly=False, type=(kBool))
	# -enableGracefulRestart (readOnly=False, type=(kBool))
	# -enableLinkFlap (readOnly=False, type=(kBool))
	# -enableNextHop (readOnly=False, type=(kBool))
	# -enableOptionalParameters (readOnly=False, type=(kBool))
	# -enableSendIxiaSignatureWithRoutes (readOnly=False, type=(kBool))
	# -enableStaggeredStart (readOnly=False, type=(kBool))
	# -holdTimer (readOnly=False, type=(kInteger))
	# -interfaces (readOnly=False, type=(kObjref)=null,/vport/interface,/vport/protocolStack/atm/dhcpEndpoint/range,/vport/protocolStack/atm/ip/l2tpEndpoint/range,/vport/protocolStack/atm/ipEndpoint/range,/vport/protocolStack/atm/pppoxEndpoint/range,/vport/protocolStack/ethernet/dhcpEndpoint/range,/vport/protocolStack/ethernet/ip/l2tpEndpoint/range,/vport/protocolStack/ethernet/ipEndpoint/range,/vport/protocolStack/ethernet/pppoxEndpoint/range,/vport/protocolStack/ethernetEndpoint/range)
	# -interfaceStartIndex (readOnly=False, type=(kInteger))
	# -interfaceType (readOnly=False, type=(kString))
	# -ipV4Mdt (readOnly=False, type=(kBool))
	# -ipV4Mpls (readOnly=False, type=(kBool))
	# -ipV4MplsVpn (readOnly=False, type=(kBool))
	# -ipV4Multicast (readOnly=False, type=(kBool))
	# -ipV4MulticastVpn (readOnly=False, type=(kBool))
	# -ipV4Unicast (readOnly=False, type=(kBool))
	# -ipV6Mpls (readOnly=False, type=(kBool))
	# -ipV6MplsVpn (readOnly=False, type=(kBool))
	# -ipV6Multicast (readOnly=False, type=(kBool))
	# -ipV6MulticastVpn (readOnly=False, type=(kBool))
	# -ipV6Unicast (readOnly=False, type=(kBool))
	# -isAsbr (readOnly=False, type=(kBool))
	# -isInterfaceLearnedInfoAvailable (readOnly=True, type=(kBool))
	# -isLearnedInfoRefreshed (readOnly=True, type=(kBool))
	# -linkFlapDownTime (readOnly=False, type=(kInteger))
	# -linkFlapUpTime (readOnly=False, type=(kInteger))
	# -localAsNumber (readOnly=False, type=(kString))
	# -localIpAddress (readOnly=False, type=(kIP))
	# -md5Key (readOnly=False, type=(kString))
	# -nextHop (readOnly=False, type=(kIPv4))
	# -numUpdatesPerIteration (readOnly=False, type=(kInteger))
	# -rangeCount (readOnly=False, type=(kInteger))
	# -remoteAsNumber (readOnly=False, type=(kInteger64), deprecated)
	# -restartTime (readOnly=False, type=(kInteger))
	# -staggeredStartPeriod (readOnly=False, type=(kInteger))
	# -staleTime (readOnly=False, type=(kInteger))
	# -tcpWindowSize (readOnly=False, type=(kInteger))
	# -trafficGroupId (readOnly=False, type=(kObjref)=null,/traffic/trafficGroup)
	# -ttlValue (readOnly=False, type=(kInteger))
	# -type (readOnly=False, type=(kEnumValue)=external,internal)
	# -updateInterval (readOnly=False, type=(kInteger))
	# -vpls (readOnly=False, type=(kBool))
# Execs:
	# getInterfaceAccessorIfaceList((kObjref)=/vport/protocols/bgp/neighborRange)
	# getInterfaceLearnedInfo((kObjref)=/vport/protocols/bgp/neighborRange)
	# refreshLearnedInfo((kObjref)=/vport/protocols/bgp/neighborRange)

# ====================
# Route Range
# ====================
# Child Lists:
	# asSegment (kLegacyUnknown : getList)
	# cluster (kLegacyUnknown : getList)
	# community (kLegacyUnknown : getList)
	# extendedCommunity (kLegacyUnknown : getList)
	# flapping (kLegacyUnknown : getList)
# Attributes:
	# -aggregatorAsNum (readOnly=False, type=(kInteger64))
	# -aggregatorIpAddress (readOnly=False, type=(kIP))
	# -asPathSetMode (readOnly=False, type=(kEnumValue)=includeAsSeq,includeAsSeqConf,includeAsSet,includeAsSetConf,noInclude,prependAs)
	# -enableAggregator (readOnly=False, type=(kBool))
	# -enableAggregatorIdIncrementMode (readOnly=False, type=(kBool))
	# -enableAsPath (readOnly=False, type=(kBool))
	# -enableAtomicAttribute (readOnly=False, type=(kBool))
	# -enableCluster (readOnly=False, type=(kBool))
	# -enableCommunity (readOnly=False, type=(kBool))
	# -enabled (readOnly=False, type=(kBool))
	# -enableGenerateUniqueRoutes (readOnly=False, type=(kBool))
	# -enableIncludeLoopback (readOnly=False, type=(kBool))
	# -enableIncludeMulticast (readOnly=False, type=(kBool))
	# -enableLocalPref (readOnly=False, type=(kBool))
	# -enableMed (readOnly=False, type=(kBool))
	# -enableNextHop (readOnly=False, type=(kBool))
	# -enableOrigin (readOnly=False, type=(kBool))
	# -enableOriginatorId (readOnly=False, type=(kBool))
	# -enableProperSafi (readOnly=False, type=(kBool))
	# -enableTraditionalNlriUpdate (readOnly=False, type=(kBool))
	# -endOfRib (readOnly=False, type=(kBool))
	# -fromPacking (readOnly=False, type=(kInteger))
	# -fromPrefix (readOnly=False, type=(kInteger))
	# -ipType (readOnly=False, type=(kEnumValue)=ipAny,ipv4,ipv6)
	# -iterationStep (readOnly=False, type=(kInteger))
	# -localPref (readOnly=False, type=(kInteger))
	# -med (readOnly=False, type=(kInteger64))
	# -networkAddress (readOnly=False, type=(kIP))
	# -nextHopIpAddress (readOnly=False, type=(kIP))
	# -nextHopIpType (readOnly=False, type=(kEnumValue)=ipAny,ipv4,ipv6)
	# -nextHopMode (readOnly=False, type=(kEnumValue)=fixed,incrementPerPrefix,nextHopIncrement)
	# -nextHopSetMode (readOnly=False, type=(kEnumValue)=sameAsLocalIp,setManually)
	# -numRoutes (readOnly=False, type=(kInteger))
	# -originatorId (readOnly=False, type=(kIP))
	# -originProtocol (readOnly=False, type=(kEnumValue)=egp,igp,incomplete)
	# -thruPacking (readOnly=False, type=(kInteger))
	# -thruPrefix (readOnly=False, type=(kInteger))
# Execs:
	# reAdvertiseRoutes((kObjref)=/vport/protocols/bgp/neighborRange/routeRange)

