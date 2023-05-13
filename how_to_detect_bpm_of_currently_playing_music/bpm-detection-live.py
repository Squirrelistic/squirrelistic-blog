import pyaudiowpatch as pyaudio
import numpy as np
import librosa

RECORD_SECONDS = 10

with pyaudio.PyAudio() as p:
    wasapi_info = p.get_host_api_info_by_type(pyaudio.paWASAPI)
    default_speakers = p.get_device_info_by_index(wasapi_info["defaultOutputDevice"])

    if not default_speakers["isLoopbackDevice"]:
        for loopback in p.get_loopback_device_info_generator():
            if default_speakers["name"] in loopback["name"]:
                default_speakers = loopback
                break
        else:
            print("Default loopback output device not found 😭")
            exit()

    sampleRate = int(default_speakers['defaultSampleRate'])
    chunk = sampleRate * RECORD_SECONDS

    stream = p.open(format = pyaudio.paFloat32,
                    channels = 1,
                    rate = sampleRate,
                    input = True,
                    input_device_index = default_speakers['index'],
                    frames_per_buffer = chunk)

    print(f"Recording {RECORD_SECONDS} seconds from {default_speakers['index']} {default_speakers['name']} 🎤")
    sound = stream.read(chunk)
    print("Recording complete 🎹")

    stream.stop_stream()
    stream.close()

    print("Analysing BPM 🎵")
    np_sound = np.frombuffer(sound, dtype=np.float32)
    tempo, beat_frames = librosa.beat.beat_track(y=np_sound, sr=sampleRate)
    if (tempo < 100):
        print(f'Estimated tempo: {round(tempo)} or {round(tempo * 2)} bpm')
    else:
        print(f'Estimated tempo: {round(tempo)} bpm')
