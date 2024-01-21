::Ω≈±æ“¿¿µ∫œ≤¢
::@author FB
::@version 1.0.0

@ECHO OFF
Powershell.exe -NonInteractive -Command ^& {^
  Param(^
    [Parameter(Mandatory)] $Source,^
    [Parameter(ValueFromRemainingArguments)] $Dependencies^
  );^
  $ErrorActionPreference = 'SilentlyContinue';^
  $Source = Get-Item $Source ^| Where-Object PSIsContainer -eq $false;^
  $Dependencies = Get-Item $Dependencies ^| Where-Object PSIsContainer -eq $false;^
  $Content = Get-Content -Raw $Source;^
  $Content += """`r`n""" + ':' * 80 + """`r`n""";^
  foreach ($File in $Dependencies) {^
    $Label = $File.Name -replace ' ', '_';^
    $Content += """`r`n""" + """:""" + $Label + """`r`n""";^
    $Content += Get-Content $File ^| Where-Object {^
      ($PSItem -notmatch '^^\s*$') -and ($PSItem -notmatch '^^\s*::')^
    } ^| Out-String;^
  }^
  foreach ($File in $Dependencies) {^
    $Label = $File.Name -replace ' ', '_';^
    $Pattern = 'CALL \"""*' + [Regex]::Escape("""$($File.Name)""") + '\"""*';^
    $Content = $Content -replace $Pattern, """CALL :$Label"""^
  }^
  $Output = $Source.Directory.FullName + '\[Merged]' + $Source.Name;^
  Out-File -Encoding OEM -InputObject $Content -LiteralPath $Output;^
  Exit -not $?^
} %*
EXIT /B %ERRORLEVEL%
