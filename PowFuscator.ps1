<#
.SYNOPSIS
This PowerShell script provides an easy way to obfuscate your code while evading character frequency anlysis.


.DESCRIPTION
Encodes your script in a binary type fashion, whilst keeping character frequency at an average level (Works best with large scripts). Multiplies file size by about 14 times though.

.LINK
GITHUB: https://github.com/Tobi15Online/PowFuscator
#>


param([string]$infile="null", [string]$outfile)

if(-NOT (Test-Path $infile) ){
    write-host
    write-host """$infile"" is not a valid file." -ForegroundColor Red -BackgroundColor Black
    write-host
exit
}

foreach($line in (Get-Content $infile)){$InputStr += $line+";"}
$Freq= [ordered]@{9.912="E";7.414="T";5.512="A";5.43="R";5.303="S";5.041="I";5.025="N";4.944="O";3.609="L";3.3="M";3.191="C";3.076="$";2.914="P";2.753="D";2.69="U";1.955="-";1.917=".";1.822="""";1.626="F";1.526="G";1.489="H";1.482="B";1.362="(";1.354=")";1.321="=";1.222="Y";1.154="W";0.904="V";0.799="{";0.79="}";0.757=",";0.643="X";0.618="[";0.615="]";0.564="_";0.484="\";0.48=":";0.447="K";0.419="/";0.415="0";0.328="J";0.325="1";0.288="+";0.26="|";0.251="2";0.248=";";0.23=">";0.223="Q";0.221="<";0.154="Z";0.129="3";0.128="5";0.126="``";0.103="*";0.102="4";0.099="@";0.092="6";0.077="7";0.071="8";0.066="9";0.06="%";0.052="!";0.037="?";0.028="&";0.023="^";}
$DictOne = [ordered]@{}
$DictZero = [ordered]@{}

foreach($char in [char[]]$InputStr){
    $Binary = [CONVERT]::ToString(([BYTE][CHAR]$char), 2)
    if($Binary.length -lt 7){
        $Binary = "0"+$Binary
    }
    $FullBinary += $Binary;
}

$Ones = (((Select-String -InputObject $FullBinary -Pattern "1" -AllMatches).Matches.Count/$FullBinary.length)*100)


$Freq.keys | foreach {
    $i++
    if(($OneSubst + $_) -le $Ones){
        $DictOne.Add((($OneSubst + $_)/$Ones)*100, $Freq.$_) *>$null
        $OneSubst += $_
    }else{
        $DictZero.Add((($ZeroSubst + $_)/(100-$Ones))*100, $Freq.$_) *>$null
        $ZeroSubst += $_
    }
}
write-host $i

$BiggestNumOne = (($DictOne.keys | Sort-Object -Descending)[0])
$BiggestNumZero = (($DictZero.keys | Sort-Object -Descending)[0])

foreach ($char in [char[]]$FullBinary){
    if($char -eq "1"){
            $Obfuscated += $DictOne.Item((($DictOne.keys -ge (get-random -Maximum $BiggestNumOne) | Sort-Object -Descending)[-1])+"00")
    }else{
            $Obfuscated += $DictZero.Item((($DictZero.keys -ge (get-random -Maximum $BiggestNumZero) | Sort-Object -Descending)[-1])+"00")
    }
}

$OneRegex = "'[" + ($DictOne.values -join "" -replace "[\\]","\\" -replace "[\-]","\-" -replace "[\]]","\]") +"]'"
$ZeroRegex = "'["+ ($DictZero.values -join "" -replace "[\\]","\\" -replace "[\-]","\-" -replace "[\]]","\]") +"]'"

$FullScript='$BinStr='''+$Obfuscated+''' -replace '+$OneRegex+',"~" -replace '+$ZeroRegex+',"0" -replace "~","1";for($i=0;$i -lt $BinStr.length;$i+=7){$byte += [Text.Encoding]::ASCII.GetString([convert]::ToInt32($BinStr.SubString($i,7),2));};IEX($byte)'
if($outfile -ne ""){
    echo $FullScript > $outfile
    Write-host "Done!"
}else{
    Write-host $FullScript
}