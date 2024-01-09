#!/bin/sh
set -e
set -u
set -o pipefail

function on_error {
  echo "$(realpath -mq "${0}"):$1: error: Unexpected failure"
}
trap 'on_error $LINENO' ERR


# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")


variant_for_slice()
{
  case "$1" in
  "bctoolbox-ios.xcframework/ios-arm64")
    echo ""
    ;;
  "bctoolbox-ios.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "bctoolbox.xcframework/ios-arm64")
    echo ""
    ;;
  "bctoolbox.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "belcard.xcframework/ios-arm64")
    echo ""
    ;;
  "belcard.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "belle-sip.xcframework/ios-arm64")
    echo ""
    ;;
  "belle-sip.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "belr.xcframework/ios-arm64")
    echo ""
    ;;
  "belr.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "lime.xcframework/ios-arm64")
    echo ""
    ;;
  "lime.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "linphone.xcframework/ios-arm64")
    echo ""
    ;;
  "linphone.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "linphonetester.xcframework/ios-arm64")
    echo ""
    ;;
  "linphonetester.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "mediastreamer2.xcframework/ios-arm64")
    echo ""
    ;;
  "mediastreamer2.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "msamr.xcframework/ios-arm64")
    echo ""
    ;;
  "msamr.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "mscodec2.xcframework/ios-arm64")
    echo ""
    ;;
  "mscodec2.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "msopenh264.xcframework/ios-arm64")
    echo ""
    ;;
  "msopenh264.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "mssilk.xcframework/ios-arm64")
    echo ""
    ;;
  "mssilk.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "mswebrtc.xcframework/ios-arm64")
    echo ""
    ;;
  "mswebrtc.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "ortp.xcframework/ios-arm64")
    echo ""
    ;;
  "ortp.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "ZXing.xcframework/ios-arm64")
    echo ""
    ;;
  "ZXing.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  esac
}

archs_for_slice()
{
  case "$1" in
  "bctoolbox-ios.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "bctoolbox-ios.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "bctoolbox.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "bctoolbox.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "belcard.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "belcard.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "belle-sip.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "belle-sip.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "belr.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "belr.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "lime.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "lime.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "linphone.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "linphone.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "linphonetester.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "linphonetester.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "mediastreamer2.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "mediastreamer2.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "msamr.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "msamr.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "mscodec2.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "mscodec2.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "msopenh264.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "msopenh264.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "mssilk.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "mssilk.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "mswebrtc.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "mswebrtc.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "ortp.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "ortp.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "ZXing.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "ZXing.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  esac
}

copy_dir()
{
  local source="$1"
  local destination="$2"

  # Use filter instead of exclude so missing patterns don't throw errors.
  echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --links --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" \"${source}*\" \"${destination}\""
  rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --links --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" "${source}"/* "${destination}"
}

SELECT_SLICE_RETVAL=""

select_slice() {
  local xcframework_name="$1"
  xcframework_name="${xcframework_name##*/}"
  local paths=("${@:2}")
  # Locate the correct slice of the .xcframework for the current architectures
  local target_path=""

  # Split archs on space so we can find a slice that has all the needed archs
  local target_archs=$(echo $ARCHS | tr " " "\n")

  local target_variant=""
  if [[ "$PLATFORM_NAME" == *"simulator" ]]; then
    target_variant="simulator"
  fi
  if [[ ! -z ${EFFECTIVE_PLATFORM_NAME+x} && "$EFFECTIVE_PLATFORM_NAME" == *"maccatalyst" ]]; then
    target_variant="maccatalyst"
  fi
  for i in ${!paths[@]}; do
    local matched_all_archs="1"
    local slice_archs="$(archs_for_slice "${xcframework_name}/${paths[$i]}")"
    local slice_variant="$(variant_for_slice "${xcframework_name}/${paths[$i]}")"
    for target_arch in $target_archs; do
      if ! [[ "${slice_variant}" == "$target_variant" ]]; then
        matched_all_archs="0"
        break
      fi

      if ! echo "${slice_archs}" | tr " " "\n" | grep -F -q -x "$target_arch"; then
        matched_all_archs="0"
        break
      fi
    done

    if [[ "$matched_all_archs" == "1" ]]; then
      # Found a matching slice
      echo "Selected xcframework slice ${paths[$i]}"
      SELECT_SLICE_RETVAL=${paths[$i]}
      break
    fi
  done
}

