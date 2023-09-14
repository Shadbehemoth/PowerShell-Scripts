$files = Get-ChildItem -Path . -Recurse -File
foreach ($file in $files) {
  $dest = Join-Path . $file.Name
  if (Test-Path $dest) {
    $i = 1
    do {
      $newName = "$($file.BaseName)_$i$($file.Extension)"
      $newDest = Join-Path . $newName
      $i++
    } while (Test-Path $newDest)
    Move-Item -Path $file.FullName -Destination $newDest
  } else {
    Move-Item -Path $file.FullName -Destination $dest
  }
}

Get-ChildItem -Directory | Where-Object {(Get-ChildItem $_ -Recurse -File).count -eq 0} | ForEach-Object {Remove-Item $_ -Recurse}