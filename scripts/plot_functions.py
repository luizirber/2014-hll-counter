#! /usr/bin/env python

import matplotlib.pyplot as plt
import seaborn as sns

from matplotlib.ticker import FormatStrFormatter


THREADS = [1, 2, 4, 8, 16]
REPLICATES = range(1, 11)


def prepare_plot_data(summary_io, summary_hll, value):
    constant_line = None
    for t in THREADS:
        df = summary_io[['replicate', value, 'threads']].copy()
        df['threads'] = t
        df['condition'] = 'Just I/O'
        if constant_line is None:
            constant_line = df
        else:
            constant_line = constant_line.append(df, ignore_index=True)

    plot_hll = summary_hll[['replicate', value, 'threads']].copy()
    plot_hll['condition'] = 'Parallel HLL'

    return plot_hll.append(constant_line, ignore_index=True)


def tsplot(plot_data, value, unit_traces=False):
    majorFormatter = FormatStrFormatter('%d')

    err_style = 'ci_band'
    if unit_traces:
        err_style = 'unit_traces'

    fig = plt.figure(figsize=(10, 8))
    ax = fig.gca()
    sns.tsplot(plot_data, ax=ax, ci=95,
               err_style=err_style,
               linestyle='-', marker='o',
               time="threads", unit='replicate', condition='condition',
               value=value)
    ax.lines[-1].set_linestyle("--")
    ax.lines[-1].set_marker("s")
    ax.set_xscale("log", basex=2)
    ax.xaxis.set_major_formatter(majorFormatter)

    ax.set_yscale("log", basey=2)
    ax.yaxis.set_major_formatter(majorFormatter)

    ax.legend(loc='best')

    return fig
