function Out-TypeData
{
    <#
    .Synopsis
        Takes a series of type views and format actions and outputs a type data XML
    .Description
        Takes a series of type views and format actions and outputs a type data XML
    .Example
        # Create a quick view for any XML element.
        # Piping it into Out-FormatData will make one or more format views into a full format XML file
        # Piping the output of that into Add-FormatData will create a temporary module to hold the formatting data
        # There's also a Remove-FormatData and
        Write-FormatView -TypeName "System.Xml.XmlNode" -Wrap -Property "Xml" -VirtualProperty @{
            "Xml" = {
                $strWrite = New-Object IO.StringWriter
                ([xml]$_.Outerxml).Save($strWrite)
                "$strWrite"
            }
        } |
            Out-FormatData

    #>
    param(
    # The Format XML Document.  The XML document can be supplied directly,
    # but it's easier to use Write-FormatView to create it
    [Parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
    [ValidateScript({
        if ((-not $_.Type)) {
            throw "The root of a types XML most be a type element"
        }
        return $true
    })]
    [Xml]
    $TypeXml
    )

    begin {
        $type = ""
    }
    process {
        if ($TypeXml.Type) {
            $type+= "<Type>$($TypeXml.Type.InnerXml)</Type>"
        }
    }

    end {
        $xml = [xml]"
        <!-- Generated with EZOut $($MyInvocation.MyCommand.Module.Version): Install-Module EZOut or https://github.com/StartAutomating/EZOut -->
        <Types>
        $type
        </Types>
        "
        $strWrite = New-Object IO.StringWriter
        $xml.Save($strWrite)
        return "$strWrite"
    }
}