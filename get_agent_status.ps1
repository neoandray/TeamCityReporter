
$encodedBytes    = [System.Text.Encoding]::UTF8.GetBytes("Bolaji:")
$encodedText     = [System.Convert]::ToBase64String($encodedBytes)
$serverResponse   = (iwr -UseBasicParsing -uri http://10.213.104.12/app/rest/server -Headers @{"contents"="text/xml"; "Authorization"="Basic $encodedText"}).content
$serverResponse   =  [xml]$serverResponse
$agentsURI        = "http://10.213.104.12"+($serverResponse.server.agents).href
$agentResponse    = (iwr -UseBasicParsing -uri $agentsURI  -Headers @{"contents"="text/xml"; "Authorization"="Basic $encodedText"}).content
$agentResponse    =  [xml]$agentResponse 
$agentInventory   =   New-Object System.Collections.Generic.List[System.Object];
$totalFreeSpace   = 0
$agentCount       = $agentResponse.agents.count
$totalConnected   = 0
$totalEnabled     = 0
$totalAuthorized  = 0
$totalUpToDate    = 0
$agentResponse.agents.agent|%{
$currentAgent     = $_
$currentAgentURI  = "http://10.213.104.12"+$currentAgent.href
$currentAgentInfo = (iwr  -UseBasicParsing -uri $currentAgentURI  -Headers @{"contents"="text/xml"; "Authorization"="Basic $encodedText"}).content
$currentAgentInfo = [xml]$currentAgentInfo

$agentInfo        = New-Object -TypeName PsObject -Property @{}

$agentInfo|Add-Member -MemberType NoteProperty -Name id -Value $currentAgentInfo.agent.id
$agentInfo|Add-Member -MemberType NoteProperty -Name connected -Value $currentAgentInfo.agent.connected
$agentInfo|Add-Member -MemberType NoteProperty -Name enabled -Value $currentAgentInfo.agent.enabled
$agentInfo|Add-Member -MemberType NoteProperty -Name authorized -Value $currentAgentInfo.agent.authorized
$agentInfo|Add-Member -MemberType NoteProperty -Name uptodate -Value $currentAgentInfo.agent.uptodate
$agentInfo|Add-Member -MemberType NoteProperty -Name ip -Value $currentAgentInfo.agent.ip
$agentInfo|Add-Member -MemberType NoteProperty -Name webUrl -Value $currentAgentInfo.agent.webUrl

if( $currentAgentInfo.agent.connected -eq "true"){
    $totalConnected+=1
}else{
  write-host "not connected"
  write-host "id: "+$currentAgentInfo.agent.id
}

if( $currentAgentInfo.agent.enabled -eq "true"){
   $totalEnabled+=1
}

if( $currentAgentInfo.agent.authorized -eq "true"){
   $totalAuthorized+=1
}

if( $currentAgentInfo.agent.uptodate -eq "true"){
   $totalUpToDate+=1
}

$currentAgentInfo.agent.properties.property | where -filter {$_.Name -match "teamcity.agent"}|%{
 $name = $_.name.replace("system.teamcity.agent.","").replace("teamcity.agent.","")
 $value = $_.value
 $agentInfo|Add-Member -MemberType NoteProperty -Name $name -Value $value
 if($name -eq "work.dir.freeSpaceMb" -and $currentAgentInfo.agent.connected -eq "true"){
    $totalFreeSpace+=$value
 }
}
 $agentInfo = $agentInfo
 $agentInventory.add($agentInfo)|Out-Null
  
 }

 $buildQueue = (iwr -UseBasicParsing -uri http://10.213.104.12/app/rest/buildQueue -Headers @{"contents"="text/xml"; "Authorization"="Basic $encodedText"}).content

 $buildQueue= [xml]$buildQueue
  
 $buildQueueCount = $buildQueue.builds.count
  
 $totalFreeSpaceGB =  (($totalFreeSpace)/1024).ToString("#.##")+"GB"

$totalConnected  =  ( $totalConnected/$agentCount).tostring("P")
$totalEnabled  =  ( $totalEnabled/$agentCount).tostring("P")
$totalAuthorized  =  ( $totalAuthorized/$agentCount).tostring("P")
$totalUpToDate  =  ( $totalUpToDate/$agentCount).tostring("P")
#

$reportData = New-Object -TypeName psobject -Property @{}
$reportData | Add-Member -MemberType NoteProperty -Name "Name" -Value "System Status"
$reportData | Add-Member -MemberType NoteProperty -Name AgentCount -Value $agentCount
$reportData | Add-Member -MemberType NoteProperty -Name AgentsConnected -Value $totalConnected
$reportData | Add-Member -MemberType NoteProperty -Name AgentsEnabled -Value $totalEnabled
$reportData | Add-Member -MemberType NoteProperty -Name AgentsAuthorized -Value $totalAuthorized
$reportData | Add-Member -MemberType NoteProperty -Name AgentsUptoDate -Value $totalUpToDate
$reportData | Add-Member -MemberType NoteProperty -Name BuildQueueSize -Value $buildQueueCount
$reportData | Add-Member -MemberType NoteProperty -Name TotalFreeSpaceGB -Value $totalFreeSpaceGB
#$reportData



function  get-table {
param(
  [Parameter(Mandatory=$true) ][System.Object] $tableObject
  ,[Parameter(Mandatory=$true) ][System.Object] $alternateColour= "#f2f2f2"
 )
 
 $body=@()
 $name = $tableObject.name
 $body+="<table>"
$body+="<caption style=`"background-color:$alternateColour;`">TeamCity Agent: $name</caption>"
$body+="<tr><td><strong>No.</strong></td><td><strong> Property</strong></td> <td><strong>Value</strong></td></tr>"
$index=1
$tableObject.PSObject.Properties | ForEach-Object {

if( $_.name -ne $Null){
 $prop    =  $_.Name
 $value   =  $_.Value
 $prop    =  $prop.toLower()
 if($prop -in @('agentsconnected','agentsenabled','agentsauthorized', 'agentsuptodate') -and $value.toString().trim() -ne "100.00%"){
    $style = "style=`"background-color: #eb6e9a;`""
 }elseif($prop -in @('connected','enabled','authorized', 'uptodate') -and $value.toString() -ne "true"){
    $style = "style=`"background-color: #eb6e9a;`""
 }elseif($prop -eq 'buildqueuesize ' -and $value.toString() -ne "0"){
      $style = "style=`"background-color: #faae4b;`""
 }elseif($prop -eq "work.dir.freespacemb" -and $value -lt ($totalFreeSpace/$agentCount) ){
         $style = "style=`"background-color: #eb6e9a;`""
 }elseif($prop -eq "totalfreespacegb" -and $value.Replace("GB","") -lt ("4000.00") ){
         $style = "style=`"background-color: #eb6e9a;`""
 }else{
   $style = if($index %2 -eq 0){"style=`"background-color: $alternateColour;`""}else{""}
   }
   $body+="<tr $style ><td>$index</td><td> $prop </td>  <td>$value</td></tr>"
    ++$index
    }
 }
$body+="</table>"
 return $body -join ""
}



$ownerFirstName  =  'Mobolaji'
$senderFirstName =  'TeamcityMonitor'
$body =" Hello.<br/>"
$body+="<br/>"
$body+="Trust this meets you well.<br/>"
$body+="<br/>"
$body+="Please see the report below for the status of Teamcity in RENO."
$body+="<br />"
$body+="<style>
<style>
table, th, td {
  border: 1px solid black;
  border-collapse: collapse;
}
th, td {
  padding: 10px;
  text-align: left;
}
table{
  width: 50%;    
}
</style>"

$body+= get-table $reportData "#afbfdb"
$body+="<br />"
$agentInventory| %{
	$body+= get-table $_ "#afbfdb"
	
	$body+="<br />"
}
$body+="<br />"

$body+="<br />"
$body+="Have a great day."
$body+="<br />"
$body+="<br />"
$body+="Best Regards,"
$body+="<br />"
$body+="<br />"
$body+=$senderFirstName
$password = if([string]::IsNullOrEmpty($vmInfo.emailPassword)){""} else{$vmInfo.emailPassword};

 #$email_password            = ConvertTo-SecureString $password -AsPlainText -Force
 #$email_credential          = New-Object System.Management.Automation.PSCredential ($vmInfo.emailUser, $email_password)
 
 $VmName  =$vmInfo.name
 $reportDate= (get-date).ToString("yyyy-MM-ddhh-mm-ss") 
$sendMailParams = @{
    From        ='TeamcityMonitor@igt.com'
    To          = 'Mobolaji.Aina@igt.com'
    #Cc          = $ccAddress
    Subject     = "Teamcity Status Report at $reportDate"
    Body        = $body
	SMTPServer  = "156.24.14.132"
	Port        = 25
	UseSsl      = $false
	BodyAsHtml  = $true
  #  Credential  = $email_credential
}
Send-MailMessage @sendMailParams