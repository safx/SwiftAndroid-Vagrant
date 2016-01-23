#!/bin/sh

echo --- initial setup
sudo apt-get update
sudo apt-get install -y android-tools-adb

echo --- install NDK
curl -LOs http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin
chmod a+x android-ndk-r10e-linux-x86_64.bin
./android-ndk-r10e-linux-x86_64.bin > /dev/null
export ANDROID_NDK_HOME=$HOME/android-ndk-r10e

echo --- install SwiftAndroid
curl -LOs https://github.com/SwiftAndroid/swift/releases/download/swiftandroid-2016-01-06/swift_android_2016-01-06.tar.xz
tar xf swift_android_2016-01-06.tar.xz
export PATH=$HOME/swiftandroid/bin:$PATH

echo --- test compile
echo 'print("Hello world!")' > hello.swift
swiftc-android hello.swift
file hello

echo --- install JDK
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install -y libncurses5:i386 libstdc++6:i386 zlib1g:i386
sudo apt-get install -y openjdk-7-jdk

echo --- install Android SDK
curl -LOs http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
tar xf android-sdk_r24.4.1-linux.tgz
export ANDROID_HOME=$HOME/android-sdk-linux
echo "y" | $ANDROID_HOME/tools/android update sdk --no-ui --all --filter platform-tools,tools,android-23,build-tools-23.0.2

echo --- install Gradle
sudo apt-get install -y git clang
git clone https://github.com/SwiftAndroid/swift-android-gradle.git
(cd swift-android-gradle && ./gradlew install)

echo --- compile Sample App
git clone https://github.com/SwiftAndroid/swift-android-samples.git
cd swift-android-samples/swifthello
./gradlew build

echo --- copy to host
cp -r build/outputs/apk/ /vagrant

cd $HOME
rm -f ./android-ndk-r10e-linux-x86_64.bin ./android-sdk_r24.4.1-linux.tgz
