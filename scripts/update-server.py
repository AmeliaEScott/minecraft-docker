import os
import sys
import hashlib
import requests
import shutil

SERVER_JAR = "/server/server.jar"

if not os.path.exists("/server/runserver.sh"):
    print("No runserver.sh found, copying over the default one.")
    shutil.copyfile("/scripts/default_runserver.sh", "/server/runserver.sh")
    os.chmod("/server/runserver.sh", 0o777)

version = os.getenv("MC_VERSION")
if version is None:
    print("No MC_VERSION specified. Skipping server update.")
    sys.exit(0)

response = requests.get("https://launchermeta.mojang.com/mc/game/version_manifest.json")

if response.status_code != 200:
    print("Invalid response when requesting version manifest. Skipping automatic version update.")
    sys.exit(-1)

version_list = response.json()

if version.lower() == "latest_release":
    version = version_list['latest']['release']
elif version.lower() == "latest_snapshot":
    version = version_list['latest']['snapshot']

print("Searching for version '{}'...".format(version))

try:
    version_metadata = next(filter(lambda d: d['id'] == version, version_list['versions']))
except StopIteration:
    print("No version {} found. Skipping automatic version update.".format(version))
    sys.exit(-4)
print("Version metadata: {}".format(version_metadata))

r = requests.get(version_metadata['url'])

if r.status_code != 200:
    print("Invalid response when requesting version {} metadata. Skipping automatic version update.".format(version))
    sys.exit(-2)

download_metadata = r.json()['downloads']
server_sha = download_metadata['server']['sha1']
server_url = download_metadata['server']['url']

if os.path.exists(SERVER_JAR):
    hash = hashlib.sha1()
    with open(SERVER_JAR, 'rb') as f:
        while True:
            data = f.read(65536)
            if not data:
                break
            hash.update(data)
    hash = hash.hexdigest().lower()
else:
    hash = None

if hash == server_sha:
    print("Server already up to date. Done!")

else:
    print("Downloading server from {}".format(server_url))
    r = requests.get(server_url)
    if r.status_code != 200:
        print("Invalid response when downloading server from {}. Skipping update.".format(server_url))
        sys.exit(-3)
    with open(SERVER_JAR, "wb") as f:
        f.write(r.content)
    os.chmod(SERVER_JAR, 0o764)  # TODO: Is this actually necessary?
    print("Done updating server!")


