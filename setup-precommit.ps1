# Ensure you're inside your virtual environment before running this

Write-Output " Installing pre-commit and pipreqs..."
pip install pre-commit pipreqs

Write-Output " Creating .pre-commit-config.yaml..."
$config = @"
repos:
  - repo: local
    hooks:
      - id: update-requirements
        name: Update requirements.txt with pipreqs
        entry: pipreqs . --force
        language: system
        pass_filenames: false
"@
Set-Content -Path ".pre-commit-config.yaml" -Value $config -Encoding UTF8

Write-Output " Installing pre-commit hook into .git/hooks..."
pre-commit install

Write-Output "Setup complete! Now every commit will auto-update requirements.txt."
