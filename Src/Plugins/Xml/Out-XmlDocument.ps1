function Out-XmlDocument
{
<#
    .SYNOPSIS
        Xml output plugin for PScribo.

    .DESCRIPTION
        Outputs a xml representation of a PScribo document object.
#>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments','pluginName')]
    param
    (
        ## ThePScribo document object to convert to a xml document
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Management.Automation.PSObject] $Document,

        ## Output directory path for the .xml file
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNull()]
        [System.String] $Path,

        ### Hashtable of all plugin supported options
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.Collections.Hashtable] $Options
    )
    process
    {
        $pluginName = 'Xml'
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        WriteLog -Message ($localized.DocumentProcessingStarted -f $Document.Name)
        $documentName = $Document.Name

        $xmlDocument = New-Object -TypeName System.Xml.XmlDocument
        [ref] $null = $xmlDocument.AppendChild($xmlDocument.CreateXmlDeclaration('1.0', 'utf-8', 'yes'))
        $documentId = ($Document.Id -replace '[^a-z0-9-_\.]','').ToLower()
        $element = $xmlDocument.AppendChild($xmlDocument.CreateElement($documentId))
        [ref] $null = $element.SetAttribute("name", $documentName)
        foreach ($subSection in $Document.Sections.GetEnumerator())
        {
            $sectionId = ($subSection.Id -replace '[^a-z0-9-_\.]','').ToLower();
            $currentIndentationLevel = 1
            if ($null -ne $subSection.PSObject.Properties['Level'])
            {
                $currentIndentationLevel = $subSection.Level +1
            }
            Write-PScriboProcessSectionId -SectionId $sectionId -SectionType $subSection.Type -Indent $currentIndentationLevel

            switch ($subSection.Type)
            {
                'PScribo.Section' { [ref] $null = $element.AppendChild((Out-XmlSection -Section $subSection)) }
                'PScribo.Paragraph' { [ref] $null = $element.AppendChild((Out-XmlParagraph -Paragraph $subSection)) }
                'PScribo.Table' { [ref] $null = $element.AppendChild((Out-XmlTable -Table $subSection)) }
                'PScribo.PageBreak'{ } ## Page breaks are not implemented for Xml output
                'PScribo.LineBreak' { } ## Line breaks are not implemented for Xml output
                'PScribo.BlankLine' { } ## Blank lines are not implemented for Xml output
                'PScribo.TOC' { } ## TOC is not implemented for Xml output
                'PScribo.Image' { [ref] $null = $element.AppendChild((Out-XmlImage -Image $subSection)) }
                Default {
                    WriteLog -Message ($localized.PluginUnsupportedSection -f $subSection.Type) -IsWarning
                }
            }
        }
        $stopwatch.Stop()
        WriteLog -Message ($localized.DocumentProcessingCompleted -f $Document.Name)
        $destinationPath = Join-Path $Path ('{0}.xml' -f $Document.Name)
        WriteLog -Message ($localized.SavingFile -f $destinationPath)
        ## Core PowerShell XmlDocument requires a stream
        $streamWriter = New-Object System.IO.StreamWriter($destinationPath, $false)
        $xmlDocument.Save($streamWriter)
        $streamWriter.Close()

        if ($stopwatch.Elapsed.TotalSeconds -gt 90)
        {
            WriteLog -Message ($localized.TotalProcessingTimeMinutes -f $stopwatch.Elapsed.TotalMinutes)
        }
        else
        {
            WriteLog -Message ($localized.TotalProcessingTimeSeconds -f $stopwatch.Elapsed.TotalSeconds)
        }

        Write-Output (Get-Item -Path $destinationPath)
    }
}
