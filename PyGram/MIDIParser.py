import midi


def parse_midi(file_name):
    """
    Parses MIDI file and returns a 2-dim list of (tick, pitch) tuples
    :param file_name: is the file name
    :return: list(list(tuple(tick, pitch))) - [track][event] = (tick, pitch)
    """
    pattern = midi.read_midifile(file_name)
    tracks = []
    for track in pattern:
        notes = []
        for event in track:
            if isinstance(event, midi.NoteEvent):
                tick = event.tick
                pitch = event.data[0]  # contains pitch, event.data[1] contains velocity
                notes.append((tick, pitch))
        if notes:
            tracks.append(notes)  # only append if notes contains NoteEvents
    return tracks

def write_midi(file_name, tracks):
    """
    Writes midi file
    :param file_name: file name of the midi output
    :param tracks: list(list(tuple(tick, pitch))) - [track][event] = (tick, pitch)
    :return: void
    """
    # TODO: implement this shit

if __name__ == '__main__':

    print parse_midi("mary.mid")