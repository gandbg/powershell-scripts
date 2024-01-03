param (
	[Parameter(Mandatory=$true)][string]$WorkingPath
)

# Check to see if ffprobe is available
try {
	ffmpeg -version | Out-Null
}
catch {
	Write-Error "FFProbe is not avaiable"
	exit
}

function Invoke-FileAnalysis {
	param (
		[Parameter(Mandatory=$true)][string]$WorkingFile
	)

	# Read the file with FFProbe
	$FileData = ffprobe -v quiet -print_format json -show_format -show_streams $WorkingFile | ConvertFrom-Json
	$AudioStream = $FileData.streams | Where-Object codec_type -EQ "audio"

	<#
		The bitrate of an uncompressed PCM audio stream is = Sample rate in Herts * Bit depth in Bits * Channels
		So for a CDDA-like stream the calculator is: 44100 * 16 * 2 = 1411200 Bits per second
		We can then multiply this by the ammount of seconds the streams lasts and the divide by 8 to convert from Bits to Bytes (1 Byte = 8 Bits)

		---

		Only the first number is converted from string to number since the others are handled by PowerShell itself
		    Sample rate                                  (times)        Bit depth           (times)     Channels    (times)    Seconds      (Bits to byte)
	#>
	$Size = [System.Int32]::Parse($AudioStream.sample_rate) * $AudioStream.bits_per_raw_sample * $AudioStream.channels * $FileData.format.duration / 8
	return $Size
}

$TotalSize = 0

$FileArray = Get-ChildItem -Path $($WorkingPath.Trim()+'/*') -Include *.flac

foreach($File in $FileArray){
	$TotalSize += Invoke-FileAnalysis -WorkingFile $File
}

Write-Host "The total calculated size is $TotalSize B, $([System.Math]::Truncate($TotalSize / 1000000)) MB, $([System.Math]::Truncate($TotalSize / 1000000000)) GB"
