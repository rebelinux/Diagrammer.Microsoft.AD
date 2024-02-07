Function Get-HTMLNodeTable {
    <#
    .SYNOPSIS
        Function to convert a string array to a HTML Table with Graphviz Nodes split by Columns (Includes Icons)
    .DESCRIPTION
        Takes an array and converts it to a HTML table used for GraphViz Node label
    .Example
        $DCs = @("Server-DC-01v", "Server-DC-02v")
        Get-HTMLNodeTable -Rows $DCs -Align "Center" -IconType "DomainController" -ColumnSize 2
            ________________________________
            |               |               |
            |      Icon     |     Icon      |
            ________________________________
            |               |               |
            | Server-DC-01V | Server-DC-02V |
            ________________________________

    .NOTES
        Version:        0.1.6
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .PARAMETER inputObject
        The array of object to processn
    .PARAMETER Align
        Align content inside table cell
    .PARAMETER TableBorder
        The table line border
    .PARAMETER CellBorder
        The table cell border
    .PARAMETER FontSize
        The text fornt size used inside the cell
    .PARAMETER IconType
        Icon used to draw the node type
    .PARAMETER ColumnSize
        This number is used to specified how to split the object in side the HTML table
    .PARAMETER Port
        Used inside Graphviz to point the edge between nodes
    #>
    param(
        [string[]] $inputObject,
        [string] $Align = 'Center',
        [int] $tableBorder = 0,
        [int] $cellBorder = 0,
        [int] $fontSize = 14,
        [string] $iconType,
        [int] $columnSize = 2,
        [string] $Port = "EdgeDot",
        [string[]] $Data,
        [Switch]$MultiIcon
    )

    if ($inputObject.Count -le 1) {
        $Group = $inputObject
    } else {
        $Group = Split-Array -inArray $inputObject -size $columnSize
    }

    if ($images[$iconType]) {
        $Icon = $images[$iconType]
    } else { $Icon = $false }

    $Number = 0

    $TD = ''
    $TR = ''
    if ($Icon) {
        if ($URLIcon) {
            if ($MultiIcon) {
                while ($Number -ne $Group.Count) {
                    foreach ($Element in $Group[$Number]) {
                        $TD += '<TD PORT="{0}" ALIGN="{1}" colspan="1">ICON</TD>' -f $Port, $Align
                    }

                    $TR += '<TR>{0}</TR>' -f $TD

                    $TD = ''
                    $Number++
                }
            } else {
                $TD += '<TD PORT="{0}" ALIGN="{1}" colspan="{2}">ICON</TD>' -f $Port, $Align, $inputObject.Count
                $TR += '<TR>{0}</TR>' -f $TD
            }
        } else {
            if ($MultiIcon) {
                while ($Number -ne $Group.Count) {
                    foreach ($Element in $Group[$Number]) {
                        $TD += '<TD PORT="{0}" ALIGN="{1}" colspan="1"><img src="{2}"/></TD>' -f $Port, $Align, $Icon
                    }

                    $TR += '<TR>{0}</TR>' -f $TD

                    $TD = ''
                    $Number++
                }
            } else {
                $TD += '<TD PORT="{0}" ALIGN="{1}" colspan="{2}"><img src="{3}"/></TD>' -f $Port, $Align, $inputObject.Count, $Icon
                $TR += '<TR>{0}</TR>' -f $TD
            }
        }
    }

    $Number = 0
    $TD = ''
    while ($Number -ne $Group.Count) {
        foreach ($Element in $Group[$Number]) {
            # $TRDATA = @()
            # foreach ($r in $Element.Data) {
            #     $TRDATA += $r.getEnumerator() | ForEach-Object { "<TR><TD ALIGN='$Align' colspan='1'><FONT POINT-SIZE='$fontSize'>$($_.Key): $($_.Value)</FONT></TD></TR>" }
            # }

            $TD += '<TD PORT="{0}" ALIGN="{1}" colspan="1">{2}</TD>' -f $Port, $Align, $Element
        }

        $TR += '<TR>{0}</TR>' -f $TD

        $TD = ''
        $Number++
    }

    if ($URLIcon) {
        return '<TABLE COLOR="red" border="1" cellborder="1" cellpadding="5">{0}</TABLE>' -f $TR
    } else {
        return '<TABLE border="{0}" cellborder="{1}" cellpadding="5">{2}</TABLE>' -f $tableBorder, $cellBorder, $TR
    }
}