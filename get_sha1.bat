@echo off
echo Getting SHA-1 fingerprint for Google Sign-In setup...
echo.
cd android
call gradlew signingReport
echo.
echo Look for SHA1 under "Variant: debug" in the output above
echo Copy that SHA1 value and add it to Google Cloud Console
pause

