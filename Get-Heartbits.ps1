function GetRolePulse
{
    $RX_MBytes = 0
    $TX_MBytes = 0

    # Get an object for the network interfaces, excluding any that are currently disabled.
    $colInterfaces = Get-WmiObject -class Win32_PerfFormattedData_Tcpip_NetworkInterface | select BytesReceivedPersec, BytesSentPersec

    foreach ($interface in $colInterfaces) {
        $RX_MBytes += $interface.BytesReceivedPersec / 1024 / 1024
        $TX_MBytes += $interface.BytesSentPersec / 1024 / 1024
    }

    $RX = [Math]::Round($RX_MBytes, 2)
    $TX = [Math]::Round($TX_MBytes, 2)

    $memfree = (Get-WmiObject Win32_OperatingSystem).FreePhysicalMemory
    $memfreeMB = [Math]::Round($memfree / 1024, 0)

    $pf = (Get-WmiObject Win32_PerfFormattedData_PerfOS_memory).PageFaultsPerSec
    $hardpage = (Get-WmiObject Win32_PerfFormattedData_PerfOS_memory).PagesPerSec
    $iowrite = (Get-WmiObject Win32_PerfFormattedData_PerfProc_Process | Where-Object { $_.Name -eq "_Total"}).IOWriteOperationsPersec
    $cpu = (Get-WmiObject Win32_Processor).LoadPercentage

    $timestamp = $(Get-Date).ToUniversalTime()

    $out = Write-Output "$timestamp RX=$RX MBps, TX=$TX MBps, CPU=$cpu, FreePhysicalMemory=$memfreeMB MB, PageFaultsPerSec=$pf, PagesPerSec=$hardpage, DiskIOWritePerSec=$iowrite"
    $out
    $out | Out-File -Append pulse.txt
}

while (1)
{
    GetRolePulse
    Start-Sleep -Milliseconds 300
}