# port install android
export ANDROID_HOME=/opt/local/share/java/android-sdk-macosx
export PATH="${ANDROID_HOME}/platform-tools:${PATH}"

# download https://developer.android.com/studio/command-line/sdkmanager
# extract to $ANDROID_HOME/cmdline-tools
# $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME --licenses

# mkdir -p "${XDG_STATE_HOME}/android"
# keytool -genkey -v -keystore "${XDG_STATE_HOME}/android/release-key.jks" -keyalg RSA -keysize 2048 -validity 10000 -alias release-key -dname "CN=Kevin James"
