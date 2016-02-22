#!/usr/bin/env python
from __future__ import division
from hashlib import md5
from sys import argv

# preselected suitable (vibrant enough) colours
x256_colours = range(1,8) + range(9,15) + range(34,52) + range(76,87) + range(196,231)


def deterministic_x256(*args):
    '''Produces a weighted deterministic colour'''
    seed = unicode(args)

    m = md5()
    m.update(seed)
    digest = m.hexdigest()

    index = int(digest,16) % len(x256_colours)

    return x256_colours[index]


def wrap(string,colour):
    return '\033[38;5;%sm%s\033[0m' % (colour,string)


def colourise(string):
    colour = deterministic_x256(string)
    return wrap(string,colour)


print deterministic_x256(*argv[1:])
