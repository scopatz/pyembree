#!/usr/bin/env python3
"""
A Python 3 standard library only utility to download embree releases
and copy them into the home directory for every plaform.
"""

import os
import sys
import json
import tarfile
import logging
import argparse
from io import BytesIO
from fnmatch import fnmatch
from platform import system
from typing import Optional
from zipfile import ZipFile

log = logging.getLogger('pyembree')
log.setLevel(logging.DEBUG)
log.addHandler(logging.StreamHandler(sys.stdout))
_cwd = os.path.abspath(os.path.expanduser(os.path.dirname(__file__)))


def fetch(url, sha256):
    """
    A simple standard-library only "fetch remote URL" function.

    Parameters
    ------------
    url : str
      Location of remote resource.
    sha256: str
      The SHA256 hash of the resource once retrieved,
      wil raise a `ValueError` if the hash doesn't match.

    Returns
    -------------
    data : bytes
      Retrieved data in memory with correct hash.
    """
    import hashlib
    from urllib.request import urlopen

    data = urlopen(url).read()
    hashed = hashlib.sha256(data).hexdigest()
    if hashed != sha256:
        log.error(f'`{hashed}` != `{sha256}`')
        raise ValueError('sha256 hash does not match!')

    return data


def extract(tar, member, path, chmod):
    """
    Extract a single member from a tarfile to a path.
    """
    if os.path.isdir(path):
        return

    if hasattr(tar, 'extractfile'):
        # a tarfile
        data = tar.extractfile(member=member)
        if not hasattr(data, 'read'):
            return
        data = data.read()
    else:
        # ZipFile -_-
        data = tar.read(member.filename)

    if len(data) == 0:
        return
    # make sure root path exists
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'wb') as f:
        f.write(data)
    if chmod is not None:
        # python os.chmod takes an octal value
        os.chmod(path, int(str(chmod), base=8))


def handle_fetch(url: str,
                 sha256: str,
                 target: str,
                 chmod: Optional[int] = None,
                 extract_skip: Optional[bool] = None,
                 extract_only: Optional[bool] = None,
                 strip_components: int = 0):
    """
    A macro to fetch a remote resource (usually an executable) and
    move it somewhere on the file system.

    Parameters
    ------------
    url : str
      A string with a remote resource.
    sha256 : str
      A hex string for the hash of the remote resource.
    target : str
      Target location on the local file system.
    chmod : None or int.
      Change permissions for extracted files.
    extract_skip : None or iterable
      Skip a certain member of the archive.
    extract_only : None or str
      Extract *only* a single file from the archive,
      overrides `extract_skip`.
    strip_components : int
      Strip off this many components from the file path
      in the archive, i.e. at `1`, `a/b/c` is extracted to `target/b/c`
    """
    if '..' in target:
        target = os.path.join(_cwd, target)
    target = os.path.abspath(os.path.expanduser(target))

    if os.path.exists(target):
        log.debug(f'`{target}` exists, skipping')
        return

    # get the raw bytes
    log.debug(f'fetching: `{url}`')
    raw = fetch(url=url, sha256=sha256)

    if len(raw) == 0:
        raise ValueError(f'{url} is empty!')

    # if we have an archive that tar supports
    if url.endswith(('.tar.gz', '.tar.xz', '.tar.bz2', 'zip')):

        if url.endswith('.zip'):
            tar = ZipFile(BytesIO(raw))
            members = tar.infolist()
        else:
            # mode needs to know what type of compression
            mode = f'r:{url.split(".")[-1]}'
            # get the archive
            tar = tarfile.open(fileobj=BytesIO(raw), mode=mode)
            members = tar.getmembers()

        if extract_skip is None:
            extract_skip = []

        for member in members:

            if hasattr(member, 'filename'):
                name = member.filename
            else:
                name = member.name

            # final name after stripping components
            name = '/'.join(name.split('/')[strip_components:])

            # if any of the skip patterns match continue
            if any(fnmatch(name, p) for p in extract_skip):
                log.debug(f'skipping: `{name}`')
                continue

            if extract_only is None:
                path = os.path.join(target, name)
                log.debug(f'extracting: `{path}`')
                extract(tar=tar, member=member, path=path, chmod=chmod)
            else:
                name = name.split('/')[-1]
                if name == extract_only:
                    path = os.path.join(target, name)
                    log.debug(f'extracting `{path}`')
                    extract(tar=tar, member=member, path=path, chmod=chmod)
                    return
    else:
        # a single file
        name = url.split('/')[-1].strip()
        path = target
        with open(path, 'wb') as f:
            f.write(raw)

        # apply chmod if requested
        if chmod is not None:
            # python os.chmod takes an octal value
            os.chmod(path, int(str(chmod), base=8))


def load_config(path: Optional[str] = None) -> list:
    """
    Load a config file for embree download locations.
    """
    if path is None or len(path) == 0:
        # use a default config file
        path = os.path.join(_cwd, 'embree.json')
    with open(path, 'r') as f:
        return json.load(f)


def is_current_platform(platform: str) -> bool:
    """
    Check to see if a string platform identifier matches the current platform.
    """
    # 'linux', 'darwin', 'windows'
    current = system().lower().strip()
    if current.startswith('dar'):
        return platform.startswith('dar') or platform.startswith('mac')
    elif current.startswith('win'):
        return platform.startswith('win')
    elif current.startswith('lin'):
        return platform.startswith('lin')
    else:
        raise ValueError(f'{current} ?= {platform}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Install system packages for trimesh.')
    parser.add_argument(
        '--install',
        type=str,
        action='append',
        help='Install package.')
    parser.add_argument(
        '--config',
        type=str,
        help='Specify a different config JSON path')

    args = parser.parse_args()

    config = load_config(path=args.config)

    # allow comma delimeters and de-duplicate
    if args.install is None:
        parser.print_help()
        exit()
    else:
        select = set(' '.join(args.install).replace(',', ' ').split())

    for option in config:
        if option['name'] in select and is_current_platform(
                option['platform']):
            subset = option.copy()
            subset.pop('name')
            subset.pop('platform')
            handle_fetch(**subset)