install_xcframework() {
  local basepath="$1"
  local name="$2"
  local package_type="$3"
  local paths=("${@:4}")

  # Locate the correct slice of the .xcframework for the current architectures
  select_slice "${basepath}" "${paths[@]}"
  local target_path="$SELECT_SLICE_RETVAL"
  if [[ -z "$target_path" ]]; then
    echo "warning: [CP] $(basename ${basepath}): Unable to find matching slice in '${paths[@]}' for the current build architectures ($ARCHS) and platform (${EFFECTIVE_PLATFORM_NAME-${PLATFORM_NAME}})."
    return
  fi
  local source="$basepath/$target_path"

  local destination="${PODS_XCFRAMEWORKS_BUILD_DIR}/${name}"

  if [ ! -d "$destination" ]; then
    mkdir -p "$destination"
  fi

  copy_dir "$source/" "$destination"
  echo "Copied $source to $destination"
}

install_xcframework "${PODS_ROOT}/linphone-sdk-novideo/linphone-sdk-novideo/apple-darwin/XCFrameworks/bctoolbox-ios.xcframework" "linphone-sdk-novideo" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/linphone-sdk-novideo/linphone-sdk-novideo/apple-darwin/XCFrameworks/bctoolbox.xcframework" "linphone-sdk-novideo" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/linphone-sdk-novideo/linphone-sdk-novideo/apple-darwin/XCFrameworks/belcard.xcframework" "linphone-sdk-novideo" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/linphone-sdk-novideo/linphone-sdk-novideo/apple-darwin/XCFrameworks/belle-sip.xcframework" "linphone-sdk-novideo" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/linphone-sdk-novideo/linphone-sdk-novideo/apple-darwin/XCFrameworks/belr.xcframework" "linphone-sdk-novideo" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/linphone-sdk-novideo/linphone-sdk-novideo/apple-darwin/XCFrameworks/lime.xcframework" "linphone-sdk-novideo" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/linphone-sdk-novideo/linphone-sdk-novideo/apple-darwin/XCFrameworks/linphone.xcframework" "linphone-sdk-novideo" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/linphone-sdk-novideo/linphone-sdk-novideo/apple-darwin/XCFrameworks/linphonetester.xcframework" "linphone-sdk-novideo" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/linphone-sdk-novideo/linphone-sdk-novideo/apple-darwin/XCFrameworks/mediastreamer2.xcframework" "linphone-sdk-novideo" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/linphone-sdk-novideo/linphone-sdk-novideo/apple-darwin/XCFrameworks/msamr.xcframework" "linphone-sdk-novideo" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/linphone-sdk-novideo/linphone-sdk-novideo/apple-darwin/XCFrameworks/mscodec2.xcframework" "linphone-sdk-novideo" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/linphone-sdk-novideo/linphone-sdk-novideo/apple-darwin/XCFrameworks/msopenh264.xcframework" "linphone-sdk-novideo" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/linphone-sdk-novideo/linphone-sdk-novideo/apple-darwin/XCFrameworks/mssilk.xcframework" "linphone-sdk-novideo" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/linphone-sdk-novideo/linphone-sdk-novideo/apple-darwin/XCFrameworks/mswebrtc.xcframework" "linphone-sdk-novideo" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/linphone-sdk-novideo/linphone-sdk-novideo/apple-darwin/XCFrameworks/ortp.xcframework" "linphone-sdk-novideo" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/linphone-sdk-novideo/linphone-sdk-novideo/apple-darwin/XCFrameworks/ZXing.xcframework" "linphone-sdk-novideo" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"

