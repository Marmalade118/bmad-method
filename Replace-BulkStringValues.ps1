# Bulk find and replace in files
# This script will search for specific words in files and replace them with their British English equivalents.
# Ensure you run this script in the directory where your files are located.

Get-ChildItem -Recurse -Include *.yml, *.yaml, *.md, *.bicep, *.ps1 | 
ForEach-Object {
    (Get-Content $_.FullName) |
    ForEach-Object { 
        $_ `
            -replace '\binfra\b', 'infrastructure' `
            -replace '\bdev\b', 'development' `
            -replace '\bprod\b', 'production' `
            -replace '\bbehaviou?r\b', 'behaviour' `
            -replace '\bord?rganisati?on\b', 'organisation' `
            -replace '\blazer\b', 'laser' `
            -replace '\bcolour\b', 'colour' `
            -replace '\bflavor\b', 'flavour' `
            -replace '\boptimiz?e\b', 'optimise' `
            # add more rules as needed
    } | Set-Content $_.FullName
}