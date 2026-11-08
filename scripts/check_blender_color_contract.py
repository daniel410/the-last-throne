"""Reject authoring/review scene assignments without explicit Standard settings."""
import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
issues = []
checked = 0
for path in sorted((ROOT / 'tools').glob('*.py')):
    text = path.read_text()
    tree = ast.parse(text, filename=str(path))
    # The matched A/B renderer intentionally renders both transforms.
    if path.name in {'render-standard-color-review.py', 'update-blender-standard-color.py'}:
        continue
    for node in ast.walk(tree):
        if not isinstance(node, ast.Assign):
            continue
        value = ast.get_source_segment(text, node.value) or ''
        is_scene = (value.startswith('bpy.data.scenes.new(')
                    or value.startswith('bpy.data.scenes[')
                    or value == 'bpy.context.scene')
        if not is_scene:
            continue
        variable = ast.get_source_segment(text, node.targets[0])
        if variable not in {'scene', 's', 'gallery', 'review'}:
            continue
        checked += 1
        # Settings belong immediately after scene creation, before material/render/export work.
        window = '\n'.join(text.splitlines()[node.lineno:node.lineno + 7])
        expected = [f"{variable}.display_settings.display_device = 'sRGB'",
                    f"{variable}.view_settings.view_transform = 'Standard'",
                    f"{variable}.view_settings.look = 'None'",
                    f'{variable}.view_settings.exposure = 0',
                    f'{variable}.view_settings.gamma = 1',
                    f'{variable}.view_settings.use_curve_mapping = False']
        if not all(s in window for s in expected):
            issues.append(f'{path.relative_to(ROOT)}:{node.lineno}: missing Standard baseline')
print(f'Blender color contract: {checked} scene assignments checked')
for issue in issues:
    print(issue)
raise SystemExit(bool(issues))
