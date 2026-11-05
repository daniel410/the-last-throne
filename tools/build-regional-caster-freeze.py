"""Compatibility entry point; all current builds produce one shared Place file."""
from pathlib import Path
import runpy
runpy.run_path(str(Path(__file__).with_name('build-game.py')), run_name='__main__')
