function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$PackageSource
	)

    $package = Get-PackageSource -Name $PackageSource -Verbose
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure = "Present",

		[parameter(Mandatory = $true)]
		[System.String]
		$PackageSource
	)

    if ($Ensure -eq 'Present')
    {
        Write-Verbose "Adding package source:" $PackageSource
        Register-PackageSource -Name $PackageSource -Force -Verbose
    }
    elseif ($Ensure -eq 'Absent')
    {
        Write-Verbose "Removing package source:" $PackageSource
        Unregister-PackageSource -Name $PackageSource -Force -Verbose
    }
}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure = "Present",

		[parameter(Mandatory = $true)]
		[System.String]
		$PackageSource
	)

    $source = Get-PackageSource $PackageSource

    if (($Ensure -eq 'Present') -and ($source -eq $null))
    {
        Write-Verbose "Ensure is set to $Ensure, but packagesource is absent"
        return $false
    }
    elseif (($Ensure -eq 'Absent') -and ($source -eq $null))
    {
        Write-Verbose "Ensure is set to $Ensure, and packagesource is absent"
        return $true
    }
    elseif (($Ensure -eq 'Present') -and ($source -ne $null))
    {
        Write-Verbose "Ensure is set to $Ensure, and packagesource is present"
        return $true
    }
    elseif (($Ensure -eq 'Absent') -and ($source -ne $null))
    {
        Write-Verbose "Ensure is set to $Ensure, but packagesource is present"
        return $false
    }

    Write-Verbose "Ensure is set to $Ensure, but packagesource is $source"
    return $false
}


Export-ModuleMember -Function *-TargetResource

