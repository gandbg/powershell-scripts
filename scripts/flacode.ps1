param (
	[String[]][Parameter(Mandatory=$true)]$WorkingPath
)

function Get-FileInfo {
	param (
		[String[]]$FilePath
	)

	$FileInfoRaw = Get-Item -Path $FilePath
	$FileInfo = [PSCustomObject]@{
		Name = [System.IO.Path]::GetFileNameWithoutExtension($FileInfoRaw.Name)
		Extension = $FileInfoRaw.Extension
		LastAccessTime = $FileInfoRaw.LastAccessTime
		LastWriteTime = $FileInfoRaw.LastWriteTime
		CreationTime = $FileInfoRaw.CreationTime
	}

	return $FileInfo
}

function Assert-File {
	param (
		[String[]]$WorkingFile
	)

	$FileInfo = Get-FileInfo -FilePath $WorkingFile
	$TemporaryFileName = [System.IO.Path]::GetDirectoryName($WorkingFile) + '/' + $FileInfo.Name + '_encode' + $FileInfo.Extension
	$OriginalFileName = [System.IO.Path]::GetDirectoryName($WorkingFile) + '/' + $FileInfo.Name + $FileInfo.Extension

	flac -8 "$WorkingFile" -o $TemporaryFileName
	Start-Sleep -Milliseconds 200
	Remove-Item -Path $OriginalFileName
	Rename-Item -Path $TemporaryFileName -NewName $OriginalFileName -Force

	Set-ItemProperty -Path $OriginalFileName -Name CreationTime -Value $FileInfo.CreationTime
	Set-ItemProperty -Path $OriginalFileName -Name LastWriteTime -Value $FileInfo.LastWriteTime
	Set-ItemProperty -Path $OriginalFileName -Name LastAccessTime -Value $FileInfo.LastAccessTime
}

# Check if provided path is a directory or a file
if( (Get-Item -Path $WorkingPath) -Is [System.IO.DirectoryInfo] ){
	$FileArray = Get-ChildItem -Path $($WorkingPath.Trim()+'/*') -Include *.flac

	foreach($File in $FileArray){
		Assert-File -WorkingFile $File
	}
} else {
	Assert-File -WorkingFile $WorkingPath
}
