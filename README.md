# Python Version Parser

Script to generate a PEP 440 (Post) version from git-describe output.

## Overview

This script facilitates a form of automatic versioning where the current version is read from its source code
repository, rather than being defined within the project itself. This approach ensures package versions keep in step
with the source repository and are always unique.

Versions are based on the output from `git-describe`, itself dependent on Git tags, and formed into a 'PEP 440 (Post)'
complaint version string (e.g. `0.3.0` or `0.3.0.post5.dev0`). Versions are expected to be used once.

## Usage

```
python python_version_helper.py $(git describe --tags)
```

Where: `$(git describe --tags)` is the output of `git describe --tags`.

The generated version string will be written to *stdout*. If any errors occur they will be written to *stderr*.

Where a commit is a tagged version (e.g. a final release) the version is the same as the tag minus its prefix:

Example input: 'v0.3.0'
Example output: '0.3.0'

Otherwise, the commit will be treated as a post development release for/from the most recent tag plus the distance to
the head commit (e.g. head might be 3 commits ahead of the most recent tag).

Example input:  'v0.3.0-5-g345C2B1'
Example output: '0.3.0.post5.dev0'

The components in this version string are:

* `0.3.0`: the most recent tag/version
* `.post5`: the number of commits since the tag (e.g. 5 commits)
* `.dev0`: signifies a development release (the 0 is a dummy/fixed version prefix)

## Development

```shell
$ git clone https://gitlab.data.bas.ac.uk/MAGIC/infrastructure/python-version-parser.git
$ cd python-version-parser
```

### Development environment

A Python development environment is available for developing this project locally. It is defined using Docker Compose
in `./docker-compose.yml`.

To create a local development environment:

1. pull docker images: `docker-compose pull` [1]
3. run the the development environment `docker-compose run --entrypoint=ash app`

To destroy a local development environment, exit the container and run `docker-compose down`.

[1] This requires access to the BAS Docker Registry (part of [gitlab.data.bas.ac.uk](https://gitlab.data.bas.ac.uk)).

You will need to sign-in using your GitLab credentials (your password is set through your GitLab profile) the first
time this is used:

```shell
$ docker login docker-registry.data.bas.ac.uk
```

### Python version

When upgrading to a new version of Python, ensure the following are also checked and updated where needed:

* `Dockerfile`:
    * base stage image (e.g. `FROM python:3.X-alpine as base` to `FROM python:3.Y-alpine as base`)
* `pyproject.toml`
    * `[tool.poetry.dependencies]`
        * `python` (e.g. `python = "^3.X"` to `python = "^3.Y"`)
    * `[tool.black]`
        * `target-version` (e.g. `target-version = ['py3X']` to `target-version = ['py3Y']`)

### Dependencies

Python dependencies for this project are managed with [Poetry](https://python-poetry.org) in `pyproject.toml`.

Non-code files, such as static files, can also be included in the [Python package](#python-package) using the
`include` key in `pyproject.toml`.

#### Adding new dependencies

To add a new (development) dependency:

```shell
$ docker-compose run --entrypoint=ash app
$ apk update
$ apk add build-base
$ poetry add [dependency] (--dev)
```

Then rebuild the [Development container](#development-container) and push to GitLab (GitLab will rebuild other images
automatically as needed):

```shell
$ docker-compose build app
$ docker-compose push app
```

#### Updating dependencies

```shell
$ docker-compose run --entrypoint=ash app
$ apk update
$ apk add build-base
$ poetry update
```

Then rebuild the [Development container](#development-container) and push to GitLab (GitLab will rebuild other images
automatically as needed):

```shell
$ docker-compose build app
$ docker-compose push app
```

### Static security scanning

To ensure the security of this API, source code is checked against [Bandit](https://github.com/PyCQA/bandit) for issues
such as not sanitising user inputs or using weak cryptography. Bandit is configured in `.bandit`.

**Warning:** Bandit is a static analysis tool and can't check for issues that are only be detectable when running the
application. As with all security tools, Bandit is an aid for spotting common mistakes, not a guarantee of secure code.

To run checks manually:

```shell
$ docker-compose run app bandit -r .
```

Checks are ran automatically in [Continuous Integration](#continuous-integration).

### Code Style

PEP-8 style and formatting guidelines must be used for this project, with the exception of the 80 character line limit.

[Black](https://github.com/psf/black) is used to ensure compliance, configured in `pyproject.toml`.

Black can be [integrated](https://black.readthedocs.io/en/stable/editor_integration.html#pycharm-intellij-idea) with a
range of editors, such as PyCharm, to perform formatting automatically.

To apply formatting manually:

```shell
$ docker-compose run app black python_version_parser/
```

To check compliance manually:

```shell
$ docker-compose run app black --check python_version_parser/
```

Checks are ran automatically in [Continuous Integration](#continuous-integration).

### Testing

Automated tests are not yet used in this project.

#### Continuous Integration

All commits will trigger a Continuous Integration process using GitLab's CI/CD platform, configured in `.gitlab-ci.yml`.

## Deployment

### Docker image

A container image, defined by `./Dockerfile`, is built and tagged manually as `:latest` and after each release. It's
hosted in the private BAS Docker Registry (part of [gitlab.data.bas.ac.uk](https://gitlab.data.bas.ac.uk)):

[docker-registry.data.bas.ac.uk/MAGIC/infrastructure/python-version-parser](https://docker-registry.data.bas.ac.uk/magic/infrastructure/python-version-parser/container_registry)

If you don't have access to the BAS Docker Register, you can build this image locally using `docker-compose build app`.

## Release procedure

For all releases:

1. create a release branch
2. close release in `CHANGELOG.md`
3. push changes, merge the release branch into `master` and tag with version

## Feedback

The maintainer of this project is the BAS Mapping and Geographic Information Centre (MAGIC), they can be contacted at:
[servicedesk@bas.ac.uk](mailto:servicedesk@bas.ac.uk).

## Issue tracking

This project uses issue tracking, see the
[Issue tracker](https://gitlab.data.bas.ac.uk/MAGIC/infrastructure/python-version-parser/issues) for more information.

**Note:** Read & write access to this issue tracker is restricted. Contact the project maintainer to request access.

## License

© UK Research and Innovation (UKRI), 2020, British Antarctic Survey.

You may use and re-use this software and associated documentation files free of charge in any format or medium, under
the terms of the Open Government Licence v3.0.

You may obtain a copy of the Open Government Licence at http://www.nationalarchives.gov.uk/doc/open-government-licence/
