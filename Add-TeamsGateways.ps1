##Vodacom Teams direct Routing Derived Trunk Edited##
$sbcsipport = "5061"
$pstngateway = "XXX.mtb.msdr.teams.vodacom.co.za, XXX.cfo.msdr.teams.vodacom.co.za"
$numpatt = ".*"
$pstnusage = "PSTN Usage for Teams DR (VODA-HA-01-VR)"
$onlinevoiceroute = "Default-Voice-Route(VODA-HA-01-VR)"
$onlinevoiceroutingpolicy = "Global"
$tenantdialplan = "Global"



$NR1 = New-CsVoiceNormalizationRule -Name 'ZA-TollFree' -Parent Global -Pattern '^0(80\d{7})\d*$' -Translation '+27$1' -InMemory
$NR2 = New-CsVoiceNormalizationRule -Name 'ZA-Premium' -Parent Global -Pattern '^0(86[24-9]\d{6})$' -Translation '+27$1' -InMemory
$NR3 = New-CsVoiceNormalizationRule -Name 'ZA-Mobile' -Parent Global -Pattern '^0(([7]\d{8}|8[1-5]\d{7}))$' -Translation '+27$1' -InMemory
$NR4 = New-CsVoiceNormalizationRule -Name 'ZA-National' -Parent Global -Pattern '^0(([1-5]\d\d|8[789]\d|86[01])\d{6})\d*(\D+\d+)?$' -Translation '+27$1' -InMemory
$NR5 = New-CsVoiceNormalizationRule -Name 'ZA-Service' -Parent Global -Pattern '^(1\d{2,4})$' -Translation '$1' -InMemory
$NR6 = New-CsVoiceNormalizationRule -Name 'ZA-International' -Parent Global -Pattern '^(?:\+|00)(1|7|2[07]|3[0-46]|39\d|4[013-9]|5[1-8]|6[0-6]|8[1246]|9[0-58]|2[1235689]\d|24[013-9]|242\d|3[578]\d|42\d|5[09]\d|6[789]\d|8[035789]\d|9[679]\d)(?:0)?(\d{6,14})(\D+\d+)?$' -Translation '+$1$2' -InMemory
set-CsTenantDialPlan -Identity $tenantdialplan -NormalizationRules @{Add=$NR1,$NR2,$NR3,$NR4,$NR5,$NR6}



Set-CsOnlinePstnUsage -Identity Global -Usage @{Add=$pstnusage}
New-CsOnlineVoiceRoute -Identity $onlinevoiceroute -NumberPattern $numpatt -OnlinePstnGatewayList $pstngateway -Priority 1 -OnlinePstnUsages $pstnusage
Set-CsOnlineVoiceRoutingPolicy -identity $onlinevoiceroutingpolicy -OnlinePstnUsages $pstnusage