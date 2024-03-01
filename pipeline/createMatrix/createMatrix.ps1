param(
    [string]$basedir,
    [string]$prefix = "build-config",
    [string]$centralFilePath,
    [string]$mergeKeyFile,
    [switch]$verbose,
    [switch]$azpMatrix,
    [switch]$githubMatrix
)

function UpdateConanProperty($yamlContent, $config, $filedir) {
    # Check for the existence of either conanfile.txt or conanfile.py
    $conanfileTxtExists = Test-Path (Join-Path $filedir "conanfile.txt")
    $conanfilePyExists = Test-Path (Join-Path $filedir "conanfile.py")

    if ($null -eq $yamlContent[$config]['conan'] -and ($conanfileTxtExists -or $conanfilePyExists)) {
        Write-Host "Adding conan: true to $config as conanfile.txt or conanfile.py exists."
        $yamlContent[$config]['conan'] = $true
    }
}

function AddRelativeDirectory($yamlContent, $config, $relativedir) {
    $yamlContent[$config]['directory'] = $relativedir
}

function UpdateProperties($yamlContent, $config, $property, $keyName, $replace) {
    if ($null -ne $property) {
        if ($yamlContent[$config].ContainsKey($keyName)) {
            if ($replace) {
                $yamlContent[$config][$keyName] = $yamlContent[$config][$keyName]
            } else {
                $yamlContent[$config][$keyName] = "$property " + $yamlContent[$config][$keyName]
            }
        } else {
            $yamlContent[$config][$keyName] = $property
        }
    }
}

function ProcessYamlFile($file, $basedir) {
    $filedir = Split-Path -Parent $file
    if ($basedir -eq ".") {
        $basedir = (Get-Location).Path
    }
    $relativedir = $filedir.Substring($basedir.Length).TrimStart('\').TrimStart('/')

    Write-Host "Processing: $file"

    # Check for CMakeLists.txt in the same directory
    if (-not (Test-Path (Join-Path $filedir "CMakeLists.txt"))) {
        Write-Host "##vso[task.logissue type=warning]CMakeLists.txt not found in directory: $filedir"
        return $null
    }

    $mergeKeyContent = $null
    if ($mergeKeyFile) {
      if(Test-Path $mergeKeyFile) {
        $mergeKeyContent = Get-Content $mergeKeyFile -Raw
      }
      else {
        Write-Host "##vso[task.logissue type=error]Error loading merge keys file: $file"
        return $null
      }
    }

    try {
        # Merge the content of the merge-key file with the current file's content
        $fileContent = Get-Content $file -Raw
        if ($mergeKeyContent) {
            $fileContent = $fileContent + "`n" + $mergeKeyContent  # Append the optional file content to the current file content
        }
        $yamlContent = ConvertFrom-Yaml -UseMergingParser -Yaml $fileContent
    } catch {
        Write-Host "Error processing file $file : $($_.Exception.Message)"
        return $null
    }

    $allBuildConfigs = @{}
    
    # Assume the first non-merge key is the package name, and configuration are under 'configuration'
    $packageKey = $yamlContent.keys | Where-Object { $_ -notlike "_*" } | Select-Object -First 1
    Write-Host $packageKey
    if ($null -ne $packageKey -and $yamlContent[$packageKey].ContainsKey('configuration')) {
        $configuration = $yamlContent[$packageKey]['configuration']

        $packageNameKey = $yamlContent[$packageKey].Keys | Where-Object { $_ -ieq 'packagename' } | Select-Object -First 1
        $projectNameKey = $yamlContent[$packageKey].Keys | Where-Object { $_ -ieq 'projectname' } | Select-Object -First 1
        
        $packageNameValue = if ($null -ne $packageNameKey) { $yamlContent[$packageKey][$packageNameKey] } else { $null }
        $projectNameValue = if ($null -ne $projectNameKey) { $yamlContent[$packageKey][$projectNameKey] } else { $null }
    
        foreach ($configName in $configuration.keys) {
            $fullName = "$($packageKey)_$($configName)"
            $allBuildConfigs[$fullName] = $configuration[$configName]
            
            UpdateProperties -yamlContent $allBuildConfigs -config $fullName -property $packageNameValue -keyName 'packagename' -replace $true
            UpdateProperties -yamlContent $allBuildConfigs -config $fullName -property $projectNameValue -keyName 'projectname' -replace $true
            
            UpdateConanProperty -yamlContent $allBuildConfigs -config $fullName -filedir $filedir
            AddRelativeDirectory -yamlContent $allBuildConfigs -config $fullName -relativedir $relativedir
        }

        return $allBuildConfigs
    } else {
        Write-Host "Expected 'configuration' key not found under package key: $packageKey"
        return $null
    }

}

# Check if the PowerShell-yaml module is available
if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
    Write-Host "The powershell-yaml module is not installed. Please install it using 'Install-Module powershell-yaml'."
    exit
}

