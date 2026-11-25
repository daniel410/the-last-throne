"""Compare the fourth-chapter fixture profiles over matching Studio runs."""
import argparse
import json
from pathlib import Path
import sys

from PIL import Image, ImageDraw

evidence = Path(__file__).resolve().parent
sys.path.insert(0, str(evidence.parent / 'epic-third-chapter-rescue-routes-20261124'))
from compare import frames, records

targets = {
    'ReturnRopeGuide': 11,
    'RefugeBoardRest': 10,
    'RelayPlateCradle': 8,
    'PressureLineSaddle': 21,
    'GateSurveyLedge': 9,
}


def compare(log_dir):
    versions = ('0.115.108', '0.115.109')
    audits = [(log_dir / f'{version}-audit.log').read_text() for version in versions]
    reports = []
    for version, audit in zip(versions, audits):
        models = records(audit, 'INFRASTRUCTURE_LANDMARK')
        models_by_name = {model['model']: model for model in models}
        assert len(models_by_name) == len(models)
        assert set(targets) <= models_by_name.keys()
        clear = 'FOURTH_CHAPTER_LANDMARK_OVERLAP_CLEAR '
        assert {line.removeprefix(clear) for line in audit.splitlines() if line.startswith(clear)} == set(targets)
        walks = records(audit, 'SECOND_CHAPTER_WALK')
        assert len(walks) == 5
        assert {walk['chapter'] for walk in walks} == {models_by_name[name]['chapter'] for name in targets}
        assert all(walk['inbound'] < 2.5 and walk['outbound'] < 2.5 for walk in walks)
        regression, = records((log_dir / f'{version}-regression.log').read_text(), 'CAMPAIGN_EXPANSION_NATIVE')
        assert regression['blockers'] == [] and regression['checks'] > 0
        camera, = records(audit, 'INFRASTRUCTURE_CAMERA_PLAN')
        reports.append((models_by_name, walks, regression, camera, frames(audit)))

    before, after = reports
    assert before[0].keys() == after[0].keys()
    unchanged = sorted(before[0].keys() - targets.keys())
    assert all(before[0][name] == after[0][name] for name in unchanged)
    for name, count in targets.items():
        old, new = before[0][name], after[0][name]
        for field in ('chapter', 'goal', 'step', 'ground', 'anchor', 'version'):
            assert old[field] == new[field], (name, field)
        assert new['parts'] == count and new['routeClearance'] >= 3
        assert new['maxFloorError'] < .2
    for field in ('checks', 'incidents', 'steps', 'samples'):
        assert before[2][field] == after[2][field], field
    assert after[2]['parts'] - before[2]['parts'] == sum(
        after[0][name]['parts'] - before[0][name]['parts'] for name in targets
    )

    assert before[3] == after[3]
    shots = [shot['id'] for shot in before[3]]
    assert len(shots) == 10 and list(before[4]) == list(after[4]) == shots
    board = Image.new('RGB', (824, 28 + 250 * len(shots)), '#171c20')
    labels = ImageDraw.Draw(board)
    for x, version, report in zip((6, 418), versions, reports):
        labels.text((x, 6), version, fill='white')
        for index, shot in enumerate(shots):
            y = 28 + 250 * index
            board.paste(report[4][shot], (x, y))
            labels.text((x, y + 229), shot, fill='white')
    board.save(evidence / 'comparison.jpg', quality=92, optimize=True)
    results = {'unchangedModels': unchanged, 'framePairs': shots, 'versions': {}}
    for version, (models, walks, regression, _, _) in zip(versions, reports):
        results['versions'][version] = {
            'models': [models[name] for name in targets],
            'walks': walks,
            'overlapClear': list(targets),
            'expansionRegression': regression,
        }
    (evidence / 'studio-results.json').write_text(json.dumps(results, indent=2) + '\n')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('log_dir', type=Path)
    compare(parser.parse_args().log_dir)
