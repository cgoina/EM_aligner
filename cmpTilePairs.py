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
        json.dump(pairs, sys.stdout, indent=INDENT, sort_keys=True)
    else:
        if f.endswith('.gz'):
            open_fn = gzip.open
        else:
            open_fn = open
        with open_fn(f, 'w') as newPairsFile:
            json.dump(pairs, newPairsFile, indent=INDENT, sort_keys=True)


def indexTilePairs(tilePairs, indexedGroups={}):
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

    f1IndexedPairs = {}
    for f in f1.split(','):
        f1IndexedPairs = indexTilePairs(readPairs(f), f1IndexedPairs)

    cond_for_common_groups_only = lambda tp: pairGroups(tp) in f1IndexedPairs and tilePair(tp) not in f1IndexedPairs[pairGroups(tp)]

    if options.includeAllGroups:
        include_cond = lambda tp: cond_for_common_groups_only(tp) or pairGroups(tp) not in f1IndexedPairs
    else:
        include_cond = cond_for_common_groups_only


    newPairs = {
    }

    def pair_iterator(fileList):
        alreadyFoundPairs = set()
        for f in fileList.split(','):
            pairs = readPairs(f)
            renderParametersUrlTemplate = pairs['renderParametersUrlTemplate']
            previousRenderParametersUrlTemplate = newPairs.get('renderParametersUrlTemplate', None)

            if previousRenderParametersUrlTemplate is None:
                newPairs['renderParametersUrlTemplate'] = renderParametersUrlTemplate
            elif previousRenderParametersUrlTemplate != renderParametersUrlTemplate:
                yield Exception('RenderParametersTemplate must be the same for all new collections')

            for tp in pairs['neighborPairs']:
                if include_cond(tp):
                    if tilePair(tp) not in alreadyFoundPairs:
                        alreadyFoundPairs.add(tilePair(tp))
                        yield(tp)


    filteredPairs = [tp for tp in pair_iterator(f2)]

    newPairs['neighborPairs'] = filteredPairs

    writePairs(newPairs, f3)
    print('Written ', len(filteredPairs), ' new pairs')


if __name__ == '__main__':
    sys.exit(main())
