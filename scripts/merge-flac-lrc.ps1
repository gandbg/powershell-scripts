param (
	[Parameter(Mandatory=$true)][string]$WorkingPath
)

function Write-Info {
	param (
		[Parameter(Mandatory=$true)][string]$Message
	)
	Write-Host ">> $Message" -ForegroundColor Green
}

Set-Location $WorkingPath

$FileMap = @()

Write-Info "Mapping files"

Get-ChildItem -Path '.\*' -Include '*.flac' | ForEach-Object {
	$FlacFile = $_

	if(Test-Path -LiteralPath ([System.IO.Path]::ChangeExtension($FlacFile, '.lrc')) -Type Leaf){
		$LrcFile = Get-Item -LiteralPath ([System.IO.Path]::ChangeExtension($FlacFile, '.lrc'))
	} else {
		$LrcFile = $false
	}

	$FileMap += [PSCustomObject]@{
		FLAC = $FlacFile
		LRC = $LrcFile
	}
}

if(($FileMap | Where-Object LRC -ne $false).Count -lt (Get-ChildItem -Path '.\*' -Include '*.flac').Count){
	Write-Warning "It appers that some FLAC files don't have a corresponding LRC file"
	Write-Warning "Found $((Get-ChildItem -Path '.\*' -Include '*.flac').Count) FLAC file(s)"
	Write-Warning "But only $(($FileMap | Where-Object LRC -ne $false).Count) LRC file(s)"
	pause
}

$FileMap | Where-Object LRC -ne $false | ForEach-Object {
	Write-Info "Merging ""$([System.IO.Path]::GetFileName($_.FLAC))"" with ""$([System.IO.Path]::GetFileName($_.LRC))"""

	metaflac --preserve-modtime --remove-tag=LYRICS $_.FLAC
	metaflac --preserve-modtime "--set-tag-from-file=LYRICS=$($_.LRC)" $_.FLAC

	Remove-Item -LiteralPath $_.LRC
}
