# Last updated for qtbase-opensource-src-5.8.0.tar.xz

source $setup

if [ "$version" != "5.8.0" ]; then
  echo "You need to update the license fragment builder for Qt $version."
  exit 1
fi

tar -xf $src
mv qtbase-* qtbase

# Read the license files here instead of in the big string so it is a fatal
# error if any of them are missing.
license_qt=$(cat qtbase/LICENSE.LGPLv3)
cd qtbase/src/3rdparty
license_android=$(cat android/LICENSE)
license_angle1=$(cat angle/LICENSE)
license_angle2=$(cat angle/TRACEEVENT_LICENSE)
license_angle3=$(cat angle/SYSTEMINFO_LICENSE)
license_atspi2=$(cat atspi2/LICENSE)
license_dc=$(cat double-conversion/LICENSE)
license_easing=$(cat easing/LICENSE)
license_forkfd=$(cat forkfd/LICENSE)
license_freebsd=$(cat freebsd/LICENSE)
license_freetype=$(cat freetype/docs/LICENSE.TXT)
license_harfbuzz=$(cat harfbuzz/COPYING)
license_ia2=$(cat iaccessible2/LICENSE)
license_libjpeg=$(cat libjpeg/LICENSE)
license_libpng=$(cat libpng/LICENSE)
license_pcre=$(cat pcre/LICENCE)
license_pixman=$(cat pixman/LICENSE)
license_rfc6234=$(cat rfc6234/LICENSE)
license_sha3_1=$(cat sha3/BRG_ENDIAN_LICENSE)
license_sha3_2=$(cat sha3/CC0_LICENSE)
license_xcb=$(cat xcb/LICENSE)
license_xkbcommon=$(cat xkbcommon/COPYING)
license_zlib=$(cat zlib/README)

cat > $out <<EOF
<p>
  The Qt Toolkit is licensed under the
  GNU Lesser General Public License Version 3 (LGPLv3) as shown below.
</p>

<pre>
$license_qt
</pre>

<h2>Third-party components bundled with Qt</h2>

<p>
  This software might include code from third-party comoponents bundled with Qt.
  The copyright notices of those components are reproduced below.
</p>

<pre>
$license_android
</pre>

<pre>
$license_angle1
</pre>

<pre>
$license_angle2
</pre>

<pre>
$license_angle3
</pre>

<pre>
$license_atspi2
</pre>

<pre>
$license_dc
</pre>

<pre>
$license_easing
</pre>

<pre>
$license_forkfd
</pre>

<pre>
$license_freebsd
</pre>

<pre>
$license_freetype
</pre>

<pre>
$license_harfbuzz
</pre>

<pre>
$license_ia2
</pre>

<pre>
$license_libjpeg
</pre>

<pre>
$license_libpng
</pre>

<pre>
$license_pcre
</pre>

<pre>
$license_pixman
</pre>

<pre>
$license_rfc6234
</pre>

<pre>
$license_sha3_1
</pre>

<pre>
$license_sha3_2
</pre>

<pre>
$license_xcb
</pre>

<pre>
$license_xkbcommon
</pre>

<pre>
$license_zlib
</pre>
EOF
