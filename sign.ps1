Param([String]$FilePath)
#$TimestampServer="http://timestamp.verisign.com/scripts/timestamp.dll"
$TimestampServer="http://timestamp.digicert.com/"

$cert = Get-ChildItem cert:\CurrentUser\my -CodeSigning
Set-AuthenticodeSignature -FilePath $FilePath -TimestampServer $TimestampServer -IncludeChain "All" -Certificate $cert
