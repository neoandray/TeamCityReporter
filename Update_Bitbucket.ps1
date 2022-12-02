#get-template
#connect-viserver -server '172.22.38.56'
#get-vmHost|get-datastore| sort -pro FreeSpaceGB -Descending
#get-vm|  select *,@{N="IP_Address";E={@($_.Guest.IPAddress)| WHERE -filter{$_ -notmatch ':' }  }}, @{N="VMX_File";E={$_.Extensiondata.Summary.Config.VmPathName}}

#$vmInfo = @{}
#$vmInfo["templates"] = get-template| SELECT NAME;
#$vmInfo["hosts"]= get-vmhost| select NAME, @{n='CPUCores';e={$_.Numcpu}}, @{n='FreeMemory'; e={$_.MemoryTotalGB - $_.MemoryUsageGB}},@{n='FreeCPU'; e={$_.CpuTotalMhz - $_.CpuUsageMhz}}|Sort -Property FreeMemory,FreeCPU  -Descending 
#$vmInfo["hostDatastoreMap"] =get-vmhost|foreach{$vmhost= $_;$vmhost|get-datastore | select  @{n='HostName';e={$vmhost.Name}}, @{n='DataStoreName';e={$_.Name}}, CapacityGB, FreeSpaceGB|Sort -property FreeSpaceGB -Descending } 
#$vmInfo["hostNetworkMap"] =get-vmhost|foreach{$vmhost= $_;$vmhost|get-virtualportGroup | select  @{n='HostName';e={$vmhost.Name}}, @{n='NetworkName';e={$_.Name}} }  
#$vmInfo |convertto-json
#get-vmhost| select NAME, @{n='CPUCores';e={$_.Numcpu}}, @{n='FreeMemory'; e={$_.MemoryTotalGB - $_.MemoryUsageGB}},@{n='FreeCPU'; e={$_.CpuTotalMhz - $_.CpuUsageMhz}} | SORT -Property FreeMemory,FreeCPU  -Descending


function Update-BitBucket{
param(
      [Parameter(Mandatory=$true) ][System.Object] $location
     , [Parameter(Mandatory=$true) ][System.Object] $message
     , [Parameter(Mandatory=$true) ][System.Object] $remoteRepo
     
)

$addCommand    =  "git add ."
$commitCommand =  "git commit -am '$message'"
$pushCommand   =  "git push origin $remoteRepo"

 set-location  $location
 invoke-expression -Command $addCommand
 invoke-expression -Command $commitCommand 
 invoke-expression -Command $pushCommand 

}


$jenkins="jenkins"
$vmSharedLibrary="jenkins"


$projectName="jenkins"


 $projectLocation1 = 'C:\Users\jgw51912\Documents\J\Jenkins\Pipelines\Script_Tests'
 $projectLocation2 ='C:\Users\jgw51912\Documents\J\Jenkins\Shared_Libraries\vmware'
 
 #$codeError="groovy.lang.MissingPropertyException: No such property: vmSpecsMap for class: groovy.lang.Binding"
 
 
 $attempt+=1
 $commitMessage1   = "Attempt $attempt - Correct Error: Dependent dropdown list"
 $commitMessage2= "Add getVMHostMap function"
 #$commitMessage1  = "Add to JSON function"
 
 $remoteRepo1  = "main"
 $remoteRepo2   = "master"

if($projectName -eq $jenkins){
    Update-BitBucket    $projectLocation1  $commitMessage1 $remoteRepo1
} elseif($projectName -eq $vmSharedLibrary){
Update-BitBucket    $projectLocation2  $commitMessage2 $remoteRepo2
}
