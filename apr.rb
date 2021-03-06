require "formula"

class Apr < Formula
  homepage "https://apr.apache.org/"
  url "https://archive.apache.org/dist/apr/apr-1.5.1.tar.bz2"
  sha1 "f94e4e0b678282e0704e573b5b2fe6d48bd1c309"

  bottle do
    root_url "https://bitbucket.org/alanthing/homebrew-apache/downloads"
    sha1 "259fcfc9649870d98684a8eb562f2c4eeab3bfb7" => :snow_leopard
    sha1 "2e221228f0a4deb80aab2248290b6f54070d7210" => :lion
    sha1 "15ec64fd80b16cd2ee40c4038cceab5d90d1132e" => :mountain_lion
    sha1 "5ffdf92905c34e53060e26283978a23c0a84fa04" => :mavericks
    sha1 "6e2ccbbbcf3b50a6360c574efc4f4c3fb70b330e" => :yosemite
  end

  keg_only :provided_by_osx

  # Configure switch unconditionally adds the -no-cpp-precomp switch
  # to CPPFLAGS, which is an obsolete Apple-only switch that breaks
  # builds under non-Apple compilers and which may or may not do anything
  # anymore.
  # Reported upstream: https://issues.apache.org/bugzilla/show_bug.cgi?id=48483
  patch :DATA

  def install
    # Compilation will not complete without deparallelize
    ENV.deparallelize

    system "./configure", "--disable-debug", "--prefix=#{prefix}"
    system "make", "install"
  end
end

__END__
diff --git a/configure b/configure
index 860c65b..0e840d6 100755
--- a/configure
+++ b/configure
@@ -6802,10 +6802,10 @@ if test "x$apr_preload_done" != "xyes" ; then
     *-apple-darwin*)
 
   if test "x$CPPFLAGS" = "x"; then
-    test "x$silent" != "xyes" && echo "  setting CPPFLAGS to \"-DDARWIN -DSIGPROCMASK_SETS_THREAD_MASK -no-cpp-precomp\""
-    CPPFLAGS="-DDARWIN -DSIGPROCMASK_SETS_THREAD_MASK -no-cpp-precomp"
+    test "x$silent" != "xyes" && echo "  setting CPPFLAGS to \"-DDARWIN -DSIGPROCMASK_SETS_THREAD_MASK\""
+    CPPFLAGS="-DDARWIN -DSIGPROCMASK_SETS_THREAD_MASK"
   else
-    apr_addto_bugger="-DDARWIN -DSIGPROCMASK_SETS_THREAD_MASK -no-cpp-precomp"
+    apr_addto_bugger="-DDARWIN -DSIGPROCMASK_SETS_THREAD_MASK"
     for i in $apr_addto_bugger; do
       apr_addto_duplicate="0"
       for j in $CPPFLAGS; do
