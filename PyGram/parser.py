import midi, ngram, os, glob

MAX_VELOCITY = 127
MAX_LENGTH = 100
N = 3


def main():

    pattern = midi.read_midifile("midis/elise.mid")
    print pattern
    """

    g = ngram.NGram(N)
    midis = parse_midis("midis")

    for midi in midis:
        for track in midi:
            print track
            g.add(track)

    generated = g.generate(g.beginnings[0], MAX_LENGTH)
    print(generated)
    output = [generated]
    write_midi("new.mid", output)

    """

def parse_midi(file_name):
    """
    Parses MIDI file and returns a 2-dim list of event tuples
    :rtype : object
    :param file_name: is the file name
    :return: list(list(event))) - [track][event] = event()
    """
    pattern = midi.read_midifile(file_name)
    tracks = []
    for track in pattern:
        events = []
        for event in track:
            if isinstance(event, midi.NoteEvent):
                tick = event.tick
                pitch = event.pitch
                velocity = False if event.velocity == 0 else True
                events.append((tick, velocity, pitch))
        if events:
            tracks.append(events)  # only append if events contains NoteEvents
    return tracks


def write_midi(file_name, tracks):
    """
    Writes midi file
    :param file_name: file name of the midi output
    :param tracks: list(list(tuple(tick, pitch))) - [track][event] = (tick, pitch)
    :return: void
    """
    new_pattern = midi.Pattern()
    for track in tracks:
        new_track = midi.Track()
        for event in track:
            velocity = 0 if event[1] == False else MAX_VELOCITY
            new_track.append(midi.NoteOnEvent(tick=event[0], velocity=velocity, pitch=event[2]))
        new_pattern.append(new_track)
        new_track.append(midi.EndOfTrackEvent(tick=1))
    midi.write_midifile(file_name, new_pattern)


def parse_midis(directory):
    midis = []
    for i, file_name in enumerate(glob.glob(os.path.join(directory, '*.mid'))):
        print "Parsing file " + str(i + 1) + ": \"" + str(file_name) + "\""
        midis.append(parse_midi(file_name))
    return midis

if __name__ == '__main__':
    main()