#! /bin/bash

CONTRACT_NAME="eosio.token"
unamestr=`uname`

if [[ "${unamestr}" == 'Darwin' ]]; then
   PREFIX=/usr/local
else
   PREFIX=~/opt
   BOOST=~/opt/boost/include
fi

mkdir -p bin/${CONTRACT_NAME}
### BUILD THE CONTRACT
EOSCLANG="${PREFIX}/wasm/bin/clang++ -I/usr/local/include/libc++/upstream/include -I/usr/local/include/musl/upstream/include -I/usr/local/include -Ideps/eosio.token/include -Ideps/eosio.exchange/include -I${BOOST}"
LINK="${PREFIX}/wasm/bin/llvm-link -only-needed "
LLC="${PREFIX}/wasm/bin/llc -thread-model=single --asm-verbose=false"
S2W="/usr/local/bin/eosio-s2wasm "
W2W="/usr/local/bin/eosio-wast2wasm "

deps=()

for dep in "${deps[@]}"; do
   echo "building ${dep}"
   pushd ./deps/${dep} &> /dev/null
   ./build.sh $1
   popd &> /dev/null
done

echo "building eosio.token"
${EOSCLANG}  -Iinclude -c -emit-llvm -O3 --std=c++14 --target=wasm32 -nostdinc -DBOOST_DISABLE_ASSERTS -DBOOST_EXCEPTION_DISABLE -nostdlib -nostdlibinc -ffreestanding -nostdlib -fno-threadsafe-statics -fno-rtti -fno-exceptions -o ${CONTRACT_NAME}.bc src/${CONTRACT_NAME}.cpp
${LINK} -o linked.bc ${CONTRACT_NAME}.bc /usr/local/usr/share/eosio/contractsdk/lib/eosiolib.bc /usr/local/usr/share/eosio/contractsdk/lib/libc++.bc /usr/local/usr/share/eosio/contractsdk/lib/libc.bc
${LLC} -o ${CONTRACT_NAME}.s linked.bc
${S2W} -o ${CONTRACT_NAME}.wast -s 16384 ${CONTRACT_NAME}.s
${W2W} ${CONTRACT_NAME}.wast bin/${CONTRACT_NAME}/${CONTRACT_NAME}.wasm -n
cp abi/${CONTRACT_NAME}.abi bin/${CONTRACT_NAME}/${CONTRACT_NAME}.abi

if [[ "$1" == 'notests' ]]; then
   rm ${CONTRACT_NAME}.bc linked.bc ${CONTRACT_NAME}.wast ${CONTRACT_NAME}.s
   exit 0
fi

pushd tests &> /dev/null
mkdir build 
pushd build &> /dev/null
cmake -DCONTRACT_DIR="../../" ../
make -j8
popd &> /dev/null
popd &> /dev/null

if [[ "$1" == 'noinstall' ]]; then
   rm ${CONTRACT_NAME}.bc linked.bc ${CONTRACT_NAME}.wast ${CONTRACT_NAME}.s
   exit 0
fi

### INSTALL THE HEADERS
cp -r include/* /usr/local/include

rm ${CONTRACT_NAME}.bc linked.bc ${CONTRACT_NAME}.wast ${CONTRACT_NAME}.s
