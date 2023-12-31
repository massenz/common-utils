#  Copyright (c) 2020-2023 AlertAvert.com.  All rights reserved.
#
#  Licensed under the Apache License, Version 2.0
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Author: Marco Massenzio (marco@alertavert.com)

import argparse
import re
import sys
from tempfile import mkstemp


MODIFIED_PATTERN = re.compile(r"(?P<opt>\w+)(?P<modifier>[-!?+*])?")


class StderrParser(argparse.ArgumentParser):
    def __init__(self, **kwargs):
        super().__init__(prog='', **kwargs)

    def exit(self, status=0, message=None):
        if message:
            print(message, file=sys.stderr)
        exit(status)

    def error(self, message):
        self.print_usage(file=sys.stderr)
        self.exit(status=1, message=f"ERROR: {message}")

    def print_help(self, file=None):
        super().print_usage(file=sys.stderr)
        self.exit(status=1)


def make_parser(*args):
    parser = StderrParser()
    for arg in args:
        kwargs = {}
        m = re.match(MODIFIED_PATTERN, arg)
        if m:
            mod = m.group('modifier')
            if mod == "!":
                kwargs["required"] = True
            kwargs['action'] = 'store_true' if mod == '-' else 'store'
            if mod == '+':
                prefix = ''
            elif mod == '?':
                prefix = ''
                kwargs['nargs'] = '?'
            elif mod == '*':
                prefix = ''
                kwargs['nargs'] = '*'
            else:
                prefix = '--'
            parser.add_argument(f"{prefix}{m.group('opt')}", **kwargs)
    return parser


def parse_opts(args, options):
    res = {}
    for arg in args:
        m = re.match(MODIFIED_PATTERN, arg)
        if m:
            var = m.group('opt')
            if hasattr(options, var):
                val = getattr(options, var)
                if val:
                    res[var] = val
    return res


def main(names, values):
    parser = make_parser(*names)
    config = parser.parse_args(values)
    options = parse_opts(names, config)
    tmpfile = mkstemp(text=True)[1]
    with open(tmpfile, 'w') as dest:
        for key, val in options.items():
            # Arrays in Shell scripts are declared differently
            # from how Python prints them out.
            if isinstance(val, list):
                dest.write(f"{key}=(")
                for item in val:
                    dest.write(f"{item} ")
                dest.write(")\n")
            else:
                dest.write(f"{key}={val}\n")
    print(tmpfile)


if __name__ == '__main__':
    try:
        pos = sys.argv.index('--')
        options_names = sys.argv[1:pos]
        options_values = sys.argv[pos+1:]
        main(options_names, options_values)
    except ValueError:
        print(f"Command line is malformed, missing '--' separator", file=sys.stderr)
        exit(1)
