"""A command-line utility that generates the MIPS assembly code that plays the given MIDI file."""
import math
import argparse
from pathlib import Path

import pretty_midi

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate MIPS assembly code for playing a given MIDI file.')
    parser.add_argument('output', type=Path, help='The path to the output file.')
    parser.add_argument('midi_pattern', type=str, help='A glob pattern for the midi files to load.')
    args = parser.parse_args()

    args.output.parent.mkdir(exist_ok=True, parents=True)
    with open(args.output.with_suffix('.asm'), 'w+', encoding='utf-8') as fp:
        midi_files = Path.cwd().glob(args.midi_pattern)
        for midi_filepath in midi_files:
            # load midi and process it
            midi_data = pretty_midi.PrettyMIDI(str(midi_filepath.resolve()))
            code = f'play_midi_{midi_filepath.stem}:\n'
            notes_by_start_time = {}
            for instrument in midi_data.instruments:
                for note in instrument.notes:
                    if note.start not in notes_by_start_time:
                        notes_by_start_time[note.start] = []
                    notes_by_start_time[note.start].append((instrument, note))
            
            start_times = sorted(notes_by_start_time.keys())
            for i, start_time in enumerate(start_times):
                notes = notes_by_start_time[start_time]
                for j, (instrument, note) in enumerate(notes):
                    if j == len(notes) - 1:
                        syscall_num = 33 # make it blocking
                    else:
                        syscall_num = 31 # make it non-blocking
                    code += f'\tli $v0, {syscall_num}\n' # load syscall number
                    code += f'\tli $a0, {note.pitch}\n'
                    if i < len(start_times) - 1:
                        duration = start_times[i + 1] - start_time
                    else:
                        duration = note.get_duration()
                    # convert duration to number of milliseconds
                    duration *= 1000
                    duration = int(math.ceil(duration))
                    # write assembly code to play note
                    code += f'\tli $a1, {duration}\n'
                    code += f'\tli $a2, {instrument.program}\n'
                    code += f'\tli $a3, {note.velocity}\n'
                    code += f'\tsyscall\n'

                    
            # return
            code += f'\tjr $ra\n'
            fp.write(code)
    