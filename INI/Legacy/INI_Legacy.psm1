<#
    Module : INI_Legacy.psm1
    Updated: 11/12/2018
    Author : Rudesind <rudesind76@gmail.com>
    Version: 1.0

    Summary:
    This module reads and writes data to ini file. Use the function Get-IniFile
    to input the file contents into a key\value array (hash table), and use
    Write-IniFile to write the contents of a hash table to an ini file.

    The legacy version is for POSReady 2009 and 7 devices.

    Disclosure:
    The below script is transposed from the following scripts:
    https://gallery.technet.microsoft.com/scriptcenter/ea40c1ef-c856-434b-b8fb-ebd7a76e8d91
    https://gallery.technet.microsoft.com/scriptcenter/7d7c867f-026e-4620-bf32-eca99b4e42f4
    All functions will be described in detail. All credit goes to the original
    author: Oliver Lipkau <oliver@lipkau.net>
#>

Function Get-IniFile {
    <#
    .Synopsis
        This function loads and processes an ini file into a key\value hash table.
    .Description
        This function is part of the INI module. This module is used to read and write data to an INI file with a hash table using a key\value structure.

    .Notes
        Module : INI.psm1
        Updated: 11/12/2018
        Author : Rudesind <rudesind76@gmail.com>
        Version: 1.0

        Disclosure:
        This function is transposed from the following script:
        https://gallery.technet.microsoft.com/scriptcenter/ea40c1ef-c856-434b-b8fb-ebd7a76e8d91

        All functions will be described in detail. All credit goes to the original author: Oliver Lipkau <oliver@lipkau.net>

    .Inputs
        System.String

    .Outputs
        System.Collections.Hashtable

    .Parameter File
        The name of the .ini file including its path.

    .Example
        $iniFile = Get-IniFile example.ini
        $iniFile.section.key

    .Example
        example.ini | $iniFile = Get-IniFile

    #>

    # Allows the script to operate like a compiled cmdlet
    #
    [CmdletBinding()]

    # The inner comments of the Param block will be displayed with: Get-Help ... -Detailed if no Parameter section is defined
    #
    Param(

        # Cannot be $null or ""
        #
        [ValidateNotNullOrEmpty()]

        # Path to the file must exist and have a ".ini" extension
        #
        [ValidateScript({(Test-Path $_) -and ((Get-Item $_).Extension -eq ".ini")})]

        # Parameter is mandatory and allows piped data
        #
        [Parameter(ValueFromPipeline=$True, Mandatory=$True)]

        [string] $File
    )


    # Error Codes
    #
    New-Variable INI_PROCESSING_FAILED -option Constant -value 4000

    # Initialize the function
    #
    try {

        # Friendly error message for the function
        #
        [string] $errorMsg = [string]::Empty

        # Holds the section of the ini file
        #
        [string] $section = [string]::Empty

        # Holds the name of a key for a section
        #
        [string] $key = [string]::Empty

        # Holds the value that relates to a key
        #
        [string] $value = [string]::Empty

        # The hash table
        #
        [object] $ini = $null

        # Holds the comment count found for a particular section
        #
        [float] $CommentCount = 0

    } catch {
        throw "Error initializing function"
        return -1
    }

    # Begin processing the INI file
    #
    try {

        # Create the hash table
        #
        $ini = @{}

        # Create a switch function based on regular expression cases
        #
        switch -regex -file $File {

            # Finds the section from a ini file
            #
            "^\[(.+)\]$" {

                # Pulls the value from the match
                #
                $section = $matches[1]

                # Adds the value to the hash table
                #
                $ini[$section] = @{}

                # Prepares the comments for this section
                #
                $CommentCount = 0
            }

            # Finds any comments in the ini file
            #
            "^(;.*)$" {

                # Checks if there is no section for this call
                #
                if (!($section)) {

                    # No section was found, so add "NoSection" to the hash table
                    #
                    $section = "NoSection"
                    $ini[$section] = @{}
                }

                # Grabs the value of the match
                #
                $value = $matches[1]

                # Increments the amount of comments found for this section
                #
                $CommentCount = $CommentCount + 1

                # Names the comment based on the count
                #
                $key = "Comment" + $CommentCount

                # Adds the value to the current section in the hash table
                #
                $ini[$section][$key] = $value
            }

            # Finds the key\value pair for a section
            #
            "(.+?)\s*=\s*(.*)" {

                if (!($section)) {
                    $section = "NoSection"
                    $ini[$section] = @{}
                }

                # Grabs the values for the key and adds both to hash table
                #
                $key,$value = $matches[1..2]
                $ini[$section][$key] = $value
            }
        }

        return $ini

    } catch {
        $errorMsg = "Error processing $File file: " + $Error[0]
        throw
        return $INI_PROCESSING_FAILED
    }

    return 0

}

