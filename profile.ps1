function push {
    param (
        [string]$commitMessage
    )

    if (-not $commitMessage) {
        Write-Host "Please provide a commit message." -ForegroundColor Red
        return
    }

    git add .

    try {
        git commit -m $commitMessage
    } catch {
        Write-Host "Error: Failed to commit changes. You may not have any new staged changes." -ForegroundColor Red
        return
    }

    $branchName = git rev-parse --abbrev-ref HEAD
    $upstream = git for-each-ref --format='%(upstream:short)' refs/heads/$branchName

    if (-not $upstream) {
        Write-Host "No upstream branch set for '$branchName'. Setting upstream to origin/$branchName..." -ForegroundColor Yellow
        try {
            git push --set-upstream origin $branchName
        } catch {
            Write-Host "Error: Failed to push and set upstream for branch '$branchName'." -ForegroundColor Red
            return
        }
    } else {
        try {
            git push
        } catch {
            Write-Host "Error: Failed to push changes to remote." -ForegroundColor Red
            return
        }
    }

    Write-Host "Changes have been committed and pushed with message: $commitMessage" -ForegroundColor Green
}

function relogin {
   
    Write-Host "Logging out from the current GitHub account..." -ForegroundColor Blue
    gh auth logout --hostname "github.com"

    $reloginPrompt = Read-Host "Do you want to log in with a new GitHub account? (yes/no)"
    
    if ($reloginPrompt -eq "yes") {
        Write-Host "Logging in with a new GitHub account..." -ForegroundColor Green
        gh auth login
        Write-Host "Login successful." -ForegroundColor Green
    } else {
        Write-Host "No login attempted. You are logged out." -ForegroundColor Yellow
    }
}



