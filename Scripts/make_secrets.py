import json
import sys
from functools import reduce
from getopt import getopt
from pathlib import Path

from kamaaalpy.lists import find_index


def parse_opts(longopts: list[str] = []) -> dict[str, str]:
    unique_longopts = list(set(longopts))
    opts, _ = getopt(sys.argv[1:], ":", map(lambda x: f"{x}=", unique_longopts))
    opts_dict = {}

    for opt, arg in opts:
        if arg == "":
            continue

        opt = opt.replace("-", "", 2)
        given_opt_index = find_index(
            unique_longopts, lambda given_opt: given_opt == opt
        )
        if given_opt_index is None:
            continue

        opts_dict[unique_longopts[given_opt_index]] = arg

    return opts_dict


def main():
    output_keys = ["github_token", "forex_api_url", "stonks_kit_url"]
    opts = parse_opts(longopts=["output"] + output_keys)
    output = opts.get("output")
    if not output:
        raise Exception("No output provided")

    secrets = json.dumps(
        reduce(lambda acc, key: {**acc, key: opts.get(key)}, output_keys, {})
    )

    output_path = Path(output)
    output_path.write_text(secrets)
    print("successfully written secrets")


if __name__ == "__main__":
    main()
