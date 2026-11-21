"""Compare the same Studio audit under the baseline and candidate Places."""
import argparse
import hashlib
import json
from pathlib import Path
import runpy

from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
audit = runpy.run_path(str(HERE.parent / 'epic-finale-readability-20261120' / 'compare.py'))
rows = audit['rows']
by_name = audit['by_name']
captures = audit['captures']
COUNTS = {
    'ConvoyRoadLoadingSill': (11, 15),
    'NorthernWindgapStrata': (7, 9),
    'FreightSledLanding': (9, 13),
    'DispatchCarrierCradle': (15, 27),
    'AlliedReturnParapet': (10, 13),
}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('baseline', type=Path)
    parser.add_argument('candidate', type=Path)
    args = parser.parse_args()
    before, after = (path.read_text() for path in (args.baseline, args.candidate))
    stable = ('ROUTE_COMPILE', 'ROUTE_NAV_ORIGINAL', 'ROUTE_NAV_EASY', 'CONTOUR', 'STATION', 'RESCUE_SOLID')
    for tag in stable:
        assert rows(before, tag) and rows(before, tag) == rows(after, tag), tag
    assert 'TLT_DISPATCH_ROLLERS_OK 6 2' in after
    models = []
    walks = []
    for log in (before, after):
        assert 'TLT_ROUTE_FINAL' in log and 'TLT_RESCUE_DONE' in log
        regional_models = by_name(log, 'ROUTE_MODEL')
        assert regional_models == by_name(log, 'ROUTE_DIRECT')
        models.append(regional_models)
        round_trips = by_name(log, 'ROUTE_WALK')
        assert len(round_trips) == 23
        assert all(walk['approach']['arrived'] and walk['retreat']['arrived'] for walk in round_trips.values())
        walks.append(round_trips)
    assert walks[0].keys() == walks[1].keys()
    assert models[0].keys() == models[1].keys() and COUNTS.keys() <= models[0].keys()
    for name, baseline in models[0].items():
        candidate = models[1][name]
        if name in COUNTS:
            assert (baseline['parts'], candidate['parts']) == COUNTS[name], name
            assert {key: value for key, value in baseline.items() if key != 'parts'} == {
                key: value for key, value in candidate.items() if key != 'parts'
            }, name
        else:
            assert baseline == candidate, name

    images = [captures(log) for log in (before, after)]
    frame_hashes = {
        name: [hashlib.sha256(panel[name].tobytes()).hexdigest() for panel in images]
        for name in images[0]
    }
    changed = [name for name, hashes in frame_hashes.items() if hashes[0] != hashes[1]]
    for name in COUNTS:
        story = models[1][name]['story']
        assert any(frame.startswith(story) for frame in changed), story
    build = json.loads((HERE / 'build.json').read_text())
    versions = (build['baseline']['version'], build['version'])
    board = Image.new('RGB', (836, 30 + 250 * len(frame_hashes)), '#171c20')
    draw = ImageDraw.Draw(board)
    for x, version, frames in zip((12, 424), versions, images, strict=True):
        draw.text((x, 8), version, fill='white')
        for index, (name, frame) in enumerate(frames.items()):
            y = 30 + 250 * index
            board.paste(frame, (x, y))
            draw.text((x, y + 229), name, fill='white')
    board.save(HERE / 'comparison.jpg', quality=92, optimize=True)
    results = {
        'compiled': rows(after, 'ROUTE_COMPILE')[0],
        'navigation': {tag: rows(after, tag)[0] for tag in stable if tag.startswith('ROUTE_NAV')},
        'matchingLandmarks': len(models[0]) - len(COUNTS),
        'models': [{name: stage[name] for name in COUNTS} for stage in models],
        'walks': walks,
        'frameSHA256': frame_hashes,
        'changedFrames': changed,
    }
    (HERE / 'studio-results.json').write_text(json.dumps(results, indent=2) + '\n')


if __name__ == '__main__':
    main()
