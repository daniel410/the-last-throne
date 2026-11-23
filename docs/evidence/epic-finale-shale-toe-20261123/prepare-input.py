"""Seed the GW-07 approach in a disposable Studio-only copy."""
import argparse
from pathlib import Path
from xml.etree import ElementTree as ET

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('artifact', type=Path)
parser.add_argument('fixture', type=Path)
args = parser.parse_args()
if args.artifact.resolve() == args.fixture.resolve():
    parser.error('Fixture must be a separate file')
tree = ET.parse(args.artifact)
inventory = [
    item for item in tree.iter('Item')
    if item.findtext('./Properties/string[@name="Name"]') == 'InventoryService'
]
assert len(inventory) == 1
source = inventory[0].find('./Properties/string[@name="Source"]')
needle = 'local profile, errorCode = state.store:open(player.UserId)'
assert source.text.count(needle) == 1
seed = Path(__file__).with_name('seed.luau').read_text()
source.text = source.text.replace(needle, needle + '\n' + seed)
with args.fixture.open('xb') as output:
    tree.write(output, encoding='utf-8', xml_declaration=True)
