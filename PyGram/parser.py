import midi
import ngram

def main():
    parsed = parse_midi("mary.mid")
    write_midi("new.mid", parsed)

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
                velocity = event.velocity
                events.append((tick, pitch, velocity))
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
            new_track.append(midi.NoteOnEvent(tick=event[0], velocity=event[1], pitch=event[2]))
        new_pattern.append(new_track)
        new_track.append(midi.EndOfTrackEvent(tick=1))
    midi.write_midifile(file_name, new_pattern)


if __name__ == '__main__':
    main()