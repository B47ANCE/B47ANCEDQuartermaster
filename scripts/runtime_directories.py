"""Recreate engine-required empty directories that Git cannot retain.

Only known empty runtime roots are created. No files are removed or packaged.
"""
from pathlib import Path

DIRECTORIES = (
    'common/media/AnimSets', 'common/media/actiongroups',
    '42/media/AnimSets', '42/media/actiongroups',
)


def ensure(mod_root):
    mod_root = Path(mod_root).resolve()
    if not (mod_root / '42/mod.info').is_file():
        raise ValueError('Expected an existing authoritative mod root')
    for relative in DIRECTORIES:
        path = mod_root / relative
        if not path.resolve().is_relative_to(mod_root):
            raise ValueError('Runtime directory escapes mod root')
        path.mkdir(parents=True, exist_ok=True)


if __name__ == '__main__':
    ensure(Path(__file__).resolve().parents[1] / 'src/B47ANCEDQuartermaster')
