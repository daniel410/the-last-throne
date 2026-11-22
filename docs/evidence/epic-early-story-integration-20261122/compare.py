"""Check the two landmark audits and the shared campaign regression."""
import argparse
import json
from pathlib import Path
import re

from PIL import Image, ImageDraw

EVIDENCE = Path(__file__).resolve().parent
AUDITS = {
    'epic-opening-landmark-profiles-20261122': (
        'OPENING',
        {'CreekCargoSill', 'WheeltrackForkRootCut', 'WindbreakAscentBank',
         'FreightCarrierWheelSeat', 'ScoutApproachStoneFooting'},
    ),
    'epic-third-chapter-integrated-20261122': (
        'THIRD_CHAPTER',
        {'ReliefRosterStand', 'RefugeReturnRootMarker', 'RavineWalkRailAnchor',
         'BelowRailCoolantInspectionHead', 'KeeperServiceDoorJamb'},
    ),
}


def records(log, prefix):
    return [json.loads(value) for value in re.findall(rf'^{prefix} (.+)$', log, re.M)]


def frames(log):
    assert 'TLT_APPROACH_FRAMES_DONE' in log
    rows = {}
    for name, y, data in re.findall(r'^TLT_APPROACH_FRAME (\S+) (\d+) ([a-f0-9]+)$', log, re.M):
        frame = rows.setdefault(name, {})
        assert int(y) not in frame, (name, y)
        frame[int(y)] = bytes.fromhex(data)

    images = {}
    for name, frame in rows.items():
        assert set(frame) == set(range(225)), name
        assert all(len(row) == 1200 for row in frame.values()), name
        image = Image.frombytes('RGB', (400, 225), b''.join(frame[y] for y in range(225)))
        assert any(low < high for low, high in image.getextrema()), (name, 'blank capture')
        images[name] = image
    return images


def audit(directory, name, prefix, targets):
    logs = {label: (directory / f'{label}-{name}.log').read_text()
            for label in ('base', 'candidate')}
    camera_plan, = records(logs['base'], prefix + '_CAMERA_PLAN')
    assert records(logs['candidate'], prefix + '_CAMERA_PLAN') == [camera_plan]
    images = {label: frames(log) for label, log in logs.items()}
    shots = [shot['id'] for shot in camera_plan]
    assert len(shots) == 10
    assert all(list(group) == shots for group in images.values())
    models = {}
    walks = {}
    for label, log in logs.items():
        rows = records(log, prefix + '_LANDMARK')
        models[label] = {row['model']: row for row in rows}
        assert len(models[label]) == len(rows)
        walks[label] = records(log, 'THIRD_CHAPTER_WALK')

    old_models, new_models = models['base'], models['candidate']
    assert old_models.keys() == new_models.keys() and targets <= old_models.keys()
    unchanged = set(old_models) - set().union(*(names for _, names in AUDITS.values()))
    assert all(old_models[name] == new_models[name] for name in unchanged)
    chapters = {new_models[name]['chapter'] for name in targets}
    for rows in walks.values():
        assert len(rows) == 5 and {row['chapter'] for row in rows} == chapters, rows
        assert all(row.get('inbound', 2.5) < 2.5 and row.get('outbound', 2.5) < 2.5 for row in rows), rows
    for name in targets:
        old, new = old_models[name], new_models[name]
        for field in ('chapter', 'goal', 'step', 'ground', 'anchor', 'maxFloorError', 'bounds', 'clearance'):
            assert old.get(field) == new.get(field), (name, field, old.get(field), new.get(field))
        assert new['parts'] > old['parts'], name

    report = {
        'models': [{'baseline': old_models[name], 'candidate': new_models[name]} for name in sorted(targets)],
        'unchangedModels': sorted(unchanged),
        'walks': walks,
        'framePairs': shots,
    }
    return report, [(name, images['base'][name], images['candidate'][name]) for name in shots]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('logs', type=Path)
    args = parser.parse_args()
    reports = {}
    pairs = []
    for name, (prefix, targets) in AUDITS.items():
        reports[name], captures = audit(args.logs, name, prefix, targets)
        pairs.extend(captures)

    campaign = {}
    for label in ('base', 'candidate'):
        report, = records((args.logs / f'{label}-campaign.log').read_text(), 'CAMPAIGN_EXPANSION_NATIVE')
        assert report['blockers'] == [] and report['checks'] > 0
        campaign[label] = report
    for field in ('incidents', 'steps', 'samples', 'checks'):
        assert campaign['base'][field] == campaign['candidate'][field], field
    added_parts = sum(pair['candidate']['parts'] - pair['baseline']['parts']
                      for report in reports.values() for pair in report['models'])
    assert campaign['candidate']['parts'] - campaign['base']['parts'] == added_parts

    version = json.loads((EVIDENCE / 'build.json').read_text())['version']
    for start, chapter in ((0, 'opening'), (10, 'third-chapter')):
        board = Image.new('RGB', (824, 2528), '#171c20')
        labels = ImageDraw.Draw(board)
        labels.text((6, 6), '0.115.46', fill='white')
        labels.text((418, 6), version, fill='white')
        for row, (name, left, right) in enumerate(pairs[start:start + 10]):
            y = 28 + 250 * row
            board.paste(left, (6, y))
            board.paste(right, (418, y))
            labels.text((6, y + 229), name, fill='white')
        board.save(EVIDENCE / f'{chapter}.jpg', quality=92, optimize=True)
    (EVIDENCE / 'studio-results.json').write_text(
        json.dumps({'audits': reports, 'campaign': campaign, 'addedParts': added_parts}, indent=2) + '\n'
    )


if __name__ == '__main__':
    main()
