

# Script PowerShell para automatizar git add, commit e push

if ($MyInvocation.InvocationName -eq $null -or $MyInvocation.InvocationName -eq '.') {
    Write-Host "\nExecute este script com:"
    Write-Host "powershell -File .\git_auto_push.sh -Mensagem 'Sua mensagem de commit'\n"
    exit 1
}

param(
    [Parameter(Mandatory = $true)]
    [string]$Mensagem
)

git add .
git commit -m "$Mensagem"
git push
