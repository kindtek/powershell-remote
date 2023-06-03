$host.UI.RawUI.ForegroundColor = "White"
$host.UI.RawUI.BackgroundColor = "Black"
$img_tag = $args[0]

function install_winget {
    param (
        $git_parent_path
    )
    $software_name = "WinGet"
    Write-Host "`r`n"
    if (!(Test-Path -Path "$git_parent_path/.winget-installed" -PathType Leaf)) {
        $file = "$git_parent_path/get-latest-winget.ps1"
        Invoke-WebRequest "https://raw.githubusercontent.com/kindtek/dvl-adv/dvl-works/get-latest-winget.ps1" -OutFile $file;
        powershell.exe -executionpolicy remotesigned -File $file
        # install winget and use winget to install everything else
        Write-Host "Installing $software_name ..." 
        # $p = Get-Process -Name "PackageManagement"
        # Stop-Process -InputObject $p
        # Get-Process | Where-Object { $_.HasExited }
        Write-Host "$software_name installed" | Out-File -FilePath "$git_parent_path/.winget-installed"
    }
    else {
        Write-Host "$software_name already installed"   
    }
}

function install_repo {
    param (
        $git_parent_path, $git_path, $repo_src_owner, $repo_src_name, $repo_dir_name, $repo_src_branch 
    )
    $software_name = "Github CLI"
    $refresh_envs = "$HOME/repos/kindtek/RefreshEnv.cmd"
    $global:progress_flag = 'silentlyContinue'
    $orig_progress_flag = $progress_flag 
    $progress_flag = 'SilentlyContinue'
    Invoke-WebRequest "https://raw.githubusercontent.com/kindtek/choco/ac806ee5ce03dea28f01c81f88c30c17726cb3e9/src/chocolatey.resources/redirects/RefreshEnv.cmd" | Out-Null
    $progress_flag = $orig_progress_flag
    if (!(Test-Path -Path "$git_parent_path/.github-installed" -PathType Leaf)) {
        Write-Host "Installing $software_name ..."
        winget install --exact --id GitHub.cli --silent --locale en-US --accept-package-agreements --accept-source-agreements
        winget upgrade --exact --id GitHub.cli --silent --locale en-US --accept-package-agreements --accept-source-agreements
        winget install --id Git.Git --source winget --silent --locale en-US --accept-package-agreements --accept-source-agreements; `
        winget upgrade --id Git.Git --source winget --silent --locale en-US --accept-package-agreements --accept-source-agreements; `
        Write-Host "$software_name installed" | Out-File -FilePath "$git_parent_path/.github-installed"; `
    
    }
    else {
        Write-Host "$software_name already installed" 
    }
    # allow git to be used in same window immediately after installation
    Write-Host "making sure git command works"
    ([void]( New-Item -path alias:git -Value 'C:\Program Files\Git\bin\git.exe' -ErrorAction SilentlyContinue | Out-Null ))
    powershell.exe -Command $refresh_envs | Out-Null
    Write-Host "checking if github repos need to be updated ..." 
    Set-Location $git_parent_path
    ((git -C $repo_dir_name pull --progress) -Or `
    (git clone "https://github.com/$repo_src_owner/$repo_src_name" --branch $repo_src_branch --progress -- $repo_dir_name) -And `
    ($new_install = $true)) 
    Push-Location $repo_dir_name
    ((git submodule update --remote --progress -- dvlp dvl-adv powerhell) -Or `
    (git submodule update --init --remote --progress -- dvlp dvl-adv powerhell) -And `
    ($new_install = $true)) 
    Set-Location dvlp
    ((git submodule update --init --progress -- mnt kernels) -Or `
    (git submodule update --init --progress -- mnt kernels))
    return $new_install
}

