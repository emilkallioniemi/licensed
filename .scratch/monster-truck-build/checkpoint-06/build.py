#!/usr/bin/env python3
"""Local Windows Steam checkpoint export. Does not publish or change the source preset."""
import argparse
import hashlib
import json
import shutil
import subprocess
import tempfile
import zipfile
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--godot', required=True)
parser.add_argument('--windows-template', required=True, type=Path)
parser.add_argument('--output', required=True, type=Path)
parser.add_argument('--macos-godotsteam', type=Path, help='Matching GodotSteam osx directory, needed when exporting on macOS')
args = parser.parse_args()
repo = Path(__file__).resolve().parents[3]
output = args.output.resolve()
output.mkdir(parents=True, exist_ok=True)
if any(output.iterdir()):
    raise SystemExit('Choose an empty output directory to preserve earlier builds.')

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

tracked = subprocess.check_output(['git', 'ls-files', '-z'], cwd=repo).decode().split('\0')
untracked = subprocess.check_output(['git', 'ls-files', '--others', '--exclude-standard', '-z'], cwd=repo).decode().split('\0')
files = sorted(set(p for p in tracked + untracked if p and not p.startswith(('.scratch/', '.agents/', 'docs/'))))
source = {p: sha(repo / p) for p in files if (repo / p).is_file()}
with tempfile.TemporaryDirectory(prefix='licensed-checkpoint-export-') as temporary:
    stage = Path(temporary)
    for p in source:
        destination = stage / p
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(repo / p, destination)
    native_hashes = {}
    if args.macos_godotsteam:
        native = stage / 'addons/godotsteam/osx'
        shutil.copytree(args.macos_godotsteam, native)
        native_hashes = {str(p.relative_to(native)): sha(p) for p in native.rglob('*') if p.is_file()}
        extension = stage / 'addons/godotsteam/godotsteam.gdextension'
        extension.write_text(extension.read_text().replace('[libraries]', '[libraries]\nmacos.debug = "res://addons/godotsteam/osx/libgodotsteam.macos.template_debug.universal.dylib"\nmacos.release = "res://addons/godotsteam/osx/libgodotsteam.macos.template_release.universal.dylib"').replace('[dependencies]', '[dependencies]\nmacos.universal = { "res://addons/godotsteam/osx/libsteam_api.dylib": "" }'))
    preset = stage / 'export_presets.cfg'
    preset.write_text(preset.read_text().replace('custom_template/release=""', 'custom_template/release=' + json.dumps(str(args.windows_template.resolve()))))
    with (output / 'export.log').open('w') as log:
        result = subprocess.run([args.godot, '--headless', '--path', str(stage), '--export-release', 'Windows Desktop', str(output / 'licensed.exe')], stdout=log, stderr=subprocess.STDOUT, timeout=300)
    export_text = (output / 'export.log').read_text()
    if result.returncode or 'SCRIPT ERROR' in export_text or 'Parse Error' in export_text or 'Failed to export' in export_text:
        raise SystemExit(f'Export failed ({result.returncode}); inspect {output / "export.log"}')
    required = ['licensed.exe', 'licensed.pck', 'libgodotsteam.windows.template_release.x86_64.dll', 'steam_api64.dll']
    for name in required:
        if not (output / name).is_file() or not (output / name).stat().st_size:
            raise SystemExit(f'Export missing nonempty {name}')
    (output / 'run-checkpoint.cmd').write_text('@echo off\ncd /d "%~dp0"\nlicensed.exe --windowed --resolution 1280x720 --max-fps 60 --log-file "%~dp0checkpoint-engine.log" -- --checkpoint-diagnostics\n')
    shutil.copy2(Path(__file__).with_name('session.md'), output / 'SESSION.md')
    shutil.copy2(Path(__file__).with_name('summarize.py'), output / 'summarize.py')
    manifest = {
        'head': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=repo).decode().strip(),
        'working_source_sha256': source,
        'source_manifest_sha256': hashlib.sha256(json.dumps(source, sort_keys=True).encode()).hexdigest(),
        'godot_version': subprocess.check_output([args.godot, '--version']).decode().strip(),
        'godot_executable_sha256': sha(Path(args.godot)),
        'windows_template_sha256': sha(args.windows_template),
        'export_only_macos_godotsteam_sha256': native_hashes,
        'godotsteam': '4.22.1 / Steamworks SDK 1.65',
        'steam_app_id': 480,
        'acceptance': 'Export artifact only; Windows launch and three-human Steam acceptance pending.',
        'files_sha256': {name: sha(output / name) for name in required + ['run-checkpoint.cmd', 'SESSION.md', 'summarize.py']},
    }
    (output / 'MANIFEST.json').write_text(json.dumps(manifest, indent=2) + '\n')
    archive = output / 'licensed-checkpoint-06.zip'
    with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as bundle:
        for name in required + ['run-checkpoint.cmd', 'SESSION.md', 'summarize.py', 'MANIFEST.json']:
            bundle.write(output / name, name)
    (output / 'SHA256.txt').write_text(sha(archive) + '  ' + archive.name + '\n')
    print(archive)
