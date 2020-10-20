########################################################################################
# SetVars.ps1 is used to set multiple environment variables from a specified .env file
# Usage:  ./setvars.ps1 -FilePath "C:\File\Path\myvars.env"
# Verify: gci env:* | sort-object name
#
# Environment variable source file format and rules are listed below.
########################################################################################


param([Parameter(Mandatory = $true)] $FilePath, $Remove = "false") # Get full file path

$dir = Get-Location  # Save current working directory
Set-Location Env:    # Go to Env directory for Set/Get commands to work
$i = 0               # Index to count vars

ForEach ($file in (Get-Content $FilePath)) {
    if ($file.Contains('=')) {
        # Get var name
        $name = $file.substring(0, $file.IndexOf("=")).Trim()

        # Remove always by setting first in case it does not exist
        if ($Remove -eq "true") {
            Set-Content -Path $name -Value "fake"
            Remove-Item $name
            'Env var removed: ' + $name
            $i = $i + 1
        }
        else {
            # Get var value
            $val = ($file -replace $name, '').Trim()
            $val = $val.Substring(1)
            if ($val.IndexOf(" ") -gt 0) {
                $val = $val.substring(0, $val.IndexOf(" ")) 
            }

            # Set valid env vars
            if ($val.Length -gt 0 -and -not($name.Contains('#'))) {
                Set-Content -Path $name -Value $val
                'Env var set: ' + $name + ' = ' + (Get-Content -Path $name)
                $i = $i + 1
            }
        }
    }
}

'Total vars modified: ' + $i  # Display count of vars set
Set-Location $dir        # Return to current working directory


########################################################################################
#                            ENVIRONMENT VARIABLE FILE RULES
# Basic format:
#  variable_name=variable_value
#
# Rules:
#  * Variable names and values should not contain spaces or '#'
#  * There should be no spaces surrounding the '=' sign
#  * Variable values can contain multiple '=' signs
#  * Leading and trailing spaces are ignored
#  * Lines starting with # are treated as comments and are ignored
#  * A comment at the end of a line is ignored
#
# Samples (with leading comments removed in the actutal .env file): 
#
#  TF_VAR_TEST_FOO="bar"
#  TF_VAR_MY_VAR_ONE=value_one 
#  TF_VAR_MY_VAR_TWO=value_two #valid comment is ignored
#  TF_VAR_MY_PRIVATE_IP=10.200.0.5
#  
#  #Valid comment is ignored
#  TF_VAR_MY_VAR_PATH=../../../folder/file.ps1
#  TF_VAR_MY_VAR_PARAM="'IsFlagSet'=\$true"
#  TF_VAR_MY_VAR_MULTI_PARAMS="'HostName'='localhost';'IsFlagSet'=\$true"
#
########################################################################################