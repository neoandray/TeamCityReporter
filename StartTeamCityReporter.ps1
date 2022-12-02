
$jsonConfig = Get-Content -Path $PSSCriptRoot"\config.json"
$config     =  $jsonConfig|ConvertFrom-Json 
[System.Environment]::SetEnvironmentVariable('TeamcityStatusMonitor','IsRunning')
$startTime = get-date 
$interval    =$config.minsInterval*60
Start-Process -FilePath "powershell" -WorkingDirectory $PSSCriptRoot  -ArgumentList  "-executionpolicy","Bypass", "-file",  "C:\Users\jgw51912\Documents\T\TeamCity\get_agent_status.ps1"
set-content -Path $PSSCriptRoot"\pid.txt" -value   $pid
while($env:TeamcityStatusMonitor -eq 'IsRunning'){
    $elaspedTime =  (Get-Date)-$startTime

     $seconds = ($elaspedTime.TotalMilliseconds) /1000
    if($seconds -ge $interval){
     write-host "running"
        Start-Process -FilePath "powershell" -WorkingDirectory $PSSCriptRoot  -ArgumentList  "-executionpolicy","Bypass", "-file",  "C:\Users\jgw51912\Documents\T\TeamCity\get_agent_status.ps1"
        $startTime = get-date 
    }else{
   
     write-host "Elasped: $seconds seconds elapsed out of $interval"

    }
    Start-Sleep -Seconds 5
}
