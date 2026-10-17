"""Offline cold-checkout directory preparation without making a package."""
import importlib.util
from pathlib import Path
import tempfile


def run():
    helper = Path(__file__).resolve().parents[1] / 'scripts/runtime_directories.py'
    spec = importlib.util.spec_from_file_location('runtime_directories', helper)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    with tempfile.TemporaryDirectory(prefix='b47-cold-checkout-') as temp:
        root = Path(temp) / 'mod'
        (root / '42').mkdir(parents=True)
        info = root / '42/mod.info'
        info.write_text('id=Fixture\n', encoding='utf-8')
        module.ensure(root)
        assert all((root / relative).is_dir() for relative in module.DIRECTORIES)
        protected = root / module.DIRECTORIES[0] / 'preserve.txt'
        protected.write_bytes(b'existing owned file')
        module.ensure(root)
        assert info.read_text(encoding='utf-8') == 'id=Fixture\n'
        assert protected.read_bytes() == b'existing owned file'
        try:
            module.ensure(Path(temp) / 'missing')
        except ValueError:
            pass
        else:
            raise AssertionError('Ambiguous source directory accepted')
    print('PASS OFFLINE runtime directories: cold checkout, idempotence, preserved files and invalid-root rejection')


if __name__ == '__main__':
    run()
