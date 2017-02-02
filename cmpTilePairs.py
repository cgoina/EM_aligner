import gzip
import json
import sys

from optparse import OptionParser, OptionGroup


def readPairs(f):
    if f.endswith('.gz'):
        open_fn = gzip.open
    else:
        open_fn = open

    with open_fn(f) as pairsFile:
        pairs = json.load(pairsFile)

    return pairs


def writePairs(pairs, f=None):
    INDENT = 2
    if f is None:
        json.dump(pairs, sys.stdout, indent=INDENT)
    else:
        if f.endswith('.gz'):
            open_fn = gzip.open
        else:
            open_fn = open
        with open_fn(f, 'w') as newPairsFile:
            json.dump(pairs, newPairsFile, indent=INDENT)


def indexTilePairs(tilePairs):
    indexedGroups = {}

    for tp in tilePairs['neighborPairs']:
        indexedGroupKey = pairGroups(tp)
        indexedGroup = indexedGroups.get(indexedGroupKey, None)
        if indexedGroup is None:
            indexedGroup = set()
            indexedGroups.update({indexedGroupKey: indexedGroup})

        indexedGroup.add(tilePair(tp))

    return indexedGroups


def pairGroups(tp):
    return (tp['p']['groupId'], tp['q']['groupId'])


def tilePair(tp):
    return (tp['p']['id'], tp['q']['id'])


def main(args=None):
    usage = "usage: %prog [options] file1 file2 [output]"

    parser = OptionParser(usage=usage)
    parser.add_option('--include-pairs-from-new-groups', help='Output the pair from <file2> even if corresponding group is not present in <file1>',
                      action='store_true',
                      dest='includeAllGroups')

    (options, args) = parser.parse_args()

    if len(args) < 2:
        parser.print_help()
        return

    f1 = args[0]
    f2 = args[1]
    f3 = args[2] if len(args) > 2 else None

    f1IndexedPairs = indexTilePairs(readPairs(f1))
    f2Pairs = readPairs(f2)

    cond_for_common_groups_only = lambda tp: pairGroups(tp) in f1IndexedPairs and tilePair(tp) not in f1IndexedPairs[pairGroups(tp)]

    if options.includeAllGroups:
        include_cond = lambda tp: cond_for_common_groups_only(tp) or pairGroups(tp) not in f1IndexedPairs
    else:
        include_cond = cond_for_common_groups_only

    filteredPairs = [tp for tp in f2Pairs['neighborPairs'] if include_cond(tp)]
    f2Pairs['neighborPairs'] = filteredPairs

    writePairs(f2Pairs, f3)


if __name__ == '__main__':
    sys.exit(main())
