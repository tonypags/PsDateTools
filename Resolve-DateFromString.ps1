function Resolve-DateFromString
{
    <#
    .EXAMPLE
    Resolve-DateFromString 'June 51, 2001'
    .EXAMPLE
    'June 51, 2001' | Resolve-DateFromString
    #>
    [CmdletBinding()]
    param(

        # String to attempt to convert to date
        [Parameter(ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [string]
        $Date,

        # If unable to resolve, returns original string, else throws an error.
        [Parameter()]
        [switch]
        $PassThru

    )

    if ($Datedate -as [datetime]) {

        $Date -as [datetime]
    
    } else {
    
        if ($PassThru) {

            $Date

        } else {

            throw "Invalid date: $date"

        }
    
    }

}
