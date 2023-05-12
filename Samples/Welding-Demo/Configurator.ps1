<#
.SYNOPSIS
    Set up the end to end solution using the Aks Edge Essentials cluster.

.DESCRIPTION
    Runs the configuration to get the solution up and running
    1) Configures Grafana and components
    2) Deploys the Kubernetes solution
    3) Grab services information and configure Telegraf
    4) Open Grafana dashboard
    
.OUTPUTS
    Bool

.PARAMETER clean
    Input parameter to clean previous Welding Demo deployment

#>
param (
    [bool] $clean
)

Write-Host "1. Starting Welding Demo configuration" -ForegroundColor Green
$origPath = Get-Location

Write-Host "2. Installing Grafana dependencies" -ForegroundColor Green
Set-Location "C:\Program Files\GrafanaLabs\grafana\bin"
.\grafana-cli.exe plugins install ryantxu-ajax-panel
.\grafana-cli.exe plugins install agenty-flowcharting-panel
.\grafana-cli.exe plugins install cloudspout-button-panel

Write-Host "3. Restarting Grafana service" -ForegroundColor Green
Restart-Service -Name Grafana
Set-Location $origPath

if($clean)
{
    Write-Host "4. Cleaning previous deployments" -ForegroundColor Green
    kubectl delete -f .\welding-demo.yaml
}
else{
    Write-Host "4. No need to clean previous deployments" -ForegroundColor Green
}

Write-Host "5. Aplying new deployment configuration" -ForegroundColor Green
kubectl apply -f .\welding-demo.yaml

Write-Host "6. Ensure all the Grafana components are delted (Dashabords, Datasource and APIKey)" -ForegroundColor Green
$confirmation = Read-Host "Ready? [y/n]"
while($confirmation -ne "y")
{
    if ($confirmation -eq 'n') {exit}
    $confirmation = Read-Host "Ready? [y/n]"
}

Write-Host "7. Getting new deployment configuration" -ForegroundColor Green

$telegrafJson = kubectl get svc telegraf-svc -o json | ConvertFrom-Json
$telegrafIP = $telegrafJson.spec.loadBalancerIP
$telegrafPort = $telegrafJson.spec.ports.nodePort
if([string]::IsNullOrEmpty($telegrafIP) -or [string]::IsNullOrEmpty($telegrafPort))
{
    Write-Host "Error with Telegraf service (${telegrafIP}:${telegrafPort}) - Manually check the service" -ForegroundColor Red
    return $false
}
Write-Host "   Telegraf running on $telegrafIP and port $telegrafPort" -ForegroundColor Cyan

$influxDbJson = kubectl get svc influxdb-svc -o json | ConvertFrom-Json
$influxDbIP = $influxDbJson.spec.loadBalancerIP
$influxDbPort = $influxDbJson.spec.ports.nodePort
if([string]::IsNullOrEmpty($influxDbIP) -or [string]::IsNullOrEmpty($influxDbPort))
{
    Write-Host "Error with InfluxDb service (${influxDbIP}:${influxDbPort}) - Manually check the service" -ForegroundColor Red
    return $false
}
Write-Host "   InfluxDb running on $influxDbIP and port $influxDbPort" -ForegroundColor Cyan

$opcuaJson = kubectl get svc opcua-svc -o json | ConvertFrom-Json
$opcuaIP = $opcuaJson.spec.loadBalancerIP
$opcuaPort = $opcuaJson.spec.ports.nodePort
if([string]::IsNullOrEmpty($opcuaIP) -or [string]::IsNullOrEmpty($opcuaPort))
{
    Write-Host "Error with OPCUA service (${opcuaIP}:${opcuaPort}) - Manually check the service" -ForegroundColor Red
    return $false
}
Write-Host "   OPCUA running on $opcuaIP and port $opcuaPort" -ForegroundColor Cyan

Write-Host "8. Restoring telegraf to default configuration" -ForegroundColor Green
Set-Location "C:\Program Files\InfluxData\telegraf\"
.\telegraf.exe --service uninstall --config "C:\Program Files\InfluxData\telegraf\telegraf.conf"
Set-Location $origPath
Copy-Item .\telegraf\telegraf.conf 'C:\Program Files\InfluxData\telegraf\telegraf.conf'

Write-Host "9. Aplying new deployment configuration" -ForegroundColor Green
python .\grafana\configure.py -influxip $influxDbIP -influxport $influxDbPort -opcuaip $opcuaIP -opcuaport $opcuaPort -telegrafip $telegrafIP -telegrafport $telegrafPort

Write-Host "10. Aplying new telegraf configuration" -ForegroundColor Green
Set-Location "C:\Program Files\InfluxData\telegraf\"
.\telegraf.exe --service install --config "C:\Program Files\InfluxData\telegraf\telegraf.conf"
.\telegraf.exe --service start
Set-Location $origPath

Write-Host "11. Configuration completed - Opening Grafana Dashboard" -ForegroundColor Green
Start-Process microsoft-edge:http://localhost:3000