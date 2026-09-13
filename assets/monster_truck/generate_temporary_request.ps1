Add-Type -AssemblyName System.Speech
$speech = New-Object System.Speech.Synthesis.SpeechSynthesizer
$speech.Rate = -1
$speech.SetOutputToWaveFile((Join-Path $PSScriptRoot 'temporary_request.wav'))
$speech.Speak('I would like to see a turn, a reverse, and a parked vehicle.')
$speech.Dispose()
