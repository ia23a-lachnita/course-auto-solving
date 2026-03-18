param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [switch]$IncludeCodeText
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Path)) {
    Write-Error "Path not found: $Path"
    exit 2
}

$proseExtensions = @(".md", ".txt")
$codeExtensions = @(".js", ".ts", ".sol", ".py", ".ps1")
$excludeDirs = "node_modules|artifacts|cache|.git|.venv"

$rules = @(
    @{ Pattern = "ß"; Message = "Verbotenes Zeichen: ß (immer ss verwenden)" },
    @{ Pattern = "—"; Message = "Verbotenes Zeichen: em dash (normalen Bindestrich oder Komma verwenden)" },
    @{ Pattern = "\bfuer\b"; Message = "Umlaut ersetzen: fuer -> für" },
    @{ Pattern = "\bFuer\b"; Message = "Umlaut ersetzen: Fuer -> Für" },
    @{ Pattern = "\bAenderung\b"; Message = "Umlaut ersetzen: Aenderung -> Änderung" },
    @{ Pattern = "\baenderung\b"; Message = "Umlaut ersetzen: aenderung -> änderung" },
    @{ Pattern = "\bAendern\b"; Message = "Umlaut ersetzen: Aendern -> Ändern" },
    @{ Pattern = "\baendern\b"; Message = "Umlaut ersetzen: aendern -> ändern" },
    @{ Pattern = "\bEmpfaenger\b"; Message = "Umlaut ersetzen: Empfaenger -> Empfänger" },
    @{ Pattern = "\bempfaenger\b"; Message = "Umlaut ersetzen: empfaenger -> empfänger" },
    @{ Pattern = "\bgeschuetzt\b"; Message = "Umlaut ersetzen: geschuetzt -> geschützt" },
    @{ Pattern = "\bGeschuetzt\b"; Message = "Umlaut ersetzen: Geschuetzt -> Geschützt" },
    @{ Pattern = "\bgeschuetzte\b"; Message = "Umlaut ersetzen: geschuetzte -> geschützte" },
    @{ Pattern = "\bGeschuetzte\b"; Message = "Umlaut ersetzen: Geschuetzte -> Geschützte" }
)

if ($IncludeCodeText) {
    $extensions = $proseExtensions + $codeExtensions
}
else {
    $extensions = $proseExtensions
}

$files = Get-ChildItem -LiteralPath $Path -Recurse -File |
    Where-Object {
        $extensions -contains $_.Extension -and
        $_.FullName -notmatch $excludeDirs
    }

$violations = @()

foreach ($file in $files) {
    $matches = Select-String -Path $file.FullName -Pattern ($rules.Pattern) -AllMatches
    foreach ($m in $matches) {
        foreach ($rule in $rules) {
            if ($m.Line -match $rule.Pattern) {
                $violations += [pscustomobject]@{
                    File = $file.FullName
                    Line = $m.LineNumber
                    Rule = $rule.Message
                    Text = $m.Line.Trim()
                }
            }
        }
    }
}

if ($violations.Count -gt 0) {
    Write-Host "German style check failed. Violations:" -ForegroundColor Red
    $violations |
        Sort-Object File, Line |
        ForEach-Object {
            Write-Host ("- {0}:{1} | {2}`n  {3}" -f $_.File, $_.Line, $_.Rule, $_.Text)
        }
    exit 1
}

if ($IncludeCodeText) {
    Write-Host "German style check passed (prose + code text mode)." -ForegroundColor Green
}
else {
    Write-Host "German style check passed (prose mode)." -ForegroundColor Green
}
exit 0