Function Write-IniFile {
    <#
    .Synopsis
        This function writes the contents of a hash table to an ini file.

    .Description
        This function is part of the INI module. This module is used to read and write data to an INI file with a hash table using a key\value structure.

    .Notes
        Module : INI.psm1
        Updated: 10/12/2018
        Author : Configuration Management
        Version: 1.0
        Documentation: INI.md

        Disclosure:
        This function is transposed from the following script:
        https://gallery.technet.microsoft.com/scriptcenter/7d7c867f-026e-4620-bf32-eca99b4e42f4

        All functions will be described in detail. All credit goes to the original author: Oliver Lipkau <oliver@lipkau.net>

    .Inputs
        System.String
        System.Collections.Hashtable

    .Outputs
        System.Int32

    .Parameter Append
        Append the info to the end of the file.

    .Parameter InputHastTable
        The data (hash table) to be written to the file.

    .Parameter File
        The file to write the data to.

    .Example
        $ini = Get-IniFile .\example.ini
        $ini.network.ip = "10.200.10.13"
        Write-IniFile .\example.ini $ini

    #>

    # Allows the script to operate like a compiled cmdlet
    #
    [CmdletBinding()]

    Param(

        # Holds a true or false value that is triggered by including "-Append"
        #
        [switch]$Append,

        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Test-Path $_) -and ((Get-Item $_).Extension -eq ".ini")})]
        [Parameter(Mandatory=$True)]
        [string] $File,

        [ValidateNotNullOrEmpty()]
        [Parameter(ValueFromPipeline=$True, Mandatory=$True)]
        [Hashtable]$InputHashTable

    )

    # Error Codes
    #
    New-Variable FILE_CREATE_FAILED -option Constant -value 4000
    New-Variable INI_WRITE_FAILED -option Constant -value 4001

    # Initialize the function
    #
    try {

        # Friendly error message for the function
        #
        [string] $errorMsg = [string]::Empty

        # The encoding to write the file in. Uses standard Unicode
        # Can be turned into an optional parameter if desired.
        #
        [string] $encoding = "Unicode"

        # Reference to the output file
        #
        [object] $outFile = $null

    } catch {
        throw "Error initializing function"
        return -1
    }


    # Begin writing to the INI file
    #
    try {

        # Checks if the "Append" option is true
        #
        if ($Append) {

            # If true, we are appending. Pull current file text if any
            #
            $outFile = Get-Item $File

        } else {

            # Otherwise we are creating or overwriting the current file
            # NOTE: This file will always overwrite any existing file
            #
            $outFile = New-Item -ItemType file -Path $File -Force

        }

        # Ensures no issues were encountered when loading the file
        #
        if (!($outFile)) {

            # Error encountered, throw exception and exit function
            #
            $errorMsg = "Error, could not create or load $file"
            throw $errorMsg
            return $FILE_CREATE_FAILED

        }

        # Begin cycling through all the sections in the hash table
        #
        foreach ($key in $InputHashTable.keys) {

            # TODO: Understand the below better

            # I do not fully understand the reason for the below test
            # My guess is that it is checking for a section
            #
            if (!($($InputHashTable[$key].GetType().Name) -eq "Hashtable")) {
                # No Section found?

                # Write key\value without a section
                #
                Add-Content -Path $outFile -Value "$key=$($InputHashTable[$key])" -Encoding $encoding

            } else {

                # Section found?

                # Write the section name to the file
                #
                Add-Content -Path $outFile -Value "[$key]" -Encoding $encoding

                # Cycle through each section key
                #
                foreach ($sectionKey in $($InputHashTable[$key].keys | Sort-Object)) {

                    # Check if section key is a comment
                    #
                    if ($sectionKey -match "^Comment[\d]+") {

                        # Write comment value to file
                        #
                        Add-Content -Path $outFile -Value "$($InputHashTable[$key][$sectionKey])" -Encoding $encoding

                    } else {

                        # If not a comment, write key\value to file under the current section
                        #
                        Add-Content -Path $outFile -Value "$sectionKey=$($InputHashTable[$key][$sectionKey])" -Encoding $encoding

                    }
                }

                # Write blank line to file
                #
                Add-Content -Path $outFile -Value "" -Encoding $encoding

            }
        }

        # Return any data desired here

    } catch {
        $errorMsg = "Error processing $file file: " + $Error[0]
        throw
        return $INI_WRITE_FAILED
    }

    return 0

}
