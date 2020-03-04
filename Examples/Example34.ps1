[CmdletBinding()]
param (
    [System.String[]] $Format = 'Html',
    [System.String] $Path = '~\Desktop',
    [System.Management.Automation.SwitchParameter] $PassThru
)

Import-Module PScribo -Force -Verbose:$false

$example34 = Document -Name 'PScribo Example 34' {

    <#
        Captions can be added to standard tables and keyed list tables (list
        tables render multiple tables and aren't supported).

        The default position is below the table, but this can be overridden
        by defining a custom table style using -CaptionLocation 'Above'.

        Table captions are prefixed with the word 'Table'. The prefix can be
        changed by defining a custom table style using the -CaptionPrefix
        parameter.

        Captions can be styled by defining the required style and assigning
        it to the table style's -CaptionStyle parameter.
    #>

    TableStyle -Id Righty -Align Right

    $servers = @(
        [Ordered] @{ 'Computer Name' = 'DC1'; 'Domain Name' = 'example.local'; FQDN = 'dc1.example.local'; 'IP Address' = '192.168.0.1' }
        [Ordered] @{ 'Computer Name' = 'DC2'; 'Domain Name' = 'example.local'; FQDN = 'dc2.example.local'; 'IP Address' = '192.168.0.2' }
        [Ordered] @{ 'Computer Name' = 'DC3'; 'Domain Name' = 'example.local'; FQDN = 'dc3.example.local'; 'IP Address' = '192.168.0.3' }
    )

    Table -Hashtable $servers -List -Key 'Computer Name' -Caption '- Server Information' -Width 0  -Style Righty

    <#
        The table above, will be rendered like so:

        Computer Name DC1               DC2               DC3
        ------------- ---               ---               ---
        DomainName    example.local     example.local     example.local
        FQDN          dc1.example.local dc2.example.local dc3.example.local
        IpAddress     192.168.0.1       192.168.0.2       192.168.0.3

        Table 1 - Server Information
    #>
}
$example34 | Export-Document -Path $Path -Format $Format -PassThru:$PassThru