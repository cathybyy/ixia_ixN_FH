#=========================================================================
# �汾�ţ�2.4
# �ļ�����Ixia.tcl
# �ļ�������IxiaHL���ʼ���ļ������û����� "package require IxiaHL" ���ô��ļ�
# ���ߣ�����ʯ(Shawn Li)
# ����ʱ��: 2010.03.30
# �޸ļ�¼��
#			2010.4.22 by Shawn
#			1��ɾ�����ֿռ� 
#			2���޸�ȫ�ֱ��������ʽ
#			3�����env(IXIA_VERSION)�Լ�TRAFFICGENȫ�ֱ���
#			2010.6.28
#			1) �޸ļ���IxP·��
# ��Ȩ���У�Ixia
#====================================================================================
#================================
#���ض���ĸ������Լ����Ա����
set currDir [file dirname [info script]]
source [file join $currDir Ixia_Util.tcl]
source [file join $currDir Ixia_CTester.tcl]
source [file join $currDir Ixia_CPort.tcl]
source [file join $currDir Ixia_CTraffic.tcl]
source [file join $currDir Ixia_CFilter.tcl]
source [file join $currDir Ixia_CCapture.tcl]
source [file join $currDir Ixia_CRoutingMisc.tcl]
source [file join $currDir Ixia_CBgp.tcl]
source [file join $currDir Ixia_COspf.tcl]
source [file join $currDir Ixia_CIsis.tcl]
#=============================
#���ü���IxiaHL����Ļ�������
if {[catch {
   #===================================================
   #-- modified by Eric for suitbale for multi-versions
   #===================================================
   #set oskey         {HKEY_LOCAL_MACHINE\SOFTWARE\Ixia Communications\IxOS} ;#ixos��ע���keyֵ
   #set ossubkey      [registry keys $oskey]                                 ;#ixos��ע����е�subkeyֵ
   #set installinfo   [append oskey \\ $ossubkey \\ InstallInfo]             ;#installinfo��keyֵ
   #set ospath        [registry get $installinfo  HOMEDIR]                   ;#ixos�İ�װ·��
   #--end modify
IxDebugOn   
   set oskey         {HKEY_LOCAL_MACHINE\SOFTWARE\Ixia Communications\IxOS} ;#ixos��ע���keyֵ
   set ossubkey      [ lindex [registry keys $oskey] end ]                  ;#ixos��ע����е�subkeyֵ,ע��Ҫ�����ֻ��װһ��os�汾
   set installinfo   [append oskey \\ $ossubkey \\ InstallInfo]             ;#installinfo��keyֵ
   set ospath        [registry get $installinfo  HOMEDIR]                   ;#ixos�İ�װ·��
Deputs "ospath:$ospath"
   set ixnkey        {HKEY_LOCAL_MACHINE\SOFTWARE\Ixia Communications\IxNetwork} ;#ixnetwork��ע���keyֵ
   set versionCount  [ llength [ registry keys $ixnkey ] ]
   if { $versionCount == 1 } {
      set ixnsubkey 		 [lindex [registry keys $ixnkey] 0]
   } else {
      set ixnsubkey 		 [lindex [registry keys $ixnkey] [ expr $versionCount - 2 ] ]      
   }
   set ixninstallinfo [append ixnkey \\$ixnsubkey \\ InstallInfo]                       
   set ixnpath       [registry get $ixninstallinfo HOMEDIR]                      ;#ixnetwork�İ�װ·��
Deputs "ixnpath:$ixnpath"
   set ixpkey        {HKEY_LOCAL_MACHINE\SOFTWARE\Ixia Communications\IxNProtocols} ;#ixnprotocol��ע���keyֵ
   set versionCount  [ llength [ registry keys $ixpkey ] ]
   if { $versionCount == 1 } {
      set ixpsubkey 		 [lindex [registry keys $ixpkey] 0]
   } else {
      set ixpsubkey 		 [lindex [registry keys $ixpkey] [ expr $versionCount - 2 ] ]
   }
   set ixpinstallinfo [append ixpkey \\$ixpsubkey \\ InstallInfo]                       
   set ixppath       [registry get $ixpinstallinfo HOMEDIR]                      ;#ixnprotocol�İ�װ·��
Deputs "ixppath:$ixppath"   
   set ixhltkey      {HKEY_LOCAL_MACHINE\SOFTWARE\Ixia Communications\hltapi} ;#HLTAPI��ע���keyֵ
   set ixhltsubkey 	 [lindex [registry keys $ixhltkey] 0]
   set ixhltinstallinfo [append ixhltkey \\$ixhltsubkey \\ InstallInfo]                       
   set ixhltpath       [registry get $ixhltinstallinfo HOMEDIR]               ;#HLTAPI�İ�װ·��
Deputs "ixhltpath:$ixhltpath" 
   #=======================================
   #�޸�tcl������auto_path�Լ�env(path)����   
   #lappend auto_path $ospath
   lappend auto_path [file join $ospath "TclScripts/lib"]
   lappend auto_path [file join $ospath "TclScripts/lib/IxTcl1.0"]
   append  env(PATH) ";${ospath}"
   #append  env(PATH) [format ";%s" [file join $ospath "../.."]]
   lappend auto_path [file join $ixnpath "TclScripts/Lib/IxTclNetwork"]
   #==========================================
   #�޸�auto_path������ʹ���ܼ���IxTclProtocol
   lappend auto_path [file join $ixppath "TclScripts/Lib/IxTclProtocol"]
   append  env(PATH) ";${ixppath}"
   lappend auto_path [file join $ixhltpath "TclScripts/lib/hltapi"]
   
   #===========
   #����HLTAPI
   package require Ixia
  
   } gErrMsg]} {
   error "Error: $gErrMsg."
}


