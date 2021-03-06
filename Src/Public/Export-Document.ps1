function Export-Document {
<#
    .SYNOPSIS
        Exports a PScribo document object to one or more output formats.
#>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock','')]
    [OutputType([System.IO.FileInfo])]
    param
    (
        ## PScribo document object
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Management.Automation.PSObject] $Document,

        ## Output formats
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.String[]] $Format,

        ## Output file path
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path = (Get-Location -PSProvider FileSystem),

        ## PScribo document export option
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.Collections.Hashtable] $Options,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $PassThru
    )
    begin
    {
        try { $Path = Resolve-Path $Path -ErrorAction SilentlyContinue; }
        catch { }

        if ( $(Test-CharsInPath -Path $Path -SkipCheckCharsInFileNamePart -Verbose:$false) -eq 2 )
        {
            throw $localized.IncorrectCharsInPathError
        }

        if (-not (Test-Path $Path -PathType Container))
        {
            ## Check $Path is a directory
            throw ($localized.InvalidDirectoryPathError -f $Path)
        }
    }
    process
    {
        foreach ($f in $Format)
        {
            WriteLog -Message ($localized.DocumentInvokePlugin -f $f) -Plugin 'Export';

            ## Dynamically generate the output format function name
            $outputFormat = 'Out-{0}Document' -f $f
            $outputParams = @{
                Document = $Document
                Path = $Path
            }
            if ($PSBoundParameters.ContainsKey('Options'))
            {
                $outputParams['Options'] = $Options
            }

            $fileInfo = & $outputFormat @outputParams
            WriteLog -Message ($localized.DocumentExportPluginComplete -f $f) -Plugin 'Export'

            if ($PassThru)
            {
                Write-Output -InputObject $fileInfo
            }
        }
    }
}
