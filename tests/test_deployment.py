"""Prove the gate rejects extras, missing files, and altered bytes."""
import importlib.util
from pathlib import Path
import shutil
import tempfile

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('deployment', ROOT/'scripts/check_deployment.py')
gate = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gate)
with tempfile.TemporaryDirectory() as directory:
    target = Path(directory)/'mod'
    shutil.copytree(gate.SOURCE, target)
    gate.validate(local=target)
    extra = target/'42/media/lua/shared/obsolete/Authority.lua'
    extra.parent.mkdir();extra.write_text('next({})')
    try:
        gate.validate(local=target)
        raise AssertionError('extra file passed')
    except ValueError:
        pass
    extra.unlink()
    info = target/'42/mod.info'
    original = info.read_bytes();info.unlink()
    try:
        gate.validate(local=target)
        raise AssertionError('missing file passed')
    except ValueError:
        pass
    info.write_bytes(original+b'\nobsolete=true\n')
    try:
        gate.validate(local=target)
        raise AssertionError('changed bytes passed')
    except ValueError:
        pass
print('PASS parity gate rejects extra, missing and changed production files')
