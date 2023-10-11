function Get-ItemDateTimeAttributes {
	param (
		[Parameter(Mandatory=$true)][string]$Path
	)

	$ItemAttributes = Get-ItemProperty -Path $Path

	return [PSCustomObject]@{
		CreationTime = $ItemAttributes.CreationTimeUtc
		LastAccessTime = $ItemAttributes.LastAccessTimeUtc
		LastWriteTime = $ItemAttributes.LastWriteTimeUtc
	}
}

function Set-ItemDateTimeAttributes {
	param (
		[Parameter(Mandatory=$true)][string]$Path,
		[Parameter(Mandatory=$true)][PSCustomObject]$Data
	)

	Set-ItemProperty -Path $Path -Name CreationTimeUtc -Value $Data.CreationTime
	Set-ItemProperty -Path $Path -Name LastWriteTimeUtc -Value $Data.LastWriteTime
	Set-ItemProperty -Path $Path -Name LastAccessTimeUtc -Value $Data.LastAccessTime
}
