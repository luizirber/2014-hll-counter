import os

import pandas as pd


def parse_replicate(filename):
    measures = {}
    with open(filename, 'r') as f:
        for line in f:
            key, value = line.strip().split(': ')

            value = value.strip('%')
            if ':' in value:
                walltime = value.split(':')
                assert len(walltime) <= 3
                hours = 0.
                minutes = 0.
                seconds = walltime[-1]
                if len(walltime) == 3:
                    hours = float(walltime[0])
                    minutes = float(walltime[1])
                elif len(walltime) == 2:
                    minutes = float(walltime[0])
                value = hours * 3600 + minutes * 60 + float(seconds)

            measures[key] = value
    return measures


def parse_exp(name, replicates, threads=None, dir="benchmarks"):
    all_data = {}
    if threads is None:
        threads = [1]

    for thread in threads:
        for rep in replicates:
            filename = "{dir}/{name}_r{rep:02d}".format(dir=dir, name=name, rep=rep)
            if not os.path.exists(filename):
                filename += "t{thr:02d}".format(thr=thread)
            all_data[rep] = parse_replicate(filename)


    return pd.DataFrame(all_data).T.convert_objects(convert_numeric=True)