function Add-Member {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Users
    )

    if (!(Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Host "Error: GitHub CLI (gh) is not installed." -ForegroundColor Red
        return
    }

    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Not logged in to GitHub. Run 'gh auth login' first." -ForegroundColor Red
        return
    }

    if (!(Test-Path .git)) {
        Write-Host "Error: Current directory is not a git repository." -ForegroundColor Yellow
        return
    }

    $remoteUrl = git remote get-url origin
    if ($remoteUrl -match "github.com[/:](?<owner>[^/]+)/(?<repo>[^.]+)(\.git)?$") {
        $repoOwner = $matches['owner']
        $repoName = $matches['repo']
    } else {
        Write-Host "Error: Could not determine repository owner and name from git remote URL." -ForegroundColor Red
        return
    }

    $userList = $Users -split ',' | ForEach-Object { $_.Trim() }

    foreach ($username in $userList) {
        try {
            $userCheck = gh api -H "Accept: application/vnd.github+json" "/users/$username" 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Warning: User '$username' not found on GitHub. Use GitHub username instead." -ForegroundColor Yellow
                continue
            }

            Write-Host "Adding $username to $repoOwner/$repoName with push permission..." -ForegroundColor Blue
            $result = gh api `
                --method PUT `
                -H "Accept: application/vnd.github+json" `
                -H "X-GitHub-Api-Version: 2022-11-28" `
                "/repos/$repoOwner/$repoName/collaborators/$username" `
                -f "permission=push"
            
            Write-Host "Success: Added $username" -ForegroundColor Green
            Write-Host "Note: They need to accept the invitation to gain access." -ForegroundColor Cyan
        }
        catch {
            $errorMessage = $_.Exception.Message
            if ($errorMessage -like "*422*") {
                Write-Host "Warning: $username may already be a collaborator." -ForegroundColor Yellow
            }
            elseif ($errorMessage -like "*404*") {
                Write-Host "Error: Failed to add $username. Check:" -ForegroundColor Red
                Write-Host "1. Using GitHub username (not email)" -ForegroundColor Yellow
                Write-Host "2. Permissions to add collaborators" -ForegroundColor Yellow
                Write-Host "3. Repository existence and directory accuracy" -ForegroundColor Yellow
            }
            else {
                Write-Host "Error: Failed to add $username. $errorMessage" -ForegroundColor Red
            }
        }
    }
}

Set-Alias -Name add_member -Value Add-Member





function pull {
    git pull
    Write-Host "Latest changes have been pulled." -ForegroundColor Green
}


function delete_branch {
    param (
        [Parameter(Position=0, Mandatory=$false)]
        [string]$branchName,
        [switch]$localonly
    )
    
    if (-not $branchName) {
        Write-Host "Please provide a branch name to delete." -ForegroundColor Red
        return
    }

    if (-not (Test-Path .git)) {
        Write-Host "Error: This directory is not a Git repository." -ForegroundColor Red
        return
    }

    $currentBranch = git rev-parse --abbrev-ref HEAD

    if ($branchName -eq $currentBranch) {
        Write-Host "Error: Cannot delete the currently checked-out branch '$branchName'. Please switch to a different branch first." -ForegroundColor Red
        return
    }

    $branchExists = git branch --list $branchName
    if (-not $branchExists) {
        Write-Host "Error: Branch '$branchName' does not exist locally." -ForegroundColor Red
        return
    }

    try {
        git branch -d $branchName
        Write-Host "Branch '$branchName' deleted locally." -ForegroundColor Green
    } catch {
        Write-Host "Error: Failed to delete branch '$branchName' locally. It may have unmerged changes. Use '-D' to force delete if necessary." -ForegroundColor Red
        return
    }

    if (-not $localonly) {
        try {
            git push origin --delete $branchName
            Write-Host "Branch '$branchName' deleted from the remote." -ForegroundColor Green
        } catch {
            Write-Host "Error: Failed to delete branch '$branchName' from the remote." -ForegroundColor Red
        }
    }
}



# Set an alias for convenience
# Set-Alias -Name mydetails -Value mydetails


function Remove-Member {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Users
    )

   
    if (!(Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error "GitHub CLI (gh) is not installed. Please install it first."
        return
    }

    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Not logged in to GitHub. Please run 'gh auth login' first."
        return
    }

   
    if (!(Test-Path .git)) {
        Write-Error "This directory is not a Git repository."
        return
    }

    $remoteUrl = git remote get-url origin
    if ($remoteUrl -match "github.com[/:](?<owner>[^/]+)/(?<repo>[^.]+)(\.git)?$") {
        $repoOwner = $matches['owner']
        $repoName = $matches['repo']
    } else {
        Write-Error "Could not determine repository owner and name from git remote URL."
        return
    }

   
    Write-Host "You are about to remove members from: $repoOwner/$repoName" -ForegroundColor Yellow
    Write-Host "Continue? (Y/N): " -ForegroundColor Red -NoNewline
    $confirm = Read-Host
    if ($confirm -notmatch '^[Yy]$') {
        Write-Host "Operation cancelled." -ForegroundColor Cyan
        return
    }

   
    $userList = $Users -split ',' | ForEach-Object { $_.Trim() }

    foreach ($username in $userList) {
        try {
            
            $userCheck = gh api -H "Accept: application/vnd.github+json" "/users/$username" 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Host "User '$username' not found on GitHub." -ForegroundColor Yellow
                continue
            }

            Write-Host "Removing $username from $repoOwner/$repoName..."
            
            $result = gh api `
                --method DELETE `
                -H "Accept: application/vnd.github+json" `
                -H "X-GitHub-Api-Version: 2022-11-28" `
                "/repos/$repoOwner/$repoName/collaborators/$username"
            
            Write-Host "Successfully removed $username" -ForegroundColor Green
        }
        catch {
            $errorMessage = $_.Exception.Message
            if ($errorMessage -like "*404*") {
                Write-Host "Failed to remove $username. Please check: " -ForegroundColor Red
                Write-Host "1. The user is actually a collaborator" -ForegroundColor Yellow
                Write-Host "2. You have permission to remove collaborators" -ForegroundColor Yellow
                Write-Host "3. The username is correct" -ForegroundColor Yellow
            }
            else {
                Write-Host "Failed to remove $username. Error: $errorMessage" -ForegroundColor Red
            }
        }
    }
}

Set-Alias -Name remove_member -Value Remove-Member



function delete_repo {
    param (
        [string]$repoName
    )

    if (-not $repoName) {
        Write-Host "Please provide the repository name to delete." -ForegroundColor Red
        return
    }

    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Host "Error: GitHub CLI (gh) is not installed. Please install it from https://cli.github.com/ and try again." -ForegroundColor Red
        return
    }

    $confirmation = Read-Host "Are you sure you want to delete the repository '$repoName'? This action cannot be undone. Type 'yes' to confirm" 

    if ($confirmation -ne "yes") {
        Write-Host "Repository deletion canceled." -ForegroundColor Blue
        return
    }

    try {
        $deleteRepoResult = gh repo delete "$repoName" --yes
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Repository '$repoName' has been successfully deleted." -ForegroundColor Green
        } else {
            Write-Host "GitHub CLI failed to delete the repository." -ForegroundColor Red
        }
    } catch {
        $errorMessage = $_.Exception.Message

        if ($errorMessage -match "HTTP 403: Must have admin rights to Repository") {
            Write-Host "Error: You need admin rights to delete the repository. Refreshing authentication to grant required permissions..." -ForegroundColor Red
            try {
                gh auth refresh -s delete_repo
                $deleteRepoResult = gh repo delete "$repoName" --yes

                if ($LASTEXITCODE -eq 0) {
                    Write-Host "Repository '$repoName' has been successfully deleted after re-authentication." -ForegroundColor Green
                } else {
                    Write-Host "Error: Failed to delete repository '$repoName' after re-authentication." -ForegroundColor Red
                }
            } catch {
                Write-Host "Error: Failed to delete repository '$repoName' after authentication refresh. Ensure you have the required permissions." -ForegroundColor Red
            }
        } else {
            Write-Host "Error: Failed to delete repository '$repoName'. $errorMessage" -ForegroundColor Red
        }
    }

    if (Test-Path .git) {
        try {
            Remove-Item -Recurse -Force .git
            Write-Host "Git folder has been removed from the local repository." -ForegroundColor Green
        } catch {
            Write-Host "Error: Failed to remove the Git folder." -ForegroundColor Red
        }
    }
}




function sync {
    param (
        [string]$commitMessage
    )

    if (-not $commitMessage) {
        Write-Host "Please provide a commit message." -ForegroundColor Red
        return
    }

    Write-Host "Pulling latest changes..." -ForegroundColor Blue
    git pull

    git add .

    git commit -m $commitMessage

    git push

    Write-Host "Changes have been pulled, committed, and pushed with message: $commitMessage" -ForegroundColor Green
}


function create_repo {
    param (
        [string]$repoName
    )

    if (-not $repoName) {
        Write-Host "Please provide a repository name." -ForegroundColor Red
        return
    }

    # Fetch the GitHub username dynamically using GitHub CLI
    $userInfo = gh api "user" -H "Accept: application/vnd.github+json" | ConvertFrom-Json
    $username = $userInfo.login
    if (-not $username) {
        Write-Host "Error: Unable to fetch the GitHub username." -ForegroundColor Red
        return
    }

    $commitMessage = Read-Host "Enter commit message (default: 'Initial commit')" 
    if (-not $commitMessage) {
        $commitMessage = "Initial commit"
    }

    $visibility = Read-Host "Do you want the repository to be public or private? (default: public)" 
    $visibility = $visibility.ToLower()
    if ($visibility -ne "private") {
        $visibility = "public"
    }

    Write-Host "Creating GitHub repository '$repoName' as $visibility..." -ForegroundColor Blue
    gh repo create $repoName --$visibility --confirm

    if (-not (Test-Path .git)) {
        git init
    }

    if ((Get-ChildItem -File | Measure-Object).Count -eq 0) {
        Write-Host "No files found in the directory. Skipping commit and push steps." -ForegroundColor Blue
    } else {
        git add .
        try {
            git commit -m $commitMessage
            git branch -M main
            git remote add origin "https://github.com/$username/$repoName.git"
        } catch {
            Write-Host "Error: Failed to commit changes. There may be no changes to commit." -ForegroundColor Red
            return
        }
    }

    try {
        git push -u origin main
        Write-Host "Repository '$repoName' created as $visibility and pushed with message: $commitMessage" -ForegroundColor Green
    } catch {
        Write-Host "Repository '$repoName' created as $visibility but no files were pushed (empty directory)." -ForegroundColor Red
    }
}


function switchto {
    param (
        [string]$branchName
    )

    if (-not $branchName) {
        Write-Host "Please provide a branch name." -ForegroundColor Red
        return
    }

    if (-not (Test-Path .git)) {
        Write-Host "Error: This directory is not a Git repository." -ForegroundColor Red
        return
    }

    $branchExists = git branch --list $branchName

    try {
        if ($branchExists) {
            Write-Host "Switching to branch '$branchName'..." -ForegroundColor Blue
            git checkout $branchName
        } else {
            Write-Host "Branch '$branchName' does not exist. Creating and switching to it..." -ForegroundColor Yellow
            git checkout -b $branchName
        }
    } catch {
        Write-Host "Error: Failed to switch to or create branch '$branchName'." -ForegroundColor Red
    }

    try {
        $currentBranch = git rev-parse --abbrev-ref HEAD
        Write-Host "Currently on branch: $currentBranch" -ForegroundColor Green
    } catch {
        Write-Host "Error: Failed to confirm the current branch." -ForegroundColor Red
    }
}

function List-Repo {
    # Check if GitHub CLI (gh) is installed
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Host "GitHub CLI (gh) is not installed. Please install it from https://cli.github.com/" -ForegroundColor Red
        return
    }

    # Fetch repositories using GitHub CLI
    try {
        $repos = gh repo list --json name,visibility --limit 1000 | ConvertFrom-Json
        if ($repos.Count -eq 0) {
            Write-Host "No repositories found for this account." -ForegroundColor Yellow
            return
        }

        # Format output as a table with columns for name and visibility
        $repos | ForEach-Object {
            [PSCustomObject]@{
                Name       = $_.name
                Visibility = $_.visibility
            }
        } | Format-Table -Property Name, Visibility -AutoSize
    } catch {
        Write-Host "Failed to retrieve repository list. Ensure you are authenticated with 'gh auth login'." -ForegroundColor Red
    }
}

# Set an alias for convenience
Set-Alias -Name list_repo -Value List-Repo