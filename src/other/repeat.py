# upsampling by 4
with open("music.pcm", "rb") as infile:
    with open("music4.pcm", "wb") as outfile:
        while True:
            dword = infile.read(4)
            if dword == b'':
                break
            for i in range(4):
                outfile.write(dword)