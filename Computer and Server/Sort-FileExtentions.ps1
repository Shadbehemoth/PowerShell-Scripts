$path = "C:\Users\USERNAME\Desktop"
foreach ($file in (get-childitem -file $path))
{
    $newpath = "$($path)\$($file.extension.trimstart('.'))"
    mkdir $newpath -force
    move-item $file $newpath
}