param (
	[Parameter(Mandatory=$true)][string]$WorkingPath,
	[switch]$TestRun
)

#Function to map BCP 47 language codes to English names
#Returns $null if the code is not mapped
function Convert-LanguageCode {
	param (
		[Parameter(Mandatory=$true)][string]$LanguageCode,
		[Parameter(Mandatory=$true)][AllowEmptyString()][string]$LanguageCodeIetf
	)

	if($LanguageCodeIetf -ne ''){
		$LanguageName = [System.Globalization.CultureInfo]::GetCultureInfoByIetfLanguageTag($LanguageCodeIetf).EnglishName
		if($LanguageName -match "\(\w\w\)"){
			return $null
		} else {
			return $LanguageCode
		}
	}

	switch ($LanguageCode) {
		eng {"English"}
		ger {"German"}
		ita {"Italian"}
		Default {$null}
	}
}

#Function to obtain the audio tracks, along with their language, from a Matroska file and modity its title
function Invoke-TrackRenaming {
	param (
		[Parameter(Mandatory=$true)][string]$WorkingFile
	)

	# Get all audio tracks
	$Tracks = (mkvmerge --identification-format json --identify $WorkingFile | ConvertFrom-Json).tracks | Where-Object type -eq "audio"

	#Process each track
	foreach($Track in $Tracks){
		$Track.language
		#Get track language
		$TrackLanguage = Convert-LanguageCode -LanguageCode $Track.properties.language -LanguageCodeIetf $Track.properties.language_ietf

		#Actually modify the file only if the language code was converted and the run is not a test
		if (($null -ne $TrackLanguage) -and ($TestRun -eq $false)) {
			Write-Error "Edit logic"
		} elseif ($TestRun -eq $true) {
			Write-Host "File: $WorkingFile `n>> Track: $($Track.id) `n>> Language: $($Track.properties.language) converted to $TrackLanguage"
		} else {
			Write-Error "Not supported"
		}
	}
}

# Check if provided path is a directory or a file
if((Get-Item -Path $WorkingPath) -Is [System.IO.DirectoryInfo]){
	$FileArray = Get-ChildItem -Path $($WorkingPath.Trim()+'/*') -Include *.mkv

	foreach($File in $FileArray){
		Invoke-TrackRenaming -WorkingFile $File
	}
} else {
	Invoke-TrackRenaming -WorkingFile $WorkingPath
}
