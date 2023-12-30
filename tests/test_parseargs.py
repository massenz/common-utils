#  Copyright (c) 2020-2023 AlertAvert.com.  All rights reserved.
#
#  Licensed under the Apache License, Version 2.0
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Author: Marco Massenzio (marco@alertavert.com)
#
#  Licensed under the Apache License, Version 2.0
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Author: Marco Massenzio (marco@alertavert.com)
#
#  Licensed under the Apache License, Version 2.0
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Author: Marco Massenzio (marco@alertavert.com)

import argparse
import unittest

from parse_args import make_parser, parse_opts


class TestParser(unittest.TestCase):
    def test_args(self):
        p = make_parser("foo", "bar+")
        c = p.parse_args(["--foo", "3", "my_value"])
        self.assertEqual("3", c.foo)
        self.assertEqual("my_value", c.bar)

    def test_required(self):
        # --foo is optional; --needs is required, and `bar` is a positional required arg
        p = make_parser("foo", "needs!", "bar+")
        c = p.parse_args(["--foo", "3", "--needs", "4", "my_value"])
        self.assertEqual("4", c.needs)
        self.assertEqual("3", c.foo)
        self.assertEqual("my_value", c.bar)

    def test_required_missing_raise(self):
        # --foo is optional; --needs is required, and `bar` is a positional required arg
        p = make_parser("foo", "needs!", "bar+")
        c = p.parse_args(["--needs", "14", "my_value"])
        self.assertEqual("14", c.needs)
        with self.assertRaises(SystemExit, msg="Missing required --needs flag should raise"):
            p.parse_args(["--foo", "3", "my_value"])
        with self.assertRaises(SystemExit, msg="Missing required positional arg should raise"):
            p.parse_args(["--needs", "is_needed"])

    def test_many_positionals(self):
        p = make_parser("foo", "bar+", "baz+", "qufix?")
        c = p.parse_args(["--foo", "3", "bar_value", "baz_value"])
        self.assertEqual("3", c.foo)
        self.assertEqual("bar_value", c.bar)
        self.assertEqual("baz_value", c.baz)
        self.assertIsNone(c.qufix)

    def test_many_positionals_with_optional(self):
        p = make_parser("foo", "bar+", "baz+", "qufix?")
        c = p.parse_args(["--foo", "a-val", "bartender", "baz_v", "q-val"])
        self.assertEqual("a-val", c.foo)
        self.assertEqual("bartender", c.bar)
        self.assertEqual("baz_v", c.baz)
        self.assertIsNotNone(c.qufix)
        self.assertEqual("q-val", c.qufix)

    def test_many_positionals_missing_required(self):
        p = make_parser("foo", "bar+", "baz+")
        with self.assertRaises(SystemExit, msg="Missing required positional argument should raise"):
            p.parse_args(["--foo", "3", "bar_value"])

    def test_optional_positional(self):
        p = make_parser("out", "bar?")
        c = p.parse_args(["--out", "/tmp/bar", "bar_value"])
        self.assertEqual("bar_value", c.bar)
        self.assertEqual("/tmp/bar", c.out)

    def test_positional_array(self):
        p = make_parser("pos*")
        c = p.parse_args(["one", "two", "three"])
        self.assertIn("one", c.pos)
        self.assertIn("two", c.pos)
        self.assertIn("three", c.pos)


class TestWriter(unittest.TestCase):
    def test_parse_opts(self):
        parser = argparse.ArgumentParser()
        parser.add_argument("--test")
        opts = parser.parse_args(["--test", "value"])
        tmp = parse_opts(("test",), opts)
        self.assertEqual("value", tmp["test"])

    def test_positional(self):
        parser = argparse.ArgumentParser()
        parser.add_argument("--test")
        parser.add_argument("fname")
        opts = parser.parse_args(["--test", "value", "/tmp/foo"])
        tmp = parse_opts(("test", "fname+"), opts)
        self.assertEqual("value", tmp["test"])
        self.assertEqual("/tmp/foo", tmp["fname"])

    def test_optional_positional(self):
        parser = argparse.ArgumentParser()
        parser.add_argument("--test")
        parser.add_argument("fname")
        parser.add_argument("another", nargs='?')

        opts = parser.parse_args(["--test", "value", "/tmp/foo"])
        tmp = parse_opts(("test", "fname+", "another?"), opts)
        self.assertEqual("value", tmp["test"])
        self.assertEqual("/tmp/foo", tmp["fname"])

        opts = parser.parse_args(["--test", "value", "/tmp/foo", "another_value"])
        tmp = parse_opts(("test", "fname+", "another*"), opts)
        self.assertEqual("another_value", tmp["another"])

        with self.assertRaises(SystemExit):
            parser.parse_args(["--test", "value"])
