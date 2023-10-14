param (
	[Parameter(Mandatory=$true)][string]$ResourcePath
)
$ResourcePath = $ResourcePath -replace '"',''

function Write-Info {
	param (
		[Parameter(Mandatory=$true)][string]$Message
	)
	Write-Host ">> $Message" -ForegroundColor Green
}

Write-Info "Preparing..."

Set-Location "$env:USERPROFILE\Desktop"

$DownloadPath = "$env:USERPROFILE\Desktop\download"
$DownloadPathIsAcceptable = $false

while ($DownloadPathIsAcceptable -eq $false) {
	#Check if directory already exists, creating a folder only if it doesn't
	if(Test-Path -Path $DownloadPath -PathType Container){
		$DownloadPath = "$env:USERPROFILE\Desktop\download" + '-' + (Get-Random -Minimum 1 -Maximum 99)
	} else {
		New-Item -Path $DownloadPath -ItemType Directory | Out-Null
		$DownloadPathIsAcceptable = $true
	}
}

$Resource = Get-Content $ResourcePath -Encoding UTF8 | ConvertFrom-Json
$Resource | ForEach-Object {
	New-Item -Path $DownloadPath -Name $_.name -ItemType Directory | Out-Null
}

$DownloadedHTMLBasedResources = @()

Start-Sleep -Milliseconds 40

Write-Info "Downloading resources"

$Resource | ForEach-Object {
	Write-Info "Downloading topic ""$($_.name)"""
	Set-Location (Join-Path -Path $DownloadPath -ChildPath "$($_.name)")

	$_.subtopic | ForEach-Object {
		$SubtopicName = $_.name
		New-Item -Path (Get-Location) -Name $SubtopicName -ItemType Directory | Out-Null

		#The URL of items with launchBrowser = $true is not a direct download and needs to be handled differently
		$_.subtopic | Where-Object launchBrowser -eq $false | ForEach-Object {
			Write-Host ">> >> Downloading $($_.name)" -ForegroundColor DarkGray
			Start-BitsTransfer -Source $_.url -Destination $SubtopicName
		}

		# Handling of HTML-Based (launchBrowser = $true) items
		$_.subtopic | Where-Object launchBrowser -eq $true | ForEach-Object {
			Write-Host ">> >> Downloading HTML-Based resource: $($_.name)" -ForegroundColor DarkGray

			#URL for reference: https://it-content.pearson.com/products/f82b28a9-8688-4cbb-976d-0fbcf844d5d8/video_u01/asset_8077072.html
			if([regex]::Match($_.url, 'https?:\/\/[a-z]{2}-content\.pearson\.com\/products\/\S{36}\/\S*\/\S*\.html').Success){
				$JSONUrl = [regex]::Replace($_.url, '(https?:\/\/[a-z]{2}-content\.pearson\.com\/products\/\S{36}\/\S*)\/(\S*)\.html', '$1/assets/$2.json')
				$JSONData = Invoke-RestMethod -Uri $JSONUrl
				$ZipPath = $JSONData.zip_path -replace 'http:','https:'

				#Multiple resources can have the same zip file
				if($DownloadedHTMLBasedResources[-1] -ne $ZipPath){
					Start-BitsTransfer -Source $ZipPath -Destination $SubtopicName
					$DownloadedHTMLBasedResources += $ZipPath
				}
			}
		}
	}

	Set-Location (Resolve-Path -Path ((Get-Location).Path + '\..\..'))
}
