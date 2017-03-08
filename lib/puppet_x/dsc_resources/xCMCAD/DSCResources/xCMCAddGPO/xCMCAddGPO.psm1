



function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $GPOName,

        [parameter(Mandatory = $true)]
        [System.String]
        $OU
    )

    $LinkEnabled = ''

    Try{

        $GPO = Get-GPO -Name $GPOName -Domain $Domain -ErrorAction Stop

        $GPOLinks = (Get-GPInheritance -Target $OU -ErrorAction Stop).GpoLinks

        Foreach($Link in $GPOLinks){
 
            If($Link.DisplayName -eq $GPOName){
                
                Switch($Link.Enabled){

                    True{$LinkEnabled = 'Yes'}
                    False{$LinkEnabled = 'No'}
                    Default{$LinkEnabled = 'No'}
                }
            }
        }
    }
    Catch{
        
    }

    $returnValue = @{
        GPOName = $GPOName
        OU = $OU
        LinkEnabled = $LinkEnabled
    }

    $returnValue
    
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $GPOName,

        [parameter(Mandatory = $true)]
        [System.String]
        $OU,

        [System.String]
        $Domain,

        [ValidateSet("Yes","No","Unspecified")]
        [System.String]
        $LinkEnabled,

        [System.String]
        $GPOBackup_Name,

        [System.String]
        $GPOBackup_Path
    )

    Switch($LinkEnabled){

        Yes{$strLink = 'True'}
        No{$strLink = 'False'}
        Unspecified{$strLink = 'False'}
    }

    Try{

        $GPO = Get-GPO -Name $GPOName -Domain $Domain -ErrorAction Stop
        
        Write-Verbose "GPO $GPOName exist, check GPOLink on $OU"
        $GPOLinks = (Get-GPInheritance -Domain $Domain -Target $OU).GpoLinks

        $blnGPOFound = $False
        Foreach($Link in $GPOLinks){
 
            Write-Debug $Link.DisplayName
            If($Link.DisplayName -eq $GPOName){
                
                $blnGPOFound = $True
                Write-Verbose "GPOLink found"

                If($Link.Enabled -ne $strLink){

                    Write-Verbose 'GPOLink incorrect'
                    Write-Debug $Link.Enabled
                    Set-GPLink -Guid $Link.GpoId -Target $OU -LinkEnabled $LinkEnabled -Domain $Domain
                }
                Else{

                    Write-Verbose 'GPOLink correct' #Hoort niet voor te komen...
                }
            }
        }
        If(!($blnGPOFound)){
            Write-Verbose "GPO Link not found, creating GPO Link $GPOName"
            New-GPLink -Guid $GPO.ID -Target $OU -LinkEnabled $LinkEnabled -Domain $Domain
        }
    }

    Catch{

        Write-Verbose "GPO $GPOName does not exist. Create GPO from backup"
        $GPO = New-GPO -Name $GPOName -Domain $Domain

        Import-GPO -BackupGpoName $GPObackup_Name -TargetName $GPOName -Path $GPOBackup_Path
        New-GPLink -Guid $GPO.ID -Target $OU -LinkEnabled  $LinkEnabled -Domain $Domain
    }

}



function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $GPOName,

        [parameter(Mandatory = $true)]
        [System.String]
        $OU,

        [System.String]
        $Domain,

        [ValidateSet("Yes","No","Unspecified")]
        [System.String]
        $LinkEnabled,

        [System.String]
        $GPOBackup_Name,

        [System.String]
        $GPOBackup_Path
    )

    Try{
        $GPO = Get-GPO -Name $GPOName -Domain $Domain -ErrorAction Stop
        Write-Verbose "GPO $GPOName does exist."
        return $True
    }
    Catch{
        Write-Verbose "GPO $GPOName does not exist."
        return $false
    } 
}



Export-ModuleMember -Function *-TargetResource