function run_devels_playground {
    param (
        $git_path, $img_name_tag, $non_interactive, $default_distro
    )
    try {
        $software_name = "devel`'s playground"
        # if (!(Test-Path -Path "$git_path/.dvlp-installed" -PathType Leaf)) {
        Write-Host "`r`nNOTE:`tDocker Desktop is required to be running for the devel's playground to work.`r`n`r`n`tDo NOT quit Docker Desktop until you are done running it.`r`n" 
        Start-Sleep 10
        Write-Host "`r`n`r`nAttempting to start wsl import tool ..."
        Start-Sleep 3
        # @TODO: add cdir and python to install with same behavior as other installs above
        # not eloquent at all but good for now

        # ... even tho cdir does not appear to be working on windows
        # $cmd_command = pip install cdir
        # Start-Process -FilePath PowerShell.exe -NoNewWindow -ArgumentList $cmd_command
    
        # @TODO: maybe start in new window
        # $start_devs_playground = Read-Host "`r`nstart devel's playground ([y]/n)"
        # if ($start_devs_playground -ine 'n' -And $start_devs_playground -ine 'no') { 

        # // commenting out background building process because this is NOT quite ready.
        # // would like to run in separate window and then use these new images in devel's playground 
        # // if they are more up to date than the hub - which could be a difficult process
        # $cmd_command = "$git_path/devels_playground/docker-images-build-in-background.ps1"
        # &$cmd_command = cmd /c start powershell.exe -Command "$git_path/devels_playground/docker-images-build-in-background.ps1" -WindowStyle "Maximized"

        Write-Host "Launching $software_name ...`r`n" 
        # Write-Host "&$devs_playground $global:img_name_tag"
        # Write-Host "$([char]27)[2J"
        # Write-Host "`r`npowershell.exe -Command `"$git_path/dvlp/scripts/wsl-docker-import.cmd`" $img_name_tag`r`n"
        $img_name_tag = $img_name_tag.replace("\s+", '')
        write-host `$img_name_tag $img_name_tag
        write-host `$non_interactive $non_interactive
        write-host `$default_distro $default_distro
        powershell.exe -Command "$git_path/dvlp/scripts/wsl-docker-import.cmd" "$img_name_tag" "$non_interactive" "$default_distro"
        # &$devs_playground = "$git_path/dvlp/scripts/wsl-docker-import.cmd $global:img_tag"
        # Write-Host "$software_name installed`r`n" | Out-File -FilePath "$git_path/.dvlp-installed"
        Write-Host "$software_name installed successfully" | Out-File -FilePath "$git_path/.dvlp-installed"
        # }
    }
    catch {}
}

# jump to bottom line without clearing scrollback
$dvlp_options = 'n'
do {


    $repo_src_owner = 'kindtek'
    $repo_src_name = 'devels-workshop'
    $repo_src_branch = 'main'
    $repo_dir_name = 'dvlw'
    $git_parent_path = "$HOME/repos/$repo_src_owner"
    $git_path = "$git_parent_path/$repo_dir_name"
    $img_name = 'devels-playground'
    $img_tag = $args[0]
    $img_name_tag = "$img_name`:$img_tag"

    $confirmation = ''
    

    if (($dvlp_options -ine 'u') -And (!(Test-Path -Path "$git_path/.dvlp-installed" -PathType Leaf))) {
        Write-Host "$([char]27)[2J"
        $host.UI.RawUI.ForegroundColor = "Black"
        $host.UI.RawUI.BackgroundColor = "DarkRed"

        # $confirmation = Read-Host "`r`nRestarts may be required as new applications are installed. Save your work now.`r`n`r`n`tHit ENTER to continue`r`n`r`n`tpowershell.exe -Command $file $args" 
        $confirmation = Read-Host "`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`nRestarts may be required as new applications are installed. Save your work now.`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`tHit ENTER to continue`r`n"
        Write-Host "$([char]27)[2J"
        Write-Host "`r`n`r`n`r`n`r`n`r`n`r`nRestarts may be required as new applications are installed. Save your work now.`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`t"

    }
    if ($confirmation -eq '') {   
        $host.UI.RawUI.ForegroundColor = "Black"
        $host.UI.RawUI.BackgroundColor = "DarkRed" 
        Write-Host "`t-- use CTRL + C or close this window to cancel anytime --"
        Start-Sleep 3
        Write-Host ""
        Start-Sleep 1
        Write-Host ""


        # source of the below self-elevating script: https://blog.expta.com/2017/03/how-to-self-elevate-powershell-script.html#:~:text=If%20User%20Account%20Control%20(UAC,select%20%22Run%20with%20PowerShell%22.
        # Self-elevate the script if required
        if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
            if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
                $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
                Start-Process -FilePath PowerShell.exe -Verb Runas -WindowStyle "Maximized" -ArgumentList $CommandLine
                Exit
            }
        }
        $host.UI.RawUI.ForegroundColor = "White"
        $host.UI.RawUI.BackgroundColor = "Black"
        Write-Host ""
        Start-Sleep 1
        Write-Host ""
        Start-Sleep 1
        Write-Host "`r`n`r`nThese programs will be installed or updated:" -ForegroundColor Magenta
        Start-Sleep 1
        Write-Host "`r`n`t- WinGet`r`n`t- Github CLI`r`n`t- devels-workshop repo`r`n`t- devels-playground repo" -ForegroundColor Magenta
        
        # Write-Host "Creating path $HOME\repos\kindtek if it does not exist ... "  
        New-Item -ItemType Directory -Force -Path $git_parent_path | Out-Null

        install_winget $git_parent_path

        install_repo $git_parent_path $git_path $repo_src_owner $repo_src_name $repo_dir_name $repo_src_branch  

        powershell.exe -Command "$git_path/scripts/install-everything.ps1"

        $host.UI.RawUI.ForegroundColor = "Black"
        $host.UI.RawUI.BackgroundColor = "DarkRed"

        if (!(Test-Path -Path "$git_path/.dvlp-installed" -PathType Leaf)) {
            # make sure failsafe official-kali-rolling-latest distro is installed so changes can be easily reverted
            # run_devels_playground "$git_path" "default" "official-kali-rolling-latest"
            # install distro requested in arg
            run_devels_playground "$git_path" "$img_name_tag" "kindtek-$img_name_tag"
        }
        else {
            run_devels_playground "$git_path" "$img_name_tag" ""
        }
        Write-Host "`r`n`r`n"

        # $dvlp_options = Read-Host "`r`nHit ENTER to exit or choose from the following:`r`n`t- launch [W]SL`r`n`t- launch [D]evels Playground`r`n`t- launch repo in [V]S Code`r`n`t- build/install a Linux [K]ernel`r`n`r`n`t"
        Write-Host "`r`n`tChoose from the following:`r`n`r`n`t- [l]aunch default WSL distro`r`n`t- [i]mport Docker image as WSL distro`r`n`t- [s]etup Kindtek LINUX environment`r`n`t- [u]pdate Kindtek WINDOWS environment`r`n`r`n    (exit)`r`n"
        $dvlp_options = Read-Host
        if ($dvlp_options -ieq 'l') {    
            # wsl sh -c "cd /hel;exec $SHELL"
            wsl.exe --cd /hal
            $dvlp_options = 'u'
        }
        elseif ($dvlp_options -ieq 'i') {
            run_devels_playground "$git_path" "$img_name_tag"
            $dvlp_options = 'u'
        }
        if ($dvlp_options -ieq 's') {
            wsl.exe --cd /hal exec bash setup.sh $env:USERNAME
            $dvlp_options = 'u'
        }
        if ($dvlp_options -ieq 'u') {
            Write-Host 'checking for new updates ...'
            $dvlp_options = 'u'
        }
        # elseif ($dvlp_options -ieq 'v') {
        #     wsl sh -c "cd /hel;. code"
        # }
        else {
            $dvlp_options = ''
            break
        }
    }
} while ($dvlp_options -ieq 'u')


Write-Host "`r`nGoodbye!`r`n"
