#!/bin/sh

echo --- initial setup
sudo apt-get update
sudo apt-get install -y curl libcurl4-openssl-dev android-tools-adb

echo --- install JDK
sudo dpkg --add-architecture i386
sudo apt-get update 
sudo apt-get install -y libncurses5:i386 libstdc++6:i386 zlib1g:i386 openjdk-7-jdk

echo --- install NDK
curl -LOs https://dl.google.com/android/repository/android-ndk-r13b-linux-x86_64.zip
unzip android-ndk-r13b-linux-x86_64.zip > /dev/null
export ANDROID_NDK_HOME=$HOME/android-ndk-r13b

echo --- install SwiftAndroid
curl -LOs http://housedillon.com/other/SwiftAndroid.tar.gz
tar xf SwiftAndroid.tar.gz
export PATH=$HOME/usr/bin:$PATH

echo --- Link android gold into /usr/bin
sudo ln -s $ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/arm-linux-androideabi/bin/ld.gold /usr/bin/armv7-none-linux-androideabi-ld.gold

echo --- Hack around swiftc not finding the right linker \(temporary, in response to SR-1264\)
sudo mv /usr/bin/ld.gold /usr/bin/ld.gold-orig
sudo ln -s $ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/arm-linux-androideabi/bin/ld.gold /usr/bin/ld.gold

echo --- install Android SDK
curl -LOs http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
tar xf android-sdk_r24.4.1-linux.tgz
export ANDROID_HOME=$HOME/android-sdk-linux
echo "y" | $ANDROID_HOME/tools/android update sdk --no-ui --all --filter platform-tools,tools,android-23,build-tools-23.0.2

echo --- install Gradle
sudo apt-get install -y git clang
git clone https://github.com/SwiftAndroid/swift-android-gradle.git
(cd swift-android-gradle && ./gradlew install > /dev/null)

echo --- test compile
echo 'print("Hello world!")' > hello.swift
swiftc -v \
    -target armv7-none-linux-androideabi \
    -sdk $ANDROID_NDK_HOME/platforms/android-21/arch-arm \
    -L   $ANDROID_NDK_HOME/sources/cxx-stl/llvm-libc++/libs/armeabi-v7a \
    -L   ./android-ndk-r13b/toolchains/x86_64-4.9/prebuilt/linux-x86_64/lib/gcc/x86_64-linux-android/4.9.x/ \
    hello.swift
file hello

echo --- compile Sample App
git clone https://github.com/SwiftAndroid/swift-android-samples.git
cd swift-android-samples/swifthello
./gradlew build

echo --- copy to host
cp -r build/outputs/apk/ /vagrant

cd $HOME
rm -f ./android-ndk-r10e-linux-x86_64.bin ./android-sdk_r24.4.1-linux.tgz
