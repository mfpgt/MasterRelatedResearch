#! /usr/bin/env python
"""
Demo script for the syntcomp experiment
christophe@pallier.org
"""

import random, sys
import expyriment
from expyriment import design, control, stimuli, io, misc
import csv


#%% Different types of fixation 

FixCross = "Both" # or 'Lines' or 'Cross'


#%% Load the stimuli (assuming they are in 1 column csv file)


incsv =  csv.reader(open(sys.argv[1]))
incsv.next() # skip header
onset, cond, items = [], [], []
for lines in incsv:
     onset.append(int(lines[0]))
     cond.append(lines[1])
     items.append(lines[2])



exp = design.Experiment(name="First Experiment")
exp.data_variable_names = [ 'onset', 'targetonset', 'cond', 'stim', 'resp' ]

# comment the following line to get in real mode
# control.set_develop_mode(True)

control.initialize(exp)


#%%

fixcross = stimuli.FixCross()
fixcross.preload()

fixcrossblue = stimuli.FixCross(colour=(0,0,255))
fixcrossblue.preload()

block = design.Block(name="block1")

MaxWidth, MaxHeight = 0, 0


for i in items:
    stim = stimuli.TextLine(i.decode('utf-8'),
                            text_font=misc.find_font('Inconsolata.ttf'),
                            text_size=28)
    x, y = stim.surface_size
    if x > MaxWidth: 
        MaxWidth = x
    if y > MaxHeight: 
        MaxHeight = y

    trial = design.Trial()
    trial.add_stimulus(stim)
    block.add_trial(trial)
    
exp.add_block(block)


MaxWidth = MaxWidth + 12
MaxHeight = MaxHeight + 12

line1 = stimuli.Line((-MaxWidth/2, MaxHeight/2), (MaxWidth/2, MaxHeight/2), 1, (127,127,127))
line2 = stimuli.Line((-MaxWidth/2, -MaxHeight/2), (MaxWidth/2, -MaxHeight/2), 1, (127,127,127))


    
#%%

control.start(exp)

for block in exp.blocks:
     fixcrossblue.present()
     exp.keyboard.wait_char('s')  #     wait_for_MRI_synchro()
     exp.screen.clear()
     exp.screen.update()
     t0 = expyriment.misc.Clock()
     
     for n in range(len(block.trials)):
          trial = block.trials[n]
          while (t0.time < onset[n]):
               exp.clock.wait(1)

          stim = trial.stimuli[0]
        
          if FixCross == 'Cross':
               fixcross.present(clear=True, update=False)
          elif FixCross == 'Lines':
               line1.present(clear=True, update=False)
               line2.present(clear=False)
          elif FixCross == 'Both':
               line1.present(clear=True, update=False)
               line2.present(clear=False, update=True)
	       exp.clock.wait(300)
               line1.present(clear=True, update=False)
               line2.present(clear=False, update=False)
               fixcross.present(clear=False, update=True)
               t_fixcross=200

          exp.clock.reset_stopwatch()
          stim.preload()
          exp.clock.wait(t_fixcross)
          exp.screen.clear()
          exp.screen.update()	
          line1.present(clear=True, update=False)
          line2.present(clear=False, update=False)
          stim.present(clear=False)
          presenttime = t0.time

          exp.keyboard.clear()
          exp.clock.wait(200)       
          exp.screen.clear()
          exp.screen.update()
          exp.clock.wait(3000)
          keys = exp.keyboard.read_out_buffered_keys()
          if keys == []:
               key = 0
          else:
               key = keys[0]
          exp.data.add([presenttime, onset[n], cond[n], items[n], key])
        

### 

control.end()
