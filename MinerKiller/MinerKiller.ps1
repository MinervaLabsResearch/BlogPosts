# The function "Killer" was adapted from a miner eliminating its competitors
# Can be used to fight back against this malware, alongside others
# Provided with zero liability (!)
# 
# Full details are available in our blog post:
# https://blog.minerva-labs.com/ghostminer-cryptomining-malware-goes-fileless

Function Killer
{

	# Remove known miners by services names
	$SrvName = "xWinWpdSrv", "SVSHost","Microsoft Telemetry","lsass","Microsoft","system","Oracleupdate","CLR","sysmgt","\gm","WmdnPnSN", 
	"Sougoudl","Nationaaal","Natimmonal","Nationaloll"
	foreach ($Srv in $SrvName)
	{

#		Set-Service -Name $Srv -StartupType Disabled -ErrorAction SilentlyContinue

#		Stop-Service -Name $Srv -Force -ErrorAction SilentlyContinue

		$Null = SC.exe Config $Srv Start= Disabled
		$Null = SC.exe Stop $Srv
		$Null = SC.exe Delete $Srv
	}

	# Remove known miners by scheduled tasks names
	$TaskName = "Mysa","Mysa1","Mysa2","Mysa3","ok", "Oracle Java","Oracle Java Update","Microsoft Telemetry","Spooler SubSystem Service",
	"Oracle Products Reporter","Update service for  products","gm","ngm"

	foreach ($Task in $TaskName)
	{
		SchTasks.exe /Delete /TN $Task /F 2> $Null
	}

	
	# Terminates and removes miners by indicative command line arguments
	$CmdLine = Get-WmiObject -Class Win32_Process | Where-Object {$_.CommandLine -like '*cryptonight*' -Or $_.CommandLine -like '*stratum+*' 
	-Or $_.CommandLine -like '*--donate-level*' -Or $_.CommandLine -like '*--max-cpu-usage*' -Or $_.CommandLine -like '*-p x*' 
	-Or $_.CommandLine -like '*pool.electroneum.hashvault.pro*'}
	
	if ($CmdLine -ne $Null)
	{
		$PathArray = @()
		foreach ($m in $CmdLine)
		{
			$evid = $($m.ProcessId)
			# The line below is wasn't originally commented, it white-lists the miner itself
			# if (($evid -eq $PId) -or ($evid -eq $minerPId)) { continue }
			Write-Host "[i] Miner PId: $evid"
			Get-Process -Id $evid | Stop-Process -Force

			
			# Create an array of competing miners' paths to remove
			$Path = $($m.Path)
			if ($Path -eq "$Env:WinDir\System32\cmd.exe" -Or $Path -eq "$Env:WinDir\SysWOW64\cmd.exe" -Or $Path -eq "$Env:WinDir\Explorer.exe" -Or $Path -eq "$Env:WinDir\Notepad.exe") { continue }
			if ($PathArray -NotContains $Path) { $PathArray+=$Path }
		}

		
		# Remove miners from the disk
		foreach ($Path in $PathArray)
		{
			for ($i=0; $i -lt 30; $i++)
			{
				Remove-Item $Path -Force -ErrorAction SilentlyContinue
				if (Test-Path $Path)
				{
					Start-Sleep -Milliseconds 100
				}
				else
				{
					$Null = New-Item $Path -Type Directory -ErrorAction SilentlyContinue
					if ($?)
					{
						$file = Get-Item $Path -Force
						$file.CreationTime = '10/10/2000 10:10:10'
						$file.LastWriteTime = '10/10/2000 10:10:10'
						$file.LastAccessTime = '10/10/2000 10:10:10'
						$file.Attributes = "ReadOnly","System","Hidden"
					}
					break
				}
			}
		}
	}

	
	# Uses netstat to list all "ESTABLISHED" connections
	# Afterwards it filters lines containing ports associated with miners and terminates the process using it
	[array]$psids = Get-Process -Name PowerShell | Sort CPU -Descending | ForEach-Object {$_.Id}
	$tcpconn = NetStat -anop TCP
	if ($psids -ne $null)
	{
		foreach ($t in $tcpconn)
		{
			$line = $t.split(' ')| ?{$_}
			if ($line -eq $null) { continue }
			if (($psids[0] -eq $line[-1]) -and $t.contains("ESTABLISHED") -and ($t.contains(":80 ") -or $t.contains(":443 ") -or $t.contains(":1111") -or $t.contains(":2222") -or $t.contains(":3333") -or $t.contains(":4444") -or $t.contains(":5555") -or $t.contains(":6666") -or $t.contains(":7777") -or $t.contains(":8888") -or $t.contains(":9999") -or $t.contains(":14433") -or $t.contains(":14444") -or $t.contains(":45560") -or $t.contains(":65333")))
			{
				$evid = $line[-1]
				
				# The line below is wasn't originally commented, it white-lists the miner itself
				# if (($evid -eq $PId) -or ($evid -eq $minerPId)) { continue }
				Write-Host "[i] Miner PId: $evid"
				Get-Process -Id $evid | Stop-Process -Force
			}
		}
	}

	# Uses netstat to list all "ESTABLISHED" connections
	# Afterwards it lists processes connecting to remote ports associated with miners and terminates it
	foreach ($t in $tcpconn)
	{
		$line = $t.split(' ')| ?{$_}
		if (!($line -is [array])) { continue }
		if (($line[-3] -ne $null) -and $t.contains("ESTABLISHED") -and ($line[-3].contains(":1111") -or $line[-3].contains(":2222") -or $line[-3].contains(":3333") -or $line[-3].contains(":4444") -or $line[-3].contains(":5555") -or $line[-3].contains(":6666") -or $line[-3].contains(":7777") -or $line[-3].contains(":8888") -or $line[-3].contains(":9999") -or $line[-3].contains(":14433") -or $line[-3].contains(":14444") -or $line[-3].contains(":45560") -or $line[-3].contains(":65333")   -or $line[-3].contains(":55335")))
		{
			$evid = $line[-1]
			# The line below is wasn't originally commented, it white-lists the miner itself
			# if (($evid -eq $PId) -or ($evid -eq $minerPId)) { continue }
			Write-Host "[i] Miner PId: $evid"
			Get-Process -Id $evid | Stop-Process -Force
		}
	}

	# Remove known miners by known process names
	$Miner = "msinfo", "xmrig*","minerd","MinerGate","Carbon","yamm1","upgeade","auto-upgeade",'svshost',"SystemIIS","SystemIISSec",'WindowsUpdater*',"WindowsDefender*","update", "carss","service","csrsc","cara","javaupd","gxdrv", "lsmosee"
	
	foreach ($m in $Miner)
	{
		Get-Process -Name $m -ErrorAction SilentlyContinue | Stop-Process -Force
	}
}