#=================================================================
#�˻�������������HLTAPIʹ������API��Ҳ���Բο�HLTAPI release note
#env(IXIA_VERSION) HLT IxOS IxRouter IxNetwork IxAccess IxLoad 
#HLTSET70 4.00 GA Patch1 5.60 GA Patch1 N/A 5.50 SP1 (P) N/A 5.0 EA Patch1 
#HLTSET71 4.00 GA Patch1 5.60 GA Patch1 N/A 5.50 SP1 (N) N/A 5.0 EA Patch1 
#HLTSET72 4.00 GA Patch1 5.60 GA Patch1 N/A 5.50 SP1 (NO) N/A 5.0 EA Patch1 
#HLTSET73 4.00 GA Patch1 5.60 GA Patch1 N/A 5.50 EA SP1 (P2NO) N/A 5.0 EA Patch1 
#HLTSET74 4.00 GA Patch1 5.70 EA EA SP1 N/A 5.60 EA(P)(*) N/A 5.10 EA(*) 
#HLTSET75 4.00 GA Patch1 5.70 EA EA SP1 N/A 5.60 EA(N)(*) N/A 5.10 EA(*) 
#HLTSET76 4.00 GA Patch1 5.70 EA EA SP1 N/A 5.60 EA(NO)(*) N/A 5.10 EA(*) 
#HLTSET77 4.00 GA Patch1 5.70 EA EA SP1 N/A 5.60 EA(P2NO)(*) N/A 5.10 EA(*) 
set env(IXIA_VERSION) HLTSET74

#============
#����ȫ�ֱ���  
set ::SUCCESS 1
set ::FAILURE 0
set ::VERSION 2.4
set TRAFFICGEN "ixos"
set PORTLIST   ""
set TXPORTLIST ""
set RXPORTLIST ""
set CAPPORTLIST ""
set OBJECTLIST  ""
set CAPFILENAME	""

#======================================
#������IxiaHL�ռ��µ�����뵽ȫ�ֿռ�
package provide IxiaHL $::VERSION