Sc config wsearch start=disabled
Net stop wsearch

EsentUtl.exe /d %AllUsersProfile%\Microsoft\Search\Data\Applications\Windows\Windows.edb

cleanmgr /verylowdisk

Sc config wsearch start=delayed-auto

Net start wsearch