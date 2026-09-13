#!/usr/bin/env python3
"""Export both platforms from one git archive; never publish or replace output."""
import argparse
import hashlib
import json
import re
import plistlib
import shutil
import subprocess
import tempfile
import zipfile
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]

def run(command, **kwargs):
    return subprocess.check_output(command, text=True, **kwargs).strip()

def sha(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()

def hashes(root):
    return {str(p.relative_to(root)): sha(p) for p in sorted(root.rglob('*')) if p.is_file()}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--commit', help='Required for final builds; full commit resolved by git.')
    parser.add_argument('--working-tree', action='store_true', help='PROVISIONAL: tracked plus untracked nonignored files.')
    parser.add_argument('--godot', required=True, type=Path)
    parser.add_argument('--windows-template', required=True, type=Path)
    parser.add_argument('--macos-template', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    if bool(args.commit) == args.working_tree:
        parser.error('Choose exactly one of --commit or --working-tree.')
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    if any(output.iterdir()):
        parser.error('Output must be empty; historical builds are never replaced.')
    inputs = json.loads(Path(__file__).with_name('inputs.json').read_text())
    paths = {'godot': args.godot.resolve(), 'windows_template': args.windows_template.resolve(), 'macos_template': args.macos_template.resolve()}
    for key, path in paths.items():
        if sha(path) != inputs[key]['sha256']:
            parser.error(f'{key} differs from pinned inputs.json: {path}')
    commit = run(['git', 'rev-parse', '--verify', (args.commit or 'HEAD') + '^{commit}'], cwd=REPO)
    with tempfile.TemporaryDirectory(prefix='licensed-release-') as temp:
        stage = Path(temp) / 'source'
        stage.mkdir()
        if args.working_tree:
            names = run(['git', 'ls-files', '-z', '--cached', '--others', '--exclude-standard'], cwd=REPO).split('\0')
            for name in set(names):
                src = REPO / name
                if name and src.is_file():
                    dst = stage / name
                    dst.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(src, dst)
        else:
            archive = Path(temp) / 'source.tar'
            subprocess.run(['git', 'archive', '--format=tar', '-o', str(archive), commit], cwd=REPO, check=True)
            subprocess.run(['tar', '-xf', str(archive), '-C', str(stage)], check=True)
            # The recipe and pins must also be the ones identified by the commit.
            for name in ('build.py', 'inputs.json'):
                if sha(Path(__file__).with_name(name)) != sha(stage / '.scratch/monster-truck-build/release' / name):
                    parser.error(f'Run {name} from the selected commit.')
        source = hashes(stage)
        for name, expected in inputs['native_addons'].items():
            if source.get(name) != expected:
                parser.error(f'Native dependency does not match pinned input: {name}')
        manifest = {'source_commit': commit, 'source_tree': run(['git', 'rev-parse', commit + '^{tree}'], cwd=REPO),
                    'provisional_working_tree': args.working_tree, 'source_files_sha256': source,
                    'source_manifest_sha256': hashlib.sha256(json.dumps(source, sort_keys=True).encode()).hexdigest(),
                    'inputs': inputs, 'godot_version': run([str(paths['godot']), '--version']),
                    'signing': 'macOS ad hoc; not Developer ID signed or notarized. Windows unsigned.',
                    'verification_limits': 'Builder checks archives and binary structure/signatures. Native macOS arm64 boot is recorded separately. Windows, Intel Mac and three-human Steam acceptance pending.'}
        preset = stage / 'export_presets.cfg'
        sections = preset.read_text().split('[preset.1]')
        sections[0] = sections[0].replace('custom_template/release=""', 'custom_template/release=' + json.dumps(str(paths['windows_template'])))
        sections[1] = sections[1].replace('custom_template/release=""', 'custom_template/release=' + json.dumps(str(paths['macos_template'])))
        preset.write_text('[preset.1]'.join(sections))
        manifest['staging_override'] = 'Only custom_template/release paths for the pinned templates in export_presets.cfg.'
        for platform, preset_name, target in [('windows-x86_64', 'Windows Desktop', 'licensed.exe'), ('macos-universal', 'macOS', 'licensed.app')]:
            folder = output / ('licensed-scrapyard-' + platform)
            folder.mkdir()
            logpath = output / (platform + '-export.log')
            with logpath.open('w') as log:
                result = subprocess.run([str(paths['godot']), '--headless', '--path', str(stage), '--export-release', preset_name, str(folder / target)], stdout=log, stderr=subprocess.STDOUT, timeout=600)
            logtext = logpath.read_text()
            errors = [line for line in logtext.splitlines() if 'ERROR:' in line]
            # Sandboxed provisional exports cannot persist the host editor preferences.
            # These exact settings-write errors do not concern exported resources.
            if args.working_tree:
                errors = [line for line in errors if not re.fullmatch(r"ERROR: (Cannot save file '.*/editor_settings-4\.7\.tres'\.|Error saving editor settings to .*/editor_settings-4\.7\.tres)", line)]
            if result.returncode or errors or any(error in logtext for error in ('SCRIPT ERROR', 'Parse Error', 'Failed to export')):
                raise RuntimeError(f'Export failed; inspect {logpath}')
            if platform.startswith('windows'):
                for name in ('licensed.exe', 'libgodotsteam.windows.template_release.x86_64.dll', 'steam_api64.dll'):
                    data = (folder / name).read_bytes()
                    offset = int.from_bytes(data[60:64], 'little')
                    assert data[:2] == b'MZ' and data[offset:offset+6] == b'PE\0\0d\x86', name
                assert (folder / 'licensed.pck').stat().st_size > 0
                (folder / 'run-playtest.cmd').write_text('@echo off\ncd /d "%~dp0"\nlicensed.exe --windowed --resolution 1280x720 --max-fps 60 --log-file "%~dp0playtest-engine.log" -- --checkpoint-diagnostics\n')
            else:
                app = folder / target
                binaries = list((app / 'Contents/MacOS').iterdir()) + list((app / 'Contents/Frameworks').glob('*.dylib'))
                assert any('template_release' in p.name for p in binaries)
                assert any(p.name == 'libsteam_api.dylib' for p in binaries)
                checks = []
                for binary in binaries:
                    arch = run(['lipo', '-archs', str(binary)])
                    assert set(arch.split()) == {'arm64', 'x86_64'}, (binary, arch)
                    linkage = run(['otool', '-L', str(binary)])
                    if 'template_release' in binary.name:
                        assert '@loader_path/libsteam_api.dylib' in linkage
                        assert (binary.parent / 'libsteam_api.dylib').is_file()
                    checks.append(linkage)
                    checks.append(run(['vtool', '-show-build', str(binary)]))
                subprocess.run(['codesign', '--verify', '--deep', '--strict', str(app)], check=True)
                plist = plistlib.loads((app / 'Contents/Info.plist').read_bytes())
                assert plist.get('NSMicrophoneUsageDescription')
                entitlements = subprocess.check_output(['codesign', '-d', '--entitlements', ':-', str(app)], stderr=subprocess.DEVNULL)
                assert plistlib.loads(entitlements).get('com.apple.security.device.audio-input') is True
                (output / 'macos-binary-checks.txt').write_text('\n'.join(checks) + '\n')
            release_docs = stage / '.scratch/monster-truck-build/release'
            shutil.copy2(release_docs / 'LAUNCH.md', folder / 'README.md')
            shutil.copy2(release_docs / 'SESSION.md', folder / 'SESSION.md')
            shutil.copy2(stage / '.scratch/monster-truck-build/checkpoint-06/summarize.py', folder / 'summarize.py')
            platform_manifest = dict(manifest, platform=platform, files_sha256=hashes(folder))
            (folder / 'MANIFEST.json').write_text(json.dumps(platform_manifest, indent=2) + '\n')
            archive = output / (folder.name + '.zip')
            if platform.startswith('macos'):
                subprocess.run(['ditto', '-c', '-k', '--sequesterRsrc', '--keepParent', str(folder), str(archive)], check=True)
            else:
                with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as bundle:
                    for path in sorted(folder.rglob('*')):
                        if path.is_file():
                            bundle.write(path, str(path.relative_to(output)))
            with zipfile.ZipFile(archive) as bundle:
                assert bundle.testzip() is None
                for name, expected in platform_manifest['files_sha256'].items():
                    assert hashlib.sha256(bundle.read(folder.name + '/' + name)).hexdigest() == expected, name
                assert bundle.read(folder.name + '/MANIFEST.json') == (folder / 'MANIFEST.json').read_bytes()
        (output / 'SHA256.txt').write_text(''.join(sha(p) + '  ' + p.name + '\n' for p in sorted(output.glob('*.zip'))))
        print(output)

if __name__ == '__main__':
    main()
