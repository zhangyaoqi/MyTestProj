set -e
export PATH="`pwd`/tools":$PATH
ARG=$1
. repo-bin.sh

CONTRIB_ROOT=contrib
function do_repo_sync()
{
    REPO_NAME=$1
    REPO_URL=$2
    REPO_HASH=$3
    if [ -z $1 -o -z $2 -o -z $3 ]; then
        echo "invalid call repo_sync() '$1' '$2' '$3'"
    else
    git fetch --all --tags
        git checkout $REPO_HASH -B sandbox
    fi
}

function do_check_bin_sync()
{
    REPO_NAME=$1
    REPO_EXPECT_HASH=$2
    if [ ! -d $REPO_NAME ] || [ ! -f $REPO_NAME/version.txt ] ; then
    if [ ! -f .warehouse/$REPO_EXPECT_HASH ] ; then
        mkdir -p .warehouse
        curl -o .warehouse/$REPO_EXPECT_HASH.tar.bz2 http://172.16.0.97:7070/ibili-ios/bin/ffmpeg/ffmpeg-fat-$REPO_EXPECT_HASH.tar.bz2
    fi
    mkdir -p .warehouse/$REPO_EXPECT_HASH
    tar xvf .warehouse/$REPO_EXPECT_HASH.tar.bz2 -C .warehouse/$REPO_EXPECT_HASH
    ln -s .warehouse/$REPO_EXPECT_HASH/build/universal $REPO_NAME
    fi
    cd $REPO_NAME
    HASH=`cat version.txt`
    if [  $HASH = $REPO_EXPECT_HASH ]; then
    echo "$REPO_NAME is latest"
    else
    if [ "$ARG" = "XCODE" ]; then
        echo "please run build2.sh"
        exit 1
    else
        cd ../
        rm -rf $REPO_NAME
        do_check_bin_sync $1 $2 
    fi
    fi
    cd -
}

rm -f "${CONTRIB_ROOT}/lastHash"
rm -f "${CONTRIB_ROOT}/changeLogs"
rm -f "${CONTRIB_ROOT}/lastHash.txt"
rm -f "${CONTRIB_ROOT}/changeLogs.html"

python build.py $ARG
mkdir -p "${CONTRIB_ROOT}"
cd "${CONTRIB_ROOT}"
do_check_bin_sync ffmpeg-bin2 $REPO_FFMPEG_BIN_HASH

mkdir -p ijkplayer/ios/build
cd ijkplayer/ios/build
rm -rf universal
ln -s ../../../ffmpeg-bin2 universal

echo "done"
