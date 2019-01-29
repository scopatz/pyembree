from rever.activity import dockeractivity

$PROJECT = $GITHUB_REPO = 'pyembree'
$GITHUB_ORG = 'scopatz'
$WEBSITE_URL = 'https://github.com/scopatz/pyembree'

with! dockeractivity(name='pyembree-examples', lang='sh'):
    python examples/attenuate.py --no-plots

$ACTIVITIES = ['pyembree-examples', 'version_bump', 'changelog',
               'tag', 'push_tag', 'conda_forge','ghrelease'
               ]

$VERSION_BUMP_PATTERNS = [
    ('recipes/pyembree/meta.yaml', 'version:.*', 'version: $VERSION'),
    ('pyembree/__init__.py', r'__version__\s*=.*', "__version__ = '$VERSION'"),
    ('setup.py', r'version\s*=.*', "version='$VERSION',"),
    ]
$CHANGELOG_FILENAME = 'CHANGELOG.rst'
$CHANGELOG_TEMPLATE = 'TEMPLATE.rst'

$DOCKER_APT_DEPS = ['gcc']
$DOCKER_CONDA_DEPS = ['numpy', 'embree', 'gcc', 'setuptools', 'cython']
$DOCKER_INSTALL_COMMAND = ('git clean -fdx && '
                           './setup.py install')
$DOCKER_GIT_NAME = 'Anthony Scopatz'
$DOCKER_GIT_EMAIL = 'scopatz@gmail.com'
