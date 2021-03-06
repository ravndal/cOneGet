$modulePath = ("{0}\DSCResources\Thinq_cOneGet" -f (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)))
$moduleFile = "Thinq_cOneGet.psm1"
$moduleFilePath = ("{0}\{1}" -f $modulePath, $moduleFile)

Describe "Test cOneGet DSC Resource execution" {
    Copy-Item $moduleFilePath TestDrive:\script.ps1 -Force
    Mock Export-ModuleMember {return $true}
    . "TestDrive:\script.ps1"
 
    Context "Get-TargetResource with mock" {
        $expected = "Sublime Text Build 3065"
        mock -commandName Get-Package -mockWith {
             return ([pscustomobject]@{ Name = $expected }) 
        }

        $actual = (Get-TargetResource -PackageName sublimetext3)

        It "Test if the Get-TargetResource return a hashtable" {
            $actual.Name  | Should Be ($expected)
        }
    }

    Context "Test-TargetResource" {
        $expected = $true
        $actual = (Test-TargetResource -PackageName sublimetext3 -Ensure "Absent")

        it "the package should not be present" {
            $actual | should be $expected
        }
    }

    Context "Set-TargetResource" {

        $currentState = (Test-TargetResource -PackageName winscp -Ensure "Present")

        it "precheck to verify that winscp is not already present"  {
            $currentState | should be $false
        }

        # install the package
        Set-TargetResource -PackageName winscp -Ensure "Present"
        $currentState = (Test-TargetResource -PackageName winscp -Ensure "Present")
        
        it "should have installed winscp" {
            $currentState | should be $true
        }

        # remove the package
        Set-TargetResource -PackageName winscp -ProviderName Chocolatey -Ensure "Absent"
        Set-TargetResource -PackageName winscp -ProviderName ARP -Ensure "Absent"
        $currentState = (Test-TargetResource -PackageName winscp -Ensure "Present")
        
        it "should have removed winscp" {
            $currentState| should be $false
        }
    }
} 