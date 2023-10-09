param (
	[Parameter(Mandatory=$true)][string]$WorkingPath,
	[switch]$TestRun
)

#Function to convert language codes to English names
#Matroska v4 uses IETF codes supported by Powershell, but for Matroska v3 (or prior) a manual mapping is needed
#Returns $null if the code is not mapped
function Convert-LanguageCode {
	param (
		[Parameter(Mandatory=$true)][string]$LanguageCode,
		[Parameter(Mandatory=$true)][AllowEmptyString()][string]$LanguageCodeIetf
	)

	if($LanguageCodeIetf -ne ''){
		$LanguageName = [System.Globalization.CultureInfo]::GetCultureInfoByIetfLanguageTag($LanguageCodeIetf).EnglishName

		#If the code is not recognized the output is "Unkown Language ({the lanugage code})"
		if($LanguageName -match "\(\w\w\)"){
			return $null
		} else {
			return $LanguageName
		}
	}

	switch ($LanguageCode) {
		cze {"Czech"}
		dan {"Danish"}
		dut {"Dutch"}
		eng {"English"}
		fin {"Finnish"}
		fre {"French"}
		ger {"German"}
		hin {"Hindi"}
		hun {"Hungarian"}
		ita {"Italian"}
		kor {"Korean"}
		nob {"Norwegian Bokmål"}
		pol {"Polish"}
		por {"Portuguese"}
		rus {"Russian"}
		spa {"Spanish"}
		swe {"Swedish"}
		tha {"Thai"}
		tur {"Turkish"}
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
		#Get track language
		$TrackTitle = Convert-LanguageCode -LanguageCode $Track.properties.language -LanguageCodeIetf $Track.properties.language_ietf

		# If the track name is 'und' (Undefined) use format: Codec / Channel count / Sampling frequency
		if(($Track.properties.language -eq 'und') -and ($Track.properties.language_ietf -eq 'und')){
			$TrackTitle = "$($Track.codec) / $($Track.properties.audio_channels) Channel(s) / $($Track.properties.audio_sampling_frequency) Hz"
		}

		#Actually modify the file only if the language code was converted and the run is not a test
		if (($null -ne $TrackTitle) -and ($TestRun -eq $false)) {
			$TrackId = $Track.id + 1
			mkvpropedit $WorkingFile --edit "track:$TrackId" --set "name=$TrackTitle" --quiet
		} elseif ($TestRun -eq $true) {
			Write-Host "File: $WorkingFile"
			Write-Host ">> Track: $($Track.id)"
			Write-Host ">> Language: $($Track.properties.language) converted to $TrackTitle"
		} else {
			Write-Error "Language code not mapped"
		}
	}

	Write-Host ">> Renamed audio tracks of $WorkingFile" -ForegroundColor Green
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
