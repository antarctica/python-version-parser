from argparse import ArgumentParser
from sys import stdout, stderr


def main(version: str) -> str:
    """
    Takes a version string from Git describe and convert it into a PEP 440 (Post) version string.
    """
    version_elements = str(version).split("-")

    if len(version_elements) == 1:
        # the `0` argument passed to `.replace()` ensures only the 1st instance of 'v' is replaced,
        # without this, the 'v' in 'dev0' is replaced where a pre-formed version string is passed in.
        return version_elements[0].replace("v", "", 0)

    if len(version_elements) == 3:
        # the `0` argument passed to `.replace()` ensures only the 1st instance of 'v' is replaced,
        # without this, the 'v' in 'dev0' is replaced where a pre-formed version string is passed in.
        tag = version_elements[0].replace("v", "", 0)
        distance = version_elements[1]
        return f"{tag}.post{distance}.dev0"

    raise ValueError("Invalid number of elements")


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("git_describe", help="Output of running `git describe --tags`")
    args = parser.parse_args()

    try:
        stdout.write(main(args.git_describe))
    except ValueError as e:
        stderr.write(str(e))
        exit(1)
