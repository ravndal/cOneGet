function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$PackageName,

        [ValidateSet("Chocolatey","NuGet","PSModule")]
        [System.String]
        $ProviderName = "Chocolatey"
	)

    $package = Get-Package -Name $PackageName -ProviderName $ProviderName
    $package
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
		[ValidateNotNullOrEmpty()]
		[System.String]
		$PackageName,

		[System.String]
		$RequiredVersion,

		[ValidateSet("Chocolatey","NuGet","PSModule")]
		[System.String]
		$ProviderName = "Chocolatey",

		[System.Management.Automation.PSCredential]
		$Credential,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        # [System.Collections.Hashtable]
		$CustomParameters
	)
    $p = ValidateParameteres $PSBoundParameters

    if ($Ensure -eq 'Present')
    {
        Write-Verbose "Installing package $PackageName"
        Install-Package @p
    }
    elseif ($Ensure -eq 'Absent')
    {
        Write-Verbose "Uninstalling package $PackageName"
        
        if($RequiredVersion -ne $null) 
        {
            $package = Get-Package -Name $PackageName -RequiredVersion $RequiredVersion -ProviderName $ProviderName
            Uninstall-Package $package -Force
        } else {
            Uninstall-Package -Name $PackageName -ProviderName $ProviderName -Force
        }
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
        [ValidateNotNullOrEmpty()]
        [System.String]
        $PackageName,

        [System.String]
        $RequiredVersion,

        [ValidateSet("Chocolatey","NuGet","PSModule")]
        [System.String]
        $ProviderName = "Chocolatey",

        [System.Management.Automation.PSCredential]
        $Credential,

        [PSObject]
        $CustomParameters
    )

    $package = Get-Package -Name $PackageName -ProviderName $ProviderName -ErrorAction SilentlyContinue

    if (($Ensure -eq 'Present') -and ($package -eq $null))
    {
        Write-Verbose "Ensure is set to $Ensure, but package is absent"
        return $false
    }
    elseif (($Ensure -eq 'Absent') -and ($package -eq $null))
    {
        Write-Verbose "Ensure is set to $Ensure, and package is absent"
        return $true
    }
    elseif (($Ensure -eq 'Present') -and ($package -ne $null))
    {
        Write-Verbose "Ensure is set to $Ensure, and package is present"
        return $true
    }
    elseif (($Ensure -eq 'Absent') -and ($package -ne $null))
    {
        Write-Verbose "Ensure is set to $Ensure, but package is present"
        return $false
    }

    Write-Verbose "Ensure is set to $Ensure, but package is $package"
    return $false

}

function ValidateParameteres {
    $p = @{};

    $p.Name = $PackageName
    $p.Remove("Ensure");
    $p.Remove("PackageName");

    # Default to Chocolatey
    if($p.ProviderName -eq $null -or $p.ProviderName.Length -eq 0) 
    {
        $p.ProviderName = "Chocolatey"
    }

    if($p.ContainsKey("CustomParameters")) {

        $validOptions = (Get-PackageProvider -Name $p.ProviderName).DynamicOptions | % { $_.Name }
        $requiredOptions = (Get-PackageProvider -Name $p.ProviderName).DynamicOptions | % { if($_.IsRequired ) { $_.Name} }

        foreach($key in $p.CustomParameters.Keys) {
            if(!($validOptions.Contains($key))) {
                Write-Error [System.ArgumentException] ("Provider '{0}' does not support the parameter '{1}' provided in the CustomParameters DSC config"-f $p.ProviderName, $key)
            }
            $p[$key] = $p.CustomParameters.$key;
        }

        foreach($key in $requiredOptions) {
            if(!($p.Contains($key))) {
                Write-Error [System.ArgumentException] ("Provider '{0}' requires the parameter '{1}' to be present (as part of the CustomParameters configuration element)"-f $p.ProviderName, $key)
            }
        }
    }

    return $p
}

Export-ModuleMember -Function *-TargetResource