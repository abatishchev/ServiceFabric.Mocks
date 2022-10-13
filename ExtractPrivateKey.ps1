﻿Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string] $pfxPwd
)

[string] $pfxFilePath = ".\src\ServiceFabric.Mocks\ServiceFabric.Mocks.pfx"
[string] $snkFilePath = [IO.Path]::GetFileNameWithoutExtension($pfxFilePath) + ".snk";
[byte[]] $certificateContent = Get-Content $pfxFilePath -AsByteStream;
$exportable = [Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
$certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certificateContent, $pfxPwd, $exportable)

$rsaPrivateKey = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($certificate)
$rsaParameters = $rsaPrivateKey.ExportParameters($true)   
$csp = New-Object Security.Cryptography.RSACryptoServiceProvider
$csp.ImportParameters($rsaParameters)
$certificateContent = $csp.ExportCspBlob($true)

[IO.File]::WriteAllBytes([IO.Path]::Combine([IO.Path]::GetDirectoryName($pfxFilePath), $snkFilePath), $certificateContent)