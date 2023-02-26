$repo_src_owner = 'kindtek'
$repo_src_name = 'docker-to-wsl'
$repo_src_branch = 'dev'
$dir_host = "$repo_src_owner/$repo_src_name/$repo_src_branch/scripts"
$dir_local = "$repo_src_name/scripts"
$download1 = "docker-wsl-install.ps1"
$download2 = "get-latest-winget.ps1"
$add_wsl_windows_features = "add-wsl-windows-features"
$download3 = "$add_wsl_windows_features/add-features.ps1"

# make directory tree for incoming repo
$null = New-Item -Path $dir_local -ItemType Directory -Force -ErrorAction SilentlyContinue 
Push-Location $dir_local
$null = New-Item -Path 'add-wsl-windows-features' -f -ItemType Directory -Force -ErrorAction SilentlyContinue 
Push-Location 'add-wsl-windows-features'
# "$pwd_path/windows-features-wsl-add/configure-windows-features.ps1"


$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/$dir_host/$download1", "$dir_local/$download1")
Write-Host "`n`rDownloading: https://raw.githubusercontent.com/$dir_host/$download1`r`nDestination: $dir_local/$download1" -ForegroundColor Magenta 
$WebClient.DownloadFile("https://raw.githubusercontent.com/$dir_host/$download2", "$dir_local/$download2")
Write-Host "`n`rDownloading: https://raw.githubusercontent.com/$dir_host/$download2`r`nDestination: $dir_local/$download2" -ForegroundColor Magenta 
$WebClient.DownloadFile("https://raw.githubusercontent.com/$dir_host/$download3", "$dir_local/$download3")
Write-Host "`n`rDownloading: https://raw.githubusercontent.com/$dir_host/$download3`r`nDestination: $dir_local/$download3`n`r" -ForegroundColor Magenta 

Set-Location $repo_src_name
# return to original working dir
$file = "scripts/$download1"
Write-Output $file
powershell -Command $file
