function ListActivePorts(){
$hostAddresses = @{}
Get-PrinterPort | Select-Object -Property Name, PrinterHostAddress| % {
  $hostAddresses.Add($_.Name, $_.PrinterHostAddress)

  }

  Get-WmiObject Win32_Printer | % {
    $HostAddress=$hostAddresses[$_.PortName]
    if($HostAddress){
      New-Object PSObject -Property @{
        "Name" = $_.Name
        "Shared" = $_.Shared
        "DriverName" = $_.DriverName
        "Port-Name" = $_.PortName
        "HostAddress" = $hostAddress   
      } 
    }
  }
}

#Write-Host "Name;HostAddress;DriverName;Shared"
#ListActivePorts | % { Write-Host "$($_.Name);$($_.HostAddress);$($_.DriverName);$($_.Shared)" } 
