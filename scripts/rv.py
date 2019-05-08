# download reddit videos

import requests
import os

# change this url to the post's url
post_url = "https://www.reddit.com/r/holdmycatnip/comments/7vyada/hmc_so_i_can_drink_this_air_real_quick/"

# use UA headers to prevent 429 error
headers = {
    'User-Agent': 'My User Agent 1.0',
    'From': 'testyouremail@domain.com'
}
url = post_url + ".json"
data = requests.get(url, headers=headers).json()
media_data = data[0]["data"]["children"][0]["data"]["media"]

video_url = media_data["reddit_video"]["fallback_url"]
audio_url = video_url.split("DASH_")[0] + "audio"

print(video_url, audio_url)

# curl both audio and video separately
os.system("curl -o video.mp4 {}".format(video_url))
os.system("curl -o audio.wav {}".format(audio_url))

# mux them
os.system("ffmpeg -i video.mp4 -i audio.wav -c:v copy -c:a aac -strict experimental output.mp4")

os.system("rm ./video.mp4")
os.system("rm ./audio.wav")