# Import PowerShell-yaml module
Import-Module powershell-yaml

$WindowsBuildConfigs = @{}
$LinuxBuildConfigs = @{}

Get-ChildItem -Path $basedir -Recurse -Filter "${prefix}*.yml" | ForEach-Object {
    $yamlContent = ProcessYamlFile -file $_.FullName -basedir $basedir
    $yamlContent | Out-String | Write-Host
    if ($null -ne $yamlContent) {
        foreach ($configName in $yamlContent.keys) {
            if ($yamlContent[$configName].platform -eq 'win') {
                $WindowsBuildConfigs[$configName] = $yamlContent[$configName]
            } elseif (-Not $configName.StartsWith("_")) {
                $LinuxBuildConfigs[$configName] = $yamlContent[$configName]
            }
        }
    }
}



$allYamlContents = $WindowsBuildConfigs + $LinuxBuildConfigs

if ($githubMatrix) {
    $githubBuildConfigs = @()
    foreach ($config in $allYamlContents.GetEnumerator()) {
        $config.Value["configName"] = $config.Name
        $githubBuildConfigs += $config.Value
    }
    $allYamlContents = @{}
    $allYamlContents["config"] = $githubBuildConfigs
    if ($verbose) {
        Write-Host "Github Build Configs (YAML):"
        $allYamlContents | ConvertTo-Yaml | Out-String | Write-Host
        Write-Host "Github Build Configs (JSON):"
        $allYamlContents | ConvertTo-Json -Depth 10 | Out-String | Write-Host
    }

    "matrixconfig=$($allYamlContents | ConvertTo-Json -Compress)" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
}

if ($centralFilePath) {
    $allYamlContents | ConvertTo-Yaml | Set-Content $centralFilePath
    Write-Host "All configuration are saved in $centralFilePath."
}

if ($azpMatrix) {
    # Only write to the central file if $centralFilePath is set

    if ($verbose) {
        Write-Host "Windows Build Configs (YAML):"
        $WindowsBuildConfigs | ConvertTo-Yaml | Out-String | Write-Host
        Write-Host "Linux Build Configs (YAML):"
        $LinuxBuildConfigs | ConvertTo-Yaml | Out-String | Write-Host

        Write-Host "Windows Build Configs (JSON):"
        $WindowsBuildConfigs | ConvertTo-Json -Depth 10 | Out-String | Write-Host
        Write-Host "Linux Build Configs (JSON):"
        $LinuxBuildConfigs | ConvertTo-Json -Depth 10 | Out-String | Write-Host
    }
    Write-Host "##vso[task.setvariable variable=WindowsBuildConfigs;isOutput=true]"($WindowsBuildConfigs | ConvertTo-Json -Compress)
    Write-Host "##vso[task.setvariable variable=LinuxBuildConfigs;isOutput=true]"($LinuxBuildConfigs | ConvertTo-Json -Compress)
}

Write-Host "Done."
