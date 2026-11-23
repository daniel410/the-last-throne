"""Prepare and compare the Studio audit for the two frozen finale builds."""
import argparse
import hashlib
import json
from pathlib import Path
import runpy
import subprocess
import sys

HERE = Path(__file__).resolve().parent
DISPATCH = HERE.parent / 'epic-finale-dispatch-20261120'
PROFILES = HERE.parent / 'epic-finale-route-profiles-20261121'
MODULE = 'src/server/World/EpicFinaleScenery.luau'
MODELS = {
    'DW-07': 'ConvoyRoadLoadingSill',
    'GW-07': 'NorthernWindgapStrata',
    'FV-07': 'FreightSledLanding',
    'EC-07': 'DispatchCarrierCradle',
    'HG-07': 'AlliedReturnParapet',
}


def prepare(directory, places, build):
    target_hashes = (build['baseline']['sha256'], build['outputs'][0]['sha256'])
    for place, target_hash in zip(places, target_hashes, strict=True):
        with place.open('rb') as stream:
            actual_hash = hashlib.file_digest(stream, 'sha256').hexdigest()
        if actual_hash != target_hash:
            raise SystemExit(f'Unexpected Place SHA-256 for {place}: {actual_hash}')

    for stage, record in (('baseline', build['baseline']), ('candidate', build)):
        output = directory / f'{stage}.luau'
        command = [sys.executable, str(DISPATCH / 'prepare-studio.py'), '--output', str(output)]
        if stage == 'candidate':
            command.append('--candidate')
        subprocess.run(command, check=True)

        module = subprocess.check_output(['git', 'show', f"{record['sourceCommit']}:{MODULE}"], cwd=HERE)
        assert hashlib.sha256(module).hexdigest() == record['moduleSHA256']
        guard = 'assert(game.ServerScriptService.Server.World.EpicFinaleScenery.Source == '
        generated_guard, program = output.read_text().split('\n', 1)
        assert generated_guard.startswith(guard)
        guard += json.dumps(module.decode('utf-8')) + ', "wrong finale source for ' + stage + '")'
        if stage == 'candidate':
            program += '\ndo\n' + (PROFILES / 'check-journals.luau').read_text() + '\nend\n'
        output.write_text(guard + '\n' + program)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('directory', type=Path, help='outside the evidence tree')
    operation = parser.add_subparsers(dest='operation', required=True)
    prep = operation.add_parser('prepare')
    prep.add_argument('baseline_place', type=Path)
    prep.add_argument('candidate_place', type=Path)
    operation.add_parser('compare')
    args = parser.parse_args()
    directory = args.directory.resolve()
    build_path = HERE / 'build.json'
    directory.mkdir(parents=True, exist_ok=True)

    if args.operation == 'prepare':
        prepare(directory, (args.baseline_place, args.candidate_place), json.loads(build_path.read_text()))
    else:
        models = json.loads((HERE / 'studio-models.json').read_text())
        counts = {name: (models[story]['baselineParts'], models[story]['candidateParts'])
                  for story, name in MODELS.items()}
        compare = runpy.run_path(str(PROFILES / 'compare.py'))['compare']
        compare(directory / 'baseline.log', directory / 'candidate.log',
                counts=counts, build_path=build_path, output=directory)


if __name__ == '__main__':
    main()
