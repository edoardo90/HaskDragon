# open docker in interactive mode, link (inside docker) user folder with docker-setup folder
# to keep cache of stack setup
docker run -v `pwd`:/project \
 -v `pwd`/automation/docker-setup:/home/haskell/.stack \
 -it  mgreenly/debian-stack

 # does not work, error: too many files open, maybe  because user is not root?

 ------------------

 # Dockerfile from debian-stack -> install haskell platform and build with system-ghc
 # it works, only problem is that stack build needs to update yaml file,
 # not only, sometimes the first update is not enough and it needs to do it again 1,2 times

# from project home

# build

docker run -v `pwd`:/project \
  -v `pwd`/automation/docker-setup:/root/.stack \
  -i  debian-stack-edo stack build --system-ghc

# see inside
docker run -v `pwd`:/project \
-v `pwd`/automation/docker-setup:/root/.stack \
-it  debian-stack-edo

# caveat: sometimes OS is not responsive, e.g. files are not listed in automation/docker-setup
# but they are present
