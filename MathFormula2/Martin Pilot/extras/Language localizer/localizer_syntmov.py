#! /usr/bin/env python

"""
Demo script for the syntcomp experiment

christophe@pallier.org
"""

import random, sys, csv, os
from expyriment import design, control, stimuli, io, misc
import expyriment

#%%

exp = design.Experiment(name="First Experiment")

# comment out the following line to get in real mode
# control.set_develop_mode(True)

control.initialize(exp)

#%%

control.start(exp)

fixcross = stimuli.FixCross()
fixcross.preload()


listname = os.path.join("localizer_lists", "loc_sub%03d.csv" % exp.subject)

sequences = [  i for i in csv.reader(open(listname)) ]

block = design.Block(name="block1")

for line in sequences:
    trial = design.Trial()
    stim = []
    for w in line:
        print(w)
        stim = stimuli.TextLine(w.decode('utf-8'), text_font='Inconsolata.ttf',
                                text_size=28)
        trial.add_stimulus(stim)
    
    block.add_trial(trial)
    
exp.add_block(block)

#%%

for block in exp.blocks:
    fixcross.present()
    exp.keyboard.wait_char('s')  # wait_for_MRI_synchro()
    exp.screen.clear()

    t0 = expyriment.misc.Clock()
    exp.clock.wait(1000)
    for trial in block.trials:
        exp.data.add(t0.time)
        for stim in trial.stimuli:
            exp.clock.reset_stopwatch()
            stim.preload()
            stim.present()
            exp.clock.wait(200)
            
        exp.screen.clear()
        exp.screen.update()

        exp.clock.wait(8000)
        io.Keyboard.process_control_keys()

control.end()
