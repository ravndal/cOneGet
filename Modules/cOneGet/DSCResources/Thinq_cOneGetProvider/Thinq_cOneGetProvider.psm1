function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$PackageProvider
	)

    $package = Get-PackageProvider -Name $PackageProvider -Verbose
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.String]
        $PackageProvider
    )

	Write-Verbose "Since we can't add providers, this will just run without doing anything"
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.String]
        $PackageProvider
    )

    $package = Get-PackageProvider -Name $PackageProvider -Verbose
    if($package -eq $null) {
    	Write-Verbose ("PackageProvider '{0}' does not exist" -f $foo) -Verbose
    	return $false
    }
    return $true
}


Export-ModuleMember -Function *-TargetResource

